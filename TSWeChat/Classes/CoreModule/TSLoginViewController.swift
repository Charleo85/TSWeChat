//
//  TSLoginViewController.swift
//  TSWeChat
//
//  Created by Charlie on 5/17/16.
//  Copyright © 2016 Hilen. All rights reserved.
//

import UIKit
import Alamofire
import CoreImage
import AssetsLibrary
//import SafariServices

func delay(delay: Double, closure: ()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(),
        closure
    )
}


class TSLoginViewController: UIViewController {
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.retryButton.hidden = true
        launchButton.hidden = true

        setup()

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBOutlet weak var imgQRCode: UIImageView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var retryButton: UIButton!
    
    @IBAction func retryButton(sender: AnyObject) {
        switch retryChoice {
        case .UUID:
            break
        default:
            break
        }
            setup()
            updateStatus("扫码登录")

        self.retryButton.hidden = true
    }
    
    @IBOutlet weak var dismissButton: UIButton!
    @IBAction func dismissButton(sender: AnyObject) {
        dismiss()
    }
    
    
    @IBOutlet weak var launchButton: UIButton!
    @IBAction func launchButton(sender: AnyObject) {
        
        let softwareContext = CIContext(options:[kCIContextUseSoftwareRenderer: true])
        let cgimg = softwareContext.createCGImage(qrcodeImage, fromRect:qrcodeImage.extent)
        ALAssetsLibrary().writeImageToSavedPhotosAlbum(cgimg, metadata:qrcodeImage.properties, completionBlock:nil)
        
        
//        UIImageWriteToSavedPhotosAlbum(qrcodeImage., self, #selector(TSLoginViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        let url = ("weixin://dl/scan")
//        let url = ("weixin://dl/businessWebview/link?https://www.baidu.com")
//        delay(0.1){
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
//        }
        
    }
    
    func image(image: UIImage, didFinishSavingWithError
        error: NSErrorPointer, contextInfo:UnsafePointer<Void>) {
        
        if error != nil {
            print(error)
            // Report error to user
        }
    }
    
    var qrcodeImage: CIImage!
    
    func displayQRCodeImage() {
        let scaleX = imgQRCode.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = imgQRCode.frame.size.height / qrcodeImage.extent.size.height
        
        let transformedImage = qrcodeImage.imageByApplyingTransform(CGAffineTransformMakeScale(scaleX, scaleY))
        
        imgQRCode.image = UIImage(CIImage: transformedImage)
        launchButton.hidden = false
    }
    
    func updateStatus(status:String) {
        statusLabel.text = status
    }
    
    var retryChoice: RetryType = .UUID
    
    enum RetryType {
        case UUID
        case Login
    }

    
    func setup(){
        TSLoginInstance.getUUID(){ value in
            if let UUID = value {
                let url = "https://login.weixin.qq.com/l/\(UUID)"
                let data = url.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false)
                
                if let filter = CIFilter(name: "CIQRCodeGenerator") {
                    filter.setValue(data, forKey: "inputMessage")
                    filter.setValue("H", forKey: "inputCorrectionLevel")
                    self.qrcodeImage = filter.outputImage
                    self.displayQRCodeImage()
                    self.waitForLogin()
                }else{
                    self.retryButton.hidden = false
                    self.updateStatus("Fail to load QR code")
                }
            }else{
                self.retryChoice = .UUID
                self.retryButton.hidden = false
                self.updateStatus("Fail to fetch QR code\n 检查网络设置")
            }
        }
    }
    
    
    
    func waitForLogin(){
        delay(1.0) {
            //put your code which should be executed with a delay here
            TSLoginInstance.waitforScan(){ result in
                switch result {
                case .fail:
                    self.retryButton.hidden = false
                case .anomaly:
                    self.retryButton.hidden = false
                case .scan:
                    self.waitForLogin()
                case .success:
                    self.loginSetup()
                case .unknown:
                    self.retryButton.hidden = false
                }
                
                self.updateStatus(result.rawValue)
            }
        }
    }
    
    func dismiss() {
      self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loginSetup() {
        TSLoginInstance.login(){success in
            if success {
                self.imgQRCode.image = UserInstance.headImg!
                self.updateStatus("Hello,\n \(UserInstance.nickname!)")
                UserInstance.fetchContacts(){_ in }
                delay(1.0) {
                    self.dismiss()
                    UserInstance.syncCheck()
                }
//                delay(2.0) {
//                    UserInstance.sync()
//                    UserInstance.syncCheck()
//                }
            }else{
                TSLoginInstance.waitforScan(){ result in
                    switch result {
                    case .success:
                        self.loginSetup()
                    default:
                        self.retryButton.hidden = false
                    }
                    
                    self.updateStatus(result.rawValue)
                }
                self.retryButton.hidden = false
                self.updateStatus("connection failed")
            }
        }
    }

    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
