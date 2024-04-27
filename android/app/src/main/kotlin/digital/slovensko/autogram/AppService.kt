package digital.slovensko.autogram

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Environment.DIRECTORY_DOWNLOADS
import android.os.Environment.getExternalStoragePublicDirectory
import android.util.Log
import androidx.core.net.toFile
import androidx.core.net.toUri
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream

/**
 * Provides functionality for Flutter app:
 *  - `startQrCodeScanner()` - starts built-in QR code scanner app
 *  - `getFileName(String)` - returns only file name from content:// or file:// URI
 *  - `getFile(String)` - returns absolute file path from content:// or file:// URI
 *  - `getDownloadsDirectory()` - returns path to "Download" directory
 *  -  "incomingUri" events - emits URIs to file shared to app or open URLs
 */
internal class AppService(
    private val context: Context,
    flutterEngine: FlutterEngine
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    /** [MethodChannel] for all methods. */
    private val methods: MethodChannel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        "digital.slovensko.avm"
    )

    /** [EventChannel] for all events. */
    private val events: EventChannel = EventChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        "digital.slovensko.avm/events"
    )

    /** [EventChannel.EventSink] for "incomingUri". */
    private var incomingUriSink: EventChannel.EventSink? = null

    /** Stores the value before [incomingUriSink] was initialized. */
    private var incomingUri: String? = null

    init {
        methods.setMethodCallHandler(this)
        events.setStreamHandler(this)
    }

    /**
     * Process [intent] from [Activity.onCreate] or [Activity.onNewIntent].
     *
     * Emits value into [incomingUriSink].
     */
    fun processIntent(intent: Intent) = with(intent) {
        Log.d(TAG, "processIntent: intent=$intent")

        val uri = when (action) {
            Intent.ACTION_VIEW -> data // + it.type
            Intent.ACTION_SEND -> extras?.stream
            else -> null
        } ?: return

        val sink = incomingUriSink

        if (sink == null) {
            this@AppService.incomingUri = uri.toString()
        } else {
            sink.success(uri.toString())
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "onMethodCall: call.method=${call.method}")

        when (call.method) {
            "startQrCodeScanner" -> result.onStartQrCodeScanner()
            "getFileName" -> result.onGetFileName(call.arguments as String)
            "getFile" -> result.onGetFile(call.arguments as String)
            "getDownloadsDirectory" -> result.onGetDownloadsDirectory()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        Log.d(TAG, "onListen")

        if (arguments == "incomingUri") {
            incomingUriSink = events
            incomingUri?.let {
                events.success(it)
                incomingUri = null
            }
        }
    }

    override fun onCancel(arguments: Any?) {
        Log.d(TAG, "onCancel")

        if (arguments == "incomingUri") {
            incomingUriSink?.endOfStream()
            incomingUriSink = null
        }
    }

    private fun MethodChannel.Result.onStartQrCodeScanner() {
        val intent = Intent()
            .setClassName("com.sec.android.app.camera", "com.sec.android.app.camera.QrScannerActivity")
            .setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

        // val component = intent.resolveActivity(context.packageManager)
        val result = runCatching { context.startActivity(intent) }

        result.fold(
            onSuccess = {
                success(true)
            },
            onFailure = { error ->
                error("START_QR_CODE_SCANNER_ERROR", error.message, null)
            }
        )
    }

    private fun MethodChannel.Result.onGetFileName(value: String) {
        val result: Result<String> = runCatching {
            val uri = value.toUri()
            val name = uri.fileName

            name ?: throw IllegalArgumentException("Unsupported '${uri.scheme}' scheme.")
        }

        result.fold(
            onSuccess = {
                success(it)
            },
            onFailure = {
                error("GET_FILE_NAME_ERROR", it.message, null)
            }
        )
    }

    private fun MethodChannel.Result.onGetFile(value: String) {
        val result: Result<File> = runCatching {
            val uri = value.toUri()

            when (uri.scheme) {
                "file" -> uri.toFile() // Don't need to copy
                "content" -> uri.openRead()!!.use { stream ->
                    // Copy to file:// in cache dir
                    val name = uri.fileName!!
                    val outputFile = File(context.cacheDir, name)
                    val output = FileOutputStream(outputFile)

                    stream.copyTo(output)

                    outputFile
                }

                else -> throw IllegalArgumentException("Unsupported '${uri.scheme}' scheme.")
            }
        }

        result.fold(
            onSuccess = {
                success(it.absolutePath)
            },
            onFailure = {
                error("GET_FILE_ERROR", it.message, null)
            }
        )
    }

    private fun MethodChannel.Result.onGetDownloadsDirectory() {
        val file = getExternalStoragePublicDirectory(DIRECTORY_DOWNLOADS)

        success(file.absolutePath)
    }

    /** Gets the file name from this [Uri]. */
    private val Uri.fileName: String?
        get() = when (scheme) {
            "file" -> File(path!!).name
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
    }
}
