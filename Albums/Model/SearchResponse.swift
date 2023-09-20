//
//  SearchResponse.swift
//  Albums
//
//  Created by Anton Selivonchyk on 20/09/2023.
//

import Foundation

struct SearchResponse: Codable {
    let results: [Album]
}
