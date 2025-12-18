# Flutter_XSLT

### Overview

Flutter_XSLT is a basic Flutter plugin that transforms an XML String with an XSLT template.
This plugin is perfect for transforming API data serialize in XML from an external source into a format your app can use. It can also inject runtime data into XML and HTML documents.
Currently, this plugin is only supported on iOS and Android. Support for the iOS simulator is unavailable at this time.

Features
--------
There is only method exposed by this plug-in: transformXLM().
This method requires two arguments, an XML String and an XSLT String.

Example:

``` dart
    String transformedXML = '';
    final _flutterXsltPlugin = FlutterXslt();
    
    String rawXml = '''
        <?xml version="1.0" encoding="UTF-8"?>
        <greeting>
            <text>Hello, World!</text>
        </greeting>
    ''';
    
    String xslt = '''
        <?xml version="1.0" encoding="UTF-8"?>
        <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
             <xsl:template match="/greeting">
                 <html>
                    <body>
                        <h2><xsl:value-of select="text"/></h2>
                     </body>
                </html>
        </xsl:template>
        </xsl:stylesheet>
    ''';
    
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      transformedXml =
          await _flutterXsltPlugin.transformXML(rawXml, xslt) ??
          '';
    } on PlatformException {
      transformedXml = 'Failed to apply transform.';
    }
      
```

Expected result:

```html
    <html>
        <body>
            <h2>Hello, World!</h2>
        </body>
    </html>
```