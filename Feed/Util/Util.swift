//
//  Util.swift
//  Feed
//
//  Created by Abhayjeet Singh on 01/07/23.
//

import UIKit

class Util {
    static func getAspectImageHeight(image:UIImage?)->CGFloat {
        guard let safeImage = image else {
            return 0
        }
        let hRatio = safeImage.size.height / safeImage.size.width
        let newImageHeight = hRatio * UIScreen.main.bounds.width
        return newImageHeight
    }
}
