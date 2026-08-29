package com.example.bike2go

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

object ActivityStateStreamHandler : EventChannel.StreamHandler {

    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(
        arguments: Any?,
        events: EventChannel.EventSink?
    ) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun sendState(state: String) {
        Handler(Looper.getMainLooper()).post {
            eventSink?.success(state)
        }
    }
}