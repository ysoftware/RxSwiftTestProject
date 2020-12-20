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
    private var tagsDisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        applyViewModel()
    }

    override func viewWillLayoutSubviews() {
        tableView.contentInset.bottom = tagsStackView.frame.height
    }

    private func applyViewModel() {

        // MARK: Input

        viewModel.title
            .bind(to: rx.title)
            .disposed(by: disposeBag)

        viewModel.isRefreshing
            .bind(to: tableView.refreshControl!.rx.isRefreshing)
            .disposed(by: disposeBag)

        viewModel.restaurants
            .bind(to: tableView.rx.items(cellIdentifier: RestaurantCell.ID)) { _, viewModel, cell in
                guard let cell = cell as? RestaurantCell else { return }
                cell.nameLabel.text = viewModel.restaurant.name
                cell.subtitleLabel.text = viewModel.restaurant.cuisine.rawValue.capitalized
            }
            .disposed(by: disposeBag)

        viewModel.messageLabel
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)

        viewModel.selectedFiltersObserver
            .bind { [weak self] filters in
                guard let self = self else { return }
                self.tagsDisposeBag = DisposeBag()
                self.tagsStackView.arrangedSubviews
                    .forEach { $0.removeFromSuperview() }
                self.viewModel.tags
                    .map {
                        self.makeFilterLabel(
                            title: $0.rawValue.capitalized,
                            tag: Cuisine.allCases.firstIndex(of: $0)!,
                            isSelected: filters.contains($0)
                        )
                    }
                    .forEach { self.tagsStackView.addArrangedSubview($0) }
            }
            .disposed(by: disposeBag)

        // MARK: Output

        tableView.rx.itemSelected
            .map { $0.row }
            .bind(to: viewModel.itemSelectedObserver)
            .disposed(by: disposeBag)

        tableView.refreshControl?.rx
            .controlEvent(.valueChanged)
            .bind(to: viewModel.refreshObserver)
            .disposed(by: disposeBag)

        viewModel.initiate()
    }

    // MARK: - Setup

    private func setupViews() {
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.refreshControl = UIRefreshControl()

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

    // MARK: - Subviews

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

        let tap = UITapGestureRecognizer()
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true

        tap.rx.event
            .map { $0.view!.tag }
            .bind(to: viewModel.filterTapObserver)
            .disposed(by: tagsDisposeBag)

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
