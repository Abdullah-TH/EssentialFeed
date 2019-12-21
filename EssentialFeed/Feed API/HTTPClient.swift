//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Abdullah Althobetey on 07/08/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    
    /// The completion handler can be run in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
