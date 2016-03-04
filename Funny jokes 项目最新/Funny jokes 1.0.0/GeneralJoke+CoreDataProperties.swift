//
//  GeneralJoke+CoreDataProperties.swift
//  Funny jokes
//
//  Created by Lxrent46 on 15/9/22.
//  Copyright © 2015年 MACHAO. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData



extension GeneralJoke {

    @NSManaged var create_time: String?
    @NSManaged var gifid: String?
    @NSManaged var hate: String?
    @NSManaged var height: NSNumber?
    @NSManaged var id: String?
    @NSManaged var jokeImage: String?
    @NSManaged var jokeType: String?
    @NSManaged var jokeViedo: String?
    @NSManaged var love: String?
    @NSManaged var name: String?
    @NSManaged var profile_image: String?
    @NSManaged var text: String?
    @NSManaged var webUIEnable: NSNumber?
    @NSManaged var weixin_url: String?
    @NSManaged var width: NSNumber?

}
