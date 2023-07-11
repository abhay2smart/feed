//
//  NetworkManager.swift
//  Feed
//
//  Created by Abhayjeet Singh on 29/06/23.
//

import Foundation

import Foundation
import UIKit
import SystemConfiguration


enum DataError : Error {
    case invalidUrl
    case invalidStatusCode
}


enum HttpMethodType : String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

final class APIService {
    static let shared = APIService()
    private init() {}
    
    private let timeInterval = 60
    func makeApiTypeRequest<T: Codable>(
        url: String,
        param: [String: Any]? = nil,
        methodType: HttpMethodType,
        expecting: T.Type,
        passToken: Bool = true,
        completion: @escaping (T?, _ errorMessage:String?)->Void) {
            
            guard let url = URL(string: url) else {
                return
            }
            
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: TimeInterval(timeInterval))
            if let param = param {
                let finalData = try? JSONSerialization.data(withJSONObject: param)
                request.httpBody = finalData
            }
            
            request.httpMethod = methodType.rawValue //"post"
            request.addValue("application/json", forHTTPHeaderField: "content-type")
            
            
            
            
            
            URLSession.shared.dataTask(with: request) { (data,response,error) in
                do {
                    
                    if let error = error {
                        completion(nil, error.localizedDescription)
                        return
                    }
                    
                    if let data = data {
                        do {
                            let a = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                            print("APIService->String JSON DATA:: \(a)")
                        } catch {
                            print("Error APIService@\(#line)-> \(error.localizedDescription)")
                        }
                    }
                    
                    
                    if let data = data {
                        if let httpStatus = response as? HTTPURLResponse {
                            print("Status code::: \(httpStatus.statusCode)")
                            switch httpStatus.statusCode {
                            case 400:
                                completion(nil, "Error 400")
                            case 200:
                                let resp = String(decoding: data, as: UTF8.self)
                                print("APIService->JSON Response: \(resp)")
                                let respObj = try JSONDecoder().decode(T.self, from: data)
                                completion(respObj, nil)
                            case 500:
                                completion(nil, "Error 500")
                            default:
                                completion(nil, "Unknown Error")
                                print("Error \(self) @\(#line)-> UNKNOWN")
                            }
                        }
                        
                    } else {
                        completion(nil, "Unknown Error")
                        print("Error \(self) @\(#line)-> UNKNOWN")
                    }
                } catch(let error) {
                    completion(nil, "\(error.localizedDescription)")
                    print("Error \(self) @\(#line)-> UNKNOWN")
                    
                }
            }.resume()
            
        }
    
    func makeAsyncRequest<T: Decodable>(url: String) async throws -> T {
        guard let url = URL(string: url) else {
            throw DataError.invalidUrl
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw DataError.invalidStatusCode
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    
    var isConnectedToNetwork : Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                
                SCNetworkReachabilityCreateWithAddress(nil, $0)
                
            }
            
        }) else {
            
            return false
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    
    
    
}




