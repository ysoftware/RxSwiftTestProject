//
//  ReviewsViewController.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 16.12.2020.
//

import UIKit

class ReviewsViewController: UIViewController {

    var viewModel: ReviewsViewModel!

    override func viewDidLoad() {
        title = viewModel.title
    }
}
