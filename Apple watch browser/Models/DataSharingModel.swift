//
//  DataSharingModel.swift
//  Apple watch browser
//
//  Created by ashutosh on 30/01/22.
//
//com.appwithash.Apple-watch-browser
import Foundation
import CoreData

class AppGroupPersistentContainer: NSPersistentContainer {

    override open class func defaultDirectoryURL() -> URL {
        var storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.ManhattanGroup")
        storeURL = storeURL?.appendingPathComponent("Manhattan.sqlite")
        return storeURL!
    }
    
}
