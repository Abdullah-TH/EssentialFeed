//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Abdullah Althobetey on 27/01/2020.
//  Copyright © 2020 AbdullahTH. All rights reserved.
//

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}
