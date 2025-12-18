import 'flutter_xslt_platform_interface.dart';

class FlutterXslt {
  Future<String?> getPlatformVersion() {
    return FlutterXsltPlatformInterface.instance.getPlatformVersion();
  }

  Future<String?> transformXML(String xml, String xslt) {
    return FlutterXsltPlatformInterface.instance.transformXML(xml, xslt);
  }
}
