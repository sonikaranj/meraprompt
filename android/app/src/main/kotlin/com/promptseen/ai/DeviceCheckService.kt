package com.promptseen.ai

import android.content.Context
import android.os.Build
import android.provider.Settings

object DeviceCheckService {
    // ⚠️ SET THIS TRUE TO ENABLE DEVELOPER MODE CHECK
    // SET THIS FALSE TO ALLOW APP ON EMULATOR WITH DEVELOPER OPTIONS
    // Change this flag before building the application
    private const val ENABLE_DEVELOPER_MODE_CHECK = false
    /**
     * Check if app is running on an emulator
     */
    fun isEmulator(): Boolean {
        return (
            Build.FINGERPRINT.startsWith("generic") ||
            Build.FINGERPRINT.startsWith("unknown") ||
            Build.MODEL.contains("google_sdk") ||
            Build.MODEL.contains("Emulator") ||
            Build.DEVICE.contains("emulator") ||
            Build.DEVICE.contains("generic") ||
            Build.PRODUCT.contains("sdk_google") ||
            Build.BRAND.startsWith("generic") ||
            "Qemu" in Build.HARDWARE ||
            Build.HARDWARE.contains("ranchu") ||
            Build.FINGERPRINT.contains("vbox") ||
            Build.FINGERPRINT.contains("Android/google_sdk")
        )
    }

    /**
     * Check if Developer Options are enabled
     */
    fun isDeveloperModeEnabled(context: Context): Boolean {
        return try {
            Settings.Global.getInt(
                context.contentResolver,
                Settings.Global.DEVELOPMENT_SETTINGS_ENABLED,
                0
            ) == 1
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Check if USB Debugging is enabled
     */
    fun isUsbDebuggingEnabled(context: Context): Boolean {
        return try {
            Settings.Global.getInt(
                context.contentResolver,
                Settings.Global.ADB_ENABLED,
                0
            ) == 1
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Check if app should proceed or block
     */
    fun shouldAllowAppLaunch(context: Context): Boolean {
        // If developer mode check is disabled, always allow app to launch
        if (!ENABLE_DEVELOPER_MODE_CHECK) {
            return true
        }

        val isEmulator = isEmulator()
        val isDeveloperMode = isDeveloperModeEnabled(context)
        val isUsbDebugging = isUsbDebuggingEnabled(context)

        // Allow if none of these conditions are met
        // Block only if it's an emulator AND developer mode is on
        return !(isEmulator && (isDeveloperMode || isUsbDebugging))
    }
}
