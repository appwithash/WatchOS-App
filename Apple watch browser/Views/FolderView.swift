//
//  ContentView.swift
//  Apple watch browser
//
//  Created by ashutosh on 28/01/22.
//

import SwiftUI

struct FolderView: View {
    @ObservedObject var folderViewModel = FolderViewModel()
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var inAppPurchaseViewModel = InAppPurchaseViewModel()
    @ObservedObject var model = IphoneViewModel()
    @State var reachable = "No"
    @State var folder : Folder? = nil
    @AppStorage("is_monthly_purchased") var isMonthlyPurchased = false
    @AppStorage("is_onetime_purchased") var isOneTimePurchased = false
    var body: some View {
        
        NavigationView{
            ZStack{
                
            BackgroundView()
                ScrollView{
                        VStack(alignment:.leading){
                            if !self.model.folderList.isEmpty{
                            HStack{
                                Image(systemName: "folder.fill")
                                Text("FOLDER")
                            }
                            .foregroundColor(.gray)
                            .padding(.bottom)
                          
                        }
                            VStack {
                                if self.folder != nil {
                                    NavigationLink(destination:  BookmarkView(folder: folder!, model: self.model),isActive: $folderViewModel.navigateToBookmarkView) {EmptyView()}
                                    }
                                }.hidden()
                        ForEach(self.model.folderList){ folder in
                            Button {
                                self.folder=folder
                                print("sending msg to watch")
                            
                            } label: {
                                FolderCellView(folderViewModel: self.folderViewModel, folder: folder, currentFolder: $folder)
                            }
                        }
                    }
                        
                }
                .onAppear(perform: {
                    
                    print(self.model.session.isReachable)
                    self.folder=nil
                    if self.model.folderList.isEmpty{
                        self.model.folderList=model.dataController.fetchFolders()
                    }
                  
                    print("Folder :",self.model.folderList)
                })
            .navigationTitle(Text("Apple Watch Browser"))
            .sheet(isPresented: $folderViewModel.createFolder, content: {
                CreateFolderView(folderViewModel: self.folderViewModel,model : self.model)
                    .environment(\.managedObjectContext, model.dataController.container.viewContext)
                  
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        self.folderViewModel.editFolder.toggle()
                        if !self.folderViewModel.editFolder{
                            self.folderViewModel.selectFolderList=[]
                            for folder in self.model.folderList{
                                folder.isSelected=false
                            }
                        }
                    } label: {
                        Text(self.folderViewModel.editFolder ? "Cancel" :  "Edit")
                    }

                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {

                        if self.model.folderList.count < 2 {
                        self.folderViewModel.createFolder=true
                        }else if self.isOneTimePurchased || self.isMonthlyPurchased{
                            self.folderViewModel.createFolder=true
                        }else{
                            self.inAppPurchaseViewModel.showInAppPurchaseView=true
                        }
                    } label: {
                      Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .alert(isPresented:$folderViewModel.deleteConfirmationAlert) {
                       Alert(
                           title: Text("Delete Folder"),
                           message: Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vitae eget consectetur nisl, at nisi. Maecenas elit amet pharetra nisl aliquet proin dictum. "),
                           primaryButton: .destructive(Text("Delete")) {
                               for folder in self.folderViewModel.selectFolderList{
                                   self.model.deleteFolderInWatch(newFolder: folder)
                                   self.model.dataController.deleteFolder(folder: folder)
                               }
                               self.folderViewModel.selectFolderList=[]
                               self.model.folderList = self.model.dataController.fetchFolders()
                               self.folderViewModel.editFolder=false
                           },
                           secondaryButton: .cancel()
                       )
                   }
            .fullScreenCover(isPresented: $inAppPurchaseViewModel.showInAppPurchaseView, content: {
                InAppPurchaseView(inAppPurchaseViewModel: self.inAppPurchaseViewModel)
            })
            .overlay(
                VStack{
                    Spacer()
                    if !self.folderViewModel.selectFolderList.isEmpty{
                        Button {
                            self.folderViewModel.deleteConfirmationAlert = true
                        } label: {
                            Text("Delete (\(self.folderViewModel.selectFolderList.count))")
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
        }
        }
    }
}

struct FolderCellView : View{
    @ObservedObject var folderViewModel : FolderViewModel
    @ObservedObject var folder : Folder
    @Binding var currentFolder : Folder?
    var body : some View{
        
        HStack{
            if self.folderViewModel.editFolder{
                Button{
                    folder.isSelected.toggle()
                    if self.folder.isSelected{
                        self.folderViewModel.selectFolderList.append(self.folder)
                    }else{
                        self.folderViewModel.selectFolderList.removeAll(where: { $0.id == folder.id})
                    }
                } label:{
                    if folder.isSelected{
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
            HStack{
              
                Text(folder.folderName ?? "Unknow folder")
                Spacer()
               
                    Button {
                        self.currentFolder=folder
                        self.folderViewModel.navigateToBookmarkView=true
                      
                    } label: {
                        Image(systemName: "chevron.right")
                    }
            
            }
            .foregroundColor(.gray)
            .frame(width: self.folderViewModel.editFolder ? Screen.maxWidth*0.7 : Screen.maxWidth*0.8, height: Screen.maxHeight*0.015, alignment: .center)
            .padding()
            .background(Color.white)
            .cornerRadius(Screen.maxWidth*0.02)
           
        }
      
 
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FolderView()
    }
}
