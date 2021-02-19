//
//  GenericTableView.swift
//  Way2SmsSystemTask
//
//  Created by Pradeep's Macbook on 18/02/21.
//  Copyright © 2021 Motiv Ate Fitness. All rights reserved.
//

import UIKit

final class GenericTableView<Item, Cell: UITableViewCell>: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Private Properties
    
    private var items: [Item]
    private var config: (Cell, Item) -> ()
    private var selectionHandler: (Item) -> ()
    private let selectionStyle: UITableViewCell.SelectionStyle
    private let separatorInsetStyle: UITableViewCell.SeparatorStyle
    private var canEditRow: Bool
    private var contextualHandler: (UITableView,IndexPath,(Bool) -> Void) -> ()
    
    //MARK: - Initialization
    
    init(data: [Item],canEditRow: Bool = false,style: UITableView.Style = .plain,separatorStyle: UITableViewCell.SeparatorStyle = .none,selectionStyle: UITableViewCell.SelectionStyle = .none,config: @escaping (Cell, Item) -> (), selectionHandler: @escaping (Item) -> (), contextualHandler: @escaping (UITableView,IndexPath,(Bool) -> Void) -> ()) {
        self.items = data
        self.config = config
        self.selectionHandler = selectionHandler
        self.selectionStyle = selectionStyle
        self.separatorInsetStyle = separatorStyle
        self.canEditRow = canEditRow
        self.contextualHandler = contextualHandler
        super.init(frame: .zero, style: style)
        self.configureTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configure ViewComponents
    
    private func configureTableView() {
        self.separatorStyle = separatorInsetStyle
        self.delegate   = self
        self.dataSource = self
        self.register(Cell.self)
        self.tableFooterView = UIView()
    }
    
    override func numberOfRows(inSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: Cell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.selectionStyle = self.selectionStyle
        config(cell, self.items[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = self.items[indexPath.row]
        selectionHandler(selectedItem)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction.init(style: .destructive, title: "Remove") { (action, view, completion) in
            self.contextualHandler(tableView,indexPath, completion)
        }
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeAction
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return canEditRow
    }
    
}

extension GenericTableView {
    
    func reloadOnMainThread(_ items: [Item]) {
        self.items = items
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
    
}
