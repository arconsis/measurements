package com.arconsis.measurements

import android.content.Context
import android.content.res.Resources
import android.graphics.PointF
import android.util.Log
import android.view.View
import com.github.barteksc.pdfviewer.PDFView
import com.github.barteksc.pdfviewer.util.FitPolicy
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.io.File

class PdfViewer(val context: Context?, messenger: BinaryMessenger, id: Int, args: Map<String, Any>) : PlatformView {
	private val view: PDFView
	private val filePath: String
	private var zoomEvents: EventChannel.EventSink? = null
	private val screenWidth: Float
	private val screenHeight: Float

	init {
		linkEventChannel(messenger, id)

		val metrics = Resources.getSystem().displayMetrics

		screenWidth = metrics.widthPixels.toFloat()
		screenHeight = metrics.heightPixels.toFloat()

		if (args.containsKey("filePath")) {
			filePath = args["filePath"] as String
		} else {
			throw IllegalArgumentException("Argument \"filePath\" not provided to pdf file")
		}

		view = PDFView(context, null)
		initPdfView()
	}

	private fun linkEventChannel(messenger: BinaryMessenger, id: Int) {
		Log.d("measure_android", "listen on channel with id  $id")

		EventChannel(messenger, "measurement_pdf_zoom_$id")
				.setStreamHandler(object : EventChannel.StreamHandler {
					override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
						zoomEvents = events
					}

					override fun onCancel(arguments: Any?) {
						zoomEvents?.endOfStream()
						zoomEvents = null
					}
				})

		MethodChannel(messenger, "measurement_pdf_set_zoom_$id")
				.setMethodCallHandler { call, result ->
					if (call.method == "setZoom") {
						val zoomLevel = call.arguments<Double>()
						setZoom(zoomLevel)
					} else {
						result.notImplemented()
					}
				}
	}

	private fun setZoom(zoomLevel: Double?) {
		view.zoomCenteredTo(zoomLevel?.toFloat() ?: 1.0f, PointF(screenWidth / 2.0f, screenHeight / 2.0f))
	}

	private fun initPdfView() {
		view.fromFile(File(filePath))
				.enableSwipe(true)
				.defaultPage(0)
				.enableAntialiasing(true)
				.enableDoubletap(true)
				.pageFitPolicy(FitPolicy.WIDTH)
				.swipeHorizontal(false)
				.onZoom(this::onZoom)
				.load()
	}

	private fun onZoom(zoom: Float) {
		zoomEvents?.success(zoom)
	}

	override fun getView(): View {
		Log.d("measure_android", "returning view: $view")
		Log.d("measure_android", "initial context was $context")

		if (view.isRecycled) {
			initPdfView()
		}

		return view
	}

	override fun dispose() {
		view.recycle()
	}
}