import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zxing/zxing.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> _barcodeList = List()..add("Unknow");

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Zxing-flutter example app'),
        ),
        body: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text('barcode: $_barcodeList\n'),
              new RaisedButton(
                onPressed: () {
                  try {
                    Zxing.scan(isBeep: false, isContinuous: false).then(
                      (resultList) {
                        print("client scan result:" + resultList?.toString());
                        setState(
                          () {
                            _barcodeList = resultList;
                          },
                        );
                      },
                    );
                  } on PlatformException {
                    _barcodeList = List()..add('Failed to get barcode.');
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
