//
//  PhotoListCellViewModelTest.swift
//  FlickerSearchTests
//
//  Created by Shubham on 19/03/19.
//  Copyright © 2019 Shubham. All rights reserved.
//

import Foundation

import XCTest
@testable import FlickerSearch

class PhotoListCellViewModelTest: XCTestCase {

  var sut: PhotoListCellViewModel!
  var mockListVM: PhotoListViewModel?

  override func setUp() {
    super.setUp()
    let mockAPIService = MockWebService()
    mockListVM = PhotoListViewModel(apiClient: mockAPIService)
    sut = PhotoListCellViewModel()
    sut.thumbnailImageURL = "https://farm1.static.flickr.com/578/23451156376_8983a8ebc7.jpg"
    sut.photoListViewModel = mockListVM
  }

  override func tearDown() {
    sut = nil
    super.tearDown()
  }

  func testLoadImage() {
    let expect = XCTestExpectation(description: "loadImage triggered with bg downloading via URLSessionDataTask")
    let imageView: UIImageView = UIImageView()
    XCTAssertNil(imageView.image)
    sut.loadImage { image, _ in
      expect.fulfill()
      DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        XCTAssertNotNil(imageView.image)
      }
    }

    wait(for: [expect], timeout: 5)
  }

}
