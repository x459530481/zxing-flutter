//
//  NativeScanVC.swift
//  zxing
//
//  Created by Yohom Bao on 2018/4/26.
//

import AVFoundation
import UIKit

public protocol NativeScanVCDelegate {
    func scanned(scanResult: [String])
}

class NativeScanVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    private var _device: AVCaptureDevice!
    private var _input: AVCaptureInput!
    private var _output: AVCaptureMetadataOutput!
    private var _session: AVCaptureSession!
    private var _preview: AVCaptureVideoPreviewLayer!
    private let ScreenWidth = UIScreen.main.bounds.size.width
    private let ScreenHeight = UIScreen.main.bounds.size.height

    private var _resultList: [String] = []
    
    public var scanDelegate: NativeScanVCDelegate?
    
    // if beep
    public var isBeep = false
    // if continuous scan
    public var isContinuous = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "完成", style: .done, target: self, action: #selector(done))
        navigationItem.title = "请扫描二维码"
        initDevice()
    }
    
    func initDevice() {
        // Device
        _device = AVCaptureDevice.default(for: .video)
        
        // Input
        do {
            _input = try AVCaptureDeviceInput(device:  _device)
        } catch {
            print("Input init failed")
            return
        }
        
        // Output
        _output = AVCaptureMetadataOutput()
        _output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        //         output.rectOfInterest = CGRect(((ScreenHeight-220)/2)/ScreenHeight, ((ScreenWidth-220)/2)/ScreenWidth, 220/ScreenHeight, 220/ScreenWidth)//感兴趣的区域，设置为中心，否则全屏可扫
        
        // Session
        _session = AVCaptureSession()
        _session.sessionPreset = AVCaptureSession.Preset.high
        if  _session.canAddInput( _input) {
            _session.addInput( _input)
        } else {
            print("Session Add Input init failed")
            return
        }
        
        if  _session.canAddOutput( _output) {
            _session.addOutput( _output)
        } else {
            print("Session Add Output init failed")
            return
        }
        
        // AVMetadataObjectTypeQRCode
        _output.metadataObjectTypes = [.aztec, .code128, .code39, .code39Mod43, .code93, .qr, .ean13, .itf14, .upce,]
        
        // Preview
        _preview = AVCaptureVideoPreviewLayer(session:  _session)
        _preview.videoGravity = AVLayerVideoGravity.resizeAspectFill
        _preview.frame =  view.layer.bounds
        view.layer.insertSublayer( _preview, at: 0)
        
        // Start
        _session.startRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        if metadataObjects.count > 0 {
            if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
                if let singleResult = metadataObject.stringValue {
                    // If you've already scanned it, skip it.
                    if _resultList.contains(singleResult) {
                        return
                    }
                    _resultList.append(singleResult)
                    print("host single result:" + singleResult)
                }
                
                if !isContinuous {
                    // stop scanning
                    _session.stopRunning()
                    
                    scanDelegate?.scanned(scanResult: _resultList)
                    dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func done() {
        scanDelegate?.scanned(scanResult: _resultList)
        dismiss(animated: true, completion: nil)
    }
}
