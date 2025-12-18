import Flutter
import UIKit


public class FlutterXsltPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
      let XSLTPROCESSOR_CHANNEL_NAME = "com.saltustechnologies.flutter_xslt/xsltprocessor"
      // let PLATFORM_VERSION_CHANNEL_NAME = "com.saltustechnologies.flutter_xslt/platform_version"
      let xsltProcessorChannel = FlutterMethodChannel(
        name: XSLTPROCESSOR_CHANNEL_NAME,
        binaryMessenger: registrar.messenger()
      )
      let xsltProcessorDelegate = FlutterXsltPlugin()
      registrar
          .addMethodCallDelegate(
            xsltProcessorDelegate,
            channel: xsltProcessorChannel
          )

//      Use this method channel to make a basic function call in swift from the plugin
//      let platformVersionChannel = FlutterMethodChannel(
//        name: PLATFORM_VERSION_CHANNEL_NAME,
//        binaryMessenger: registrar.messenger()
//      )
//      let platformVersionDelegate = FlutterXsltPlugin()
//      registrar
//            .addMethodCallDelegate(
//            platformVersionDelegate,
//            channel: platformVersionChannel
//      )
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "transformXML":
        guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Arguments are missing or malformed", details: nil))
            return
        }
        let processor = XSLTProcessor()
        processor.applyTransform(arguments: arguments, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
