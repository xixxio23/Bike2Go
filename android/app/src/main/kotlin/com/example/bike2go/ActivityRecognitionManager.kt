package com.example.bike2go

import android.Manifest
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import com.google.android.gms.location.ActivityRecognition
import com.google.android.gms.location.ActivityTransition
import com.google.android.gms.location.ActivityTransitionRequest
import com.google.android.gms.location.DetectedActivity

object ActivityRecognitionManager {

    private const val REQUEST_CODE = 2001

    private fun getPendingIntent(
        context: Context
    ): PendingIntent {

        val intent = Intent(
            context,
            ActivityRecognitionReceiver::class.java
        )

        return PendingIntent.getBroadcast(
            context,
            REQUEST_CODE,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or
                PendingIntent.FLAG_MUTABLE
        )
    }

    fun start(context: Context) {

        if (
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.ACTIVITY_RECOGNITION
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }

        val transitions = listOf(

            ActivityTransition.Builder()
                .setActivityType(
                    DetectedActivity.ON_BICYCLE
                )
                .setActivityTransition(
                    ActivityTransition.ACTIVITY_TRANSITION_ENTER
                )
                .build(),

            ActivityTransition.Builder()
                .setActivityType(
                    DetectedActivity.ON_BICYCLE
                )
                .setActivityTransition(
                    ActivityTransition.ACTIVITY_TRANSITION_EXIT
                )
                .build(),

            ActivityTransition.Builder()
                .setActivityType(
                    DetectedActivity.WALKING
                )
                .setActivityTransition(
                    ActivityTransition.ACTIVITY_TRANSITION_ENTER
                )
                .build(),

            ActivityTransition.Builder()
                .setActivityType(
                    DetectedActivity.WALKING
                )
                .setActivityTransition(
                    ActivityTransition.ACTIVITY_TRANSITION_EXIT
                )
                .build()
        )

        val request =
            ActivityTransitionRequest(transitions)

        ActivityRecognition
            .getClient(context)
            .requestActivityTransitionUpdates(
                request,
                getPendingIntent(context)
            )
    }

    fun stop(context: Context) {

        ActivityRecognition
            .getClient(context)
            .removeActivityTransitionUpdates(
                getPendingIntent(context)
            )
    }
}