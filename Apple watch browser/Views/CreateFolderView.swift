//
//  CreateFolderView.swift
//  Apple watch browser
//
//  Created by ashutosh on 28/01/22.
//

import SwiftUI

struct CreateFolderView: View {
    @ObservedObject var folderViewModel : FolderViewModel
    @State var folderName = ""
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var model = IphoneViewModel()
    var body: some View {
        NavigationView{
            VStack{
                Form{
                    Section {
                        TextField("Folder Name", text:$folderName)
                    } header: {
                        Text("Folder name")
                    }

                }
        }
        .navigationTitle(Text("Add New Folder"))
        .alert("Enter folder name", isPresented: $folderViewModel.showEmptyAlert, actions: {
            Button("OK", role: .cancel) { }
        })
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Cancel")
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if !self.folderName.isEmpty{
                        let newFolder = Folder(context: self.model.dataController.container.viewContext)
                        newFolder.id = UUID()
                        newFolder.folderName=self.folderName
                        newFolder.isSelected=false
                        newFolder.bookmarkList=BookmarkList(bookmarks: [BookMarkModel]())
                        do{
                            try self.model.dataController.container.viewContext.save()
                            print("data saved",self.model.dataController.container.viewContext.insertedObjects)
                            self.model.folderList=self.model.dataController.fetchFolders()
                        }catch let error{
                            print("some error occur",String(describing: error.localizedDescription))
                        }
                      
                        print("FolderList",model.folderList)
                        print("Folder",newFolder.objectID)
                        self.model.messageToWatch(newFolder: newFolder)
                    self.presentationMode.wrappedValue.dismiss()
                    }else{
                        self.folderViewModel.showEmptyAlert=true
                    }
                } label: {
                    Text("Save")
                }
            }
        }
    }
    }
}

struct CreateFolderView_Previews: PreviewProvider {
    static var previews: some View {
        CreateFolderView(folderViewModel: FolderViewModel(), model: IphoneViewModel())
    }
}
