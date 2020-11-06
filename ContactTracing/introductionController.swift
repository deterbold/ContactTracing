//
//  introductionController.swift
//  ContactTracing
//
//  Created by Miguel Sicart on 06/11/2020.
//  Copyright © 2020 playable_systems. All rights reserved.
//

import UIKit

class introductionController: UIViewController
{
    var introductionLabel: UILabel!
    var startButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        //Label
        introductionLabel = UILabel(frame: CGRect(x: 0, y: 100, width: self.view.frame.width, height: self.view.frame.height/2))
        introductionLabel.personalLabel()
        introductionLabel.text =
            "This is a social distancing app.\n\nIt will help you keep distance from people\n\nPress START to start the app \n\nAWAY will run in the background\n while you live your life\nfree of worries and away from others"
        
        self.view.addSubview(introductionLabel)
        
        //Button
        startButton = UIButton(frame: CGRect(x: self.view.frame.midX - 100, y: self.view.frame.height - 200, width: 200, height: 100))
        startButton.setTitle("START", for: .normal)
        startButton.setTitleColor(.systemBlue, for: .normal)
        startButton.addTarget(self, action: #selector(startTheApp), for: .touchUpInside)
        self.view.addSubview(startButton)
       
    }
    
    @objc func startTheApp()
    {
        print("starting the app")
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let sd = storyBoard.instantiateViewController(withIdentifier: "socialDistanceController")
        sd.modalPresentationStyle = .overFullScreen
        print(sd)

        self.present(sd, animated: true, completion: nil)
     
    }

}
