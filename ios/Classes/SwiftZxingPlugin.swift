import Flutter
import UIKit
import swiftScan

public class SwiftZxingPlugin: NSObject, FlutterPlugin {
    
    private var _hostVC: UIViewController!
    
    private static var _registrar: FlutterPluginRegistrar!
    private var _result: FlutterResult!
    private var _navigationVC: UINavigationController!
    
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
            handleScan(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented);
        }
    }
    
    private func handleScan(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let vc = ScanViewController()
        var style = LBXScanViewStyle()
        style.animationImage = UIImage(named: "CodeScan.bundle/qrcode_scan_light_green")
        vc.scanStyle = style
        vc.scanResultDelegate = self
        
        _hostVC.present(vc, animated: true, completion: nil)
    }
}

extension SwiftZxingPlugin : LBXScanViewControllerDelegate {
    public func scanFinished(scanResult: LBXScanResult, error: String?) {
        _result(scanResult.strScanned)
        NSLog("scan result" + scanResult.strScanned!)
    }
}
