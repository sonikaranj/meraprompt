package com.promptseen.ai

import android.os.Bundle
import android.widget.Toast
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Check if app should launch before calling super.onCreate()
        if (!DeviceCheckService.shouldAllowAppLaunch(this)) {
            // Show message and close app
            Toast.makeText(
                this,
                "This app cannot run in development/emulator mode with developer options enabled",
                Toast.LENGTH_LONG
            ).show()

            // Close the app after a brief delay
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                finishAffinity()
            }, 2000)

            return
        }

        super.onCreate(savedInstanceState)
    }
}
