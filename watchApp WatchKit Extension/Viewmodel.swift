//
//  Viewmodel.swift
//  watchApp WatchKit Extension
//
//  Created by ashutosh on 29/01/22.
//

import SwiftUI
import WatchConnectivity

class Viewmodel : NSObject,  WCSessionDelegate, ObservableObject{
    @Published var folders : [Folder] = []
    @Published var favouriteFolder : Folder?
        var session: WCSession!
    @ObservedObject var coredataController = CoredataController()
    
    // Hold the KVO observers as we want to keep oberving in the extension life time.
    //
    private var activationStateObservation: NSKeyValueObservation?
    private var hasContentPendingObservation: NSKeyValueObservation?

    // An array to keep the background tasks.
    //
    private var wcBackgroundTasks = [WKWatchConnectivityRefreshBackgroundTask]()
    
    
    override init(){
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session.delegate = self
            session.activate()
            print("activated session...")
        }else{
            print("not able to activate session")
        }
        if self.favouriteFolder == nil{
           
        }
        activationStateObservation = WCSession.default.observe(\.activationState) { _, _ in
            DispatchQueue.main.async {
                self.completeBackgroundTasks()
            }
        }
        hasContentPendingObservation = WCSession.default.observe(\.hasContentPending) { _, _ in
            DispatchQueue.main.async {
                self.completeBackgroundTasks()
            }
        }
    }
    
    func deleteFolderOnIphone(folder : Folder){
        if self.session.isReachable{
        let messageToSend = [
            "folderName" : folder.folderName!,
            "isSelected" : folder.isSelected,
            "id" : folder.id!.uuidString
        ] as [String : Any]
        session.sendMessage(messageToSend, replyHandler: { replyMessage in
            print("message send to iphone os success")
        }, errorHandler: {error in
            print(error.localizedDescription)
        })
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("called 2")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
       print("called 1")
        //CREATING FOLDER
        if  session.isReachable{
        let folderName = message["folderName"] as? String
        let isSelected = message["isSelected"] as? Bool
        let id = message["id"] as? String
        if folderName != nil{
            print("New Folder : ",folderName!)
        }
        //DELETING FOLDER
        let deleteFolderId = message["DeleteFolderId"] as? String
        if deleteFolderId != nil{
            print("deleteFolderId : ",deleteFolderId!)
        }
        //ADD NEW BOOKMARK
        let addBookmarkFolderId = message["addBookmarkFolderId"] as? String
        if addBookmarkFolderId != nil{
            print("addBookmarkFolderId : ",addBookmarkFolderId!)
        }
        
        //ADD FAVOURITE BOOKMARK
        let favouriteBookmarkId = message["favouriteBookmarkId"] as? String
        let favouriteBookmarkFolderId = message["favouriteBookmarkFolderId"] as? String
        let isFavourite = message["isFavourite"] as? Bool
        if favouriteBookmarkId != nil{
            print("favouriteBookmarkId : ",favouriteBookmarkId!)
        }
        DispatchQueue.main.async {
           
            //CREATING FOLDER
            if folderName != nil && isSelected != nil && id != nil{
           let newFolder = Folder(context: self.coredataController.container.viewContext)
           newFolder.id=UUID(uuidString: id!)
           newFolder.folderName=folderName!
           newFolder.bookmarkList=BookmarkList(bookmarks: [BookMarkModel]())
           newFolder.isSelected=isSelected!
           self.folders.append(newFolder)
           do{
               try self.coredataController.container.viewContext.save()
               print("data saved",self.coredataController.container.viewContext.insertedObjects)
               self.folders=self.coredataController.fetchFolders()
               print("FOlders count :",self.folders.count)
           }catch let error{
               print("some error occur",String(describing: error.localizedDescription))
           }
           }
            
            //DELETING FOLDER
            
            else if deleteFolderId != nil && self.folders.contains(where: {$0.id == UUID(uuidString: deleteFolderId!)}){
                print("folder to delete in watch :" ,deleteFolderId!)
                self.coredataController.deleteFolder(folder: self.folders.filter({$0.id == UUID(uuidString: deleteFolderId!)})[0])
                self.folders=self.coredataController.fetchFolders()
            }
            //ADD NEW BOOKMARK
            else if addBookmarkFolderId != nil &&  self.folders.contains(where: {$0.id==UUID(uuidString: addBookmarkFolderId!)}){
               
                let bookmarkId = message["bookmarkId"] as! String
                let bookmarkName = message["bookmarkName"] as! String
                let bookmarkURL = message["bookmarkURL"] as! String
                let isBookmarked = message["isBookmarked"] as! Bool
                
                self.coredataController.createBookmark(folder: self.folders.filter({ $0.id==UUID(uuidString: addBookmarkFolderId!)})[0], newBookmark: BookMarkModel(id: UUID(uuidString: bookmarkId)!, bookmarkName: bookmarkName, bookmarkURL: bookmarkURL, isSelected: false, isBookmarked: isBookmarked))
            }
            
            //ADD BOOKMARK TO FAVOURITE
            else if favouriteBookmarkFolderId != nil && self.folders.contains(where: {$0.id == UUID(uuidString: favouriteBookmarkFolderId!)}){
                print("making bookmark fav....")
                if self.folders.filter({$0.id == UUID(uuidString: favouriteBookmarkFolderId!)})[0].bookmarkList!.bookmarkList.contains(where: {$0.id == UUID(uuidString: favouriteBookmarkId!)}){
                if isFavourite!{
                    let newFavBookmark = self.folders.filter({$0.id == UUID(uuidString: favouriteBookmarkFolderId!)})[0].bookmarkList!.bookmarkList.filter({$0.id == UUID(uuidString: favouriteBookmarkId!)})[0]
                    print("fav bm ",newFavBookmark)
                    self.coredataController.createBookmark(folder: self.folders.filter({$0.folderName == "Favourite Bookmarks"})[0], newBookmark: newFavBookmark)
                    for bookmark in self.folders.filter({$0.folderName == "Favourite Bookmarks"})[0].bookmarkList!.bookmarkList{
                        print(bookmark.bookmarkName)
                    }
                    self.folders=self.coredataController.fetchFolders()
                }else{
                        self.folders.filter({$0.folderName == "Favourite Bookmarks"})[0].bookmarkList!.bookmarkList.removeAll(where: {$0.id == UUID(uuidString: favouriteBookmarkId!)})
                    self.folders=self.coredataController.fetchFolders()
                }
                }
            }
            
            let removeBookmarkId = message["removeBookmarkId"] as? String
            let removeBookmarkFolderId = message["removeBookmarkFolderId"] as? String
            if removeBookmarkId != nil{
                print("removeBookmarkId : ",removeBookmarkId!)
            }
            if removeBookmarkId != nil{
                if self.folders.filter({$0.folderName == "Favourite Bookmarks"})[0].bookmarkList!.bookmarkList.contains(where: {$0.id == UUID(uuidString: removeBookmarkId!)}){
                    self.coredataController.deleteBookmark(folder: self.folders.filter({$0.folderName == "Favourite Bookmarks"})[0], bookmarkToDelete: self.folders.filter({$0.folderName == "Favourite Bookmarks"})[0].bookmarkList!.bookmarkList.filter({$0.id == UUID(uuidString: removeBookmarkId!)})[0])
                }
                self.coredataController.deleteBookmark(folder: self.folders.filter({$0.id == UUID(uuidString: removeBookmarkFolderId!)})[0], bookmarkToDelete: self.folders.filter({$0.id == UUID(uuidString: removeBookmarkFolderId!)})[0].bookmarkList!.bookmarkList.filter({$0.id == UUID(uuidString: removeBookmarkId!)})[0])
                self.folders=self.coredataController.fetchFolders()
            }
        }
        }
       
    }
    
    func deleteBookmarkOnIphone(folder : Folder,bookmark : BookMarkModel){
        if self.session.isReachable{
        self.coredataController.deleteBookmark(folder: self.folders.filter({$0.folderName == "Favourite Bookmarks"})[0], bookmarkToDelete: bookmark)
        self.folders=self.coredataController.fetchFolders()
        let messageToSend = [
            "deleteBookmarkFolderId" : folder.id!.uuidString,
            "deleteBookmarkId" : bookmark.id.uuidString,
        ] as [String : Any]
        session.sendMessage(messageToSend, replyHandler: { replyMessage in
            print("message send to iphone os success")
        }, errorHandler: {error in
            print(error.localizedDescription)
        })
        }
    }
    
    func removeBookmarkfromFavouriteOnIphone(bookmark : BookMarkModel){
        if self.session.isReachable{
        let messageToSend = [
            "removeBookmarkFavouriteId" : bookmark.id.uuidString,
        ] as [String : Any]
        session.sendMessage(messageToSend, replyHandler: { replyMessage in
            print("message send to iphone os success")
        }, errorHandler: {error in
            print(error.localizedDescription)
        })
        }
    }
    
    
        func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
            
        }
        
    func completeBackgroundTasks() {
        guard !wcBackgroundTasks.isEmpty else { return }

        guard WCSession.default.activationState == .activated,
            WCSession.default.hasContentPending == false else { return }
        
        wcBackgroundTasks.forEach { $0.setTaskCompletedWithSnapshot(true) }
        
        // Use Logger to log the tasks for debug purpose. A real app may remove the log
        // to save the precious background time.
        //
        Logger.shared.append(line: "\(#function):\(wcBackgroundTasks) was completed!")

        // Schedule a snapshot refresh if the UI is updated by background tasks.
        //
        let date = Date(timeIntervalSinceNow: 1)
        WKExtension.shared().scheduleSnapshotRefresh(withPreferredDate: date, userInfo: nil) { error in
            
            if let error = error {
                print("scheduleSnapshotRefresh error: \(error)!")
            }
        }
        wcBackgroundTasks.removeAll()
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        print("handling background tasks")
        for task in backgroundTasks {
            
            // Use Logger to log the tasks for debug purpose. A real app may remove the log
            // to save the precious background time.
            //
            if let wcTask = task as? WKWatchConnectivityRefreshBackgroundTask {
                wcBackgroundTasks.append(wcTask)
                Logger.shared.append(line: "\(#function):\(wcTask.description) was appended!")
            } else {
                task.setTaskCompletedWithSnapshot(true)
                Logger.shared.append(line: "\(#function):\(task.description) was completed!")
            }
        }
        completeBackgroundTasks()
    }
 
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        print("Recieved user info...")
    }
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("Recieved user info...")
    }
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("Recieved application context info...")
    }
    
    
}
//}
