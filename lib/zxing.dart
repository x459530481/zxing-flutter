import 'dart:async';

import 'package:flutter/services.dart';

class Zxing {
  static const MethodChannel _channel = const MethodChannel('zxing');

  static Future<List> scan({
    bool isBeep = true,
    bool isContinuous = false,
  }) async {
    final List resultList = await _channel.invokeMethod(
      'scan',
      Map()
        ..['isBeep'] = isBeep
        ..['isContinuous'] = isContinuous,
    );
    return resultList;
  }
}
