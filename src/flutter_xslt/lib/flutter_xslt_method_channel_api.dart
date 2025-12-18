import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_xslt_platform_interface.dart';

/// An implementation of [FlutterXsltPlatformInterface] that uses method channels.
class FlutterXSLTMethodChannelAPI extends FlutterXsltPlatformInterface {
  // This channel is created during plugin creation.
  // It is used for getting the platform version.
  // This method can be used for testing purposes and serves as an example.
  @visibleForTesting
  final PlatformVersionMethodChannel = const MethodChannel(
    'com.saltustechnologies.flutter_xslt/platform_version',
  );

  @override
  Future<String?> getPlatformVersion() async {
    final version = await PlatformVersionMethodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  // This channel is used for XSLT processing methods.
  //This channel maps to a native class in the platform implementation.
  final XSLTProcessorMethodChannel = const MethodChannel(
    'com.saltustechnologies.flutter_xslt/xsltprocessor',
  );

  @override
  Future<String?> transformXML(String xml, String xslt) async {
    final version = await XSLTProcessorMethodChannel.invokeMethod<String>(
      'transformXML',
      {'xml': xml, 'xslt': xslt},
    );
    return version;
  }
}
