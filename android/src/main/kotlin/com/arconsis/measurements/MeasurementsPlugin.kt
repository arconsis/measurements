package com.arconsis.measurements

import android.content.res.Resources
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry.Registrar

/** MeasurementsPlugin */
class MeasurementsPlugin : FlutterPlugin, MethodCallHandler {
	override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
		val channel = MethodChannel(flutterPluginBinding.binaryMessenger, "measurements")
		channel.setMethodCallHandler(MeasurementsPlugin())

		flutterPluginBinding.platformViewRegistry.registerViewFactory("measurement_view", MeasurementViewFactory(flutterPluginBinding.binaryMessenger))
	}

	// This static function is optional and equivalent to onAttachedToEngine. It supports the old
	// pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
	// plugin registration via this function while apps migrate to use the new Android APIs
	// post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
	//
	// It is encouraged to share logic between onAttachedToEngine and registerWith to keep
	// them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
	// depending on the user's project. onAttachedToEngine or registerWith must both be defined
	// in the same class.
	companion object {
		@JvmStatic
		fun registerWith(registrar: Registrar) {
			val channel = MethodChannel(registrar.messenger(), "measurements")
			channel.setMethodCallHandler(MeasurementsPlugin())

			registrar.platformViewRegistry().registerViewFactory("measurement_view", MeasurementViewFactory(registrar.messenger()))
		}
	}

	override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
	}

	override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
		if (call.method == "getPhysicalScreenSize") {
			val metrics = Resources.getSystem().displayMetrics

			val screenWidth = metrics.widthPixels / metrics.xdpi
			val screenHeight = metrics.heightPixels / metrics.ydpi

			val screenSize = HashMap<String, Double>(2)
			screenSize["width"] = screenWidth.toDouble()
			screenSize["height"] = screenHeight.toDouble()

			result.success(screenSize)
		} else {
			result.notImplemented()
		}
	}
}
