import 'dart:async';

import 'package:flutter/services.dart';

class Zxing {
  static const MethodChannel _channel = const MethodChannel('zxing');

  static Future<List<String>> scan({
    bool isBeep = true,
    bool isContinuous = false,
  }) async {
    List resultList = await _channel.invokeMethod(
      'scan',
      Map()
        ..['isBeep'] = isBeep
        ..['isContinuous'] = isContinuous,
    );
    return resultList.map((barcode) {
      return barcode as String;
    }).toList();
  }
}
