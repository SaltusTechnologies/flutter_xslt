import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_xslt_method_channel_api.dart';

abstract class FlutterXsltPlatformInterface extends PlatformInterface {
  /// Constructs a FlutterXsltPlatform.
  FlutterXsltPlatformInterface() : super(token: _token);

  static final Object _token = Object();

  static FlutterXsltPlatformInterface _instance =
  FlutterXSLTMethodChannelAPI();

  /// The default instance of [FlutterXsltPlatformInterface] to use.
  ///
  /// Defaults to [PlatformVersionMethodChannel].
  static FlutterXsltPlatformInterface get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterXsltPlatformInterface] when
  /// they register themselves.
  static set instance(FlutterXsltPlatformInterface instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> transformXML(String xml, String xslt) {
    throw UnimplementedError('transformXML() has not been implemented.');
  }
}
