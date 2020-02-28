package com.arconsis.measurements

import android.content.Context
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class MeasurementViewFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

	override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
		Log.d("measure_android", "Factory created view with id: $viewId")
		Log.d("measure_android", "Args: $args")

		val arguments = args as Map<String, Any>
		Log.d("measure_android", "Has key: ${arguments.containsKey("filePath")}")

		return PdfViewer(context, messenger, viewId, arguments)
	}
}