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

    private let cellId = "Cell"
    private let disposeBag = DisposeBag()

    private var restaurants = BehaviorRelay<[RestaurantViewModel]>(value: [])
    private var selectedFilter = BehaviorRelay<Cuisine?>(value: nil)
    private var filteredRestaurants = PublishSubject<[RestaurantViewModel]>()

    override func viewDidLoad() {
        super.viewDidLoad()
        applyViewModel()
        setupViews()
        setupFilters()
    }

    private func applyViewModel() {
        title = viewModel.title

        Observable
            .combineLatest(restaurants, selectedFilter)
            .bind(onNext: { [weak self] restaurants, filter in
                if let filter = filter {
                    self?.filteredRestaurants.onNext(restaurants.filter { $0.restaurant.cuisine == filter })
                } else {
                    self?.filteredRestaurants.onNext(restaurants)
                }
            }).disposed(by: disposeBag)

        filteredRestaurants
            .catchError { _ in
                .just([])
            }
            .map { [weak self] value -> [RestaurantViewModel] in
                self?.tableView.refreshControl?.endRefreshing()
                return value
            }
            .bind(to: tableView.rx.items(cellIdentifier: cellId)) { _, viewModel, cell in
                cell.textLabel?.text = "\(viewModel.restaurant.name) - \(viewModel.restaurant.cuisine.rawValue.capitalized)"
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
        selectedFilter
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] filter in
                guard let self = self else { return }

                self.tagsStackView.arrangedSubviews
                    .forEach {
                        $0.removeFromSuperview()
                    }

                Cuisine.allCases
                    .map {
                        self.makeFilterLabel(
                            title: $0.rawValue.capitalized,
                            tag: Cuisine.allCases.firstIndex(of: $0)!,
                            isSelected: filter == $0
                        )
                    }
                    .forEach {
                        self.tagsStackView.addArrangedSubview($0)
                    }
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Subviews

    @objc func didTapFilterView(_ gestureRecognizer: UITapGestureRecognizer) {
        let tag = Cuisine.allCases[gestureRecognizer.view!.tag]
        if selectedFilter.value == tag {
            selectedFilter.accept(nil)
        } else {
            selectedFilter.accept(tag)
        }
    }

    private func makeFilterLabel(title: String, tag: Int, isSelected: Bool) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tag = tag
        view.layer.cornerRadius = 10

        if isSelected {
            view.backgroundColor = UIColor(red: 28/255, green: 145/255, blue: 41/255, alpha: 1)
        } else {
            view.backgroundColor = UIColor(red: 73/255, green: 88/255, blue: 184/255, alpha: 1)
        }

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = title

        view.addSubview(label)
        label.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(10)
            $0.bottom.trailing.equalToSuperview().offset(-10)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapFilterView))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true

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
        table.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
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
