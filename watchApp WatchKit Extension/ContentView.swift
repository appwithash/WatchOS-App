//
//  ContentView.swift
//  watchApp WatchKit Extension
//
//  Created by ashutosh on 29/01/22.
//

import SwiftUI

struct ContentView: View {
    @State var webAddress = ""
//    @ObservedObject var coredataController = CoredataController()
    @ObservedObject var viewmodel = Viewmodel()
    @State var folderToDelete : Folder!
    @State var goToBookmarkScreen = false
    @State var folder : Folder? = nil
    @AppStorage("isLoginFirst") var isLoginFirst = true
    @State var bookmarkToDelete : BookMarkModel!
    var body: some View {
        NavigationView{
            VStack{
            
                Form{
                    TextField("Enter Web Address",text:$webAddress)
                        .font(.system(size: 14))
                        .frame(width: Screen.maxWidth, height: Screen.maxWidth*0.1, alignment: .center)
                    
                    Section {
                       
                        if self.folder != nil {
                            NavigationLink(destination:  BookmarksView(model: self.viewmodel,folder: folder!),isActive: $goToBookmarkScreen) {EmptyView()}
                            }
                      
                        ForEach(self.viewmodel.folders,id:\.self){folder in
                            if folder.folderName != "Favourite Bookmarks"{
                            HStack{
                                    
                                Text(folder.folderName!)
                                .font(.system(size: 14))
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13))
                                    .onTapGesture {
                                        self.folder = folder
                                        print("tapped on blist")
                                        for bookmark in folder.bookmarkList!.bookmarkList{
                                            print("bookmark",bookmark.bookmarkName)
                                        }
                                        self.goToBookmarkScreen=true
                                        
                                        
                                    }
                            }
                            .padding(.top)
                            }
                        }
                        .onDelete { index in
                            self.folderToDelete=self.viewmodel.folders[index.first!]
                            self.viewmodel.deleteFolderOnIphone(folder: self.folderToDelete)
                            self.viewmodel.coredataController.deleteFolder(folder: self.viewmodel.folders[index.first!])
                            self.viewmodel.folders.remove(atOffsets: index)
                        }
                        
                     
                    } header: {
                        HStack{
                            Image(systemName: "book.fill")
                            Text("Bookmarks Folder")
                                .textCase(.none)
                                .font(.system(size: 13))
                        }
                        .padding(.top)
                    }
                    .padding(.bottom)
                    
                    Section {
                        if !self.viewmodel.folders.isEmpty && viewmodel.folders.contains(where:{$0.folderName == "Favourite Bookmarks"}){
                                ForEach(viewmodel.folders.filter({$0.folderName == "Favourite Bookmarks"})[0].bookmarkList!.bookmarkList){bookmark in
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
                                                    }
                                            }
                                    }else{
                                        Link(destination: URL(string: bookmark.bookmarkURL)!, label: {
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
                                                    }
                                            }
                                        })
                                    }
                                } .onDelete { indexSet in
                                    self.bookmarkToDelete=viewmodel.folders.filter({$0.folderName == "Favourite Bookmarks"})[0].bookmarkList!.bookmarkList[indexSet.first!]
                                    self.viewmodel.removeBookmarkfromFavouriteOnIphone( bookmark: self.bookmarkToDelete)
                                    self.viewmodel.coredataController.deleteBookmark(folder: viewmodel.folders.filter({$0.folderName == "Favourite Bookmarks"})[0], bookmarkToDelete: bookmarkToDelete)
                                    viewmodel.folders.filter({$0.folderName == "Favourite Bookmarks"})[0].bookmarkList!.bookmarkList=self.viewmodel.coredataController.fetchBookmarks(folder: viewmodel.folders.filter({$0.folderName == "Favourite Bookmarks"})[0])
                                    self.viewmodel.folders = self.viewmodel.coredataController.fetchFolders()
                                }
                                }
                               
                    
                    } header: {
                        HStack{
                            Image("bmSelected")
                                .resizable()
                                .frame(width: 15, height: 15)
                            Text("Favourite Bookmarks")
                                .textCase(.none)
                                .font(.system(size: 13))
                        }
                        .padding(.bottom)
                    }
                   

                   
                }
                
              Spacer()
            }
            .navigationTitle(Text("AWBrowser"))
            .onAppear{
                self.folder=nil
                print(self.viewmodel.session.isReachable)
                self.viewmodel.folders=self.viewmodel.coredataController.fetchFolders()
                print("Folders",self.viewmodel.folders.count)
                if isLoginFirst{
                    self.isLoginFirst=false
                    let favouriteFolder = Folder(context: self.viewmodel.coredataController.container.viewContext)
                    favouriteFolder.folderName="Favourite Bookmarks"
                    favouriteFolder.id=UUID()
                    favouriteFolder.isSelected=false
                    favouriteFolder.bookmarkList = BookmarkList(bookmarks: [BookMarkModel]())
                    self.viewmodel.favouriteFolder=favouriteFolder
                    do{
                        try self.viewmodel.coredataController.container.viewContext.save()
                    }catch let error{
                        print("some error occur",String(describing: error.localizedDescription))
                    }
                    print("fav folder set")
                }
            }
            
        }
    }
}

struct Screen{
    static let maxWidth : CGFloat = 170
    static let maxHeight : CGFloat = 170
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
