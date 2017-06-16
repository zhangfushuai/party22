import ObjectMapper
public class Attachment:Mappable
{
    
    public var ID:String?
    public var fileName:String?
    public var fileNameInDisk:String?
    public var contentType:String?
    public var fileLength:Int = 0
    public var needWaterMark:Int = 0
    public var memberID:String?
    public var hiddenID:String?
    
    init(){
        
    }
    public required init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        ID    <- map["ID"]
        fileName         <- map["fileName"]
        fileNameInDisk      <- map["fileNameInDisk"]
        contentType       <- map["contentType"]
        fileLength  <- map["fileLength"]
        needWaterMark  <- map["needWaterMark"]
        memberID     <- map["memberID"]
        hiddenID    <- map["hiddenID"]
    }
}
