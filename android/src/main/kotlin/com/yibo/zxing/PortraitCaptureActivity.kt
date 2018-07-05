package com.yibo.zxing

import android.app.Activity
import android.os.Bundle
import android.view.KeyEvent
import android.widget.Toast
import com.google.zxing.ResultPoint
import com.google.zxing.client.android.BeepManager
import com.google.zxing.client.android.Intents
import com.journeyapps.barcodescanner.BarcodeCallback
import com.journeyapps.barcodescanner.BarcodeResult
import com.journeyapps.barcodescanner.DecoratedBarcodeView
import org.greenrobot.eventbus.EventBus

/**
 * Created by yohom on 22/01/2018.
 */

class PortraitCaptureActivity : Activity() {

    private var mLastBarcode = "INVALID_STRING_STATE"
    private lateinit var scannerDbv: DecoratedBarcodeView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.common_act_capture)

        val isContinuous = intent.extras["isContinuous"] as Boolean

        scannerDbv = findViewById(R.id.scannerDbv)

        val beepManager = BeepManager(this)

        if (isContinuous) {
            scannerDbv.decodeContinuous(object : BarcodeCallback {
                override fun barcodeResult(result: BarcodeResult?) {
                    if (result?.text!! != mLastBarcode) {
                        Toast.makeText(this@PortraitCaptureActivity, result.text, Toast.LENGTH_LONG).show()
                        mLastBarcode = result.text

                        if (intent.getBooleanExtra(Intents.Scan.BEEP_ENABLED, true)) {
                            beepManager.playBeepSound()
                        }

                        EventBus.getDefault().post(BarcodeEvent().apply { barcode = result.text })
                    }
                }

                override fun possibleResultPoints(resultPoints: List<ResultPoint>) {

                }
            })
        } else {
            scannerDbv.decodeSingle(object : BarcodeCallback {
                override fun barcodeResult(result: BarcodeResult?) {
                    if (result?.text!! != mLastBarcode) {
                        Toast.makeText(this@PortraitCaptureActivity, result.text, Toast.LENGTH_LONG).show()
                        mLastBarcode = result.text

                        if (intent.getBooleanExtra(Intents.Scan.BEEP_ENABLED, true)) {
                            beepManager.playBeepSound()
                        }

                        EventBus.getDefault().post(BarcodeEvent().apply { barcode = result.text })
                        finish()
                    }
                }

                override fun possibleResultPoints(resultPoints: List<ResultPoint>) {

                }
            })
        }

        scannerDbv.setStatusText("")
    }

    override fun onResume() {
        super.onResume()
        scannerDbv.resume()
    }

    override fun onPause() {
        super.onPause()
        scannerDbv.pause()
    }

    override fun onDestroy() {
        super.onDestroy()

        // fixme :结束流之后再次开始扫码flutter端就接收不到条形码了, 先不停止吧, 那么什么时候停止呢?
//        EventBus.getDefault().post(CloseStreamEvent())
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent): Boolean {
        return scannerDbv.onKeyDown(keyCode, event) || super.onKeyDown(keyCode, event)
    }
}
