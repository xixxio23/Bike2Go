package com.example.bike2go

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import com.google.android.gms.location.ActivityTransition
import com.google.android.gms.location.ActivityTransitionEvent
import com.google.android.gms.location.ActivityTransitionResult

class ActivityRecognitionReceiver : BroadcastReceiver() {

    companion object {
        private const val PREFS = "bike2go_activity"
        private const val LAST_ACTIVITY = "last_activity"

        private const val CYCLING = "cycling"
        private const val WALKING = "walking"
    }

    override fun onReceive(
        context: Context,
        intent: Intent
    ) {

        if (!ActivityTransitionResult.hasResult(intent)) {
            return
        }

        val result =
            ActivityTransitionResult.extractResult(intent)
                ?: return

        val preferences =
            context.getSharedPreferences(
                PREFS,
                Context.MODE_PRIVATE
            )

        for (event in result.transitionEvents) {

            if (
                event.transitionType !=
                ActivityTransition.ACTIVITY_TRANSITION_ENTER
            ) {
                continue
            }

            val currentActivity =
                when (event.activityType) {

                    com.google.android.gms.location.DetectedActivity.ON_BICYCLE ->
                        CYCLING

                    com.google.android.gms.location.DetectedActivity.WALKING ->
                        WALKING

                    else ->
                        null
                }

            if (currentActivity == null) {
                continue
            }

            val previousActivity =
                preferences.getString(
                    LAST_ACTIVITY,
                    null
                )

            preferences.edit()
                .putString(
                    LAST_ACTIVITY,
                    currentActivity
                )
                .apply()

            ActivityStateStreamHandler.sendState(
                currentActivity
            )

            if (
                previousActivity == CYCLING &&
                currentActivity == WALKING
            ) {
                NotificationHelper.showSheltersNotification(
                    context
                )
            }
        }
    }
}