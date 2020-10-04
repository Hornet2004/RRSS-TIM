//
//  MessageDetailViewController.swift
//  RRSS-TIM
//
//  Created by Tim on 10/3/20.
//

import UIKit

class MessageDetailViewController: UIViewController {

    @IBOutlet weak var repeaterButton: UIButton!
    @IBOutlet weak var clarifyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Make the buttons rounded
        repeaterButton.layer.cornerRadius = 10
        repeaterButton.clipsToBounds = true
        clarifyButton.layer.cornerRadius = 10
        clarifyButton.clipsToBounds = true
        
    }
    
    @IBAction func useRepeater(_ sender: Any) {
        performSegue(withIdentifier: "successSegue", sender: nil)
    }
    
    @IBAction func sendClarification(_ sender: Any) {
        performSegue(withIdentifier: "sendSegue", sender: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
