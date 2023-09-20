//
//  AlbumsViewModel_Tests.swift
//  AlbumsTests
//
//  Created by Anton Selivonchyk on 20/09/2023.
//

import XCTest
import Combine
@testable import Albums

final class AlbumsViewModel_Tests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    func test_AlbumsViewModel_initialization() {
        let dataProvider = MockDataProvider(urlString: "SearchResponseMock.json")
        let viewModel = AlbumsViewModel(searchText: UUID().uuidString,
                                        dataProvider: dataProvider)

        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.albums.count, 0)
        XCTAssertNil(viewModel.error)
    }

    func test_AlbumsViewModel_debounces() {
        let dataProvider = MockDataProvider(urlString: "SearchResponseMock.json")
        let viewModel = AlbumsViewModel(searchText: String(),
                                        dataProvider: dataProvider)

        viewModel.setSearchTerm(String())

        XCTAssertNil(viewModel.error)
        XCTAssertEqual(viewModel.albums.count, 0)
    }

    func test_AlbumsViewModel_loadsMockData() {
        let mockDataProvider = MockDataProvider(urlString: "SearchResponseMock.json")
        let albumsViewModel = AlbumsViewModel(searchText: String(), 
                                              dataProvider: mockDataProvider)
        var albums = [Album]()

        let expectation = XCTestExpectation(description: "Should load mock json")
        albumsViewModel.$albums
            .dropFirst()
            .sink {
                albums = $0
                expectation.fulfill()
            }.store(in: &cancellables)

        albumsViewModel.setSearchTerm(UUID().uuidString)
        wait(for: [expectation], timeout: 5)

        XCTAssertEqual(albums.count, 29)
    }

    func test_AlbumsViewModel_publishesInjectedAlbums() {
        let mockDataProvider = MockDataProvider(urlString: "SearchResponseMock.json")
        let injectedAlbums = [Album(collectionName: String(), artistName: String()),
                      Album(collectionName: String(), artistName: String()),
                      Album(collectionName: String(), artistName: String())]
        let albumsViewModel = AlbumsViewModel(searchText: String(), 
                                              dataProvider: mockDataProvider,
                                              albums: injectedAlbums)

        XCTAssertEqual(albumsViewModel.albums.count, injectedAlbums.count)
    }

    func test_AlbumsViewModel_publishesInjectedError() {
        let mockDataProvider = MockDataProvider(urlString: "SearchResponseMock.json")
        let albumsViewModel = AlbumsViewModel(searchText: String(),
                                              dataProvider: mockDataProvider,
                                              albums: [],
                                              error: DataProviderError.invalidURL)

        XCTAssertEqual(albumsViewModel.error as? DataProviderError, .invalidURL)
    }
}
