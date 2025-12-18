#import "XsltTransformer.h"

// IMPORTANT: these are YOUR vendored headers.
// Make sure HEADER_SEARCH_PATHS includes $(PODS_TARGET_SRCROOT)/Lib/Headers
#include <libxml2/libxml/parser.h>
#include <libxml2/libxml/tree.h>

#include <libxslt/xslt.h>
#include <libxslt/transform.h>
#include <libxslt/xsltutils.h>

#include <libexslt/exslt.h>

static NSString * const kXsltErrorDomain = @"flutter_xslt.XsltTransformer";

@implementation XsltTransformer

+ (NSString *)transformXml:(NSString *)xml xslt:(NSString *)xslt error:(NSError **)error
{
    if (xml.length == 0 || xslt.length == 0) {
        if (error) {
            *error = [NSError errorWithDomain:kXsltErrorDomain
                                         code:1
                                     userInfo:@{NSLocalizedDescriptionKey: @"xml and xslt must be non-empty"}];
        }
        return nil;
    }

    // Convert NSString -> UTF8 bytes
    NSData *xmlData  = [xml dataUsingEncoding:NSUTF8StringEncoding];
    NSData *xsltData = [xslt dataUsingEncoding:NSUTF8StringEncoding];

    // --- Parse XML ---
    xmlDocPtr xmlDoc = xmlReadMemory((const char *)xmlData.bytes,
            (int)xmlData.length,
            "input.xml",
            NULL,
            0);
    if (!xmlDoc) {
        if (error) {
            *error = [NSError errorWithDomain:kXsltErrorDomain
                                         code:2
                                     userInfo:@{NSLocalizedDescriptionKey: @"Failed to parse XML"}];
        }
        return nil;
    }

    // --- Parse XSLT doc ---
    xmlDocPtr xsltDoc = xmlReadMemory((const char *)xsltData.bytes,
            (int)xsltData.length,
            "style.xsl",
            NULL,
            0);
    if (!xsltDoc) {
        xmlFreeDoc(xmlDoc);
        if (error) {
            *error = [NSError errorWithDomain:kXsltErrorDomain
                                         code:3
                                     userInfo:@{NSLocalizedDescriptionKey: @"Failed to parse XSLT"}];
        }
        return nil;
    }

    // --- Compile stylesheet ---
    xsltStylesheetPtr style = xsltParseStylesheetDoc(xsltDoc);
    if (!style) {
        xmlFreeDoc(xmlDoc);
        // NOTE: xsltParseStylesheetDoc takes ownership of xsltDoc on success,
        // but on failure behavior depends—be safe:
        xmlFreeDoc(xsltDoc);

        if (error) {
            *error = [NSError errorWithDomain:kXsltErrorDomain
                                         code:4
                                     userInfo:@{NSLocalizedDescriptionKey: @"Failed to compile XSLT"}];
        }
        return nil;
    }

    // --- Apply transform ---
    xmlDocPtr resultDoc = xsltApplyStylesheet(style, xmlDoc, NULL);
    if (!resultDoc) {
        xsltFreeStylesheet(style);
        xmlFreeDoc(xmlDoc);

        if (error) {
            *error = [NSError errorWithDomain:kXsltErrorDomain
                                         code:5
                                     userInfo:@{NSLocalizedDescriptionKey: @"XSLT transform failed"}];
        }
        return nil;
    }

    // --- Serialize result to string ---
    xmlChar *outBuf = NULL;
    int outLen = 0;
    int saveOk = xsltSaveResultToString(&outBuf, &outLen, resultDoc, style);

    // Clean up libxml/libxslt objects
    xmlFreeDoc(resultDoc);
    xsltFreeStylesheet(style);
    xmlFreeDoc(xmlDoc);

    if (saveOk < 0 || !outBuf) {
        if (error) {
            *error = [NSError errorWithDomain:kXsltErrorDomain
                                         code:6
                                     userInfo:@{NSLocalizedDescriptionKey: @"Failed to serialize transform output"}];
        }
        return nil;
    }

    // Convert xmlChar* -> NSString, then free buffer using libxml allocator
    NSString *result = [[NSString alloc] initWithBytes:(const void *)outBuf
                                                length:(NSUInteger)outLen
                                              encoding:NSUTF8StringEncoding];

    xmlFree(outBuf);

    if (!result) {
        if (error) {
            *error = [NSError errorWithDomain:kXsltErrorDomain
                                         code:7
                                     userInfo:@{NSLocalizedDescriptionKey: @"Output was not valid UTF-8"}];
        }
        return nil;
    }

    return result;
}

@end