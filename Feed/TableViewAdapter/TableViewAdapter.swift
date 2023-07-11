//
//  TableViewAdapter.swift
//  Feed
//
//  Created by Abhayjeet Singh on 29/06/23.
//

import UIKit

class TableViewAdapter: NSObject {
    private var tableView: UITableView?
    private var feedTableData = [Search]()
    private var root: ViewController?
    private var feedVM = FeedVM()
    
    private var reusableCellId = "feed_cell"
    
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    func initialise(tableView: UITableView, root: ViewController) {
        tableView.tableFooterView = activityIndicator
        self.tableView = tableView
        self.root = root
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        
        self.tableView?.estimatedRowHeight = UITableView.automaticDimension
        
        if APIService.shared.isConnectedToNetwork {
            
            activityIndicator.startAnimating()
            
            self.feedVM.loadData(isInital: true) { [weak self] data in
                
                guard let data = data else {
                    return
                }
                
                self?.feedTableData = data
                DispatchQueue.main.async {
                    self?.root?.noDataView?.isHidden = data.count > 0
                    self?.activityIndicator.stopAnimating()
                    self?.tableView?.reloadData()
                }
            }
        } else {
            print("Go offline")
            guard let offlineRecords = getOfflineData() else {
                return
            }
            
            self.feedTableData = offlineRecords
            
            DispatchQueue.main.async {
                self.root?.noDataView?.isHidden = self.feedTableData.count > 0
                self.tableView?.reloadData()
            }
            
        }
    }
    
}

//MARK: - tableView datasource
extension TableViewAdapter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        feedTableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reusableCellId) as? FeedTableViewCell
        if feedTableData.count > indexPath.row {
            let rowData = feedTableData[indexPath.row]
            cell?.fillInfo(info: rowData, tableView: tableView)
            
        }
        return cell ?? UITableViewCell()
    }
}
//MARK: - tableView delegate

extension TableViewAdapter: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if feedTableData.count > indexPath.row {
            var detailsData = feedTableData[indexPath.row]
            // No meaning of downloading image again in next screen just set the image in the model
            let cell = tableView.cellForRow(at: indexPath) as? FeedTableViewCell
            detailsData.downloadedImage = cell?.feedImage?.image
            guard let vc = DetailsViewController.instance(data: detailsData) else {
                return
            }
            
            self.root?.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    // Pagination stuff
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // UITableView only moves in one direction, y axis
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        // Change 10 to adjust the distance from bottom
        if maximumOffset - currentOffset <= 10 {
            if APIService.shared.isConnectedToNetwork {
                self.loadRemoteData(isInitial: false)
            }
        }
    }
}


//MARK: - helper functions
extension TableViewAdapter {
    
    func isRecordExists(arr: [Search]?, id: String)->Bool {
        guard let feeds = arr else {
            return false
        }
        
        for item in feeds {
            if item.imdbID == id {
                return true
            }
        }
        return false
    }
    
    
    func loadRemoteData(isInitial: Bool) {
        
        activityIndicator.startAnimating()
        self.feedVM.loadData(isInital: isInitial) { [weak self] data in
            guard let remoteData = data else {
                return
            }
            
            for feed in remoteData {
                if (feed.poster != "" && feed.poster != "N/A") && (feed.imdbID != "") {
                    if self?.isRecordExists(arr: self?.feedTableData, id: feed.imdbID) == false {
                        self?.feedTableData.append(feed)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.root?.noDataView?.isHidden = remoteData.count > 0
                self?.tableView?.reloadData()
            }
            
        }
        
    }
    
    
    func getOfflineData()->[Search]? {
        let allDBRecords = PersistantManager.shared.fetchRecordFromCoreData()
        if let allDBRecords = allDBRecords {
            var feedTableData = [Search]()
            for item in allDBRecords {
                var search = Search()
                search.imdbID = item.imdbID ?? ""
                search.title = item.title ?? ""
                search.year = item.year ?? "NOO"
                search.downloadedImage = UIImage(data: item.imageData ?? Data())
                if isRecordExists(arr: feedTableData, id: item.imdbID ?? "") == false {
                    feedTableData.append(search)
                }
            }
            
            return feedTableData
        }
        return nil
    }
    
}
