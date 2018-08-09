//
//  StringContainsExtension.swift
//  Timeline
//
//  Created by Zachary Frew on 8/8/18.
//  Copyright © 2018 Zachary Frew. All rights reserved.
//

import Foundation

extension String {
    
    func contains(_ term: String) -> Bool {
        return self.range(of: term, options: .caseInsensitive) != nil
    }
    
}
