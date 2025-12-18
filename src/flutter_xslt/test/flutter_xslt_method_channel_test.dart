import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_xslt/flutter_xslt_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  PlatformVersionMethodChannel platform = PlatformVersionMethodChannel();
  const MethodChannel channel = MethodChannel('flutter_xslt');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return '42';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
