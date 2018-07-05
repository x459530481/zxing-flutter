import 'dart:async';

import 'package:flutter/services.dart';

class Zxing {
  static const _channel = const MethodChannel('zxing');
  static const _eventChannel = const EventChannel('zxing_stream');

  static Stream<String> scan({
    bool isBeep = true,
    bool isContinuous = false,
  }) {
    _channel.invokeMethod(
      'scan',
      Map()
        ..['isBeep'] = isBeep
        ..['isContinuous'] = isContinuous,
    );

    return _eventChannel
        .receiveBroadcastStream()
        .map<String>((data) => data as String);
  }
}
