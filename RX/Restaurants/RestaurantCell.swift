//
//  RestaurantCell.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 17.12.2020.
//

import UIKit
import RxSwift
import RxDataSources

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
        nameLabel.setContentHuggingPriority(.required, for: .vertical)

        addSubview(nameLabel)
        addSubview(subtitleLabel)
        addSubview(favouriteStar)

        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalTo(snp.leadingMargin)
            $0.trailing.equalTo(favouriteStar.snp.leading).offset(-10)
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(2)
            $0.bottom.equalToSuperview().offset(-10)
            $0.leading.equalTo(snp.leadingMargin)
            $0.trailing.equalTo(favouriteStar.snp.leading).offset(-10)
        }

        favouriteStar.snp.makeConstraints {
            $0.trailing.equalTo(snp.trailingMargin)
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

struct RestaurantSectionModel {
    var header: Int = 0
    var items: [RestaurantViewModel]
}

extension RestaurantSectionModel: AnimatableSectionModelType {
    init(original: RestaurantSectionModel, items: [RestaurantViewModel]) {
        self = original
        self.items = items
    }

    var identity: Int {
        return header
    }
}
