//
//  ViewController.swift
//  ContactTracing
//
//  Created by Miguel Angel Sicart on 27/04/2020.
//  Copyright © 2020 playable_systems. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralManagerDelegate, CLLocationManagerDelegate
{
    
    //MARK: BEACON CREATION VARIABLES
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!
    var localBeaconUUID: String!
    var localBeaconMajor: CLBeaconMajorValue!
    var localBeaconMinor: CLBeaconMinorValue!
    var beaconIdentifier: String!
    
    //MARK: BEACON TRACKING VARIABLES
    var locationManager: CLLocationManager!
    
    //MARK: INTERFACE
    var startButton: UIButton!
    var stopButton: UIButton!
    var labelUUID: UILabel!
    var majorLabel: UILabel!
    var minorLabel: UILabel!
    var distance: UILabel!
    
    //MARK: USER DEFAULTS
    let defaults = UserDefaults.standard
    
    override func viewDidAppear(_ animated: Bool)
    {
        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark
            {
                self.view.backgroundColor = .black
                
            }
            else if self.traitCollection.userInterfaceStyle == .light
            {
                self.view.backgroundColor = .white
            }
        } else {
            self.view.backgroundColor = .black
        }
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        //MARK: BUTTONS
        startButton = UIButton(frame: CGRect(x: (view.frame.midX) - 150, y: (view.frame.midY) - 50, width: 100, height: 50))
        startButton.backgroundColor = .darkGray
        startButton.layer.cornerRadius = 14
        startButton.setTitle("Start Beacon", for: .normal)
        startButton.addTarget(self, action: #selector(initLocalBeacon), for: .touchUpInside)
        startButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.view.addSubview(startButton)
        
        stopButton = UIButton(frame: CGRect(x: (view.frame.midX) + 50, y: (view.frame.midY) - 50, width: 100, height: 50))
        stopButton.backgroundColor = .darkGray
        stopButton.layer.cornerRadius = 14
        stopButton.setTitle("Stop Beacon", for: .normal)
        stopButton.addTarget(self, action: #selector(stopLocalBeacon), for: .touchUpInside)
        stopButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.view.addSubview(stopButton)
        
        //MARK: BEACON TRACKING INITS
        //we initialize the location manager
        //the delegate is the self (ah, programming)
        //we need the user authorization
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        //MARK: BEACON CREATION INITS
        if !UserDefaults.contains("UUID")
        {
            localBeaconUUID = UUID().uuidString
            defaults.set(localBeaconUUID, forKey: "UUID")
            localBeaconMajor = 123
            defaults.set(localBeaconMajor, forKey: "Major")
            localBeaconMinor = 456
            defaults.set(localBeaconMinor, forKey: "Minor")
            beaconIdentifier = randomString(length: 8)
            defaults.set(beaconIdentifier, forKey: "Identifier")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    ///-------------------------------------------------///
    //MARK: BEACON CREATION SECTION
    
    //MARK: Initializing the Beacon
    @objc func initLocalBeacon()
    {
        print("Beacon initialized")
        if localBeacon != nil
        {
            stopLocalBeacon()
        }
        
        let uuid = UUID(uuidString: localBeaconUUID)
        localBeacon = CLBeaconRegion(proximityUUID: uuid!, major: localBeaconMajor, minor: localBeaconMinor, identifier: "ABeacon")
        
        beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    //MARK: -Stopping the Beacon
    @objc func stopLocalBeacon()
    {
        print("Beacon stopped")
        if localBeacon != nil
        {
            peripheralManager.stopAdvertising()
            peripheralManager = nil
            beaconPeripheralData = nil
            localBeacon = nil
        }
        
    }
    
    //MARK: - Beacon State Update
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn
        {
            peripheralManager.startAdvertising(beaconPeripheralData as! [String: AnyObject]?)
        }
        else if peripheral.state == .poweredOff
        {
            peripheralManager.stopAdvertising()
        }
    }
    
    ///-------------------------------------------------///
    //MARK: BEACON TRACKING FUNCTIONS
    
    //MARK: - Location Manager Permissions
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        //adapted from the hacking with swift tutorial
        //if we are allowed to use location
        //SUPER IMPORTANT: IF IN MACOS, ADD THE FOLLOWING TO YOUR .PLIST
        //privacy location always usage description
        //or
        //privacy location when in use description
        if status == .authorizedAlways
        {
            //if our machine can monitor
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self)
            {
                //if it is possible to search for stuff within a range
                if CLLocationManager.isRangingAvailable()
                {
                    scanForBeacons()
                }
            }
        }
    }
    
    //MARK: - Location Manager Range
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion)
    {
        //if there are more than zero beacons
        if beacons.count > 0
        {
            //we take the first one from the array
            let beacon = beacons[0]
            //and we sen its distance to the update loop
            update(distance: beacon.proximity)
        }
        else //if there are no beacons around
        {
            //we tell the update loop that there is nothing to see here.
            update(distance: .unknown)
        }
    }
    
    
    //MARK: - Beacon Scanning
    func scanForBeacons()
    {
        //we declare the UUID to look for
        //this is the beacon UUID
        let uuid = UUID(uuidString:"5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")! //values here are taken from my Locate iOS app
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: "MyBeacon") //values here are taken from my Locate iOS app
        
        //looking for beacons
        locationManager.startMonitoring(for: beaconRegion)
        
        //and trying to figure out how far away they are
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    
    //MARK: - Update Loop
    
    //A loop that "pings" for proximity
    //I would make the calls to very simple game logic here
    //as in, things that say boom, state changes, etc.
    func update(distance: CLProximity)
    {
        switch distance
        {
        case .unknown:
            print("Unknown Distance")
        case .far:
            print("Far Distance")
        case .near:
            print("Near Distance")
        case .immediate:
            print("Immediate Distance")
        default:
            break
        }
    }
    
    ///-------------------------------------//
    //MARK: - UTILITIES
    //https://stackoverflow.com/questions/26845307/generate-random-alphanumeric-string-in-swift
    
    func randomString(length: Int) -> String
    {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}

