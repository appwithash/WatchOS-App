//
//  BookmarkViewModel.swift
//  Apple watch browser
//
//  Created by ashutosh on 28/01/22.
//

import SwiftUI

class BookmarkViewModel : ObservableObject{
    @Published var createFolder = false
    @Published var editFolder = false
    @Published var showEmptyAlert = false
    @Published var navigateToBookmarkDetailView = false
    @Published var selectBookmarkList : [BookMarkModel] = []
    @Published var deleteConfirmationAlert = false
}
