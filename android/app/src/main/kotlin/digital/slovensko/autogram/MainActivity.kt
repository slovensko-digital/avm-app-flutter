package digital.slovensko.autogram

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterFragmentActivity() {

    private lateinit var appService: AppService

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        Log.d(TAG, "onCreate: savedInstanceState=$savedInstanceState, intent=$intent")

        createNotificationChannel()
    }

    /**
     * Creates default FCM notification channel for sign requests; see
     * "default_notification_channel_id" in AndroidManifest.xml.
     */
    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            getString(R.string.sign_request_notification_channel_id),
            getString(R.string.sign_request_notification_channel_name),
            NotificationManager.IMPORTANCE_HIGH
        )

        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        appService = AppService(applicationContext, flutterEngine).also {
            it.processIntent(intent)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)

        appService.processIntent(intent)
    }

    companion object {
        private const val TAG = "MainActivity"
    }
}
