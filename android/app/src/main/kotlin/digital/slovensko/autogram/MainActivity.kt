package digital.slovensko.autogram

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterFragmentActivity() {

    private lateinit var appService: AppService

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        Log.d(TAG, "onCreate: savedInstanceState=$savedInstanceState, intent=$intent")
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        appService = AppService(applicationContext, flutterEngine).also {
            it.processIntent(intent)
        }
    }

    companion object {
        private const val TAG = "MainActivity"
    }
}
