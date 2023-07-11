//
//  DeTailsViewController.swift
//  Feed
//
//  Created by Abhayjeet Singh on 30/06/23.
//

import UIKit

class DetailsViewController: UIViewController {
    @IBOutlet weak var movieNameLbl: UILabel?
    @IBOutlet weak var movieYearLbl: UILabel?
    @IBOutlet weak var movieImage: UIImageView?
    @IBOutlet weak var movieImageHeightConstraint: NSLayoutConstraint?
    private var data: Search?
    override func viewDidLoad() {
        super.viewDidLoad()
        initialise()
    }
    
    func initialise() {
        guard let data = data else {
            return
        }
        movieNameLbl?.text = data.title
        movieYearLbl?.text = "Year: \(data.year)"
        
        if data.downloadedImage != nil {
            movieImage?.image = data.downloadedImage
            movieImageHeightConstraint?.constant = Util.getAspectImageHeight(image: data.downloadedImage)
            
        } else {
//            movieImageHeightConstraint?.constant = Util.getAspectImageHeight(image: image)
//            movieImage?.image = image
//            DispatchQueue.global().async {
//                guard let url = URL(string: data.poster) else {
//                    return
//                }
//                if let data = try? Data(contentsOf: url)  {
//                    DispatchQueue.main.async { [weak self] in
//                        let image = UIImage(data: data)
//                        self?.movieImageHeightConstraint?.constant = Util.getAspectImageHeight(image: image) ?? 0
//                        self?.movieImage?.image = image
//                    }
//
//                }
//            }
        }
    }
    
    
        

    
}

//MARK: - storyboard instance
extension DetailsViewController {
    class func instance(data: Search)->DetailsViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailsVC") as? DetailsViewController
        vc?.data = data
        return vc
    }
}
