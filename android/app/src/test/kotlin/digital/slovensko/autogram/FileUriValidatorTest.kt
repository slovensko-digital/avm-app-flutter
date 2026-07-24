package digital.slovensko.autogram

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import java.io.File

class FileUriValidatorTest {

    @get:Rule
    val tmp = TemporaryFolder()

    private lateinit var privateDataDir: File
    private lateinit var externalStorage: File
    private lateinit var downloads: File
    private lateinit var externalFiles: File
    private lateinit var validator: FileUriValidator

    @Before
    fun setUp() {
        // Mirror the on-device layout under a single tmp root so canonical
        // paths line up the same way the validator sees them at runtime.
        privateDataDir = tmp.newFolder("data", "user", "0", "digital.slovensko.avm")
        externalStorage = tmp.newFolder("storage", "emulated", "0")
        downloads = File(externalStorage, "Download").apply { mkdirs() }
        externalFiles = tmp.newFolder("storage", "emulated", "0", "Android", "data", "digital.slovensko.avm", "files")

        validator = FileUriValidator(
            privateDataDir = privateDataDir,
            allowedRoots = listOf(externalStorage, downloads, externalFiles),
        )
    }

    @Test
    fun `rejects file inside shared_prefs (the canonical attack)`() {
        val sharedPrefs = File(privateDataDir, "shared_prefs/FlutterSharedPreferences.xml").also {
            it.parentFile!!.mkdirs()
            it.createNewFile()
        }

        assertFalse(validator.isAllowed(sharedPrefs))
    }

    @Test
    fun `rejects file inside databases`() {
        val file = File(privateDataDir, "databases/app.db").also {
            it.parentFile!!.mkdirs()
            it.createNewFile()
        }

        assertFalse(validator.isAllowed(file))
    }

    @Test
    fun `rejects file inside private files dir`() {
        val file = File(privateDataDir, "files/secret.txt").also {
            it.parentFile!!.mkdirs()
            it.createNewFile()
        }

        assertFalse(validator.isAllowed(file))
    }

    @Test
    fun `allows file in Downloads`() {
        val file = File(downloads, "doc.pdf").also {
            it.createNewFile()
        }

        assertTrue(validator.isAllowed(file))
    }

    @Test
    fun `allows file in external storage root`() {
        val file = File(externalStorage, "shared.pdf").also {
            it.createNewFile()
        }

        assertTrue(validator.isAllowed(file))
    }

    @Test
    fun `allows file in app external files dir`() {
        val file = File(externalFiles, "out.pdf").also { it.createNewFile() }

        assertTrue(validator.isAllowed(file))
    }

    @Test
    fun `rejects path traversal that resolves into private data dir`() {
        // downloads is 4 levels deep under tmp root, so 4x `..` climb back out.
        val file = File(privateDataDir, "shared_prefs/x.xml").also {
            it.parentFile!!.mkdirs(); it.createNewFile()
        }

        val traversal = File(
            downloads,
            "../../../../data/user/0/digital.slovensko.avm/shared_prefs/x.xml",
        )

        // Sanity check: the traversal path really does resolve to the secret.
        assertTrue(traversal.canonicalPath == file.canonicalPath)
        assertFalse(validator.isAllowed(traversal))
    }

    @Test
    fun `rejects path traversal that resolves outside every allowed root`() {
        val file = File(downloads, "../../../../../../etc/passwd")

        assertFalse(validator.isAllowed(file))
    }

    @Test
    fun `rejects absolute path outside every allowed root`() {
        val file = tmp.newFile("loose.txt")

        assertFalse(validator.isAllowed(file))
    }

    @Test
    fun `rejects an allowed-root directory itself (not a file inside it)`() {
        // Opening the root directory as a "file" is meaningless and should not
        // pass - only paths strictly nested under a root are allowed. Use an
        // isolated validator so we are not accidentally inside a *parent* root.
        val isolatedRoot = tmp.newFolder("isolated-root")
        val validator = FileUriValidator(
            privateDataDir = privateDataDir,
            allowedRoots = listOf(isolatedRoot),
        )

        assertFalse(validator.isAllowed(isolatedRoot))
    }

    @Test
    fun `rejects sibling directory whose name starts with allowed root name`() {
        // Guards against a naive String.startsWith(rootPath) check matching
        // "/storage/emulated/0/DownloadEVIL/x" against root "/storage/.../Download".
        val sibling = File(externalStorage, "DownloadEVIL").apply { mkdirs() }
        val evil = File(sibling, "x.txt").also { it.createNewFile() }

        // Sanity: this path is under externalStorage (which IS an allowed root),
        // so the validator legitimately allows it. Re-check the same trick
        // against a root that is *not* an ancestor.
        assertTrue(validator.isAllowed(evil))

        // Now build a sibling next to `externalFiles` whose name starts the
        // same way but isn't actually inside it, and isn't inside any other
        // allowed root either.
        val unrelatedRoot = tmp.newFolder("isolated")
        val onlyFiles = File(unrelatedRoot, "files").apply { mkdirs() }
        val tightValidator = FileUriValidator(
            privateDataDir = privateDataDir,
            allowedRoots = listOf(onlyFiles),
        )
        val trickySibling = File(unrelatedRoot, "filesEVIL").apply { mkdirs() }
        val trickyFile = File(trickySibling, "x.txt").also { it.createNewFile() }

        assertFalse(tightValidator.isAllowed(trickyFile))
    }

    @Test
    fun `private dir wins over allowed root if they overlap`() {
        // If for some reason a deny root sits inside an allow root, deny must
        // still take precedence. (Not a real Android layout, but a useful
        // invariant to nail down.)
        val root = tmp.newFolder("overlap")
        val privateInsideAllowed = File(root, "private").apply { mkdirs() }
        val v = FileUriValidator(
            privateDataDir = privateInsideAllowed,
            allowedRoots = listOf(root),
        )

        val secret = File(privateInsideAllowed, "secret.txt").also { it.createNewFile() }
        val ok = File(root, "public.txt").also { it.createNewFile() }

        assertFalse(v.isAllowed(secret))
        assertTrue(v.isAllowed(ok))
    }
}
