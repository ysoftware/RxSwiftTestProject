//
//  RestaurantsViewController.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 11.12.2020.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class RestaurantsViewController: UIViewController {

    var viewModel: RestaurantsViewModel!

    private let disposeBag = DisposeBag()
    private var restaurants = BehaviorRelay<[RestaurantViewModel]>(value: [])
    private var selectedFilters = BehaviorRelay<Set<Cuisine>>(value: [])
    private var filteredRestaurants = BehaviorSubject<[RestaurantViewModel]>(value: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        applyViewModel()
        setupViews()
        setupFilters()
    }

    override func viewWillLayoutSubviews() {
        tableView.contentInset.bottom = tagsStackView.frame.height
    }

    private func applyViewModel() {
        title = viewModel.title

        Observable
            .combineLatest(restaurants, selectedFilters)
            .bind(onNext: { [weak self] restaurants, filters in
                self?.filteredRestaurants.onNext(restaurants.filter {
                    filters.contains($0.restaurant.cuisine) || filters.isEmpty
                })
            })
            .disposed(by: disposeBag)

        filteredRestaurants
            .catchError { _ in
                .just([])
            }
            .map { [weak self] value -> [RestaurantViewModel] in
                self?.tableView.refreshControl?.endRefreshing()
                return value
            }
            .bind(to: tableView.rx.items(cellIdentifier: RestaurantCell.ID)) { _, viewModel, cell in
                guard let cell = cell as? RestaurantCell else { return }
                cell.nameLabel.text = viewModel.restaurant.name
                cell.subtitleLabel.text = viewModel.restaurant.cuisine.rawValue.capitalized
            }
            .disposed(by: disposeBag)

        // MARK: Restaurants

        let observable = viewModel
            .fetchRestaurantsViewModels()
            .observeOn(MainScheduler.instance)
            .share(replay: 1)

        observable
            .bind(to: restaurants)
            .disposed(by: disposeBag)

        observable
            .subscribe(onNext: { [weak self] value in
                if value.isEmpty {
                    self?.label.text = "Nothing was found"
                } else {
                    self?.label.text = ""
                }
            }, onError: { [weak self] error in
                self?.label.text = "An error occured:\n" + error.localizedDescription
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Setup

    private func setupViews() {
        navigationController?.navigationBar.prefersLargeTitles = true

        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addAction(UIAction(handler: { _ in
            self.viewModel.refresh()
        }), for: .valueChanged)

        view.addSubview(tableView)
        view.addSubview(label)
        view.addSubview(scrollView)

        label.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(18)
            $0.centerX.centerY.equalToSuperview()
        }

        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // MARK: ScrollView

        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(content)
        content.addSubview(tagsStackView)

        scrollView.snp.makeConstraints {
            $0.bottom.equalTo(view.snp.bottomMargin)
            $0.leading.trailing.equalToSuperview()
        }

        content.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        tagsStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func setupFilters() {
        selectedFilters
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] filters in
                guard let self = self else { return }

                self.tagsStackView.arrangedSubviews
                    .forEach { $0.removeFromSuperview() }

                Cuisine.allCases
                    .map {
                        self.makeFilterLabel(
                            title: $0.rawValue.capitalized,
                            tag: Cuisine.allCases.firstIndex(of: $0)!,
                            isSelected: filters.contains($0)
                        )
                    }
                    .forEach { self.tagsStackView.addArrangedSubview($0) }
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Subviews

    @objc func didTapFilterView(_ gestureRecognizer: UITapGestureRecognizer) {
        let tag = Cuisine.allCases[gestureRecognizer.view!.tag]
        var newValue = selectedFilters.value
        if newValue.contains(tag) {
            newValue.remove(tag)
        } else {
            newValue.insert(tag)
        }
        selectedFilters.accept(newValue)
    }

    private func makeFilterLabel(title: String, tag: Int, isSelected: Bool) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tag = tag
        view.layer.cornerRadius = 10

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.text = title

        view.addSubview(label)
        label.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(10)
            $0.bottom.trailing.equalToSuperview().offset(-10)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapFilterView))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true

        if isSelected {
            view.backgroundColor = UIColor(red: 28/255, green: 145/255, blue: 41/255, alpha: 1)
        } else {
            view.backgroundColor = UIColor(red: 73/255, green: 88/255, blue: 184/255, alpha: 1)
        }
        return view
    }

    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 30, weight: .bold)
        return label
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .white
        table.tableFooterView = UIView()
        table.register(RestaurantCell.self, forCellReuseIdentifier: RestaurantCell.ID)
        return table
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private lazy var tagsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 10
        stack.directionalLayoutMargins = .init(top: 0, leading: 15, bottom: 0, trailing: 15)
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()
}

class RestaurantCell: UITableViewCell {

    static let ID = "Cell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(nameLabel)
        addSubview(subtitleLabel)

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
}
