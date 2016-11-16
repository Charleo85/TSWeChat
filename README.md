<a href="https://swift.org/"><img src="https://img.shields.io/badge/Swift-compatible-orange.svg"></a>
<img src="https://img.shields.io/badge/platform-iOS%208.0%2B-ff69b4.svg">
<a href="https://github.com/hilen/TSWeChat/blob/master/LICENSE"><img src="https://img.shields.io/badge/license-MIT-green.svg?style=flat"></a>
<a href="http://twitter.com/wjb665"><img src="https://img.shields.io/badge/twitter-@wjb665-blue.svg?style=flat"></a>

WuChat - An alternative [WeChat](https://itunes.apple.com/cn/app/wei/id414478124) mobile client. Written in Swift 2.3. 

## Requirements
- [Cocoapods](https://github.com/CocoaPods/CocoaPods) 1.0.0 +
- iOS 8.0+ / Mac OS X 10.9+
- Xcode 8


## Features
- Send your rich text, expression, image and voice.
- The cell image in `TSChatImageCell` is drawn by using `Mask Layer` . The chat background can be changed freely so that UI will look perfect.
- Custom expression keyboard, custom tool keyboard.
- Audio `wav` files can be automatically converted into `amr` files which facilite file transfer to Android devices. Both of the two type files have been doing cache.
- When you tap the `TSChatVoiceCell`. It will automatically check the cache and download it by [Alamofire](https://github.com/Alamofire/Alamofire). 
- When you send the image, it will be stored locally by using the caching mechanism of [Kingfisher](https://github.com/onevcat/Kingfisher). After successfully uploaded, it will be automatically modified to image link's `MD5` value file name.
- The data are loaded from the JSON file. All the `Models` are created via [ObjectMapper](https://github.com/Hearst-DD/ObjectMapper) which is easy to convert model objecWu (classes and structs) from JSON.



## Preview
Run `pod install` in the `Terminal` and then run `WuWeChat.xcworkspace` to see all the views.<br><br>
![](images/preview1.gif)

## Directory

Directory name|Introduction
---|---
Classes| To deposit different folders like `ViewController`, `View`. Sub directories are divided based on business logic, Such as `Message`,`Address Book`,`Tabbar`,`Me`,`Login` and etc, divided according to their functions. 
Classes/CoreModule| To deposit encapsulation of business logic of basic classes, like HttpManager, Models, ApplicationManager and etc.
General|To deposit reused `View and Class` related with business logic, such as color extension.
Helpers|Non-business logic extension, such as: `UIView+Extension.swift`, `UIImage+Resize.swift` and etc.
Macro|To deposit macros and constant definitions used in the whole application, such as ` Notifications ` name , and  the third party librarie's keys.
Resources| Resources. Such as `Assets.xcassets`, `Media.xcassets`, `JSON files`, `media files`, `plist files` and etc.
Vendor| To deposit the third party liabraries that cannot be installed by `Cocoapods`.
Supporting Files| To deposit the original files
Scripts| APNs script, export IPA file script and etc.
Sketch| To deposit the original Sketch files. All the recourses in the project are come from the WeChat IPA folder, but some images I can't find. So I decided to do it myself. Yeah, I love design, sometimes coder become a designer is feeling good. XD


## To Do
- The custom photo album
- WeChat custom ActionSheet
- Long press the chat cell
- The image viewer
- Address book
- GIF image cell 
- QRCodeViewController
- ShakeViewController
- Send my address
- Video cell 
- TimelineViewController
- Multilanguage support

##Acknowledgement
- Special to [hilen](https://github.com/hilen/), forked from [TSWeChat](https://github.com/hilen/TSWeChat/)
- Vendors
[Podfile](https://github.com/Charleo85/WuChat/blob/master/Podfile)




