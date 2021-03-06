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
import Pulsator
import UserNotifications
import AVFoundation
import CoreHaptics

class socialDistanceController: UIViewController, CBPeripheralManagerDelegate, CLLocationManagerDelegate
{
    
    //MARK: BEACON CREATION VARIABLES
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!
    var localBeaconMajor: CLBeaconMajorValue!
    var localBeaconMinor: CLBeaconMinorValue!
    var beaconIdentifier: String!
    
    //MARK: BEACON TRACKING VARIABLES
    var locationManager: CLLocationManager!
    
    //MARK: INTERFACE
    var startButton: UIButton!
    var stopButton: UIButton!
    var instructionsButton: UIButton!
    var labelUUID: UILabel!
    var majorLabel: UILabel!
    var minorLabel: UILabel!
    var distanceLabel: UILabel!
    var debugSwitch: UISwitch!
    
    var pulsator : Pulsator? = nil
    
    var pulseView: UIImageView!
    var pulseColor: CGColor!
    var pulseRadius: CGFloat!
    var pulseRep: Int!
    var pulseAnimDuration: Double!
    
    var proximityLabel: UILabel!
    
    //MARK: - VARIABLES
    var debug:Bool!
    
    //MARK: - USER DEFAULTS
    let defaults = UserDefaults.standard
    
    //MARK: - SOUND VARIABLES
    //https://stackoverflow.com/questions/32036146/how-to-play-a-sound-using-swift
    //https://stackoverflow.com/questions/35289918/play-audio-when-device-in-silent-mode-ios-swift
    var theScream: AVAudioPlayer?
    
    //MARK: - HAPTICS VARIABLES
    var hapticsAvailable: Bool { CHHapticEngine.capabilitiesForHardware().supportsHaptics}
    var hapticEngine: CHHapticEngine?
    
    //MARK: - VIEW DID APPEAR
    
    override func viewDidAppear(_ animated: Bool)
    {
        
        //MARK: PULSE
        pulseView = UIImageView(frame: CGRect(x: view.frame.midX, y: view.frame.midY, width: 1, height: 1))
        pulseView.backgroundColor = .black
        view.addSubview(pulseView)
        
        pulsator = Pulsator()
       
        pulseColor = CGColor(srgbRed: 0, green: 0.46, blue: 0.76, alpha: 1)
        pulseRadius = 600.0
        pulseRep = 6
        pulseAnimDuration = 6.0
        pulsator!.backgroundColor = pulseColor
        pulsator!.radius = pulseRadius
        pulsator!.numPulse = pulseRep
        pulsator!.animationDuration = pulseAnimDuration
        pulseView.layer.addSublayer(pulsator!)
        pulsator!.start()
    }
 
    //MARK: - VIEW DID LOAD
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .black
        debug = false
//
//        //MARK: PULSE
//        pulseView = UIImageView(frame: CGRect(x: view.frame.midX, y: view.frame.midY, width: 1, height: 1))
//        pulseView.backgroundColor = .black
//        view.addSubview(pulseView)
//
//        pulsator = Pulsator()
//
//        pulseColor = CGColor(srgbRed: 0, green: 0.46, blue: 0.76, alpha: 1)
//        pulseRadius = 600.0
//        pulseRep = 6
//        pulseAnimDuration = 6.0
//        pulsator!.backgroundColor = pulseColor
//        pulsator!.radius = pulseRadius
//        pulsator!.numPulse = pulseRep
//        pulsator!.animationDuration = pulseAnimDuration
//        pulseView.layer.addSublayer(pulsator!)
//        pulsator!.start()
        
        //MARK: SWITCH
        debugSwitch = UISwitch(frame: CGRect(x: self.view.frame.midX - 25, y: 100, width: 50, height: 50))
        debugSwitch.addTarget(self, action: #selector(debugF), for: .valueChanged)
        debugSwitch.setOn(false, animated: false)
        self.view.addSubview(debugSwitch)

        
        
        //MARK: PROXIMITY LABEL
        proximityLabel = UILabel(frame: CGRect(x: self.view.frame.midX - 50, y: self.view.frame.midY - 25, width: 100, height: 50))
        proximityLabel.adjustsFontSizeToFitWidth = true
        proximityLabel.textColor = .white
        proximityLabel.textAlignment = .center
        proximityLabel.backgroundColor = .clear
        proximityLabel.numberOfLines = 2
        proximityLabel.text = "Nothing around you"
        self.view.addSubview(proximityLabel)
        

        //MARK: BUTTONS
        startButton = UIButton(frame: CGRect(x: (view.frame.midX) - 150, y: (view.frame.midY) - 50, width: 100, height: 50))
        startButton.backgroundColor = .darkGray
        startButton.layer.cornerRadius = 14
        startButton.setTitle("Start Beacon", for: .normal)
        startButton.addTarget(self, action: #selector(initLocalBeacon), for: .touchUpInside)
        startButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.view.addSubview(startButton)
        startButton.isHidden = true
        
        stopButton = UIButton(frame: CGRect(x: (view.frame.midX) + 50, y: (view.frame.midY) - 50, width: 100, height: 50))
        stopButton.backgroundColor = .darkGray
        stopButton.layer.cornerRadius = 14
        stopButton.setTitle("Stop Beacon", for: .normal)
        stopButton.addTarget(self, action: #selector(stopLocalBeacon), for: .touchUpInside)
        stopButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.view.addSubview(stopButton)
        stopButton.isHidden = true
        
        instructionsButton = UIButton(frame: CGRect(x: self.view.frame.midX - 100, y: self.view.frame.height - 200, width: 200, height: 100))
        instructionsButton.backgroundColor = .clear
        instructionsButton.setTitleColor(.systemBlue, for: .normal)
        instructionsButton.layer.cornerRadius = 14
        instructionsButton.setTitle("INSTRUCTIONS", for: .normal)
        instructionsButton.addTarget(self, action: #selector(toInstructions), for: .touchUpInside)
        instructionsButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.view.addSubview(instructionsButton)

        
        //MARK: LABELS
        distanceLabel = UILabel(frame: CGRect(x: self.view.frame.midX - 100, y: self.view.frame.height - 200, width: 200, height: 100))
        distanceLabel.adjustsFontSizeToFitWidth = true
        distanceLabel.textColor = .white
        distanceLabel.textAlignment = .center
        distanceLabel.backgroundColor = .darkGray
        distanceLabel.text = ""
        self.view.addSubview(distanceLabel)
        distanceLabel.isHidden = true
        
        //MARK: HAPTINGS ENGINE INIT
        if hapticsAvailable
        {
            print ("haptics available")
            do
            {
                hapticEngine = try CHHapticEngine()
                try hapticEngine?.start()
            } catch {
                print("there was an error creating the haptics engine: \(error.localizedDescription)")
            }
        }
        
        //MARK: BEACON TRACKING INITS
        //we initialize the location manager
        //the delegate is the self (ah, programming)
        //we need the user authorization
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
        
        //MARK: BEACON CREATION INITS
        beaconIdentifier = "Individual Contact"
        
        initLocalBeacon()
        
        
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func toInstructions()
    {
        self.pulsator?.stop()
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let sd = storyBoard.instantiateViewController(withIdentifier: "instructionsController")
        sd.modalPresentationStyle = .overFullScreen
        self.present(sd, animated: true, completion: nil)
    }
    
    
    @objc func debugF(_ sender:UISwitch)
    {
        debug.toggle()
        if(debug)
        {
            startButton.isHidden = false
            stopButton.isHidden = false
            distanceLabel.isHidden = false
        }
        else
        {
            startButton.isHidden = true
            stopButton.isHidden = true
            distanceLabel.isHidden = true
        }
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
        startButton.backgroundColor = .red
        let localBeaconUUID = "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"
        let uuid = UUID(uuidString: localBeaconUUID)
        //localBeacon = CLBeaconRegion(proximityUUID:uuid!, major: 123, minor: 456, identifier: beaconIdentifier)
        localBeacon = CLBeaconRegion(uuid: uuid!, major: 123, minor: 456, identifier: beaconIdentifier)
        localBeacon.notifyOnEntry = true
        localBeacon.notifyOnExit = true
        beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    //MARK: -Stopping the Beacon
    @objc func stopLocalBeacon()
    {
        print("Beacon stopped")
        startButton.backgroundColor = .darkGray
        if localBeacon != nil
        {
            if peripheralManager != nil
            {
                peripheralManager.stopAdvertising()
                peripheralManager = nil
                beaconPeripheralData = nil
                localBeacon = nil
            }
        }
        
    }
    
    //MARK: - Beacon State Update
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn
        {
            print("powered on")
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
            print("authorized")
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
            //MARK: NOTIFICATIONS CODE
            //https://www.raywenderlich.com/632-ibeacon-tutorial-with-ios-and-swift#toc-anchor-006
            let content = UNMutableNotificationContent()
            content.title = "Beacon notification template"
            content.body = "Beacon detected"
            content.sound = .default
            
            let request = UNNotificationRequest(identifier: "BeaconID", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
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
        
       let localBeaconUUID = "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"
        let uuid = UUID(uuidString: localBeaconUUID)
        //localBeacon = CLBeaconRegion(proximityUUID:uuid!, major: 123, minor: 456, identifier: beaconIdentifier)
        localBeacon = CLBeaconRegion(uuid: uuid!, major: 123, minor: 456, identifier: beaconIdentifier)
        
        //looking for beacons
        locationManager.startMonitoring(for: localBeacon)
        
        //and trying to figure out how far away they are
        let beaconConstraint = CLBeaconIdentityConstraint(uuid: uuid!, major: 123, minor: 456)
        locationManager.startRangingBeacons(in: localBeacon)
        locationManager.startRangingBeacons(satisfying: beaconConstraint)
        locationManager.startMonitoring(for: localBeacon)
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
            distanceLabel.text = "Unknown Distance"
            proximityLabel.text = "Nothing around you"
            proximityLabel.layer.removeAllAnimations()
            self.pulsator!.backgroundColor = pulseColor
            self.pulsator!.animationDuration = 2
            self.pulsator!.numPulse = 3
            self.pulsator!.radius = 600
            self.pulsator!.pulseInterval = 3
            print("Interval: ", self.pulsator!.numPulse)
            //sound
            theScream?.stop()
            
        case .far:
            print("Far Distance")
            distanceLabel.text = "Far Distance"
            proximityLabel.text = "Something is out there"
            proximityLabel.blink(duration: 1)
            self.pulsator!.backgroundColor = CGColor(srgbRed: 255, green: 255, blue: 0, alpha: 1)
            self.pulsator!.animationDuration = 3
            self.pulsator!.numPulse = 4
            self.pulsator!.radius = 450
            //sound
            theScream?.stop()
            
        case .near:
            print("Near Distance")
            distanceLabel.text = "Near Distance"
            proximityLabel.text = "Something is close to you"
            proximityLabel.blink(duration: 0.9)
            self.pulsator!.backgroundColor = CGColor(srgbRed: 255, green: 165, blue: 0, alpha: 1)
            self.pulsator!.animationDuration = 4
            self.pulsator!.numPulse = 5
            self.pulsator!.radius = 200
            //sound
            theScream?.stop()
            
        case .immediate:
            print("Immediate Distance")
            distanceLabel.text = "Immediate Distance"
            proximityLabel.text = "Something is next to you"
            proximityLabel.blink(duration: 0.4)
            self.pulsator!.backgroundColor = CGColor(srgbRed: 255, green: 0, blue: 0, alpha: 1)
            self.pulsator!.animationDuration = 6
            self.pulsator!.radius = 200
            self.pulsator!.pulseInterval = 0
            self.pulsator!.numPulse = 8
            //MARK: - Screaming when close by
            let path = Bundle.main.path(forResource: "theScream.mp3", ofType: nil)!
            let url = URL(fileURLWithPath: path)
            do
            {
                theScream = try AVAudioPlayer(contentsOf: url)
                try AVAudioSession.sharedInstance().setCategory(.playback)
                theScream?.play()
            }
            catch
            {
                print("could not load file")
            }
            //MARK: - Going crazy on vibrations
            if hapticsAvailable
            {
                var events = [CHHapticEvent]()
                for i in stride(from: 0, to: 1, by: 0.1)
                {
                    let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(1 - i))
                    let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(1 - i))
                    let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i)
                    events.append(event)
                }
                do
                {
                    let patter = try CHHapticPattern(events: events, parameters:  [])
                    let player = try hapticEngine?.makePlayer(with: patter)
                    try player?.start(atTime: 0)
                }
                catch
                {
                    print("failed to play pattern: \(error.localizedDescription).")
                }
            }
            else
            {
                UIDevice.vibrate()
            }
                   
            print("Interval: ", self.pulsator!.numPulse)
            
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

