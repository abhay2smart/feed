//
//  FeedVM.swift
//  Feed
//
//  Created by Abhayjeet Singh on 29/06/23.
//

import Foundation
import CoreData
class FeedVM {
    private var isLoading = false
    private var page = 1
    func loadData(isInital: Bool, completion: @escaping (([Search]?)->())) {
        if isLoading {
            return
        }
        
        if !isInital && page < 2 {
            page = 2
        }
        
        //let url = "https://www.omdbapi.com/?apikey=57ff3294&s=Batman&page=\(page)"
        let url = "\(Constant.baseUrl)?apikey=\(Constant.APIKey)&s=Batman&page=\(page)"
        print("url \(url)")
        
        APIService.shared.makeApiTypeRequest(url: url, methodType: .get, expecting: Welcome.self) { [weak self] data, error in
            
            if error != nil {
                self?.isLoading = false
                completion(nil)
                return
            }
            
            guard let remoteData = data else {
                completion(nil)
                self?.isLoading = false
                print("No Data")
                return
            }
            
            // for the performance perspective it's not the good way to save the data in concurrent way, it's better to put the save logic in the cell
            
//            let group = DispatchGroup()
//            for feed in remoteData.search {
//                if PersistantManager.shared.isRecordExists(imdbID: feed.imdbID) {
//                    continue
//                }
//
//                group.enter()
//
//                guard let url = URL(string: feed.poster) else {
//                    continue
//                }
//
//                DispatchQueue.global().sync {
//                    if let data = try? Data(contentsOf: url) {
//                        var singleFeed = Search()
//                        singleFeed.imdbID = feed.imdbID
//                        singleFeed.year = feed.year
//                        singleFeed.title = feed.title
//                        singleFeed.poster = feed.poster
//                        singleFeed.imageData = data
//                        singleFeed.imageForOffline = nil
//                        PersistantManager.shared.saveSingleRecord(data: singleFeed) { status in
//                            print("is record saved for \(feed.imdbID) ---> \(status.description)")
//                        }
//
//                    }
//                    group.leave()
//
//                }
//            }
            
            
            
            
//            group.notify(queue: .main) {
//                completion(remoteData.search)
//                self?.page += 1
//                self?.isLoading = false
//            }
            
            completion(remoteData.search)
            self?.page += 1
            self?.isLoading = false
            
        }
        
    }
    
    
}
