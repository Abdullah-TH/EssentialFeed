//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Abdullah Althobetey on 08/12/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
