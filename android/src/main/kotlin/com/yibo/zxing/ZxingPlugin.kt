package com.yibo.zxing

import android.Manifest
import android.util.Log
import android.widget.Toast
import com.google.zxing.integration.android.IntentIntegrator
import com.tbruyelle.rxpermissions2.RxPermissions
import es.dmoral.toasty.Toasty
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.reactivex.subjects.PublishSubject
import org.greenrobot.eventbus.EventBus
import org.greenrobot.eventbus.Subscribe

const val CHANNEL_ZXING = "zxing"
const val CHANNEL_ZXING_STREAM = "zxing_stream"

@Suppress("unused")
class ZxingPlugin {

    companion object {
        @JvmField
        var REGISTRAR: Registrar? = null

        private val subject = PublishSubject.create<String>()!!

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            REGISTRAR = registrar
            EventBus.getDefault().register(this)

            registrar.addViewDestroyListener {
                EventBus.getDefault().unregister(this)
                true
            }

            val channel = MethodChannel(registrar.messenger(), CHANNEL_ZXING)
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "scan" -> handleScan(call, result)
                    "showMessage" -> handleShowMessage(call, result)
                    else -> result.notImplemented()
                }
            }

            val eventChannel = EventChannel(registrar.messenger(), CHANNEL_ZXING_STREAM)
            eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(args: Any?, events: EventChannel.EventSink?) {
                    subject.subscribe(
                            { events?.success(it) },
                            { events?.error(it.message, it.message, it.message) },
                            { events?.endOfStream(); Log.d("stream", "stream closed") }
                    )
                }

                override fun onCancel(args: Any?) {}
            })
        }

        @Subscribe
        fun onBarcode(event: BarcodeEvent) {
            Log.d("barcode", "barcode:" + event.barcode)
            subject.onNext(event.barcode)
        }

        // 暂时没有去调用关闭流的方法,因为关闭之后就flutter端无法接收到条形码了
        @Suppress("UNUSED_PARAMETER")
        @Subscribe
        fun onCloseStream(event: CloseStreamEvent) {
            subject.onComplete()
        }

        private fun handleScan(call: MethodCall, result: Result) {
            val argumentsMap = call.arguments as Map<*, *>
            val isBeep = argumentsMap["isBeep"] as Boolean
            val isContinuous = argumentsMap["isContinuous"] as Boolean
            Log.d("isBeep", isBeep.toString())
            Log.d("isContinuous", isContinuous.toString())

            RxPermissions(REGISTRAR?.activity()!!)
                    .request(Manifest.permission.CAMERA)
                    .subscribe { granted ->
                        if (granted) {
                            REGISTRAR?.addViewDestroyListener { _ ->
                                EventBus.getDefault().unregister(this)
                                return@addViewDestroyListener true
                            }

                            IntentIntegrator(REGISTRAR?.activity())
                                    .setDesiredBarcodeFormats(IntentIntegrator.ONE_D_CODE_TYPES)
                                    .setCaptureActivity(PortraitCaptureActivity::class.java)
                                    .setBeepEnabled(isBeep)
                                    .addExtra("isContinuous", isContinuous)
                                    .initiateScan()

                            result.success("启动成功")
                        } else {
                            result.error("没有相机权限!", "没有相机权限!", "没有相机权限!")
                        }
                    }
        }

        private fun handleShowMessage(call: MethodCall, result: Result) {
            val isError = call.argument<Boolean>("isError") ?: false
            val content = call.argument<String>("content") ?: ""

            if (isError) {
                Toasty.error(REGISTRAR?.context()!!, content, Toast.LENGTH_SHORT).show()
            } else {
                Toasty.normal(REGISTRAR?.context()!!, content, Toast.LENGTH_SHORT).show()
            }
            result.success(null)
        }
    }
}
