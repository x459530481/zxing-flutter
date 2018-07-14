import Flutter
import UIKit
import RxSwift
import Toast_Swift

let CHANNEL_ZXING = "zxing"
let CHANNEL_ZXING_STREAM = "zxing_stream"

public class SwiftZxingPlugin: NSObject {
    private var _hostVC: UIViewController!
    
    private static var _registrar: FlutterPluginRegistrar!
    private var _result: FlutterResult!
    private var _navigationVC: UINavigationController!
    
    // 中转扫码结果
    private let _subject = PublishSubject<String>()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        _registrar = registrar
        
        let instance = SwiftZxingPlugin()
        instance._hostVC = UIApplication.shared.delegate?.window??.rootViewController
        
        let methodChannel = FlutterMethodChannel.init(name: CHANNEL_ZXING, binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel.init(name: CHANNEL_ZXING_STREAM, binaryMessenger: registrar.messenger())
        
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance as FlutterStreamHandler & NSObjectProtocol)
    }
    
    // 处理扫码事件
    private func handleScan(call: FlutterMethodCall, result: @escaping FlutterResult) {
        Permissions.authorizeCameraWith { (granted) in
            if !granted {
                Permissions.jumpToSystemPrivacySetting()
            }
        }
        
        let argumentDic = call.arguments as! NSDictionary
        
        let nativeVC = NativeScanVC()
        nativeVC.isBeep = argumentDic["isBeep"] as! Bool
        nativeVC.isContinuous = argumentDic["isContinuous"] as! Bool
        nativeVC.scanDelegate = self
        
        _navigationVC = UINavigationController.init(rootViewController: nativeVC)
        _navigationVC.navigationBar.barStyle = .blackTranslucent
        _hostVC.present(_navigationVC, animated: true, completion: nil)
    }
    
    // 处理显示信息事件
    private func handleShowMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let argumentDic = call.arguments as! NSDictionary
        let content = argumentDic["content"] as! String
        let isError = argumentDic["isError"] as! Bool
        
        var style = ToastStyle()
        style.cornerRadius = 20
        if isError {
            style.backgroundColor = .red
        }
        ToastManager.shared.style = style
        _navigationVC.view.makeToast(content)
    }
}

// 处理扫码结果, 以流的形式传回到dart端
extension SwiftZxingPlugin : FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        _subject.subscribe(
            onNext: { (barcode) in
                eventSink(barcode)
        },
            onCompleted: {
                eventSink("")
        })
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
}

// 接收dart端发射的method call数据
extension SwiftZxingPlugin :FlutterPlugin {
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        _result = result
        switch call.method {
        case "scan":
            handleScan(call: call, result: result)
        case "showMessage":
            handleShowMessage(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented);
        }
    }
}

// 处理扫码返回的条形码
extension SwiftZxingPlugin : NativeScanVCDelegate {
    public func scanned(scanResult: String) {
        NSLog("host scan result:" + scanResult)
        _result("扫描成功")
        _subject.onNext(scanResult)
    }
}
