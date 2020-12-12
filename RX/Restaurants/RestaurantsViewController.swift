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

    private let disposeBag = DisposeBag()
    private let viewModel = RestaurantsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        applyViewModel()
    }

    private func applyViewModel() {
        title = viewModel.title
        viewModel
            .fetchRestaurantsViewModel()
            .observeOn(MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: "cell")) { index, viewModel, cell in
                cell.textLabel?.text = viewModel.displayRowValue
            }.disposed(by: disposeBag)
    }

    // MARK: - Subviews

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .white
        view.addSubview(table)
        table.snp.makeConstraints { $0.edges.equalToSuperview() }
        table.tableFooterView = UIView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
}
