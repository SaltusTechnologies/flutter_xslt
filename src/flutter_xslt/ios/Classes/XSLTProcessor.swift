import Foundation
import Flutter


class XSLTProcessor: NSObject{
    func applyTransform(arguments: [String: Any], result: @escaping FlutterResult) {
        do {
            guard let xmlString = arguments["xml"] as? String else {
                 return
            }
            
            guard let xsltString = arguments["xslt"] as? String else {
                return
            }
            var err: NSError?
            let resultString = try XsltTransformer.transformXml(
                xmlString,
                xslt: xsltString,
                error: &err
            )
            result(resultString)
        } catch let error {
            result("")
        }
    }
    
}
