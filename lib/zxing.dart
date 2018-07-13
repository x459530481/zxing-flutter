import 'dart:async';

import 'package:flutter/services.dart';

class Zxing {
  static const _channel = const MethodChannel('zxing');
  static const _eventChannel = const EventChannel('zxing_stream');
  static const _showMessageChannel = const MethodChannel('show_message');

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

  static Future<void> showMessage({
    String content = '',
    bool isError = false,
  }) {
    return _showMessageChannel.invokeMethod(
      'showMessage',
      Map()
        ..['content'] = content
        ..['isError'] = isError,
    );
  }
}
