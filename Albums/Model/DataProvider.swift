//
//  File.swift
//  Albums
//
//  Created by Anton Selivonchyk on 19/09/2023.
//

import Foundation
import Combine

protocol DataProviderProtocol {
    func searchFor(_ term: String) -> AnyPublisher<[Album], Error>
    init(urlString: String)
}

class DataProvider: DataProviderProtocol {
    private let urlString: String

    required init(urlString: String) {
        self.urlString = urlString
    }

    func searchFor(_ term: String) -> AnyPublisher<[Album], Error> {
        guard !term.isEmpty else {
            return Fail(error: DataProviderError.emptySearchTerm).eraseToAnyPublisher()
        }

        guard let url = URL(string: urlString + term) else {
            return Fail(error: DataProviderError.invalidURL).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: SearchResponse.self, decoder: JSONDecoder())
            .map(\.results)
            .receive(on: DispatchQueue.main)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
