//
//  FolderModel.swift
//  Apple watch browser
//
//  Created by ashutosh on 28/01/22.
//

import SwiftUI



class FolderrModel : Identifiable, ObservableObject{
    var id = UUID()
    @Published var folderName : String
    @Published var bookmarkList : [BookMarkModel] = []
    @Published var isSelected : Bool = false
    
    init(folderName : String){
        self.folderName=folderName
    }
}

public class BookMarkModel : NSObject,NSCoding, Identifiable,ObservableObject{
    
    public var id = UUID()
    @Published var bookmarkName : String = ""
    @Published var bookmarkURL : String = ""
    @Published var isSelected : Bool = false
    @Published var isBookmarked : Bool = false
    enum Key : String{
        case id = "id"
        case bookmarkName = "bookmarkName"
        case bookmarkURL = "bookmarkURL"
        case isSelected = "isSelected"
        case isBookmarked = "isBookmarked"
    }
    
    init(id:UUID,bookmarkName : String,bookmarkURL :String, isSelected : Bool,isBookmarked : Bool){
        self.id=id
        self.isBookmarked=isBookmarked
        self.bookmarkName=bookmarkName
        self.bookmarkURL=bookmarkURL
        self.isSelected=isSelected
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(id, forKey: Key.id.rawValue)
        coder.encode(bookmarkName, forKey: Key.bookmarkName.rawValue)
        coder.encode(bookmarkURL, forKey: Key.bookmarkURL.rawValue)
        coder.encode(isBookmarked, forKey: Key.isBookmarked.rawValue)
        coder.encode(isSelected, forKey: Key.isSelected.rawValue)
    }
    
    public required convenience init?(coder: NSCoder) {
        let mId = coder.decodeObject(forKey: Key.id.rawValue) as! UUID
       let mBookmarkName = coder.decodeObject(forKey: Key.bookmarkName.rawValue) as! String
        let mBookmarkURL = coder.decodeObject(forKey: Key.bookmarkURL.rawValue) as! String
        let mIsBookmarked = coder.decodeBool(forKey: Key.isBookmarked.rawValue)
        let mIsSelected = coder.decodeBool(forKey: Key.isSelected.rawValue)
        self.init(id:mId,bookmarkName: mBookmarkName, bookmarkURL: mBookmarkURL, isSelected: mIsSelected, isBookmarked: mIsBookmarked)
    }
   
}

public class BookmarkList :NSObject,NSSecureCoding, NSCoding, Identifiable,ObservableObject{
    public static var supportsSecureCoding: Bool = true
    

    
    @Published var bookmarkList : [BookMarkModel] = []
    enum Key :String{
        case bookmarkList = "bookmarkList"
    }
    
     init(bookmarks : [BookMarkModel]) {
        self.bookmarkList = bookmarks
    }
    public func encode(with coder: NSCoder) {
        coder.encode(self.bookmarkList,forKey: Key.bookmarkList.rawValue)
    }
    
    public required convenience init?(coder: NSCoder) {
        let bookmarkList = coder.decodeObject(forKey: Key.bookmarkList.rawValue) as! [BookMarkModel]
        self.init(bookmarks: bookmarkList)
    }
}
