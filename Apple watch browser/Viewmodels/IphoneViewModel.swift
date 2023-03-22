//
//  ViewModelWatch.swift
//  Apple watch browser
//
//  Created by ashutosh on 30/01/22.
//


import Foundation
import WatchConnectivity
import SwiftUI

class IphoneViewModel : NSObject,  WCSessionDelegate,ObservableObject{
    var session: WCSession!
    @Published var folderList : [Folder] = []
    @Published var itemToDeleteList : [Folder] = []
    @ObservedObject var dataController = CoredataController()
    @Published var msgFromWatch = ""
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
    }
    
    
    func messageToWatch(newFolder : Folder){
        if self.session.isReachable{
        print("activated session...",session.isPaired)
        print("activated session...",session.isReachable)
        let messageToSend = [
            "folderName" : newFolder.folderName!,
            "isSelected" : newFolder.isSelected,
            "id" : newFolder.id!.uuidString,
        ] as [String : Any]
          
            session.transferUserInfo(messageToSend)
            do{
                try session.updateApplicationContext(messageToSend)
                print("APPLICATION CONTEXT send successfully")
            }catch let error{
                print("APPLICATION CONTEXT ERROR",error.localizedDescription)
            }
        session.sendMessage(messageToSend, replyHandler: { replyMessage in
            print("message send to watch os success")
        }, errorHandler: {error in
            print(error)
        })
        }
    }
    
    func deleteFolderInWatch(newFolder : Folder){
        if self.session.isReachable{
        let messageToSend = [
            "DeleteFolderId" : newFolder.id!.uuidString,
        ] as [String : Any]
        

        session.sendMessage(messageToSend, replyHandler: { replyMessage in
            print("message send to watch os success")
        }, errorHandler: {error in
            print(error)
        })
        }
    }
    
    func addBookmarkToFolderInWatch(folder : Folder,bookmark : BookMarkModel){
        if self.session.isReachable{
        let messageToSend = [
            "addBookmarkFolderId" : folder.id!.uuidString,
            "bookmarkId" : bookmark.id.uuidString,
            "bookmarkName" : bookmark.bookmarkName,
            "isBookmarked" : bookmark.isBookmarked,
            "bookmarkURL" : bookmark.bookmarkURL
        ] as [String : Any]
        

        session.sendMessage(messageToSend, replyHandler: { replyMessage in
            print("message send to watch os success")
        }, errorHandler: {error in
            print(error)
        })
        }
    }
    
    func addFavouriteBookmarkToWatch(folder : Folder,bookmark : BookMarkModel,isFavourite : Bool){
        if self.session.isReachable{
        print("ADDING/REVING FAV FROM WATCH ", isFavourite)
        let messageToSend = [
            "favouriteBookmarkId" : bookmark.id.uuidString,
            "favouriteBookmarkFolderId" : folder.id!.uuidString,
            "isFavourite" : isFavourite
        ] as [String : Any]
        

        session.sendMessage(messageToSend, replyHandler: { replyMessage in
            print("message send to watch os success")
        }, errorHandler: {error in
            print(error)
        })
        }
    }
    
    func deleteBookmarkInWatch(folder: Folder,bookmark : BookMarkModel){
        if self.session.isReachable{
        let messageToSend = [
            "removeBookmarkId" : bookmark.id.uuidString,
            "removeBookmarkFolderId" : folder.id!.uuidString
        ] as [String : Any]
        session.sendMessage(messageToSend, replyHandler: { replyMessage in
            print("message send to watch os success")
        }, errorHandler: {error in
            print(error)
        })
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if self.session.isReachable{
        let id = message["id"] as? String
        let deleteBookmarkFolderId = message["deleteBookmarkFolderId"] as? String
        let deleteBookmarkId = message["deleteBookmarkId"] as? String
        let removeBookmarkFavouriteId = message["removeBookmarkFavouriteId"] as? String
        DispatchQueue.main.async {
            //DELETE FOLDER
            if id != nil && self.folderList.contains(where: {$0.id == UUID(uuidString: id!)}){
            let uuid = UUID(uuidString: id!)
            self.dataController.deleteFolder(folder: self.folderList.filter({$0.id == uuid})[0])
            self.folderList=self.dataController.fetchFolders()
            }
            //DELETE BOOKMARK
            if deleteBookmarkFolderId != nil && self.folderList.contains(where: {$0.id == UUID(uuidString: deleteBookmarkFolderId!)}){
                let fromFolder = self.folderList.filter({$0.id == UUID(uuidString: deleteBookmarkFolderId!)})[0]
                if fromFolder.bookmarkList!.bookmarkList.contains(where: {$0.id == UUID(uuidString: deleteBookmarkId!)}){
                self.dataController.deleteBookmark(folder: fromFolder, bookmarkToDelete: fromFolder.bookmarkList!.bookmarkList.filter({$0.id == UUID(uuidString: deleteBookmarkId!)})[0])
                }
            }
            if removeBookmarkFavouriteId != nil {
                let favBookmarkUUID = UUID(uuidString: removeBookmarkFavouriteId!)
                for folder in self.folderList{
                    for bookmark in folder.bookmarkList!.bookmarkList{
                        if bookmark.id == favBookmarkUUID{
                            bookmark.isBookmarked=false
                            self.dataController.update(folder: folder, bookmarkToUpdate: bookmark)
                        }
                    }
                }
                self.folderList=self.dataController.fetchFolders()
            }
        }
        }
    }
    
  
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("recieved AC : ", applicationContext)
    }
    
}
