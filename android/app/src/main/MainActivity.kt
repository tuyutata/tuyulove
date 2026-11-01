package com.tuyulove

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import org.citizen.sdk.CitizenSdkPlugin

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        if (!flutterEngine.plugins.has(CitizenSdkPlugin::class.java)) flutterEngine.plugins.add(CitizenSdkPlugin())
    }
}
