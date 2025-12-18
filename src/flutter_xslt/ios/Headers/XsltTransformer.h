#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Small, Swift-friendly wrapper around libxml2/libxslt.
///
/// Usage from Swift:
///   let result = try XsltTransformer.transform(xml: xml, xslt: xslt)
///
@interface XsltTransformer : NSObject

/// Transforms `xml` using `xslt`.
/// - Returns: transformed XML as a UTF-8 string
/// - Throws: NSError if parsing/transform fails
+ (NSString *)transformXml:(NSString *)xml xslt:(NSString *)xslt error:(NSError * _Nullable * _Nullable)error;

@end

        NS_ASSUME_NONNULL_END