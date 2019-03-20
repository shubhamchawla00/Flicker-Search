//
//  PhotoCell.swift
//  FlickerSearch
//
//  Created by Shubham on 18/03/19.
//  Copyright © 2019 Shubham. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {

  @IBOutlet weak var thumbnail: UIImageView!
  weak var cellVM: PhotoListCellViewModel?

  func initializeWithVM(cellViewModel: PhotoListCellViewModel) {
    cellVM = cellViewModel
    cellVM?.loadImage(completion: { image, thumbnailImageURL in
      Utility.ensureExecuteOnMainThread { [weak self] in
        guard let weakSelf = self else {
          return
        }

        if weakSelf.cellVM?.thumbnailImageURL == thumbnailImageURL {
          weakSelf.thumbnail.image = image
        }
      }
    })
  }

  override func prepareForReuse() {
    self.thumbnail.image = nil
    cellVM?.task?.cancel()

    super.prepareForReuse()
  }

}
