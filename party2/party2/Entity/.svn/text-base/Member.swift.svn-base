import ObjectMapper
class Member: Mappable {
    
    var ID: String?
    var username: String?
    var password: String?
    var clientIP: String?
    var companyID: Int = 0
    var companyName: String?
    var departmentID: Int = 0
    var departmentName: String?
    var groupID: String?
    var groupName: String?
    var lastLoginDate: String?
    var mobile: String?
    var registDate: String?
    var statusID: Int = 0
    var statusName: String?
    var tel: String?
    
    init(){
        
    }
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        ID    <- map["ID"]
        clientIP         <- map["clientIP"]
        companyID      <- map["companyID"]
        companyName       <- map["companyName"]
        departmentID  <- map["departmentID"]
        departmentName  <- map["departmentName"]
        groupID     <- map["groupID"]
        groupName    <- map["groupName"]
        lastLoginDate    <- map["lastLoginDate"]
        mobile    <- map["mobile"]
        password       <- map["password"]
        registDate  <- map["registDate"]
        statusID     <- map["statusID"]
        statusName    <- map["statusName"]
        tel    <- map["tel"]
        username    <- map["username"]
    }
}
