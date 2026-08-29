package com.example.bike2go

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val METHOD_CHANNEL =
            "bike2go/activity_recognition"

        private const val EVENT_CHANNEL =
            "bike2go/activity_state"

        private const val NAVIGATION_CHANNEL =
            "bike2go/navigation"

        private const val REQUEST_ACTIVITY_RECOGNITION = 1001
        private const val REQUEST_NOTIFICATIONS = 1002
    }

    private var navigationChannel: MethodChannel? = null

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "requestPermission" -> {
                    requestPermissions()
                    result.success(true)
                }

                "start" -> {
                    ActivityRecognitionManager.start(this)
                    result.success(true)
                }

                "stop" -> {
                    ActivityRecognitionManager.stop(this)
                    result.success(true)
                }

                "isAvailable" -> {
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL
        ).setStreamHandler(ActivityStateStreamHandler)

        navigationChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            NAVIGATION_CHANNEL
        )

        navigationChannel?.setMethodCallHandler { call, result ->

            when (call.method) {

                "checkOpenNearbyShelters" -> {
                    val shouldOpen =
                        intent?.getBooleanExtra(
                            "open_nearby_shelters",
                            false
                        ) ?: false

                    intent?.removeExtra(
                        "open_nearby_shelters"
                    )

                    result.success(shouldOpen)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)

        val shouldOpen =
            intent.getBooleanExtra(
                "open_nearby_shelters",
                false
            )

        if (shouldOpen) {
            intent.removeExtra(
                "open_nearby_shelters"
            )

            navigationChannel?.invokeMethod(
                "openNearbyShelters"
            )
        }
    }

    private fun requestPermissions() {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            if (
                ActivityCompat.checkSelfPermission(
                    this,
                    Manifest.permission.ACTIVITY_RECOGNITION
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(
                        Manifest.permission.ACTIVITY_RECOGNITION
                    ),
                    REQUEST_ACTIVITY_RECOGNITION
                )
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (
                ActivityCompat.checkSelfPermission(
                    this,
                    Manifest.permission.POST_NOTIFICATIONS
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(
                        Manifest.permission.POST_NOTIFICATIONS
                    ),
                    REQUEST_NOTIFICATIONS
                )
            }
        }
    }
}