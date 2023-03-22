//
//  BookmarksView.swift
//  watchApp WatchKit Extension
//
//  Created by ashutosh on 31/01/22.
//

import SwiftUI

struct BookmarksView: View {
    @ObservedObject var model :  Viewmodel
    @ObservedObject var folder : Folder
    @Environment(\.presentationMode) var presentationMode
    @State var showAlert = false
    @State var bookmarkToDelete : BookMarkModel!
    @State var alertMessage = ""
    var body: some View {
        VStack{
           
            Form{
                Section {
                    if self.folder.bookmarkList != nil{
                    ForEach(self.folder.bookmarkList!.bookmarkList,id:\.self){ bookmark in
                        if URL(string: bookmark.bookmarkURL) == nil{
                                HStack{
                                    Text(bookmark.bookmarkURL)
                                        .font(.system(size: 14))
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .foregroundColor(.gray)
                                  
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                        .onTapGesture {
                                            self.alertMessage = bookmark.bookmarkURL
                                            self.showAlert = true
                                        }
                                }
                        }else{
//                            Link(destination: URL(string: bookmark.bookmarkURL)!, label: {
                                HStack{
                                    Text(bookmark.bookmarkURL)
                                        .font(.system(size: 14))
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .foregroundColor(.gray)
                                  
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                        .onTapGesture {
                                            print("tapped on blist")
                                            for bookmark in folder.bookmarkList!.bookmarkList{
                                                print("bookmark",bookmark.bookmarkName)
                                            }
                                        }
                                }
                                .onTapGesture {
//                                    UIApplication.shared.open(url)
                                    print("tapped")
                                    WKExtension.shared().openSystemURL(URL(string: bookmark.bookmarkURL)!)
                                }
//                            })
                        }
                   
                    }.onDelete { indexSet in
                        self.bookmarkToDelete=self.folder.bookmarkList!.bookmarkList[indexSet.first!]
                        self.model.deleteBookmarkOnIphone(folder: self.folder, bookmark: self.bookmarkToDelete)
                        self.model.coredataController.deleteBookmark(folder: self.folder, bookmarkToDelete: bookmarkToDelete)
                        self.folder.bookmarkList?.bookmarkList=self.model.coredataController.fetchBookmarks(folder: folder)
                    }
                }
                } header: {
                    HStack{
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14))
                            .onTapGesture {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        Image(systemName: "book.fill")
                        Text("BookMarks Pages")
                            .textCase(.none)
                            .font(.system(size: 13))
                    }
                    .padding(.top)
                }

            }.alert(isPresented: $showAlert) {
                Alert(title: Text("Wrong URL"), message: Text("\(alertMessage) is not a valid URL."))

            }
        }
      
    }
}

struct BookmarksView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarksView(model: Viewmodel(), folder: Folder())
    }
}
