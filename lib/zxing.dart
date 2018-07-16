import 'dart:async';

import 'package:flutter/services.dart';

class Zxing {
  static const _methodChannel = const MethodChannel('zxing');
  static const _eventChannel = const EventChannel('zxing_stream');

  static Stream<String> scan({
    bool isBeep = true,
    bool isContinuous = false,
  }) {
    _methodChannel.invokeMethod(
      'scan',
      Map()
        ..['isBeep'] = isBeep
        ..['isContinuous'] = isContinuous,
    );

    return _eventChannel
        .receiveBroadcastStream()
        .distinct()
        .map<String>((data) => data as String);
  }

  static Future<void> showMessage({
    String content = '',
    bool isError = false,
  }) {
    return _methodChannel.invokeMethod(
      'showMessage',
      Map()
        ..['content'] = content
        ..['isError'] = isError,
    );
  }
}
