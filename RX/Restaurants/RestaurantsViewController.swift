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
    private let cellId = "Cell"
    private let disposeBag = DisposeBag()
    private let viewModel = RestaurantsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        applyViewModel()
        setupViews()
    }

    private func applyViewModel() {
        title = viewModel.title
        let observable = viewModel
            .fetchRestaurantsViewModels()
            .observeOn(MainScheduler.instance)
            .share(replay: 1, scope: .whileConnected)

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

        observable
            .catchError { _ in
                .just([])
            }
            .map { [weak self] value -> [RestaurantViewModel] in
                self?.tableView.refreshControl?.endRefreshing()
                return value
            }
            .bind(to: tableView.rx.items(cellIdentifier: cellId)) { _, viewModel, cell in
                cell.textLabel?.text = viewModel.displayRowValue
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Subviews

    private func setupViews() {
        navigationController?.navigationBar.prefersLargeTitles = true
        view.addSubview(tableView)
        view.addSubview(label)

        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addAction(UIAction(handler: { _ in
            self.viewModel.refresh()
        }), for: .valueChanged)

        label.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(18)
            $0.centerX.centerY.equalToSuperview()
        }

        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
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
}
