//
//  Utility.swift
//  FlickerSearch
//
//  Created by Shubham on 18/03/19.
//  Copyright © 2019 Shubham. All rights reserved.
//

import Foundation

class Utility: NSObject {

  /// Synchronously execute the passed in block if already in main thread, otherwise dispatch to main thread and excute the passed in block
  @objc public class func ensureExecuteOnMainThread(_ execute: @escaping () -> Void) {
    if Thread.isMainThread {
      execute()
    }
    else {
      DispatchQueue.main.async {
        execute()
      }
    }
  }
}
