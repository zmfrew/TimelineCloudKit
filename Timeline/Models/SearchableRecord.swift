//
//  SearchableRecord.swift
//  Timeline
//
//  Created by Zachary Frew on 8/8/18.
//  Copyright © 2018 Zachary Frew. All rights reserved.
//

import Foundation

protocol SearchableRecord {
    
    func matches(searchTerm: String) -> Bool
    
}
