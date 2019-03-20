//
//  PhotoListViewModel.swift
//  FlickerSearch
//
//  Created by Shubham on 18/03/19.
//  Copyright © 2019 Shubham. All rights reserved.
//

import Foundation
import UIKit

class PhotoListViewModel {

  private struct Constants {
    static let padding: CGFloat = 40.0
    static let numberOfColumns: CGFloat = 3.0
  }

  let apiClient: APIClientProtocol

  private var photos: [FlickrPhoto] = []
  var currentPage = 1
  var cache: NSCache<AnyObject, AnyObject>!

  var reloadCollectionViewClosure: (()->())?
  var showAlertClosure: (()->())?
  var updateLoaderWithNextRequest: ((_ startLoader: Bool)->())?
  var searchTappedClosure:(()->())?

  private var cellViewModels: [PhotoListCellViewModel] = [PhotoListCellViewModel]() {
    didSet {
      self.reloadCollectionViewClosure?()
    }
  }

  var numberOfCells: Int {
    return cellViewModels.count
  }

  var alertMessage: String? {
    didSet {
      self.showAlertClosure?()
    }
  }

  init(apiClient: APIClientProtocol = APIClient()) {
    self.apiClient = apiClient
    self.cache = NSCache()
  }

  func getCellViewModel( at indexPath: IndexPath ) -> PhotoListCellViewModel {
    return cellViewModels[indexPath.row]
  }

  func createCellViewModel( photo: FlickrPhoto ) -> PhotoListCellViewModel {
    let cellVM = PhotoListCellViewModel()
    cellVM.thumbnailImageURL = photo.thumbnailImageURL()
    cellVM.photoListViewModel = self
    return cellVM
  }

  private func processFetchedPhoto( photos: [FlickrPhoto] ) {
    self.photos = photos
    var vms = [PhotoListCellViewModel]()
    for photo in photos {
      vms.append(createCellViewModel(photo: photo))
    }

    self.cellViewModels = vms
  }

  func searchTappedWith(searchText: String?) {
    if let txt = searchText {
      searchTappedClosure?()
      currentPage = 1
      searchForResultWith(text: txt)
    }
  }

  func searchForResultWith(text searchText: String) {
    apiClient.search(queryString: searchText, pageNo: "\(currentPage)", completion: { [weak self]
      (entries) in
      guard let weakSelf = self else {
        return
      }

      guard let _ = entries else {
        weakSelf.alertMessage = "Oops! Something went wrong."
        return
      }

      if weakSelf.currentPage == 1 {
        weakSelf.photos = []
      }

      if let entry = entries, let photos = entry.photos {
        weakSelf.photos.append(contentsOf: photos.flickrPhotos)
      }

      weakSelf.processFetchedPhoto(photos: self!.photos)
    })
  }

  func supplementaryViewDisplayed(forText text: String?) {
    if photos.count > 0 {
      updateLoaderWithNextRequest?(true)
      if let searchText = text {
        currentPage = currentPage + 1
        searchForResultWith(text: searchText)
      }
    } else {
      updateLoaderWithNextRequest?(false)
    }
  }

  func itemSize() -> CGFloat {
    return (UIScreen.main.bounds.width - Constants.padding)/Constants.numberOfColumns
  }

}
