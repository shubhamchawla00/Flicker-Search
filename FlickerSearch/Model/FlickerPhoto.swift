//
//  FlickerPhoto.swift
//  FlickerSearch
//
//  Created by Shubham on 18/03/19.
//  Copyright © 2019 Shubham. All rights reserved.
//

import Foundation

struct Photos: Codable {
  var photos: PhotoArray?
}

struct PhotoArray: Codable {
  let page: Int?
  var flickrPhotos: [FlickrPhoto] = [FlickrPhoto]()

  enum CodingKeys:String, CodingKey {
    case page
    case flickrPhotos = "photo"
  }
}

struct FlickrPhoto: Codable {
  let id: String
  let farm: Int?
  let server: String?
  let secret: String?

  func thumbnailImageURL() -> String {
    var imageStr = ""
    if let pFarm = farm, let pServer = server, let pSecret = secret {
      imageStr = "https://farm\(pFarm).static.flickr.com/\(pServer)/\(self.id)_\(pSecret).jpg"
    }
    return imageStr
  }
}
