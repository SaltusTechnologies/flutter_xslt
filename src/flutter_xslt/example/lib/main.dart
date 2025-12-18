import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_xslt/flutter_xslt.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _transformedXML = '';
  final _flutterXsltPlugin = FlutterXslt();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    //Uncomment to test new platform interfaces, or changes to the plugin.
    // String platformVersion;
    // // Platform messages may fail, so we use a try/catch PlatformException.
    // // We also handle the message potentially returning null.
    // try {
    //   platformVersion =
    //       await _flutterXsltPlugin.getPlatformVersion() ?? 'Unknown platform version';
    // } on PlatformException {
    //   platformVersion = 'Failed to get platform version.';
    // }

    String transformedXml;
    String rawXml = '''<?xml version="1.0" encoding="UTF-8"?>
<greeting>
    <text>Hello, World!</text>
</greeting>''';
    String xslt = '''<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/greeting">
        <html>
            <body>
                <h2><xsl:value-of select="text"/></h2>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>''';
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      transformedXml =
          await _flutterXsltPlugin.transformXML(rawXml, xslt) ??
          '';
    } on PlatformException {
      transformedXml = 'Failed to apply transform.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _transformedXML = transformedXml;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          //child: Text('Running on: $_platformVersion\n'),
          child: Text('Sample text(A successful transform will return valid HTML): $_transformedXML\n'),
        ),
      ),
    );
  }
}
