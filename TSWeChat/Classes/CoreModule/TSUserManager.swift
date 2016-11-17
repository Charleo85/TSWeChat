//
//  TSUserManager.swift
//  TSWeChat
//
//  Created by Hilen on 11/6/15.
//  Copyright © 2015 Hilen. All rights reserved.
//
import UIKit
import KeychainAccess
import SwiftyJSON
import Alamofire
import CoreData

let UserInstance = UserManager.sharedInstance

private let kNickname    = "kTS_wechat_username"
private let kAvatar      = "kTS_wechat_avatar"
private let kAccessToken = "kTS_wechat_accessToken"
private let kUserId      = "kTS_wechat_userId"
private let kIsLogin     = "kTS_wechat_isLogin"
private let kLoginName   = "kTS_wechat_loginName"
private let kPassword    = "kTS_wechat_password"

class UserManager: NSObject {
    //    class var sharedInstance : UserManager {
    //        struct Static {
    //            static let instance : UserManager = UserManager()
    //        }
    //        return Static.instance
    //    }
    static let sharedInstance = UserManager()
    
    var headImg: UIImage?
    
    let TSKeychain = Keychain(service: "com.wechat.Hilen") //keychain
    
    var accessToken: String? {
        get { return TSUserDefaults.getString(kAccessToken, defaultValue: "这是我的 AccessToken") }
        set (newValue) { TSUserDefaults.setString(kAccessToken, value: newValue) }
    }
    
    var syncKey: [String: AnyObject]! {
        didSet{
            var value = ""
            if let dictArray = syncKey!["List"] as? [AnyObject] {
                for i in 0..<dictArray.count {
                    let dict = dictArray[i]
                    if let keyDict = dict as? [String: Int] {
                        value = value + "\(keyDict["Key"]!)_\(keyDict["Val"]!)"
                        if (i+1) != dictArray.count {
                            value = value + "|"
                        }
                    }
                }
            }
            //            print(value)
            self.synckey = value
        }
    }
    
    
    var synckey: String?
    
    /// 用户昵称，不是登录名
    var nickname: String?
    //    {
    //        get { return TSUserDefaults.getString(kNickname, defaultValue: "") }
    //        set (newValue) { TSUserDefaults.setString(kNickname, value: newValue) }
    //    }
    var avatar: String?
    
    var userId: String?
    //    {
    //        get { return TSUserDefaults.getString(kUserId, defaultValue: TSConfig.testUserID) }
    //        set (newValue) { TSUserDefaults.setString(kUserId, value: newValue) }
    //    }
    var isLogin: Bool {
        get { return TSUserDefaults.getBool(kIsLogin, defaultValue: false) }
        set (newValue) { TSUserDefaults.setBool(kIsLogin, value: newValue) }
    }
    
    /// 用户手机号 ,存在 keychain
    var loginName: String? {
        get { return  TSKeychain[kLoginName] ?? "" }
        set (newValue) { TSKeychain[kLoginName] = newValue }
    }
    
    ///密码, 存在 keychain
    var password: String?  {
        get { return  TSKeychain[kPassword] ?? "" }
        set (newValue) { TSKeychain[kPassword] = newValue }
    }
    
    private override init() {
        super.init()
    }
    
    func readAllData() {
        self.nickname = TSUserDefaults.getString(kNickname, defaultValue: "")
        self.avatar = TSUserDefaults.getString(kAvatar, defaultValue: "")
        self.userId = TSUserDefaults.getString(kUserId, defaultValue: "")
        self.isLogin = TSUserDefaults.getBool(kIsLogin, defaultValue: false)
        self.loginName = TSKeychain[kLoginName] ?? ""
        self.password = TSKeychain[kPassword] ?? ""
    }
    
    /**
     登录成功
     - parameter result: 登录成功后传进来的字典
     */
    func userLoginSuccess(result: JSON) {
        self.loginName = result["username"].stringValue
        self.password = result["password"].stringValue
        self.nickname = result["nickname"].stringValue
        self.userId = result["user_id"].stringValue
        self.isLogin = true
    }
    
    var chatSet: [String]?
    
    func loadJSON(json : JSON, completionHandler: (Bool)->Void) {
        self.nickname = json["User"]["NickName"].stringValue
        self.userId = json["User"]["UserName"].stringValue
        self.syncKey = json["SyncKey"].dictionaryObject
        let chatset = json["ChatSet"].stringValue
        self.chatSet = chatset.characters.split{$0 == ","}.map(String.init)
        //        print(chatSet)
        //        var value = ""
        //        if let dictArray = json["SyncKey"]["List"].arrayObject {
        //            for i in 0..<dictArray.count {
        //                let dict = dictArray[i]
        //                if let keyDict = dict as? [String: Int] {
        //                    value = value + "\(keyDict["Key"]!)_\(keyDict["Val"]!)"
        //                    if (i+1) != dictArray.count {
        //                        value = value + "|"
        //                    }
        //                }
        //            }
        //        }
        //        self.synckey = value
        
        
        //        print("1")
        sendMsg(.initialStatusNotify)
        //        syncCheck()
        //        sync()
        let HeadImgUrl = json["User"]["HeadImgUrl"].stringValue
        if HeadImgUrl != "" {
            getImage("https://wx.qq.com\(HeadImgUrl)"){ image in
                self.headImg = image
                completionHandler(true)
            }
        }else{
            print("fail to load head image")
            completionHandler(false)
            
            //            TSLoginInstance.login(){success in
            //                if success {
            //                    print("success finally")
            //                    completionHandler(true)
            //                }else{
            //                    print("fail to load head image")
            //                    completionHandler(false)
            //                }
            //            }
            
        }
        //        }else{
        //            print("fail to load head image url")
        //            completionHandler(false)
        //        }
        
    }
    
    func readSync(json : JSON) {
        if json["BaseResponse"]["Ret"].intValue == 0 {
            if let newkey = json["SyncKey"].dictionaryObject where json["SyncKey"]["Count"].intValue != 0 {
                self.syncKey = newkey
            }
            if json["AddMsgCount"].intValue != 0{
                addMsgList()
            }
            if json["DelContactCount"].intValue != 0{
                delContactList()
            }
            if json["ModContactCount"].intValue != 0{
                modContactList()
            }
            if json["ModChatRoomMemberCount"].intValue != 0{
                modChatRoomMemberList()
            }
            //profile
            //skey
        } else {
            //            completionHandler(false)
            print(json["BaseResponse"]["ErrMsg"].stringValue)
        }
    }
    
    func addMsgList() {
        
    }
    
    
    func delContactList() {
        
    }
    
    func modContactList() {
        
    }
    
    func modChatRoomMemberList() {
        
    }
    
    enum messageType {
        case initialStatusNotify
        case statusNotify
        case sendMsg
        case sendEmj
        
    }
    
    func sendMsg(option: messageType, toUserName: String?=nil, content: String?=nil) {
        var url = "https://wx.qq.com/cgi-bin/mmwebwx-bin/"
        var key: [String : AnyObject]?
        switch option {
        case .initialStatusNotify:
            key = ["BaseRequest": TSLoginInstance.baseRequest, "Code": 3, "FromUserName": self.userId!, "ToUserName": self.userId!, "ClientMsgId": timestampCurrent]
            url += "webwxstatusnotify?lang=zh_CN&pass_ticket=\(TSLoginInstance.loginKey.pass_ticket)"
        case .statusNotify:
            key = ["BaseRequest": TSLoginInstance.baseRequest, "Code": 1, "FromUserName": self.userId!, "ToUserName":  toUserName!, "ClientMsgId": timestampCurrent]
            url += "webwxstatusnotify?lang=zh_CN&pass_ticket=\(TSLoginInstance.loginKey.pass_ticket)"
        case .sendMsg:
            key = ["BaseRequest": TSLoginInstance.baseRequest, "Type": 1, "Content": content!, "FromUserName": self.userId!, "ToUserName": toUserName!, "LocalID": timestampModified, "ClientMsgId": timestampModified]
            url += "webwxsendmsg?pass_ticket=\(TSLoginInstance.loginKey.pass_ticket)"
        case .sendEmj:
            key = ["BaseRequest": TSLoginInstance.baseRequest, "Type": 47, "EmojiFlag": 2, "MediaId": content!, "FromUserName": self.userId!, "ToUserName": toUserName!, "LocalID": timestampModified, "ClientMsgId": timestampModified]
            url += "webwxsendemoticon?fun=sys&f=json&pass_ticket=\(TSLoginInstance.loginKey.pass_ticket)"
        }
        
        
        Alamofire.request(.POST, url, parameters: key, encoding: .JSON).responseJSON { response in
            print(response.request)
            switch response.result {
            case .Failure:
                print(response.result.error)
            //                completionHandler(false)
            case .Success:
                let json = JSON(response.result.value!)
                //                self.storeFetched(json)
                //                saveJSON(json, fileName: "statusNotify")
                //                completionHandler(true)
            }
        }
    }
    
    //    func loadJSON(json : JSON, completionHandler: (Bool)->Void) {
    //
    //
    //    }
    //"StatusNotifyCode": 5取消, 2静音
    
    
    let SyncHost = ["webpush.weixin.qq.com",
                    "webpush2.weixin.qq.com",
                    "webpush.wechat.com",
                    "webpush1.wechat.com",
                    "webpush2.wechat.com"]//,"webpush1.wechatapp.com","webpush.wechatapp.com"
    
    //    var
    
    func syncCheck () {
        //        let timestamp1 = Int(NSDate().timeIntervalSince1970*1000)
        //        delay(0.5){
        //        let timestamp2 = Int(NSDate().timeIntervalSince1970*1000)
        let key: [String: AnyObject] = ["_": TSLoginInstance.t.getLocal(), "r": timestampCurrent, "synckey": synckey!, "uin": TSLoginInstance.loginKey.uin,"sid": TSLoginInstance.loginKey.sid, "skey": TSLoginInstance.loginKey.skey, "deviceid": LoginKey.deviceID!]
        let host = SyncHost[0]
        //        for host in self.SyncHost {
        let url = "https://\(host)/cgi-bin/mmwebwx-bin/synccheck"
        
        Alamofire.request(.GET, url, parameters: key).responseString { response in
            print(response.request)
            switch response.result {
            case .Failure:
                print(response.result.error)
            case .Success:
                if let responseStr = response.result.value {
                    let res = responseStr.componentsSeparatedByString("=")[1].componentsSeparatedByString(",")  //            to optimize parse
                    let first = res[0].startIndex.advancedBy(10)..<res[0].endIndex.advancedBy(-1)
                    let second = res[1].startIndex.advancedBy(10)..<res[1].endIndex.advancedBy(-2)
                    if let retcode = Int(res[0][first]), selector = Int(res[1][second]){
                        print(retcode, selector)
                        switch retcode {
                        case 0:
                            switch selector {
                            case 0:
                                self.syncCheck()
                            case 1:
                                self.sync()
                                print("profile change")
                            case 2:
                                self.sync()
                                print("profile change")
                            case 4:
                                self.sync()
                                print("联系人列表变更")
                            case 6:
                                self.sync()
                                print("新消息")
                            case 7:
                                self.sync()
                                print("进入/离开聊天界面")
                            default:
                                print("Unknown")
                            }
                        case 1100:
                            print("失败/登出微信")
                        default:
                            print("Unknown")
                        }
                    }
                }else{
                    print(response.result.value!)
                }
                //                    break
            }
        }
        //        }
        //        }
    }
    
    func sync() {
        let key: [String : AnyObject] = ["BaseRequest": TSLoginInstance.baseRequest,
                                         "SyncKey": self.syncKey,
                                         "rr": timestampNegated]
        let url = "https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxsync?sid=\(TSLoginInstance.loginKey.sid)&skey=\(TSLoginInstance.loginKey.skey)&pass_ticket=\(TSLoginInstance.loginKey.pass_ticket)"
        
        
        Alamofire.request(.POST, url, parameters: key, encoding: .JSON).responseJSON { response in
            print(response.request)
            switch response.result {
            case .Failure:
                print(response.result.error)
            //                completionHandler(false)
            case .Success:
                let json = JSON(response.result.value!)
                //                self.readSync(json)
                //                self.storeFetched(json)
                saveJSON(json, fileName: "sync")
                //                completionHandler(true)
            }
        }
        
    }
    
    
    
    
    
    func fetchContacts(completionHandler: (Bool)->Void){
        let key = ["pass_ticket": TSLoginInstance.loginKey.pass_ticket,
                   "skey": TSLoginInstance.loginKey.skey,
                   "r": timestampCurrent,
                   "seq": "0"]
        let url = "https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxgetcontact"
        
        Alamofire.request(.GET, url, parameters: key).responseJSON { response in
            //            print(response.request)
            switch response.result {
            case .Failure:
                print(response.result.error)
                completionHandler(false)
            case .Success:
                let json = JSON(response.result.value!)
                self.storeFetched(json)
                saveJSON(json, fileName: "Contact")
                completionHandler(true)
            }
        }
    }
    
    let managedObjectContext: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    func storeFetched(data: JSON) {
        let fetchRequest = NSFetchRequest(entityName:"Contact")
        let entityDescription = NSEntityDescription.entityForName("Contact", inManagedObjectContext: managedObjectContext!)
        let contacts = data["MemberList"].arrayValue
        
        for contact in contacts {
            let Alias = contact["Alias"].stringValue
            let NickName = contact["NickName"].stringValue
            let predicate = NSPredicate(format: "alias == %@ && nickName == %@", Alias, NickName)
            fetchRequest.predicate = predicate
            
            if let results = try? self.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Contact] {
                if (results.count > 0) {
                    //                    print(results)
                    for result in results {
                        result.userName = contact["UserName"].stringValue
                        result.remarkName = contact["RemarkName"].stringValue
                        result.headImgUrl = contact["HeadImgUrl"].stringValue
                        result.starFriend = contact["StarFriend"].intValue
                        
                        if result.remarkName == "" {
                            if result.nickName == "" {
                                result.displayName = contact["Alias"].stringValue
                                result.uin = contact["Alias"].stringValue
                            }else {
                                result.displayName = contact["NickName"].stringValue
                                result.uin = contact["PYInitial"].stringValue
                            }
                        }else {
                            result.displayName = contact["RemarkName"].stringValue
                            result.uin = contact["RemarkPYInitial"].stringValue
                        }
                    }
                    continue
                }
            }else{
                print("fetch nil")
            }
            
            // else, we create the track like this
            let newcontact = Contact(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
            newcontact.userName = contact["UserName"].stringValue
            newcontact.headImgUrl = contact["HeadImgUrl"].stringValue
            newcontact.nickName = contact["NickName"].stringValue
            newcontact.alias = contact["Alias"].stringValue
            newcontact.remarkName = contact["RemarkName"].stringValue
            newcontact.verifyFlag = contact["VerifyFlag"].intValue
            newcontact.starFriend = contact["StarFriend"].intValue
            
            
            if newcontact.remarkName == "" {
                if newcontact.nickName == "" {
                    newcontact.displayName = contact["Alias"].stringValue
                    newcontact.uin = contact["Alias"].stringValue
                }else {
                    newcontact.displayName = contact["NickName"].stringValue
                    newcontact.uin = contact["PYInitial"].stringValue
                }
            }else {
                newcontact.displayName = contact["RemarkName"].stringValue
                newcontact.uin = contact["RemarkPYInitial"].stringValue
            }
            
        }
        
        // after the loop, now we save the context
        do { try managedObjectContext!.save()
        } catch {
            print("saving: \(error)")
        }
        
    }
    
    
    func getImage(url: String,  completionHandler: (UIImage?)->Void){
        Alamofire.request(.GET, url).response(){ response in
            completionHandler(UIImage(data: response.2!, scale:1))
        }
    }
    
    
    /**
     退出登录
     */
    func userLogout() {
        self.accessToken = ""
        self.loginName = ""
        self.password = ""
        self.nickname = ""
        self.userId = ""
        self.isLogin = false
    }
    
    func resetAccessToken(token: String) {
        TSUserDefaults.setString(kAccessToken, value: token)
        if token.characters.count > 0 {
            print("token success")
        } else {
            self.userLogout()
        }
    }
}

