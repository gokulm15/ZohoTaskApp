//
//  ActivityIndicatorManager.swift
//  TaskApp
//
//  Created by gokul on 05/04/24.
//

import Foundation
import UIKit

class ActivityIndicatorManager {
    static let shared = ActivityIndicatorManager()
    private init() {}

       func showLoader(on view: UIView) {
           let activityIndicator = UIActivityIndicatorView(style: .medium)
           activityIndicator.center = view.center
           activityIndicator.startAnimating()
           view.addSubview(activityIndicator)
       }

       func hideLoader(from view: UIView) {
           for subview in view.subviews {
               if let activityIndicator = subview as? UIActivityIndicatorView {
                   activityIndicator.stopAnimating()
                   activityIndicator.removeFromSuperview()
               }
           }
       }
   }
