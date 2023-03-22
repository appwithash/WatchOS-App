//
//  Transformer.swift
//  Apple watch browser
//
//  Created by ashutosh on 29/01/22.
//

import SwiftUI
import CoreData

@objc(Transformer)
class Transformer : ValueTransformer{
        
    override func transformedValue(_ value: Any?) -> Any? {
        print(1)
        guard let bookmarkList = value as? BookmarkList else {return  BookmarkList(bookmarks: [BookMarkModel]())}
        print("bookmarkList",bookmarkList.bookmarkList)
        do{
            print("bookmarkList",bookmarkList.bookmarkList)
            let data = try NSKeyedArchiver.archivedData(withRootObject: bookmarkList, requiringSecureCoding: true)
       
       
            print("Transform value success")
            return data
        }catch let error{
            print("Transform value error ",String(describing: error))
            return BookmarkList(bookmarks: [BookMarkModel]())
        }
    }
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        print(2)
        guard let data = value as? Data else {return BookmarkList(bookmarks: [BookMarkModel]())}
      
        do{
            print("data desc",data)
            let bookmarkList = try NSKeyedUnarchiver.unarchivedObject(ofClass: BookmarkList.self, from: data)
            print("Transform value success")
            return bookmarkList
        }catch let error{
            print("Transform value error ",String(describing: error.localizedDescription))
            return BookmarkList(bookmarks: [BookMarkModel]())
        }
    }
}


