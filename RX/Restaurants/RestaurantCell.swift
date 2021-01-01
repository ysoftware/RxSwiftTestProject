//
//  RestaurantCell.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 17.12.2020.
//

import UIKit
import RxSwift

class RestaurantCell: UITableViewCell {

    private var disposeBag = DisposeBag()
    static let ID = "Cell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(nameLabel)
        addSubview(subtitleLabel)
        addSubview(favouriteStar)

        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalTo(snp.leadingMargin)
            $0.trailing.equalTo(snp.trailingMargin)
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(2)
            $0.bottom.equalToSuperview().offset(-10)
            $0.leading.equalTo(snp.leadingMargin)
            $0.trailing.equalTo(snp.trailingMargin)
        }

        favouriteStar.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-10)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(25)
        }
    }

    func observeIsFavourite(_ observer: Observable<Bool>) {
        observer.bind { [weak self] isFavourite in
            self?.favouriteStar.isHidden = !isFavourite
        }.disposed(by: disposeBag)
    }

    // MARK: Subviews
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .black
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()

    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }()

    lazy var favouriteStar: UIView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "star.fill")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}
