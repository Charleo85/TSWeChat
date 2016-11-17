//
//  Contact+CoreDataProperties.swift
//  TSWeChat
//
//  Created by Charlie on 5/31/16.
//  Copyright © 2016 Hilen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Contact {

    @NSManaged var pYInitial: String?
    @NSManaged var headImgUrl: String?
    @NSManaged var chatRoomId: NSNumber?
    @NSManaged var remarkName: String?
    @NSManaged var contactFlag: NSNumber?
    @NSManaged var verifyFlag: NSNumber?
    @NSManaged var remarkPYQuanPin: String?
    @NSManaged var pYQuanPin: String?
    @NSManaged var sex: NSNumber?
    @NSManaged var memberCount: NSNumber?
    @NSManaged var uniFriend: NSNumber?
    @NSManaged var encryChatRoomId: String?
    @NSManaged var ownerUin: NSNumber?
    @NSManaged var starFriend: NSNumber?
    @NSManaged var province: String?
    @NSManaged var nickName: String?
    @NSManaged var attrStatus: NSNumber?
    @NSManaged var keyWord: String?
    @NSManaged var snsFlag: NSNumber?
    @NSManaged var alias: String?
    @NSManaged var city: String?
    @NSManaged var hideInputBarFlag: NSNumber?
    @NSManaged var remarkPYInitial: String?
    @NSManaged var uin: String?
    @NSManaged var userName: String?
    @NSManaged var appAccountFlag: NSNumber?
    @NSManaged var displayName: String?
    @NSManaged var statues: NSNumber?

}
