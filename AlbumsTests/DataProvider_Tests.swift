//
//  DataProvider_Tests.swift
//  AlbumsTests
//
//  Created by Anton Selivonchyk on 20/09/2023.
//

import XCTest
import Combine
@testable import Albums

final class DataProvider_Tests: XCTestCase {
    private let networkTimeout = TimeInterval(5)
    private var cancellables = Set<AnyCancellable>()

    func test_DataProvider_initialization() {
        let dataProvider = DataProvider(urlString: Settings.searchURL.rawValue)

        XCTAssertNotNil(dataProvider)
    }

    func test_DataProvider_searchFor_failsOnEmptySearch() {
        let dataProvider = DataProvider(urlString: Settings.searchURL.rawValue)
        let emptyString = String()
        var albums = [Album]()

        let expectation = XCTestExpectation(description: "Should fail on empty search")
        dataProvider.searchFor(emptyString)
            .sink {
                switch $0 {
                case .finished:
                    break
                case .failure(let error):
                    if (error as? DataProviderError) == .emptySearchTerm {
                        expectation.fulfill()
                    } else {
                        XCTFail()
                    }
                }
            } receiveValue: {
                albums = $0
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: networkTimeout)
        XCTAssert(albums.count == 0)
    }

    func test_DataProvider_searchFor_failsOnInvalidURL() {
        let dataProvider = DataProvider(urlString: UUID().uuidString)
        var albums = [Album]()

        let expectation = XCTestExpectation(description: "Should fail on invalid url")
        dataProvider.searchFor(Settings.defaultSearchTerm.rawValue)
            .sink {
                switch $0 {
                case .finished:
                    break
                case .failure:
                    expectation.fulfill()
                }
            } receiveValue: {
                albums = $0
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: networkTimeout)
        XCTAssert(albums.count == 0)
    }

    func test_DataProvider_searchFor_loadsExistingData() {
        let dataProvider = DataProvider(urlString: Settings.searchURL.rawValue)
        var albums = [Album]()

        let expectation = XCTestExpectation(description: "Should load data from server")
        dataProvider.searchFor(Settings.defaultSearchTerm.rawValue)
            .sink { _ in
            } receiveValue: {
                albums = $0
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: networkTimeout)
        XCTAssert(albums.count > 0)
    }
}
