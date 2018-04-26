import Flutter
import UIKit
import swiftScan

public class SwiftZxingPlugin: NSObject, FlutterPlugin {
    
    private var _hostVC: UIViewController!
    
    private static var _registrar: FlutterPluginRegistrar!
    private var _result: FlutterResult!
    private var _navigationVC: UINavigationController!
    
    private var _isBeep = false
    private var _isContinuous = false
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        _registrar = registrar
        
        let channel = FlutterMethodChannel(name: "zxing", binaryMessenger: registrar.messenger())
        let instance = SwiftZxingPlugin()
        instance._hostVC = UIApplication.shared.delegate?.window??.rootViewController
        
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        _result = result
        switch call.method {
        case "scan":
            let argumentDic = call.arguments as! NSDictionary
            _isBeep = argumentDic["isBeep"] as! Bool
            _isContinuous = argumentDic["isContinuous"] as! Bool
            handleScan(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented);
        }
    }
    
    private func handleScan(call: FlutterMethodCall, result: @escaping FlutterResult) {
        Permissions.authorizeCameraWith { (granted) in
            if !granted {
                Permissions.jumpToSystemPrivacySetting()
            }
        }
        
        let nativeVC = NativeScanVC()
        nativeVC.isBeep = _isBeep
        nativeVC.isContinuous = _isContinuous
        nativeVC.scanDelegate = self
        
        _navigationVC = UINavigationController.init(rootViewController: nativeVC)
        _navigationVC.navigationBar.barStyle = .blackTranslucent
        _hostVC.present(_navigationVC, animated: true, completion: nil)
    }
}

extension SwiftZxingPlugin : NativeScanVCDelegate {
    public func scanned(scanResult: [String]) {
        NSLog("host scan result:" + scanResult.description)
        _result(scanResult)
    }
}
