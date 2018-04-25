import 'dart:async';

import 'package:flutter/services.dart';

class Zxing {
  static const MethodChannel _channel = const MethodChannel('zxing');

  static Future<String> scan({
    bool isBeep = true,
    bool isContinuous = false,
  }) async {
    final String barcode = await _channel.invokeMethod(
      'scan',
      Map()
        ..['isBeep'] = isBeep
        ..['isContinuous'] = isContinuous,
    );
    return barcode;
  }
}
