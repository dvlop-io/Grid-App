//
//  InitialViewController.swift
//  Grid
//
//  Created by Bryan Lloyd Anderson on 11/9/15.
//  Copyright © 2015 Bryan Lloyd Anderson. All rights reserved.
//

import UIKit
import Foundation

class InitialViewController: UIViewController, CheckConnectable {

    @IBOutlet weak var refreshButton: UIButton!
    
    @IBOutlet weak var wifiLogo: UIImageView!
    
    @IBOutlet weak var noInternetLabel: UILabel!
    
    @IBOutlet weak var pleaseEnableLabel: UILabel!
    
    @IBOutlet weak var loadingImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.refreshButton.alpha = 0
        self.wifiLogo.alpha = 0
        self.noInternetLabel.alpha = 0
        self.pleaseEnableLabel.alpha = 0
        self.view.backgroundColor = colorDarkGray
        
       
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        attemptConnecting()

    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    
    func attemptConnecting() {
        if isConnectedToNetwork() == true {
            self.performSegue(withIdentifier: "ToGrid", sender: self)
        } else {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.refreshButton.alpha = 1
                self.wifiLogo.alpha = 1
                self.noInternetLabel.alpha = 1
                self.pleaseEnableLabel.alpha = 1
                self.loadingImageView.alpha = 0
            })
        }
    }


    @IBAction func retry(_ sender: AnyObject) {
        attemptConnecting()
    }
    
    
    

}




