package com.arconsis.measurements

import android.content.Context
import android.util.Log
import android.view.View
import com.github.barteksc.pdfviewer.PDFView
import com.github.barteksc.pdfviewer.util.FitPolicy
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.platform.PlatformView
import java.io.File

class PdfViewer(context: Context?, messenger: BinaryMessenger, id: Int, args: Map<String, Any>) : PlatformView {
	private val view: PDFView
	private val filePath: String
	private var zoomEvents: EventChannel.EventSink? = null

	init {
		linkEventChannel(messenger, id)

		if (args.containsKey("filePath")) {
			filePath = args["filePath"] as String
		} else {
			throw IllegalArgumentException("Argument \"filePath\" not provided to pdf file")
		}

		view = PDFView(context, null)
		initPdfView()
	}

	private fun linkEventChannel(messenger: BinaryMessenger, id: Int) {
		Log.d("MEASUREMENT", "listen on channel with id  $id")

		EventChannel(messenger, "measurement_pdf_zoom_$id").setStreamHandler(object : EventChannel.StreamHandler {
			override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
				zoomEvents = events
			}

			override fun onCancel(arguments: Any?) {
				zoomEvents?.endOfStream()
				zoomEvents = null
			}
		})
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
		Log.d("MEASUREMENT", "returning view: $view")

		return view
	}

	override fun dispose() {
//		view.recycle()
	}
}