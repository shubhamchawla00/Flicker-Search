//
//  PhotoListCellViewModel.swift
//  FlickerSearch
//
//  Created by Shubham on 18/03/19.
//  Copyright © 2019 Shubham. All rights reserved.
//

import Foundation
import UIKit

class PhotoListCellViewModel {
  var thumbnailImageURL: String = ""

  weak var photoListViewModel: PhotoListViewModel?
  var task: URLSessionDataTask?


  func loadImage(completion: @escaping (_ img: UIImage, _ url: String) -> ()) {
    guard let listVM = photoListViewModel else {
      return
    }

    let request = URLRequest(url: URL(string: thumbnailImageURL)!)
    if let image = listVM.cache.object(forKey: request as AnyObject) as? UIImage {
      completion(image, thumbnailImageURL)
    }
    else {
      task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
        if let data = data, let response = response, ((response as? HTTPURLResponse)?.statusCode ?? 500) < 300, let image = UIImage(data: data) {
          completion(image, self.thumbnailImageURL)
          listVM.cache.setObject(image, forKey: request as AnyObject)
        }
      })

      task?.resume()
    }
  }
}
