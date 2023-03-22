//
//  BookmarkView.swift
//  Apple watch browser
//
//  Created by ashutosh on 28/01/22.
//

import SwiftUI

struct BookmarkView: View {
    @ObservedObject var bookmarkViewModel = BookmarkViewModel()
    @ObservedObject var folder : Folder
    @ObservedObject  var model : IphoneViewModel
    @State var showAlert = false
    @State var alertMessage = ""
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
//        NavigationView{
        ZStack{
            BackgroundView()
            ScrollView(showsIndicators:false){
                    VStack(alignment:.leading){
                        if self.folder.bookmarkList != nil && !self.folder.bookmarkList!.bookmarkList.isEmpty{
                        HStack{
                            Image(systemName: "book.fill")
                            Text("BOOKMARK")
                        }
                        .foregroundColor(.gray)
                    }
                        if self.folder.bookmarkList != nil && !self.folder.bookmarkList!.bookmarkList.isEmpty{
                            ForEach(self.folder.bookmarkList!.bookmarkList){bookmark in
                                BookmarkCellView(bookmarkViewModel: self.bookmarkViewModel,folder:self.folder, bookmark: bookmark, model: self.model,showAlert:$showAlert, alertMessage: $alertMessage)
                            }
                        }
                 
                }
            }
            .onAppear(perform: {
//                for v in folder.bookmarkList!.bookmarkList{
//                    print(v.bookmarkName, v.isBookmarked)
//                }
            })
            .navigationTitle(Text(folder.folderName ?? "Unknown folder"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $bookmarkViewModel.createFolder, content: {
                CreateBookmarkView(folder : self.folder,model : self.model)
                    .environment(\.managedObjectContext, model.dataController.container.viewContext)
            })
            .alert(isPresented:$bookmarkViewModel.deleteConfirmationAlert) {
                       Alert(
                           title: Text("Delete Bookmarks"),
                           message: Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vitae eget consectetur nisl, at nisi. Maecenas elit amet pharetra nisl aliquet proin dictum. "),
                           primaryButton: .destructive(Text("Delete")) {
                               for bookmark in self.bookmarkViewModel.selectBookmarkList{
                                   self.model.deleteBookmarkInWatch(folder: self.folder,bookmark: bookmark )
                                   self.model.dataController.deleteBookmark(folder: self.folder, bookmarkToDelete: bookmark)
                               }
                               self.bookmarkViewModel.selectBookmarkList=[]
                               self.model.folderList = self.model.dataController.fetchFolders()
                               self.bookmarkViewModel.editFolder=false
                           },
                           secondaryButton: .cancel()
                       )
                   }
            .overlay(
                VStack{
                    Spacer()
                    if !self.bookmarkViewModel.selectBookmarkList.isEmpty{
                        Button {
                            self.bookmarkViewModel.deleteConfirmationAlert = true
                        } label: {
                            Text("Delete (\(self.bookmarkViewModel.selectBookmarkList.count))")
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: Screen.maxWidth*0.8,height:Screen.maxHeight*0.045)
                                .background(Color.red)
                                .cornerRadius(Screen.maxWidth*0.02)
                        }
                    }
                }
                    .padding(.bottom)
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.bookmarkViewModel.createFolder=true
                    } label: {
                      Image(systemName: "plus.circle.fill")
                    }
                }
            }
          
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack{
                        Button {
                            self.presentationMode.wrappedValue.dismiss()
                        } label: {
                          Image(systemName: "chevron.left")
                                .font(.system(size:15))
                        }
                    Button {
                        self.bookmarkViewModel.editFolder.toggle()
                        if !self.bookmarkViewModel.editFolder{
                            self.bookmarkViewModel.selectBookmarkList=[]
                            for bookmark in self.folder.bookmarkList!.bookmarkList{
                                bookmark.isSelected=false
                            }
                        }
                    } label: {
                        Text(self.bookmarkViewModel.editFolder ? "Cancel" :  "Edit")
                    }
                    }

                }
            }
           
        }

    }
}


struct BookmarkCellView : View{
    @ObservedObject var bookmarkViewModel : BookmarkViewModel
    @ObservedObject var folder : Folder
    @ObservedObject var bookmark : BookMarkModel
    @ObservedObject  var model : IphoneViewModel
    @Binding var showAlert : Bool
    @Binding var alertMessage : String
    var body : some View{
        HStack{
            
            if self.bookmarkViewModel.editFolder{
                Button{
                    bookmark.isSelected.toggle()
                    if self.bookmark.isSelected{
                        self.bookmarkViewModel.selectBookmarkList.append(self.bookmark)
                    }else{
                        self.bookmarkViewModel.selectBookmarkList.removeAll(where: { $0.id == bookmark.id})
                    }
                } label:{
                    if bookmark.isSelected{
                        ZStack{
                            Circle()
                                .fill(Color.blue)
                                .frame(width: Screen.maxWidth*0.04, height: Screen.maxWidth*0.04, alignment: .center)
                            Image(systemName :"checkmark")
                                .font(.system(size: 12))
                                .accentColor(.white)
                        }
                    }else{
                        Circle()
                            .stroke(Color.gray)
                            .frame(width: Screen.maxWidth*0.04, height: Screen.maxWidth*0.04, alignment: .center)
                    }
                }
            }
        if URL(string: bookmark.bookmarkURL) != nil{
            Link(destination: URL(string: self.bookmark.bookmarkURL)!) {
                HStack{
                
                    Image(self.bookmark.isBookmarked ? "bmSelected" : "bmNotSelected")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22, alignment: .leading)
                        .onTapGesture {
                            self.bookmark.isBookmarked.toggle()
                            self.model.dataController.update(folder: self.folder, bookmarkToUpdate: self.bookmark)
                            self.model.addFavouriteBookmarkToWatch(folder: self.folder, bookmark: self.bookmark, isFavourite: self.bookmark.isBookmarked)
                        }
                    VStack(alignment:.leading){
                        Text(bookmark.bookmarkName)
                            .font(.system(size: 16))
                            .bold()
                            .foregroundColor(.black)
                            .padding(.top,5)
                        Text(bookmark.bookmarkURL)
                            .font(.system(size: 14))
                            .foregroundColor(.gray.opacity(0.8))
                            .padding(.bottom,5)
                    }
                    .padding(.all,5)
                    Spacer()

                        Button {

                        } label: {
                            Image(systemName: "chevron.right")
                        }

                }
                .foregroundColor(.gray)
                .frame(width: self.bookmarkViewModel.editFolder ? Screen.maxWidth*0.7 : Screen.maxWidth*0.8, height: Screen.maxHeight*0.015, alignment: .center)
                .padding()
                .background(Color.white)
                .cornerRadius(Screen.maxWidth*0.02)
            }
        }else{
            HStack{
                Image(self.bookmark.isBookmarked ? "bmSelected" : "bmNotSelected")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22, alignment: .leading)
                    .onTapGesture {
                        
                        self.bookmark.isBookmarked.toggle()
                        print("calling func to amek fav")
                       
                        self.model.dataController.update(folder: self.folder, bookmarkToUpdate: self.bookmark)
                        self.model.addFavouriteBookmarkToWatch(folder: self.folder, bookmark: self.bookmark, isFavourite: self.bookmark.isBookmarked)
                      
                    }
                VStack(alignment:.leading){
                    Text(bookmark.bookmarkName)
                        .font(.system(size: 16))
                        .bold()
                        .foregroundColor(.black)
                        .padding(.top,5)
                    Text(bookmark.bookmarkURL)
                        .font(.system(size: 14))
                        .foregroundColor(.gray.opacity(0.8))
                        .padding(.bottom,5)
                }
                .padding(.all,5)
                Spacer()

                    Button {

                    } label: {
                        Image(systemName: "chevron.right")
                    }

            }
            .foregroundColor(.gray)
            .frame(width: self.bookmarkViewModel.editFolder ? Screen.maxWidth*0.7 : Screen.maxWidth*0.8, height: Screen.maxHeight*0.015, alignment: .center)
            .padding()
            .background(Color.white)
            .cornerRadius(Screen.maxWidth*0.02)
            .onTapGesture {
                self.alertMessage = bookmark.bookmarkURL
                self.showAlert = true
            }
        }
          
            
        }
 
    }
}

struct BookmarkView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkView(folder: Folder(), model : IphoneViewModel())
    }
}
