//
//  ReviewsViewController.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 16.12.2020.
//

import UIKit
import RxSwift

class ReviewsViewController: UIViewController {

    var viewModel: ReviewsViewModel!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        setupViews()
        applyViewModel()
    }

    private func setupViews() {
        title = viewModel.title
        view.backgroundColor = .white

        view.addSubview(favouriteButton)

        favouriteButton.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
            $0.width.height.equalTo(40)
        }
    }

    private func applyViewModel() {

        // MARK: Input

        viewModel.isFavourite
            .bind { [weak self] isFavourite in
                let imageName = isFavourite ? "star.fill" : "star"
                let image = UIImage(systemName: imageName)
                self?.favouriteButton.setImage(image, for: .normal)
            }
            .disposed(by: disposeBag)

        // MARK: Output

        favouriteButton.rx
            .controlEvent(.primaryActionTriggered)
            .bind { [weak self] in
                self?.viewModel.isFavourite.toggleValue()
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Subviews

    private lazy var favouriteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()
}
