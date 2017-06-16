import UIKit
import Foundation
public extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    convenience init (hex:String){
        //var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercased()
        var cString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substring(from: 1)
        }
        
        let rString = (cString as NSString).substring(to: 2)
        let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
}

public extension NSObject {
    
    class func fromClassName(_ className : String) -> NSObject {
        let className = Bundle.main.infoDictionary!["CFBundleName"] as! String + "." + className
        let aClass = NSClassFromString(className) as! UIViewController.Type
        return aClass.init()
    }
}
public protocol OptionalString {}
extension String: OptionalString {}

public extension Optional where Wrapped: OptionalString {
    var isNilOrEmpty: Bool {
        return ((self as? String) ?? "").isEmpty
    }
}
public extension String {
    
    func subStr(_ start: Int, end: Int) -> String
    {
        if (start < 0 || start > self.characters.count)
        {
            return ""
        }
        else if end < 0 || end > self.characters.count
        {
            return ""
        }
        let range = (self.characters.index(self.startIndex, offsetBy: start) ..< self.characters.index(self.startIndex, offsetBy: end))
        return self.substring(with: range)
    }
    func subString(_ start: Int, length: Int) -> String
    {
        let startIndex = self.characters.index(self.startIndex, offsetBy: start)
        let end = self.characters.index(self.startIndex, offsetBy: start + length)
        return self.substring(with: (startIndex ..< end))
    }
    var length: Int {
        get {
            return self.characters.count
        }
    }
    
    func contains(_ s: String) -> Bool
    {
        return self.range(of: s) != nil ? true : false
    }
    
    func replace(_ target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
    
    subscript (i: Int) -> Character
        {
        get {
            let index = characters.index(startIndex, offsetBy: i)
            return self[index]
        }
    }
    
    subscript (r: Range<Int>) -> String
        {
        get {
            let startIndex = self.characters.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.characters.index(self.startIndex, offsetBy: r.upperBound - 1)
            
            return self[(startIndex ..< endIndex)]
        }
    }
    
    
    
    func indexOf(_ target: String) -> Int
    {
        let range = self.range(of: target)
        if let range = range {
            return self.characters.distance(from: self.startIndex, to: range.lowerBound)
        } else {
            return -1
        }
    }
    
    func indexOf(_ target: String, startIndex: Int) -> Int
    {
        let startRange = self.characters.index(self.startIndex, offsetBy: startIndex)
        
        let range = self.range(of: target, options: NSString.CompareOptions.literal, range: (startRange ..< self.endIndex))
        
        if let range = range {
            return self.characters.distance(from: self.startIndex, to: range.lowerBound)
        } else {
            return -1
        }
    }
    
    func lastIndexOf(_ target: String) -> Int
    {
        var index = -1
        var stepIndex = self.indexOf(target)
        while stepIndex > -1
        {
            index = stepIndex
            if stepIndex + target.length < self.length {
                stepIndex = indexOf(target, startIndex: stepIndex + target.length)
            } else {
                stepIndex = -1
            }
        }
        return index
    }
    func isMatch(_ regex: String, options: NSRegularExpression.Options) -> Bool
    {
        let exp = try! NSRegularExpression(pattern: regex,options: options)
        let matchCount = exp.numberOfMatches(in: self, options: [], range: NSMakeRange(0, self.length))
        return matchCount > 0
    }
    func getMatches(_ regex: String, options: NSRegularExpression.Options) -> [NSTextCheckingResult]
    {
        let exp = try! NSRegularExpression(pattern: regex,options: options)
        
        let matches = exp.matches(in: self, options: [], range: NSMakeRange(0, self.length))
        return matches as [NSTextCheckingResult]
    }
    fileprivate var vowels: [String]
        {
        get
        {
            return ["a", "e", "i", "o", "u"]
        }
    }
    
    fileprivate var consonants: [String]
        {
        get
        {
            return ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "z"]
        }
    }
    
    func pluralize(_ count: Int) -> String
    {
        if count == 1 {
            return self
        } else {
            let lastChar = self.subString(self.length - 1, length: 1)
            let secondToLastChar = self.subString(self.length - 2, length: 1)
            var prefix = "", suffix = ""
            
            if lastChar.lowercased() == "y" && vowels.filter({x in x == secondToLastChar}).count == 0 {
                //prefix = self[0...self.length - 1]
                prefix = self[startIndex...endIndex]
                suffix = "ies"
            } else if lastChar.lowercased() == "s" || (lastChar.lowercased() == "o" && consonants.filter({x in x == secondToLastChar}).count > 0) {
                //prefix = self[0...self.length]
                prefix = self[startIndex...endIndex]
                suffix = "es"
            } else {
                //prefix = self[0...self.length]
                prefix = self[startIndex...endIndex]
                suffix = "s"
            }
            
            return prefix + (lastChar != lastChar.uppercased() ? suffix : suffix.uppercased())
        }
    }
}
