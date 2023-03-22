//
//  FolderViewModel.swift
//  Apple watch browser
//
//  Created by ashutosh on 28/01/22.
//

import SwiftUI

class FolderViewModel : ObservableObject{
//    @Published var folderList : [FolderrModel] = [FolderrModel(folderName: "folder 1"), FolderrModel(folderName: "folder 1")]
//    @FetchRequest(sortDescriptors: []) var folderList : FetchedResults<Folder>
   
    @Published var createFolder = false
    @Published var editFolder = false
    @Published var showEmptyAlert = false
    @Published var navigateToBookmarkView = false
    @Published var selectFolderList : [Folder] = []
    @Published var deleteConfirmationAlert = false
    @Published var showInAppPurchasePopUp = false
    
}
