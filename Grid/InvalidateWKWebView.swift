//
//  InvalidateWKWebView.swift
//  Grid
//
//  Created by Bryan Lloyd Anderson on 11/10/15.
//  Copyright © 2015 Bryan Lloyd Anderson. All rights reserved.
//

import Foundation
import UIKit
import WebKit

extension WKWebView {
    func invalidateVisibleRect() {
    let contentOffset = scrollView.contentOffset
    scrollView.setContentOffset(CGPoint(x: contentOffset.x, y: contentOffset.y + 1), animated: true)
    }
}