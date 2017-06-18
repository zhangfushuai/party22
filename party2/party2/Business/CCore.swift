import ObjectMapper
import UIKit
import Alamofire
public class CCore {
    
    // 计算文本的宽高
    public static func sizeOfString(lable:UILabel,WidthMax:CGFloat,heightMax:CGFloat) -> CGRect {
        let attributes = [NSFontAttributeName: lable.font]
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let text: NSString = NSString(cString: lable.text!.cString(using: String.Encoding.utf8)!,
                                      encoding: String.Encoding.utf8.rawValue)!
        let rect = text.boundingRect(with: CGSize(width: WidthMax,height: heightMax), options: option, attributes: attributes, context: nil)
        return rect
    }
    //获取当前用户
    public static func getCurrentMember(completeHandler:@escaping (_ data: AnyObject)->Void) {
        invoke("Member/GetCurrentMember",completeHandler:  { (data) in
            completeHandler(data)
        })
    }
    open static func invoke(_ url:String,completeHandler:@escaping (_ data:AnyObject)->Void) {
        invoke(url, formData:[:]) { (data) -> Void in
            completeHandler(data)
        }
    }
    open static func invoke(_ url:String,formData:[String: AnyObject],completeHandler:@escaping (_ data:AnyObject)->Void){
        do {
            let param = try JSONSerialization.data(withJSONObject: formData, options: JSONSerialization.WritingOptions.prettyPrinted)
            let jsonString = NSString(data: param, encoding: String.Encoding.utf8.rawValue)! as String
            Alamofire.request(CCore.getWebApi(url),  method:.post, parameters: ["formData": jsonString]).responseJSON() {
                response in
                completeHandler(JSONObjectByRemovingKeysWithNullValues(response.result.value! as AnyObject))
                
                //                if let
                //                    headerFields = response.response?.allHeaderFields as? [String: String],
                //                    URL = response.request?.URL
                //                {
                //                    let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(headerFields, forURL: URL)
                //                    print(cookies)
                //                    print("====================")
                //                    print(headerFields)
                //                    print("====================")
                //                }
                
            }
            
        } catch let error as NSError {
            print(error)
        }
    }

    open static func upload(_ filePath:URL,completeHandler:@escaping (_ data: Attachment) ->Void) {
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(filePath, withName: "uploadFile")
            },
            to: getWebApi("file/upload"),
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                        completeHandler(Mapper<Attachment>().map(JSON: response.result.value as! [String : Any])!)
                        //completeHandler(Mapper<Attachment>().map(response.result.value)!)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            }
        )
        

        
        
        /*Alamofire.upload(
         .POST,
         getWebApi("file/upload"),
         multipartFormData: { multipartFormData in
         multipartFormData.appendBodyPart(fileURL: filePath, name: "uploadFile")
         },
         encodingCompletion: { encodingResult in
         switch encodingResult {
         case .Success(let upload, _, _):
         upload.responseJSON { response in
         debugPrint(response)
         completeHandler(data: Mapper<Attachment>().map(response.result.value)!)
         }
         case .Failure(let encodingError):
         print(encodingError)
         }
         }
         )*/
    }
    
    open static func uploadDatas(_ datas:[Data],completeHandler:@escaping (_ data: [Attachment]) ->Void) {
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                for i in 0..<datas.count {
                    let name = String(format: "%ld", arguments: [arc4random()])
                    
                    multipartFormData.append(datas[i], withName: "uploadFile", fileName: name, mimeType: "image/png")
                }
        },
            to: getWebApi("file/uploads"),
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                        

                        
                        completeHandler(Mapper<Attachment>().mapArray(JSONArray: response.result.value as! [[String : Any]])!)
                        //completeHandler(Mapper<Attachment>().map(response.result.value)!)
                        
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        }
        )
        
    }

    
    private static func JSONObjectByRemovingKeysWithNullValues(_ JSONObject: AnyObject) -> AnyObject {
        switch JSONObject {
        case let JSONObject as [String: AnyObject]:
            var mutableDictionary = JSONObject
            for (key, value) in JSONObject {
                switch value {
                case _ as NSNull:
                    mutableDictionary.removeValue(forKey: key)
                default:
                    mutableDictionary[key] = JSONObjectByRemovingKeysWithNullValues(value)
                }
            }
            return mutableDictionary as AnyObject
        default:
            return JSONObject
        }
    }
    
    
    
    
    
    
    open static let OK = "OK"
    
    
    open static func getWebApi(_ url:String) ->String {
        return getStringFromInfoPlist("WebApiRoot") + "/service/" + url
    }
    
//    public static func getWebApiRoot() -> String {
//        let dicts = NSDictionary (contentsOfURL: NSBundle.mainBundle().URLForResource("Info", withExtension: "plist")!)! as NSDictionary
//        return dicts.objectForKey("WebApiRoot")as! String
//    }
    
    open static func toSafeInt(_ v:String,defaultValue:Int) -> Int {
        let a = Int(v)
        if (a != nil) {
            return a!
        } else {
            return defaultValue
        }
    }
    
    open static func toSafeInt(_ v:String) -> Int {
        
        return toSafeInt(v, defaultValue: -1)
    }
    
    open static func toSafeString(_ v:String) -> String {
        
        return String(v)
    }
    
    open static func toSafeFloat(_ v:String,defaultValue:Float) -> Float {
        let a = Float(v)
        if (a != nil) {
            return a!
        } else {
            return defaultValue
        }
    }
    
    open static func toSafeDouble(_ v:String,defaultValue:Double) -> Double {
        let a = Double(v)
        if (a != nil) {
            return a!
        } else {
            return defaultValue
        }
    }
    
    open static func getStringBeforeCharacter(_ initialString:String,str:String) -> String {
        return initialString.subStr(0, end: initialString.indexOf(str))
    }
    
    open static func getStringAfterCharacter(_ initialString:String,str:String) -> String {
        return initialString.subStr(initialString.indexOf(str) + 1, end: initialString.length)
    }
    
    open static func getStringFromInfoPlist(_ str:String) -> String {
        let dicts = NSDictionary (contentsOf: Bundle.main.url(forResource: "Info", withExtension: "plist")!)! as NSDictionary
        return dicts.object(forKey: "\(str)") as! String
    }
    fileprivate static let UUIDStr:String = "UUID"
}
