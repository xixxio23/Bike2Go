import 'dart:async';

import 'package:flutter/services.dart';

class ActivityRecognitionService {
  static const MethodChannel _channel =
      MethodChannel('bike2go/activity_recognition');

  static const EventChannel _activityChannel =
      EventChannel('bike2go/activity_state');

  static const String walking = 'walking';
  static const String cycling = 'cycling';

  Stream<String> get activityStream {
    return _activityChannel
        .receiveBroadcastStream()
        .map((event) => event.toString());
  }

  Future<bool> requestPermission() async {
    final result = await _channel.invokeMethod<bool>(
      'requestPermission',
    );

    return result ?? false;
  }

  Future<void> start() async {
    await _channel.invokeMethod<void>('start');
  }

  Future<void> stop() async {
    await _channel.invokeMethod<void>('stop');
  }

  Future<bool> isAvailable() async {
    final result = await _channel.invokeMethod<bool>(
      'isAvailable',
    );

    return result ?? false;
  }
}