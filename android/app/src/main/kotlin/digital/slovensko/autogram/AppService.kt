package digital.slovensko.autogram

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import androidx.core.os.BundleCompat

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream

/**
 * Provides functionality for Flutter app:
 *  - `getSharedFileName` - returns only file name that was shared to this app
 *  - `getSharedFile` - returns absolute accessible path to file that was shared to this app
 */
internal class AppService(
    private val context: Context,
    flutterEngine: FlutterEngine
) : MethodChannel.MethodCallHandler {

    private val methodChannel: MethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

    /** Stores file URI sent via `VIEW` or `SEND` actions. */
    private var sharedFile: Uri? = null

    init {
        methodChannel.setMethodCallHandler(this)
    }

    fun processIntent(intent: Intent) = with(intent) {
        Log.d(TAG, "processIntent: intent=$intent")

        sharedFile = when (action) {
            Intent.ACTION_VIEW -> data // + it.type
            Intent.ACTION_SEND -> BundleCompat.getParcelable(
                extras ?: Bundle.EMPTY,
                Intent.EXTRA_STREAM,
                Uri::class.java
            )

            else -> null
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "onMethodCall: call.method=${call.method}")

        when (call.method) {
            "getSharedFileName" -> result.onGetSharedFileName()
            "getSharedFile" -> result.onGetSharedFile()
        }
    }

    private fun MethodChannel.Result.onGetSharedFileName() {
        val result = runCatching {
            sharedFile?.fileName
        }

        result.fold(
            onSuccess = {
                success(it)
            },
            onFailure = {
                error("GET_SHARED_FILE_NAME_ERROR", it.message, null)
            }
        )
    }

    private fun MethodChannel.Result.onGetSharedFile() {
        val result = runCatching {
            sharedFile?.openRead()?.use { stream ->
                val name = sharedFile!!.fileName!!
                val outputFile = File(context.cacheDir, name)
                val output = FileOutputStream(outputFile)

                stream.copyTo(output)

                outputFile.absolutePath
            }
        }

        sharedFile = null

        result.fold(
            onSuccess = {
                success(it)
            },
            onFailure = {
                error("GET_SHARED_FILE_ERROR", it.message, null)
            }
        )
    }


    /** Gets the file name from this [Uri]. */
    private val Uri.fileName: String?
        get() = when (scheme) {
            "file" -> File(path!!).nameWithoutExtension
            "content" -> context.contentResolver.getDisplayName(this)
            else -> null
        }

    /** Opens this [Uri] for reading. */
    private fun Uri.openRead(): InputStream? = when (scheme) {
        "file" -> File(path!!).inputStream()
        "content" -> context.contentResolver.openInputStream(this)
        else -> null
    }

    companion object {
        private const val TAG = "AppService"
        private const val CHANNEL = "digital.slovensko.autogram"
    }
}
