//
//  CreateBookmarkView.swift
//  Apple watch browser
//
//  Created by ashutosh on 28/01/22.
//

import SwiftUI

struct CreateBookmarkView: View {
    @ObservedObject var folder : Folder
    @State var bookmarkName = ""
    @State var bookmarkURL = ""
    @State var showEmptyAlert = false

    @ObservedObject  var model : IphoneViewModel
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView{
            VStack{
                Form{
                    Section {
                        TextField("Enter Name", text:$bookmarkName)
                    } header: {
                        Text("Bookmark name")
                    }
                    Section {
                        TextField("Enter Web Address", text:$bookmarkURL)
                    } header: {
                        Text("Bookmark Address")
                    }

                }
        }
        .navigationTitle(Text("Add New Bookmark"))
        .alert("Enter all fields", isPresented: $showEmptyAlert, actions: {
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
                    if !self.bookmarkName.isEmpty && !self.bookmarkURL.isEmpty{
                      
                        let newBookmark = BookMarkModel(id: UUID(), bookmarkName: self.bookmarkName, bookmarkURL: self.bookmarkURL, isSelected: false, isBookmarked: false)
                        self.model.dataController.createBookmark(folder: self.folder, newBookmark: newBookmark)

                        do{
                            try   model.dataController.container.viewContext.save()
                            self.model.addBookmarkToFolderInWatch(folder: self.folder, bookmark: newBookmark)
                        }catch let error{
                            print("some error occur",String(describing: error.localizedDescription))
                        }
                    self.presentationMode.wrappedValue.dismiss()
                    }else{
                        self.showEmptyAlert=true
                    }
                } label: {
                    Text("Save")
                }
            }
        }
    }
    }
}

struct CreateBookmarkView_Previews: PreviewProvider {
    static var previews: some View {
        CreateBookmarkView(folder: Folder(), model: IphoneViewModel())
    }
}
