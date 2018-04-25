# zxing-flutter

this plugin is a simple wrapper of [swiftScan](https://github.com/MxABC/swiftScan) for ios and [ zxing-android-embedded](https://github.com/journeyapps/zxing-android-embedded) for android.

## Getting Started
**Currently `isBeep` parameters and `isContinuous` parameters are only valid on the android platform.**
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zxing/zxing.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _barcode = 'Unknown';

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text('barcode: $_barcode\n'),
              new RaisedButton(
                onPressed: () {
                  try {
                    Zxing.scan(isBeep: false, isContinuous: false).then((barcodeResult) {
                      print("barcodeResult:" + barcodeResult?.toString());
                      setState(() {
                        _barcode = barcodeResult;
                      });
                    });
                  } on PlatformException {
                    _barcode = 'Failed to get barcode.';
                  }
                },
                child: Text('scan'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

```