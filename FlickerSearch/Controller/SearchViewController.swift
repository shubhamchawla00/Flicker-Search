//
//  SearchViewController.swift
//  FlickerSearch
//
//  Created by Shubham on 18/03/19.
//  Copyright © 2019 Shubham. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

  @IBOutlet weak var collectionView: UICollectionView!

  private struct Constants {
    static let photoCellIdentifier = "photocell"
  }

  private let searchBar: UISearchBar = {
    let searchBar = UISearchBar()
    searchBar.searchBarStyle = .default
    return searchBar
  }()

  private lazy var viewModel: PhotoListViewModel = {
    return PhotoListViewModel()
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    searchBar.delegate = self
    navigationItem.titleView = searchBar

    initVM()
  }

  func initVM() {
    // Native binding using closures
    viewModel.showAlertClosure = { [weak self] in
      guard let weakSelf = self else {
        return
      }

      Utility.ensureExecuteOnMainThread {
        if let message = weakSelf.viewModel.alertMessage {
          weakSelf.showAlert( message )
        }
      }
    }

    viewModel.reloadCollectionViewClosure = { [weak self] () in
      guard let weakSelf = self else {
        return
      }

      Utility.ensureExecuteOnMainThread {
        weakSelf.collectionView.reloadData()
      }
    }

    viewModel.updateLoaderWithNextRequest = { [weak self] start in
      guard let weakSelf = self else {
        return
      }

      if let loader = weakSelf.view.viewWithTag(99) as? UIActivityIndicatorView {
        if start {
          loader.startAnimating()
        } else {
          loader.stopAnimating()
        }
      }
    }

    viewModel.searchTappedClosure = { [weak self] in
      guard let weakSelf = self else {
        return
      }

      weakSelf.searchBar.resignFirstResponder()
      weakSelf.collectionView.setContentOffset(CGPoint.zero, animated: false)
    }
  }

  func showAlert( _ message: String ) {
    let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
    alert.addAction( UIAlertAction(title: "Ok", style: .cancel, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }

}

extension SearchViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    viewModel.searchTappedWith(searchText: searchBar.text)
  }

  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    collectionView.setContentOffset(collectionView.contentOffset, animated: false)
  }
}


// MARK: - UICollectionView Data

extension SearchViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.numberOfCells
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.photoCellIdentifier, for: indexPath as IndexPath) as? PhotoCell else {
      fatalError("Cell doesn't exist in storyboard")
    }

    let cellVM = viewModel.getCellViewModel( at: indexPath )
    cell.initializeWithVM(cellViewModel: cellVM)

    return cell
  }
}

extension SearchViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    switch kind {
    case UICollectionView.elementKindSectionFooter:
      let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FooterView", for: indexPath)
      return footerView
    default:
      let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FooterView", for: indexPath)
      return footerView
    }
  }

  func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
    viewModel.supplementaryViewDisplayed(forText: searchBar.text)
  }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let itemSize = viewModel.itemSize()
    return CGSize(width: itemSize, height:itemSize)
  }


  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10);
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0.0;
  }

}

extension SearchViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    searchBar.resignFirstResponder()
  }
}
