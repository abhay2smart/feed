//
//  FeedTableViewCell.swift
//  Feed
//
//  Created by Abhayjeet Singh on 29/06/23.
//

import UIKit
class FeedTableViewCell: UITableViewCell {
    @IBOutlet weak var feedImage: UIImageView?
    
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var titleLbl: UILabel?
    
    private var tableView: UITableView?
    
    func fillInfo(info: Search?, tableView: UITableView?) {
        guard let info = info else {
            return
        }
        
        titleLbl?.text = info.title
        
        if info.downloadedImage != nil {
            if let image = info.downloadedImage {
                imageHeightConstraint?.constant = Util.getAspectImageHeight(image: image)
                feedImage?.image = image
            }
        } else {
            self.tableView = tableView
            guard let url = URL(string: info.poster) else {
                return
            }
            guard let tableView = tableView else {
                return
            }
            
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async { [weak self] in
                        let image = UIImage(data: data)
                        self?.imageHeightConstraint?.constant = Util.getAspectImageHeight(image: image)
                        self?.feedImage?.image = image
                        
                        var singleFeed = Search()
                        singleFeed = info
                        //singleFeed.imageData = data
                        singleFeed.downloadedImage = image
                        self?.saveDataInDB(info: singleFeed)
                        tableView.performBatchUpdates(nil)
                    }
                    
                }
            }
            
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

//MARK: - save data in DB
extension FeedTableViewCell {
    private func saveDataInDB(info: Search) {
        DispatchQueue.global().async {
            PersistantManager.shared.saveSingleRecord(data: info) { status in
                print("is record saved for \(info.imdbID) ---> \(status.description)")
            }
        }
    }
}
