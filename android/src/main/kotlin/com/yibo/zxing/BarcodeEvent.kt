package com.yibo.industrygas

import android.net.Uri
import com.blankj.utilcode.util.RegexUtils

/**
 * Created by yohom on 23/01/2018.
 */
class BarcodeEvent(barcode: String) {

    var barcode: String = barcode
        get() {
            return if (RegexUtils.isURL(field)) {
                val uri = Uri.parse(field)
                uri.getQueryParameter("barcode") ?: ""
            } else {
                field
            }
        }
}