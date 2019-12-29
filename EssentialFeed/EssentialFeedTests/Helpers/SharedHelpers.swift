//
//  SharedHelpers.swift
//  EssentialFeedTests
//
//  Created by Abdullah Althobetey on 18/12/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0, userInfo: nil)
}

func anyURL() -> URL {
    return URL(string: "http//aurl.com")!
}
