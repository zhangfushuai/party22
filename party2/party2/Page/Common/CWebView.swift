//
//  Dashboard.swift
//  diandian
//
//  Created by sunny on 16/4/12.
//  Copyright © 2016年 sunny. All rights reserved.
//

import UIKit
import WebKit
import Foundation


open class CWebView: UIViewController,WKScriptMessageHandler,WKUIDelegate,WKNavigationDelegate {
    
    open var appWebView:WKWebView!
    var config:WKWebViewConfiguration!
    var alert:UIAlertView!
    var backString:String!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        theWebView()
        

    }
    
    func theWebView() {
        config = WKWebViewConfiguration()
        
        //注册js方法
        
        config.userContentController.add(self, name: "native")
        config.userContentController.add(self, name: "redirect")
        config.userContentController.add(self, name: "upload")//上传图片 视频 音频

        appWebView = WKWebView(frame: self.view.frame,configuration: config)
        appWebView.navigationDelegate = self
        appWebView.uiDelegate = self
        
        self.view.addSubview(appWebView)
        loadWebView()
        appWebView.scrollView.bounces = false
        
//        let tapGesture = UITapGestureRecognizer(target: self,action: #selector(CWebView.handleTapGesture))
//        tapGesture.numberOfTapsRequired = 2
//        tapGesture.delegate = self
//        appWebView.addGestureRecognizer(tapGesture)
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func handleTapGesture() {
        loadWebView()
    }
    
    func loadWebView() {
        
        let strUrl = CCore.getStringFromInfoPlist("InitURL")
        let subStrURL = (strUrl as NSString).substring(to: 4)
        
        if subStrURL == "http" {
            let url = URL(string: strUrl)
            let request = URLRequest(url: url!)
            appWebView.load(request)
        } else {
            let firstPath = CCore.getStringBeforeCharacter(strUrl, str: ".")
            let lastPath = CCore.getStringAfterCharacter(strUrl,str:".")
            let request = NSMutableURLRequest(url: URL(fileURLWithPath: Bundle.main.path(forResource: "\(firstPath)", ofType: "\(lastPath)")!))
            appWebView.load(request as URLRequest)
        }
        
//        let button = UIButton()
//        button.backgroundColor = UIColor.orangeColor()
//        button.frame = CGRectMake(100, 200, 100, 30)
//        button.addTarget(self, action: #selector(CWebView.callJs), forControlEvents: .TouchUpInside)
//        appWebView.addSubview(button)
        
        let cookieStorage = HTTPCookieStorage.shared
        for cookie in cookieStorage.cookies! {
            if cookie.name == "SessionCurrentMember"  {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
    }
    
    open func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "redirect" {
            var vc = UIViewController()
            let dic = message.body as! NSDictionary
            let className = (dic["className"] as AnyObject).description
            let cls = Bundle.main.infoDictionary!["CFBundleName"] as! String + "." + className!
            let aClass = NSClassFromString(cls) as! UIViewController.Type
            vc = aClass.init() as UIViewController
            vc = type(of: vc).init()
            self.present(vc, animated: true, completion: nil)
            
        } else if message.name == "native" {
            
            let body = message.body
            let className = "CNative"
            
            if let cls = NSClassFromString((Bundle.main.object(forInfoDictionaryKey: "CFBundleName")! as AnyObject).description + "." + className) as? NSObject.Type{
                
                let obj = cls.init()
                let param = (body as AnyObject).object(forKey: "param")
    
                var functionName = ((body as AnyObject).object(forKey: "functionName") as! String)
                if param != nil {
                    functionName += ":"
                }
                
                let functionSelector = Selector(functionName)
                
                backString = obj.perform(functionSelector,with: param).takeUnretainedValue() as! String

//                    let callbackString = "Native"+"."+(body.objectForKey("functionName") as! String)
//                    appWebView.evaluateJavaScript("\(callbackString)(\(backString))"){(JSReturnValue:AnyObject?, error:NSError?) in
//                        if let errorDescription = error?.description{
//                            print("returned value: \(errorDescription)")
//                        }
//                        else if JSReturnValue != nil{
//                            print("returned value: \(JSReturnValue!)")
//                        }
//                        else{
//                            print("no return from JS")
//                        }
//                    }
                
            } else if message.name == "upload" {
                self.present(UploadViewController(), animated: true, completion: nil)
            } else {
                print("类未找到！")
            }
        }
    }
    
    
    // MARK: - WKUIDelegate
    open func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        //通知回调
        completionHandler()

        
        
        let alert = UIAlertController(title: "提醒", message: "\(message)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler:nil))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
//        self.present(alert, animated: true, completion: nil)
        
        self.present(UploadViewController(), animated: true, completion: nil)

        
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

}
