//
//  CoredataController.swift
//  Apple watch browser
//
//  Created by ashutosh on 29/01/22.
//

import SwiftUI
import CoreData

class CoredataController : ObservableObject{
    let container = NSPersistentContainer(name: "CoredataModel")
    init(){

        let storeURL = URL.storeURL(for: "group.com.appwithash.aw-browser", databaseName: "coreDatabase")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [storeDescription]

        container.loadPersistentStores { description, error in
            if let error = error{
                print("Coredata failed to load : ",error.localizedDescription)
            }else{

                print("Coredata description", self.container)
            }
        }
    }


    func fetchFolders() -> [Folder]{
        let fetchRequest = Folder.fetchRequest()

        do{
            return try container.viewContext.fetch(fetchRequest)
        }catch let error{
            print("some error occur",String(describing: error.localizedDescription))
            return []
        }

    }

    func createBookmark(folder : Folder,newBookmark : BookMarkModel){

        do{
          let newList = BookmarkList(bookmarks: [BookMarkModel]())
            for bookmark in folder.bookmarkList!.bookmarkList{
                newList.bookmarkList.append(bookmark)
            }
            newList.bookmarkList.append(newBookmark)
//            folder.bookmarkList!.bookmarkList.append(newBookmark)
            folder.bookmarkList!=newList
            folder.setValue(folder.bookmarkList!, forKey: "bookmarkList")
            try container.viewContext.save()
            print("UPDATED FOLDER -",folder.bookmarkList!.bookmarkList)
        }catch let error{
            container.viewContext.rollback()
            print("some error occur",String(describing: error.localizedDescription))
        }
    }

    func update(folder : Folder,bookmarkToUpdate : BookMarkModel){
        do{
            print(bookmarkToUpdate.isBookmarked)
            let newList = BookmarkList(bookmarks: [BookMarkModel]())
            for bookmark in folder.bookmarkList!.bookmarkList{
                if bookmark.id==bookmarkToUpdate.id{
                    newList.bookmarkList.append(bookmarkToUpdate)
                }else{
                    newList.bookmarkList.append(bookmark)
                }
            }
            folder.bookmarkList!=newList
            try container.viewContext.save()
            print("UPDATED DATA")
        }catch let error{
            container.viewContext.rollback()
            print("some error occur",String(describing: error.localizedDescription))
        }
    }
    func fetchBookmarks(folder : Folder) -> [BookMarkModel]{
        let bookmarkList = folder.bookmarkList
        if bookmarkList != nil{
            for bookmark in bookmarkList!.bookmarkList{
                print(bookmark.bookmarkName)
            }
            return bookmarkList!.bookmarkList
        }
        return []
    }

    func deleteFolder(folder : Folder){
        print("obj id to delete",folder.objectID)
        container.viewContext.delete(folder)
        do{

            print("folder deleted successfully...")
            try container.viewContext.save()
        }catch let error{
            container.viewContext.rollback()
            print("some error occur",String(describing: error.localizedDescription))
        }
    }

    func deleteBookmark(folder : Folder,bookmarkToDelete : BookMarkModel){
        do{

            let newList = BookmarkList(bookmarks: [BookMarkModel]())
            for bookmark in folder.bookmarkList!.bookmarkList{
                if bookmark.id != bookmarkToDelete.id{
                    newList.bookmarkList.append(bookmark)
            }
            }
            folder.bookmarkList!=newList
            try container.viewContext.save()
            print("Deleted Bookmark...")
        }catch let error{
            container.viewContext.rollback()
            print("some error occur",String(describing: error.localizedDescription))
        }
    }
}


//MARK: - EXTENSIONS


public extension URL {

    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }

        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}

extension DarwinNotification.Name {
    private static let appIsExtension = Bundle.main.bundlePath.hasSuffix(".appex")

    /// The relevant DarwinNotification name to observe when the managed object context has been saved in an external process.
    static var didSaveManagedObjectContextExternally: DarwinNotification.Name {
        if appIsExtension {
            return appDidSaveManagedObjectContext
        } else {
            return extensionDidSaveManagedObjectContext
        }
    }

    /// The notification to post when a managed object context has been saved and stored to the persistent store.
    static var didSaveManagedObjectContextLocally: DarwinNotification.Name {
        if appIsExtension {
            return extensionDidSaveManagedObjectContext
        } else {
            return appDidSaveManagedObjectContext
        }
    }

    /// Notification to be posted when the shared Core Data database has been saved to disk from an extension. Posting this notification between processes can help us fetching new changes when needed.
    private static var extensionDidSaveManagedObjectContext: DarwinNotification.Name {
        return DarwinNotification.Name("com.wetransfer.app.extension-did-save")
    }

    /// Notification to be posted when the shared Core Data database has been saved to disk from the app. Posting this notification between processes can help us fetching new changes when needed.
    private static var appDidSaveManagedObjectContext: DarwinNotification.Name {
        return DarwinNotification.Name("com.wetransfer.app.app-did-save")
    }
}

extension NSPersistentContainer {
    // Configure change event handling from external processes.
    func observeAppExtensionDataChanges() {
        DarwinNotificationCenter.shared.addObserver(self, for: .didSaveManagedObjectContextExternally, using: { [weak self] (_) in
            // Since the viewContext is our root context that's directly connected to the persistent store, we need to update our viewContext.
            self?.viewContext.perform {
                self?.viewContextDidSaveExternally()
            }
        })
    }
}

extension NSPersistentContainer {

    /// Called when a certain managed object context has been saved from an external process. It should also be called on the context's queue.
    func viewContextDidSaveExternally() {
        // `refreshAllObjects` only refreshes objects from which the cache is invalid. With a staleness intervall of -1 the cache never invalidates.
        // We set the `stalenessInterval` to 0 to make sure that changes in the app extension get processed correctly.
        viewContext.stalenessInterval = 0
        viewContext.refreshAllObjects()
        viewContext.stalenessInterval = -1
    }
}
