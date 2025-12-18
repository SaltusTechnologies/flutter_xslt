package com.saltustechnologies.flutter_xslt

import java.util.*
import kotlin.Result
import javax.xml.transform.TransformerFactory
import javax.xml.transform.stream.StreamSource
import javax.xml.transform.stream.StreamResult
import java.io.StringReader
import java.io.StringWriter
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result as FlutterResult

class XSLTProcessor: MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: FlutterResult) {
        when (call.method) {
            "transformXML" -> {
                try {
                    val arguments = call.arguments as? Map<*, *>
                    val transformResult = transformXML(arguments)
                    if (transformResult.isSuccess) {
                        result.success(transformResult.getOrNull())
                    } else {
                        result.error(
                            "Failed to transform XML",
                            transformResult.exceptionOrNull()?.message,
                            transformResult.exceptionOrNull()?.stackTrace.toString()
                        )
                    }
                } catch (e: Throwable) {
                    result.error(
                        "FATAL ERROR",
                        e.message,
                        e.stackTrace
                    ) // Handle any exceptions
                } // deviceUniqueIdentifier Method Channel Call
            }

            else -> result.notImplemented()
        }
    }

    private fun transformXML(arguments: Map<*, *>?): Result<String> {

        val xmlString = arguments?.get("xml") as? String
        if (xmlString.isNullOrEmpty()) {
            return Result.failure(IllegalArgumentException("XML string is null or empty"))
        }

        val xsltString = arguments?.get("xslt") as? String
        if (xsltString.isNullOrEmpty()) {
            return Result.failure(IllegalArgumentException("XSLT string is null or empty"))
        }
        val factory = TransformerFactory.newInstance()
        val transformer = factory.newTransformer(StreamSource(StringReader(xsltString)))
        val source = StreamSource(StringReader(xmlString))
        val writer = StringWriter()
        transformer.transform(source, StreamResult(writer))
        val svgString = writer.toString()
        return Result.success(svgString)
    }
}


