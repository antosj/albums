//
//  Errors.swift
//  Albums
//
//  Created by Anton Selivonchyk on 19/09/2023.
//

import Foundation

enum AlbumsError: Error {
    case empty
}

enum DataProviderError: Error {
    case invalidURL
    case emptySearchTerm
}
