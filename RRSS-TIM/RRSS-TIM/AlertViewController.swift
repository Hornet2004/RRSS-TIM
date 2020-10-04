//
//  AlertViewController.swift
//  RRSS-TIM
//
//  Created by Tim on 10/3/20.
//

import UIKit

class AlertViewController: UIViewController {
    
    @IBOutlet weak var ignoreButton: UIButton!
    @IBOutlet weak var messagesButton: UIButton!
    var orbitalData: [[String]] = [[]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make the buttons rounded
        ignoreButton.layer.cornerRadius = 10
        ignoreButton.clipsToBounds = true
        messagesButton.layer.cornerRadius = 10
        messagesButton.clipsToBounds = true
        
        // Get the API data
//        http_Get()
        
        // Parse the orbital data -> Source JPL Horizons Earth/Mars positions relative to sun
        csvArray()
    }
    
    @IBAction func ignoreMessage(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func viewMessage(_ sender: Any) {
        dismiss(animated: true, completion: {
            // Send notification to show messages tab
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showMessages"), object: nil)
        })
    }
    
    func http_Get() {

        print("Getting data...")

        // Create URL
        let url = URL(string: "https://api.nasa.gov/insight_weather/?api_key=Q7zm61KlJrbdblnTF2UkPQldiDMRDwpoAinoqqwr&feedtype=json&ver=1.0")
        guard let requestUrl = url else { fatalError() }
        // Create URL request
        var request = URLRequest(url: requestUrl)
        // Set request method
        request.httpMethod = "GET"
        // Send Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            // Check for errors
            if let error = error {
                print("Error took place \(error)")
                return
            }

            // Read response status code
            if let response = response as? HTTPURLResponse {
                print("Status code: \(response.statusCode)")
            }

            // Convert response to String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                //print("Data string:\n \(dataString)")
                
                // Convert data to dictionary
                /* *****************************************************************
                  PIP - The code below is the issue. The data gets stored under the 7 keys (one for each day).
                  However, each day has several values each with their own sets of values and the dictionary
                  only captures the top level. If you run this you will see the output for a single days data.
                */
                do {
                        if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                            // Print the entire dictionary
                            //print(dict)
                            
                            // Print one day
                            let day = dict["653"]
                            print(day ?? "Key not found.")
                            
                            // NSDictionary is probably not the best method. Using multiple Structs is probably easier
                            // However it will require 3 levels: See Structs.swift file

                        }
                    } catch let error as NSError {
                           print(error.localizedDescription)
                 }

            }

        }
        task.resume()

        print("Request ended.")

    }
    
    func csvArray() {
        
        var dataArray : [[String]] = [[]]
        if  let path = Bundle.main.path(forResource: "HorizonsData", ofType: "csv") {
            dataArray = [[]]
            let url = URL(fileURLWithPath: path)
            do {
                let data = try Data(contentsOf: url)
                let stringData = String(data: data, encoding: .utf8)
                if  let lines = stringData?.components(separatedBy: NSCharacterSet.newlines) {
                    for line in lines {
                        dataArray.append(line.components(separatedBy: ","))
                    }
                    orbitalData = dataArray
                }
            }
            catch let err {
                    print("\n Error reading CSV file: \n", err)
            }
        }
    }


}
