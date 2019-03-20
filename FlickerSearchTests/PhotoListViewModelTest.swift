//
//  PhotoListViewModelTest.swift
//  FlickerSearchTests
//
//  Created by Shubham on 19/03/19.
//  Copyright © 2019 Shubham. All rights reserved.
//

import XCTest
@testable import FlickerSearch

class PhotoListViewModelTest: XCTestCase {

  var sut: PhotoListViewModel!
  var mockAPIService: MockWebService!

  override func setUp() {
    super.setUp()
    mockAPIService = MockWebService()
    sut = PhotoListViewModel(apiClient: mockAPIService)
  }

  override func tearDown() {
    sut = nil
    mockAPIService = nil
    super.tearDown()
  }

  func testFetchPhoto() {
    // Given
    mockAPIService.completePhotos = Photos()

    // When
    sut.searchForResultWith(text: "kitten")

    // Assert
    XCTAssert(mockAPIService!.isFetchPopularPhotoCalled)
  }

  func testFetchPhotoFail() {

    // Given a failed fetch with a certain failure

    // When
    sut.searchForResultWith(text: "kitten")

    mockAPIService.fetchFail()

    // Sut should display error message
    XCTAssertNotNil(sut.alertMessage)
  }

  func testCreateCellViewModel() {
    // Given
    let photos = StubGenerator().stubPhotos()
    mockAPIService.completePhotos = photos
    let expect = XCTestExpectation(description: "reload closure triggered")
    sut.reloadCollectionViewClosure = { () in
      expect.fulfill()
    }

    // When
    sut.searchForResultWith(text: "kitten")
    mockAPIService.fetchSuccess()

    // Number of cell view model is equal to the number of photos
    XCTAssertEqual( sut.numberOfCells, photos.photos?.flickrPhotos.count )

    // XCTAssert reload closure triggered
    wait(for: [expect], timeout: 1.0)
  }

  func testGetCellViewModel() {

    //Given a sut with fetched photos
    goToFetchPhotoFinished()

    let indexPath = IndexPath(row: 0, section: 0)
    let testPhoto = mockAPIService.completePhotos.photos

    // When
    let vm = sut.getCellViewModel(at: indexPath)

    //Assert
    XCTAssertEqual( vm.thumbnailImageURL, testPhoto?.flickrPhotos[0].thumbnailImageURL())
  }

  func testCellViewModel() {
    //Given photos
    let photoCat    = FlickrPhoto(id: "1", farm: 2, server: "4905", secret: "949db070a1")
    let photoDog    = FlickrPhoto(id: "2", farm: 2, server: "4905", secret: "949db070a2")

    // When creat cell view model
    let cellViewModelCat = sut.createCellViewModel( photo: photoCat )
    let cellViewModelDog = sut.createCellViewModel( photo: photoDog )

    // Assert the correctness of display information
    XCTAssertEqual( photoCat.thumbnailImageURL(), cellViewModelCat.thumbnailImageURL )
    XCTAssertEqual( photoDog.thumbnailImageURL(), cellViewModelDog.thumbnailImageURL )

    XCTAssertNotEqual( photoCat.thumbnailImageURL(), cellViewModelDog.thumbnailImageURL )

  }

  func testProcessFetchedPhotos() {
    //Given no photos availabel initially
    XCTAssertEqual(sut.numberOfCells, 0)

    // When processFetchedPhoto called
    goToFetchPhotoFinished()

    XCTAssertEqual(sut.numberOfCells, mockAPIService.completePhotos.photos?.flickrPhotos.count)

  }

  func testSearchTappedWith() {
    // Given
    let expect = XCTestExpectation(description: "searchTapped closure triggered")
    sut.searchTappedClosure = { () in
      expect.fulfill()
    }

    // When
    sut.searchTappedWith(searchText: "kitten")

    // XCTAssert searchTapped closure triggered
    wait(for: [expect], timeout: 1.0)

    // Reset current page to 1
    XCTAssertEqual( sut.currentPage, 1 )

  }

  func testUpdateLoaderNotDisplayedForFirstRequest() {
    // Given
    let expect = XCTestExpectation(description: "updateLoader closure triggered with FALSE")
    sut.updateLoaderWithNextRequest = { (startSpinner) in
      expect.fulfill()
      XCTAssertFalse(startSpinner)
    }

    // When - loader not displayed for no photos available
    sut.supplementaryViewDisplayed(forText: "kitten")

    // XCTAssert updateLoader closure triggered
    wait(for: [expect], timeout: 1.0)

  }

  func testUpdateLoaderDisplayedForNextRequest() {
    // Given
    goToFetchPhotoFinished()
    let expect = XCTestExpectation(description: "updateLoader closure triggered with TRUE")
    sut.updateLoaderWithNextRequest = { (startSpinner) in
      expect.fulfill()
      XCTAssertTrue(startSpinner)
    }

    // When
    sut.currentPage = 1
    sut.supplementaryViewDisplayed(forText: "kitten")

    // XCTAssert updateLoader closure triggered
    wait(for: [expect], timeout: 1.0)

    XCTAssertEqual(sut.currentPage, 2)

  }

  func testItemSize() {
    let itemSize = sut.itemSize()
    XCTAssertGreaterThan(itemSize, 0)
  }


}

// MARK:- State control
extension PhotoListViewModelTest {
  private func goToFetchPhotoFinished() {
    mockAPIService.completePhotos = StubGenerator().stubPhotos()
    sut.searchForResultWith(text: "kitten")
    mockAPIService.fetchSuccess()
  }
}

// MARK:- Mocking
class MockWebService: APIClientProtocol {

  var isFetchPopularPhotoCalled = false

  var completePhotos: Photos = Photos()
  var completeClosure: PhotoCompletionHandler!

  func search(queryString: String, pageNo: String, completion: @escaping PhotoCompletionHandler) {
    isFetchPopularPhotoCalled = true
    completeClosure = completion
  }

  func fetchSuccess() {
    completeClosure(completePhotos)
  }

  func fetchFail() {
    completeClosure(nil)
  }

}

class StubGenerator {
  func stubPhotos() -> Photos {
    guard let path = Bundle(for: PhotoListViewModelTest.self).url(forResource: "response", withExtension: "json") else {
      return Photos()
    }

    guard let data = try? Data(contentsOf: path) else {
      return Photos()
    }

    guard let photos = try? JSONDecoder().decode(Photos.self, from: data) else {
      return Photos()
    }

    return photos
  }
}
