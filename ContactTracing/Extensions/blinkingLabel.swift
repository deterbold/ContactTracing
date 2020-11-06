//
//  blinkingLabel.swift
//  ContactTracing
//
//  Created by Miguel Angel Sicart on 03/05/2020.
//  Copyright © 2020 playable_systems. All rights reserved.
//


//https://stackoverflow.com/questions/6224468/blinking-effect-on-uilabel/39936878
import Foundation
import UIKit

extension UILabel
{
    func blink(duration: Float)
    {
        self.alpha = 0.0
        UIView.animate(withDuration: TimeInterval(duration), delay: 0.0, options: [.curveEaseIn, .autoreverse, .repeat], animations: { [weak self] in self?.alpha = 1.0 }, completion: nil)
    }
    
    func stopBlink()
    {
        self.alpha = 0.0
        self.layer.removeAllAnimations()
    }
    
    func personalLabel()
    {
        print("here")
        textColor = .white
//        if traitCollection.userInterfaceStyle == .light
//        {
//            textColor = .black
//        }
//        else if traitCollection.userInterfaceStyle == .dark
//        {
//            textColor = .white
//        }
        adjustsFontSizeToFitWidth = true
        textAlignment = .center
        backgroundColor = .clear
        numberOfLines = 0
        
    }
}
