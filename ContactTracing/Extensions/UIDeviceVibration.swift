//
//  UIDeviceVibration.swift
//  ContactTracing
//
//  Created by Miguel Sicart on 13/09/2020.
//  Copyright © 2020 playable_systems. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

extension UIDevice
{
    static func vibrate()
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}
