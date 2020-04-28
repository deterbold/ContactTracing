//
//  UserDefaultsExt.swift
//  ContactTracing
//
//  Created by Miguel Angel Sicart on 28/04/2020.
//  Copyright © 2020 playable_systems. All rights reserved.
//

import Foundation

extension UserDefaults
{
    static func contains(_ key: String) -> Bool
    {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}
