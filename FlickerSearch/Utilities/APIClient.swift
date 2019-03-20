//
//  APIClient.swift
//  FlickerSearch
//
//  Created by Shubham on 18/03/19.
//  Copyright © 2019 Shubham. All rights reserved.
//

import Foundation

typealias PhotoCompletionHandler = (Photos?) -> ()

protocol APIClientProtocol {
  func search(queryString: String, pageNo: String, completion: @escaping PhotoCompletionHandler)
}

final class APIClient: APIClientProtocol {

  private struct Constants {
    static let baseURL = "https://api.flickr.com/services/rest/"
    static let flickrAPIKey = "3e7cc266ae2b0e0d78e279ce8e361736"
  }

  private func get(_ request: URLRequest, completion: @escaping (_ success: Bool, _ data: Data?) -> ()) {
    dataTask(request, method: "GET", completion: completion)
  }

  private func dataTask(_ request: URLRequest, method: String, completion: @escaping (_ success: Bool, _ data: Data?) -> ()) {
    var request = request
    request.httpMethod = method

    let session = URLSession(configuration: URLSessionConfiguration.default)

    session.dataTask(with: request) { data, response, error in
      if let data = data {
        if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
          completion(true, data)
        }
        else {
          completion(false, data)
        }
      }
      }.resume()
  }

  private func clientURLRequest(_ path: String, params: Dictionary<String, String>? = nil) -> URLRequest {
    var paramString = ""
    if let params = params {
      for (key, value) in params {
        let escapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? key
        let escapedValue = value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? value
        paramString += "\(escapedKey)=\(escapedValue)&"
      }
    }

    var request = URLRequest(url: URL(string: path + "?" + paramString)!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    return request
  }

  func search(queryString: String, pageNo: String, completion: @escaping PhotoCompletionHandler) {
    let requestURL = Constants.baseURL
    let params = ["method": "flickr.photos.search", "api_key" : Constants.flickrAPIKey, "format": "json", "nojsoncallback": "1", "safe_search": "1", "text": queryString, "page": pageNo]

    get(clientURLRequest(requestURL, params: params)) { success, data -> () in
      Utility.ensureExecuteOnMainThread {
        if success {
          if let data = data {
            let photos = try! JSONDecoder().decode(Photos.self, from: data)
            completion(photos)
            return
          }
        }
        else {
          print("Something went wrong. Please try again later")
        }

        completion(nil)
      }
    }
  }

}
