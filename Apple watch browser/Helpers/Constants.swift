//
//  Constants.swift
//  Apple watch browser
//
//  Created by ashutosh on 28/01/22.
//

import SwiftUI
import CoreData
struct Screen{
    static let maxWidth = UIScreen.main.bounds.width
    static let maxHeight = UIScreen.main.bounds.height
}

//extension NSManagedObjectContext {
//
//    static func mainContextForSharedStorage() -> NSManagedObjectContext {
//        let context = NSManagedObjectContext(
//          concurrencyType: .mainQueueConcurrencyType
//        )
//        context.persistentStoreCoordinator = persistentStoreCoordinator()
//        return context
//    }
//
//    static func persistentStoreCoordinator() -> NSPersistentStoreCoordinator? {
//        let conteinerURL = FileManager.sharedContainerURL()
//        let storeFileURL = conteinerURL.appendingPathComponent("myFileNmae.sqlite")
//        let persistentStoreCoordinator = NSPersistentStoreCoordinator(
//          managedObjectModel: managedObjectModel
//        )
//        do {
//            try persistentStoreCoordinator.addPersistentStore(
//              ofType: NSSQLiteStoreType,
//              configurationName: nil,
//              at: storeFileURL,
//              options: nil
//            )
//        } catch {
//            fatalError("Unable to Load Persistent Store")
//        }
//        return persistentStoreCoordinator
//    }
//}
