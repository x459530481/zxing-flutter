//
//  ScanViewController.swift
//  swiftScan
//
//  Created by xialibing on 15/12/10.
//  Copyright © 2015年 xialibing. All rights reserved.
//

import UIKit
import swiftScan

class ScanViewController: LBXScanViewController {

    /**
     @brief  扫码区域上方提示文字
     */
    var topTitle: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        topTitle?.text = "扫描二维码"
    }

    override func handleCodeResult(arrayResult: [LBXScanResult]) {
        for result : LBXScanResult in arrayResult {
            if let str = result.strScanned {
                print(str)
            }
        }

        let result: LBXScanResult = arrayResult[0]

        self.scanResultDelegate?.scanFinished(scanResult: result, error: "...")
        self.dismiss(animated: true, completion: nil)
    }
}

