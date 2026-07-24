package digital.slovensko.autogram

import java.io.File

/**
 * Validates that a `file://` URI's target path is safe for this app to open.
 *
 * Threat model: a malicious app sends an [android.content.Intent] (ACTION_VIEW
 * or ACTION_SEND with EXTRA_STREAM) carrying a `file://` URI pointing into our
 * own private data dir (e.g. `shared_prefs/`, `databases/`). Because the file
 * is owned by our UID, we have read access - the OS sandbox does not protect
 * us from ourselves. Validation canonicalizes the path (resolves symlinks and
 * `..`), rejects anything inside [privateDataDir], then requires the path to
 * sit under one of the [allowedRoots].
 */
internal class FileUriValidator(
    privateDataDir: File,
    allowedRoots: List<File>,
) {
    private val privateRoot: File? = privateDataDir.safeCanonical
    private val canonicalAllowedRoots: List<File> = allowedRoots.mapNotNull { it.safeCanonical }

    /**
     * Returns `true` iff [file]'s canonical path lies inside one of the
     * allowed roots and not inside the private data dir.
     */
    fun isAllowed(file: File): Boolean {
        val canonical = file.safeCanonical ?: return false

        if (privateRoot != null && canonical.isInside(privateRoot)) {
            return false
        }

        return canonicalAllowedRoots.any { canonical.isInside(it) }
    }

    private fun File.isInside(root: File): Boolean {
        val a = this.path
        val r = root.path

        return a.startsWith(r + File.separator)
    }

    private val File.safeCanonical: File?
        get() = runCatching { canonicalFile }.getOrNull()
}
