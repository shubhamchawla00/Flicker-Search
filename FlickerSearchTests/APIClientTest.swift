//
//  APIClientTest.swift
//  FlickerSearchTests
//
//  Created by Shubham on 19/03/19.
//  Copyright © 2019 Shubham. All rights reserved.
//

import XCTest
@testable import FlickerSearch

class APIClientTest: XCTestCase {

  var sut: APIClient!

  override func setUp() {
    super.setUp()
    sut = APIClient()
  }

  override func tearDown() {
    sut = nil
    super.tearDown()
  }

  // Internet is required for this test to succeed
  func testFetchPhotos() {

    // Given a api service
    let sut = self.sut

    // When fetch photo for text
    let expect = XCTestExpectation(description: "callback")

    sut?.search(queryString: "kitten", pageNo: "1", completion: { (photos) in
      expect.fulfill()
      XCTAssertNotNil(photos)
    })

    wait(for: [expect], timeout: 5.0)
  }

}
