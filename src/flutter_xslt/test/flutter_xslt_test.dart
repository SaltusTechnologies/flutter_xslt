import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_xslt/flutter_xslt.dart';
import 'package:flutter_xslt/flutter_xslt_platform_interface.dart';
import 'package:flutter_xslt/flutter_xslt_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterXsltPlatform
    with MockPlatformInterfaceMixin
    implements FlutterXsltPlatformInterface {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterXsltPlatformInterface initialPlatform =
      FlutterXsltPlatformInterface.instance;

  test('$PlatformVersionMethodChannel is the default instance', () {
    expect(initialPlatform, isInstanceOf<PlatformVersionMethodChannel>());
  });

  test('getPlatformVersion', () async {
    FlutterXslt flutterXsltPlugin = FlutterXslt();
    MockFlutterXsltPlatform fakePlatform = MockFlutterXsltPlatform();
    FlutterXsltPlatformInterface.instance = fakePlatform;

    expect(await flutterXsltPlugin.getPlatformVersion(), '42');
  });
}
