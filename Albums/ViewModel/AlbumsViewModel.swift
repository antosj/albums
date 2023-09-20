//
//  AlbumsViewModel.swift
//  Albums
//
//  Created by Anton Selivonchyk on 19/09/2023.
//

import Foundation
import Combine

class AlbumsViewModel {
    private let searchTextSubject = PassthroughSubject<String, Never>()
    private var cancellables: Set<AnyCancellable> = []
    private let dataProvider: DataProviderProtocol

    @Published var albums: [Album]
    @Published var error: Error?

    init(searchText: String, dataProvider: DataProviderProtocol, albums: [Album] = [Album](), error: Error? = nil) {
        self.dataProvider = dataProvider
        self.albums = albums
        self.error = error

        searchTextSubject
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                self?.search(searchText)
            }
            .store(in: &cancellables)
    }

    func setSearchTerm(_ term: String) {
        searchTextSubject.send(term)
    }

    // MARK: Private interface
    private func search(_ text: String) {
        guard !text.isEmpty else {
            error = DataProviderError.emptySearchTerm
            return
        }

        dataProvider.searchFor(text)
            .sink { [weak self] result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error
                }
            } receiveValue: { [weak self] albums in
                self?.error = nil
                self?.albums = albums
            }
            .store(in: &cancellables)
    }
}
