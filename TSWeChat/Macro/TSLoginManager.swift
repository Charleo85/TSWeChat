//
//  TSLoginManager.swift
//  TSWeChat
//
//  Created by Charlie on 5/18/16.
//  Copyright © 2016 Hilen. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SWXMLHash
//import SafariServices

let TSLoginInstance = TSLoginManager.sharedInstance

class timestamp {
    required init (){
        initial = Int(NSDate().timeIntervalSince1970*(1000)-1)
    }
    var initial: Int
    
    func getLocal()-> String {
        initial += 1
        return String(initial)
    }
}

var timestampCurrent: String {
    return "\(Int(NSDate().timeIntervalSince1970*1000))"
}

var timestampModified: String {
    var value = timestampCurrent
    for _ in 1...4{
        value += String(Int(arc4random_uniform(10)))
    }
    return value
}

var timestampNegated: String {
    return "\(~Int(NSDate().timeIntervalSince1970*1000))"
}


struct LoginKey {
    static let appid = "wx782c26e4c19acffb"
    static let fun = "new"
    static let deviceID = TSUserDefaults.getString("deviceID", defaultValue: generateDeviceID()) //to change
    var lang: String = Lang.zh.rawValue
    var UUID: String = ""
    var skey: String = ""
    var sid: String = ""
    var uin: String = ""
    var pass_ticket: String = ""
}

//var language: String = {
//    return
//}

enum Lang: String {
    case zh = "zh_CN"
    case en = "en_US"
}

func generateDeviceID() -> String {
    var value = "e"
    for _ in 1...15{
        value += String(Int(arc4random_uniform(10)))
    }
    return value
}

func saveJSON(json : JSON, fileName: String) -> Void {
    let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
    //---full path of file to save in---
    let filePath =
        documents.stringByAppendingPathComponent("\(fileName).json")
    print(filePath)
    do{
        try json.description.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
    }catch {
        print(error)
    }
}


class TSLoginManager: NSObject {
    
//    class var sharedInstance : TSLoginManager {
//        struct Static {
//            static let instance : TSLoginManager = TSLoginManager()
//        }
//        return Static.instance
//    }
    static let sharedInstance = TSLoginManager()
    var t = timestamp()
    var loginKey = LoginKey()
    var isLogin = false

//    override init() {
//        super.init()
//        print(LoginKey.deviceID)
//    }
    


//    var inLogin: [String:String] {
//        return [
//            "tip": "1",
//            "uuid": loginKey.UUID,
//            "_": timestamp
//        ]
//    }
    
    var baseRequest: [String:String] {
        return ["Uin": loginKey.uin,
        "Sid": loginKey.sid,
        "Skey": loginKey.skey,
        "DeviceID": LoginKey.deviceID!
        ]
    }
    
    func getUUID(completionHandler: (String?)->()) {
        let key : [String:String] = [
                "appid": LoginKey.appid,
                "fun": LoginKey.fun,
                "lang": self.loginKey.lang,
                "_": t.getLocal()]
        let loginURL = "https://login.weixin.qq.com/jslogin"
        var UUID: String?
        
        Alamofire.request(.GET, loginURL, parameters: key).responseString { response in
            switch response.result {
            case .Failure:
                    print(response.result.error)
                    completionHandler(UUID)
            case .Success:
                    if let responseStr = response.result.value {
                        //                                print("Response \(responseStr)")
                        let res = responseStr.componentsSeparatedByString("; ")  //            to optimize parse
                        let UUIDstr = res[1].componentsSeparatedByString("= ")[1]
                        let range = UUIDstr.startIndex.advancedBy(1)..<UUIDstr.endIndex.advancedBy(-2)
                        UUID = UUIDstr[range]
                        self.loginKey.UUID = UUID!
                    }
                    completionHandler(UUID)
            }

        }
        //        url = "https://login.weixin.qq.com/qrcode/\(self.loginKey.UUID)"
    }
    
    enum loginResult: String {
        case fail = "登陆超时"
        case anomaly = "请求异常"
        case scan = "扫描成功"
        case success = "确认登录"
        case unknown = "未知异常"
    }

    func waitforScan(completionHandler: (loginResult)-> Void) {
        let url = "https://login.weixin.qq.com/cgi-bin/mmwebwx-bin/login?tip=1&uuid=\(loginKey.UUID)&_=\(t.getLocal())"//&loginicon=true
        
        Alamofire.request(.GET, url).responseString { response in
            //                print(response.request)
            switch response.result {
            case .Failure:
                print(response.result.error)
                completionHandler(.unknown)
            case .Success:
                if let responseStr = response.result.value {
                    //                    print("Response \(responseStr)")
                    let range = responseStr.startIndex.advancedBy(12)..<responseStr.startIndex.advancedBy(15)
                    print(responseStr[range])
                    if let code = Int(responseStr[range]){
                        var result: loginResult!
                        switch code {
                        case 408:
                            result = .fail
                            completionHandler(result)
                        case 400:
                            result = .anomaly
                            completionHandler(result)
                        case 201:
                            result = .scan
//                            print(responseStr)
//                            let res = responseStr.componentsSeparatedByString(";")[1].componentsSeparatedByString("= ")[1]
//                            let ran = res.startIndex.advancedBy(1)..<res.endIndex.advancedBy(-2)
//                            print(res[ran])
                            //                        self.waitForLogin()
                            completionHandler(result)
                        case 200:
                            //https://login.wx.qq.com/cgi-bin/mmwebwx-bin/login?loginicon=true&uuid=AYD5B8Ab_A==&tip=0&r=-261927952&_=1464845709292
                            let range = responseStr.startIndex.advancedBy(38)..<responseStr.endIndex.advancedBy(-2)
                            let redirectURL = responseStr[range]+"&fun=new"
                            //                            print(redirectURL)
                            Alamofire.request(.GET, redirectURL, encoding: .URL).responseData { response in
                                //                            print(response.result.error)
                                //                            print(response.result.value)
                                switch response.result {
                                case .Failure:
                                    print(response.result.error)
                                    completionHandler(.unknown)
                                case .Success:
                                    let xml = SWXMLHash.parse(response.result.value!)
                                    //                            print(xml)
                                    self.loginKey.skey = (xml["error"]["skey"].element?.text)!
                                    self.loginKey.sid = (xml["error"]["wxsid"].element?.text)!
                                    self.loginKey.uin = (xml["error"]["wxuin"].element?.text)!
                                    self.loginKey.pass_ticket = (xml["error"]["pass_ticket"].element?.text)!
                                    //                            print(self.loginKey.skey)
                                    result = .success
                                    completionHandler(result)
                                }
                            }
                        default:
                            result = .unknown
                            completionHandler(result)
                        }
                        //                    print(result)
                    }else{
                        completionHandler(.unknown)
                    }
                }else{
                    completionHandler(.unknown)
                }
            }
        }
    }

    func login(completionHandler: (Bool)-> Void) {
        let key = ["BaseRequest": baseRequest]
        let url = "https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxinit"
        
        Alamofire.request(.POST, url, parameters: key, encoding: .JSON).responseJSON { response in
//                        print(response.request)
            switch response.result {
            case .Failure:
                print(response.result.error)
                completionHandler(false)
            case .Success:
                let json = JSON(response.result.value!)
                UserInstance.loadJSON(json){ success in
                    if success {
                        self.isLogin = true
                        saveJSON(json, fileName: "Profile")
                    }
                    completionHandler(success)
                }
            }
        }
    }
    
//    func loginBtnTapped(sender: AnyObject) {
//        
//        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//            
//            let loginInfo : Dictionary<String,AnyObject> = ["email":"abc@g.com","password":"abc123"]
//            
//            self.loginUser(loginInfo) { responseObject, error in
//                
//                print("\(responseObject) \n  \(error) ")
//                
//                // Parsing JSON Below
//                let status = Int(responseObject?.objectForKey("status") as! String)
//                if status == 1 {
//                    // Login Successfull...Move To New VC
//                }
//                else {
//                    print(responseObject?.objectForKey("message"))! as! String)
//                }
//                return
//            }
//            dispatch_async(dispatch_get_main_queue()) {
//                MBProgressHUD.hideHUDForView(self.view, animated: true)
//            }
//        }
//        
//    }
//    
//    
//    func loginUser(parameters:NSDictionary, completionHandler: (NSDictionary?, NSError?) -> ()) {
//        
//        self.postRequest("http://qa.company.com/project/index.php/user/login",
//                         paramDict: parameters as? Dictionary<String, AnyObject>,
//                         completionHandler: completionHandler)
//    }
//    
//    func postRequest(urlString: String, paramDict:Dictionary<String, AnyObject>? = nil,
//                     completionHandler: (NSDictionary?, NSError?) -> ()) {
//        
//        Alamofire.request(.POST, urlString, parameters: paramDict)
//            .responseJSON { response in
//                switch response.result {
//                case .Success(let JSON):
//                    completionHandler(JSON as? NSDictionary, nil)
//                case .Failure(let error):
//                    completionHandler(nil, error)
//                }
//        }
//        
//    }

}

