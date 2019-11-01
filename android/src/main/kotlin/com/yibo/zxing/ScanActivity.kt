package com.yibo.zxing

import android.app.Activity
import android.content.Context
import android.os.Bundle
import android.os.Vibrator
import android.util.Log
import android.widget.ToggleButton
import cn.bingoogolapple.qrcode.core.QRCodeView
import cn.bingoogolapple.qrcode.zbar.ZBarView
import org.greenrobot.eventbus.EventBus

class ScanActivity : Activity(), QRCodeView.Delegate {

  private lateinit var mZBarView: ZBarView
  private lateinit var mToggleFlashBtn: ToggleButton

  public override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContentView(R.layout.activity_test_scan)

    mZBarView = findViewById(R.id.zbarview)
    mToggleFlashBtn = findViewById(R.id.toggleFlashBtn)
    mToggleFlashBtn.setOnCheckedChangeListener { _, isChecked ->
      if (isChecked) {
        mZBarView.openFlashlight() // 打开闪光灯
      } else {
        mZBarView.closeFlashlight() // 关闭闪光灯
      }
    }

    mZBarView.setDelegate(this)
  }

  override fun onStart() {
    super.onStart()
    mZBarView.startCamera() // 打开后置摄像头开始预览，但是并未开始识别
    mZBarView.startSpotAndShowRect() // 显示扫描框，并且延迟0.1秒后开始识别
  }

  override fun onStop() {
    mZBarView.stopCamera() // 关闭摄像头预览，并且隐藏扫描框
    mZBarView.closeFlashlight() // 关闭闪光灯
    super.onStop()
  }

  override fun onDestroy() {
    mZBarView.onDestroy() // 销毁二维码扫描控件
    super.onDestroy()
  }

  private fun vibrate() {
    val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
    vibrator.vibrate(200)
  }

  override fun onScanQRCodeSuccess(result: String) {
    Log.i("扫描结果", "扫描结果为：$result")
    EventBus.getDefault().post(BarcodeEvent(result))
    vibrate()

    mZBarView.startSpot() // 延迟0.1秒后开始识别
  }

  override fun onScanQRCodeOpenCameraError() {
    Log.e(TAG, "打开相机出错")
  }

  companion object {
    private val TAG = ScanActivity::class.java.simpleName
    private val REQUEST_CODE_CHOOSE_QRCODE_FROM_GALLERY = 666
  }
}
