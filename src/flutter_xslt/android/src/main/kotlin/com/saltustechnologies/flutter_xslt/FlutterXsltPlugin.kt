package com.saltustechnologies.flutter_xslt

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterXsltPlugin */
class FlutterXsltPlugin: FlutterPlugin, MethodCallHandler {
  private val XSLT_PROCESSOR_CHANNEL = "com.saltustechnologies.flutter_xslt/xsltprocessor"
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var xsltProcessorChannel : MethodChannel
  private lateinit var platformVersionChannel : MethodChannel

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    xsltProcessorChannel = MethodChannel(flutterPluginBinding.binaryMessenger, XSLT_PROCESSOR_CHANNEL)
    xsltProcessorChannel.setMethodCallHandler(XSLTProcessor())
    platformVersionChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.saltustechnologies.flutter_xslt/platform_version")
    platformVersionChannel.setMethodCallHandler(this)
  }

//  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
//    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.saltustechnologies.flutter_xslt/xsltprocessor")
//    channel.setMethodCallHandler(XSLTProcessor())
//  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    xsltProcessorChannel.setMethodCallHandler(null)
    platformVersionChannel.setMethodCallHandler(null)
  }
}
