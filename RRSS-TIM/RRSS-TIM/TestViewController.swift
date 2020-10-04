//
//  NavViewController.swift
//  RRSS-TIM
//
//  Created by Tim on 10/3/20.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sun: UIImageView!
    @IBOutlet weak var earth: UIImageView!
    @IBOutlet weak var mars: UIImageView!
    @IBOutlet weak var solarSystem: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var latencyLabel: UILabel!
    var orbitalData: [[String]] = [[]]
    var ssWidth: CGFloat = 0
    var ssHeight: CGFloat = 0
    var originX: CGFloat = 0
    var originY: CGFloat = 0
    var xDivisor: CGFloat = 0
    var yDivisor: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.messagesSegue), name: NSNotification.Name(rawValue: "showMessages"), object: nil)
        
        // Format the objects
        sun.layer.cornerRadius = sun.frame.size.width / 2
        sun.clipsToBounds = true
        earth.layer.cornerRadius = earth.frame.size.width / 2
        earth.clipsToBounds = true
        mars.layer.cornerRadius = mars.frame.size.width / 2
        mars.clipsToBounds = true
        
        // Get the container width / height - Offset for mars size
        ssWidth = solarSystem.frame.size.width - 16
        ssHeight = solarSystem.frame.size.height - 16
        
        // Get the 0,0 coordinates (Center of sun)
        originX = solarSystem.frame.size.width / 2
        originY = solarSystem.frame.size.height / 2
        
        print("X origin: ", originX)
        print("Y origin: ", originY)
        
        // Create an array of orbital data from the csv file
        // ** Data from JPL Horizons **
        self.csvArray()
        
        // Format the slider
        slider.minimumValue = 1
        slider.maximumValue = Float(orbitalData.count - 1)
        slider.value = 1
        print("Data points: ", orbitalData.count)
        
        // Calculate the x and y divisors
        xDivisor = 208000000 / (solarSystem.frame.size.width - 100)*2
        yDivisor = 236000000 / (solarSystem.frame.size.height - 100)*2
        
        // Set the initial positions of earth and mars
        setPositions(index: 1)
        print("Earth x: ", earth.frame.origin.x)
        print("Earth y: ", earth.frame.origin.y)
        print("Mars x: ", mars.frame.origin.x)
        print("Mars y: ", mars.frame.origin.y)
        
        // Set the labels
        setDate(index: 1)
        setDistance(index: 1)
        
        // Create a timer for the alert to appear
        self.delayAlert()
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        let roundedValue = round(slider.value)
        slider.value = roundedValue
        
        print("Slider value: ", slider.value)
        
        // Set the positions
        setPositions(index: Int(slider.value))
        
        // Set the labels
        setDate(index: Int(slider.value))
        setDistance(index: Int(slider.value))
        
    }
    
    func setDate(index: Int) {
        dateLabel.text = "Earth Date: " + orbitalData[index][0]
    }
    
    func setDistance(index: Int) {
        // Get the x,y,z coordinates
        let earthX = NumberFormatter().number(from: orbitalData[index][1]) as! CGFloat
        let earthY = NumberFormatter().number(from: orbitalData[index][2]) as! CGFloat
        let earthZ = NumberFormatter().number(from: orbitalData[index][3]) as! CGFloat
        let marsX = NumberFormatter().number(from: orbitalData[index][4]) as! CGFloat
        let marsY = NumberFormatter().number(from: orbitalData[index][5]) as! CGFloat
        let marsZ = NumberFormatter().number(from: orbitalData[index][6]) as! CGFloat
        
        // Calculate the distance
        let distance = round(sqrt(pow(earthX - marsX, 2)+pow(earthY-marsY, 2)+pow(earthZ-marsZ, 2)))
        
        // Calculate the latency
        let latency = round(((distance / 299792) / 60) * 10) / 10
        
        // Format the number
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .scientific
        numberFormatter.positiveFormat = "0.###E+0"
        numberFormatter.exponentSymbol = "e"
        let sciDistance = numberFormatter.string(from: NSNumber(value: Float(distance)))
        
        // Set the distance label
        distanceLabel.text = "Distance Earth to Mars: " + sciDistance! + " km"
        
        // Set the latency label
        latencyLabel.text = "Communication Latency: " + "\(latency)" + " mins"
    }
    
    func setPositions(index: Int) {
        // Get the positions from the array
        let earthX = NumberFormatter().number(from: orbitalData[index][1]) as! CGFloat
        let earthY = NumberFormatter().number(from: orbitalData[index][2]) as! CGFloat
        let marsX = NumberFormatter().number(from: orbitalData[index][4]) as! CGFloat
        let marsY = NumberFormatter().number(from: orbitalData[index][5]) as! CGFloat
        
        // Set the relative screen position
        earth.frame.origin.x = (originX + earthX / xDivisor) + earth.frame.size.width / 2
        earth.frame.origin.y = (originY + earthY / yDivisor) - earth.frame.size.height / 2
        mars.frame.origin.x = (originX + marsX / xDivisor) + mars.frame.size.width / 2
        mars.frame.origin.y = (originY + marsY / yDivisor) - mars.frame.size.height / 2
    }
    
    func delayAlert() {
        
        // Set the delay time
        let delay = DispatchTime.now() + 60.0
        
        // Set the action
        DispatchQueue.main.asyncAfter(deadline: delay, execute: {
        
            self.performSegue(withIdentifier: "alertSegue", sender: nil)
        
        })
        
    }
    
    @objc func messagesSegue() {
        // Modal segue to message alert
        tabBarController?.selectedIndex = 1
    }
    
    func csvArray() {
        
        // Create the temp array
        var dataArray : [[String]] = [[]]
        // Get the path to the csv file
        if  let path = Bundle.main.path(forResource: "HorizonsData", ofType: "csv") {
            let url = URL(fileURLWithPath: path)
            // Put the data into the temp array
            do {
                let data = try Data(contentsOf: url)
                let stringData = String(data: data, encoding: .utf8)
                if  let lines = stringData?.components(separatedBy: NSCharacterSet.newlines) {
                    for line in lines {
                        if line != "" {
                            dataArray.append(line.components(separatedBy: ","))
                        }
                    }
                    // Set the array property
                    orbitalData = dataArray
                }
            }
            catch let err {
                    print("\n Error reading CSV file: \n", err)
            }
        }
    }

}
