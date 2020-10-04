//
//  HomeViewController.swift
//  RRSS-TIM
//
//  Created by Tim on 10/3/20.
//

import UIKit

class HomeViewController: UIViewController {
    
    var insight: NSDictionary = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func HTTP_Request(_ sender: Any) {
        http_Get()
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
                            
                            // If all levels were parsed we could find the data like this:
//                            let day = dict["653"]!["AT"]!["MN"]! // To get the min temperature for day 653
//                            print(day ?? "Key not found.")

                        }
                    } catch let error as NSError {
                           print(error.localizedDescription)
                 }

                print("Conversion complete.")
            }

        }
        task.resume()

        print("Request ended.")

    }

}
