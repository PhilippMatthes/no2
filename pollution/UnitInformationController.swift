//
//  UnitInformationController.swift
//  pollution
//
//  Created by Philipp Matthes on 28.10.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class UnitInformationController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet var viewBackground: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func initDesign(withColor color: UIColor, andUnit unit: String) {
        self.view.addSubview(navigationBar)
        let navigationItem = UINavigationItem(title: NSLocalizedString("information", comment: "Information"))
        
        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector (self.closeButtonPressed (_:)))
        doneItem.tintColor = color
        navigationItem.rightBarButtonItem = doneItem
        navigationBar.setItems([navigationItem], animated: true)
        
        navigationBar.tintColor = color
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:Constants.colors[unit]!]

        viewBackground.backgroundColor = color
        
        webView.loadRequest(URLRequest(url: NSURL(string: NSLocalizedString(unit+"info", comment: "Link"))! as URL))
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func userSwipedDown(_ sender: UISwipeGestureRecognizer) {
        performSegueToReturnBack()
    }
    
    @objc func closeButtonPressed(_ sender:UITapGestureRecognizer){
        performSegueToReturnBack()
    }
    
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
