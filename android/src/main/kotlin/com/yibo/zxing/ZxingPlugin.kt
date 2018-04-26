package com.yibo.zxing

import android.Manifest
import android.util.Log
import com.google.zxing.integration.android.IntentIntegrator
import com.tbruyelle.rxpermissions2.RxPermissions
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import org.greenrobot.eventbus.EventBus
import org.greenrobot.eventbus.Subscribe

@Suppress("unused")
class ZxingPlugin : MethodCallHandler {

    companion object {
        @JvmField
        var REGISTRAR: Registrar? = null

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            REGISTRAR = registrar
            val channel = MethodChannel(registrar.messenger(), "zxing")
            channel.setMethodCallHandler(ZxingPlugin())
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "scan" -> {
                handleScan(call, result)
            }
            else -> result.notImplemented()
        }
    }

    private fun handleScan(call: MethodCall, result: Result) {
        val barcodeHandler = object {
            @Subscribe
            fun onBarcode(barcode: BarcodeEvent) {
                Log.d("barcodeList", "barcodeList:" + barcode.barcodeList)
                result.success(barcode.barcodeList)
            }
        }

        val argumentsMap = call.arguments as Map<*, *>
        val isBeep = argumentsMap["isBeep"] as Boolean
        val isContinuous = argumentsMap["isContinuous"] as Boolean
        Log.d("isBeep", isBeep.toString())
        Log.d("isContinuous", isContinuous.toString())

        EventBus.getDefault().register(barcodeHandler)

        RxPermissions(REGISTRAR?.activity()!!)
                .request(Manifest.permission.CAMERA)
                .subscribe({ granted ->
                    if (granted) {
                        REGISTRAR?.addViewDestroyListener({ _ ->
                            EventBus.getDefault().unregister(barcodeHandler)
                            return@addViewDestroyListener true
                        })

                        IntentIntegrator(REGISTRAR?.activity())
                                .setDesiredBarcodeFormats(IntentIntegrator.ONE_D_CODE_TYPES)
                                .setCaptureActivity(PortraitCaptureActivity::class.java)
                                .setBeepEnabled(isBeep)
                                .addExtra("isContinuous", isContinuous)
                                .initiateScan()
                    } else {
                        result.error("没有相机权限!", "没有相机权限!", "没有相机权限!")
                    }
                })
    }
}
