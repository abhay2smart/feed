//
//  ViewController.swift
//  Feed
//
//  Created by Abhayjeet Singh on 29/06/23.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var noDataView: UIView?
    
    private var tableViewAdapter = TableViewAdapter()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let tableView = tableView else {
            return
        }
        
        tableViewAdapter.initialise(tableView: tableView, root: self)
    }
}

// MARK: - IBACTIONS
extension ViewController {
    @IBAction func refreshTableViewAction(sender: UIButton) {
        tableViewAdapter.loadRemoteData(isInitial: true)
    }
}

