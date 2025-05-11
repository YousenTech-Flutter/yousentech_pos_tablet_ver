package com.example.yousentech_pos_tablet_ver

import android.content.Context
import android.graphics.Point
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.math.pow
import kotlin.math.sqrt

class MainActivity: FlutterActivity() {
    private val CHANNEL = "screen_size"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getScreenInches") {
                val inches = getPhysicalScreenSize(this)
                result.success(inches)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getPhysicalScreenSize(context: Context): Double {
        val manager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val display = manager.defaultDisplay
        val point = Point()
        display.getRealSize(point)

        val metrics = context.resources.displayMetrics
        val xInches = (point.x / metrics.xdpi).toDouble().pow(2.0)
        val yInches = (point.y / metrics.ydpi).toDouble().pow(2.0)
        return sqrt(xInches + yInches)
    }
}