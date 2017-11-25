//
//  SettingsController.swift
//  pollution
//
//  Created by Philipp Matthes on 10.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
import RevealingSplashView

class SettingsController: UITableViewController {
    
    @IBOutlet weak var roundedDesignSwitch: UISwitch!
    
    @IBOutlet weak var openAQCell: UITableViewCell!
    @IBOutlet weak var swiftSpinnerCell: UITableViewCell!
    @IBOutlet weak var chartsCell: UITableViewCell!
    @IBOutlet weak var dropperCell: UITableViewCell!
    @IBOutlet weak var swiftRaterCell: UITableViewCell!
    @IBOutlet weak var bryxBannerCell: UITableViewCell!
    @IBOutlet weak var revealingSplashViewCell: UITableViewCell!
    @IBOutlet weak var dtmHeatmapCell: UITableViewCell!
    @IBOutlet weak var gitHubCell: UITableViewCell!
    @IBOutlet weak var issueCell: UITableViewCell!
    
    @IBOutlet weak var popAndZoomOutCell: UITableViewCell!
    @IBOutlet weak var rotateOutCell: UITableViewCell!
    @IBOutlet weak var squeezeAndZoomOutCell: UITableViewCell!
    @IBOutlet weak var swingAndZoomOutCell: UITableViewCell!
    @IBOutlet weak var twitterCell: UITableViewCell!
    @IBOutlet weak var wobbleAndZoomOutCell: UITableViewCell!
    
    @IBOutlet weak var numberOfResultsField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDoneButton(withColor: State.shared.currentColor, onFields: [numberOfResultsField])
        numberOfResultsField.layer.cornerRadius = 2.5
        numberOfResultsField.text = String(State.shared.numberOfMapResults)
        roundedDesignSwitch.tintColor = State.shared.currentColor
        roundedDesignSwitch.onTintColor = State.shared.currentColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switchAnimationTypeCellsVisually(toAnimationType: State.shared.splashAnimationType)
    }
    
    @IBAction func roundedDesignSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            State.shared.cornerRadius = CGFloat(10)
        } else {
            State.shared.cornerRadius = CGFloat(0)
        }
        tabBarController!.tabBar.roundCorners([.topLeft, .topRight], withRadius: State.shared.cornerRadius)
    }
    
    func switchAnimationTypeCellsVisually(toAnimationType type: SplashAnimationType) {
        for cell in [popAndZoomOutCell, rotateOutCell, squeezeAndZoomOutCell, swingAndZoomOutCell, twitterCell, wobbleAndZoomOutCell] {
            cell!.accessoryType = .none
        }
        var cell: UITableViewCell
        switch type {
            case .popAndZoomOut:
                cell = popAndZoomOutCell
            case .rotateOut:
                cell = rotateOutCell
            case .squeezeAndZoomOut:
                cell = squeezeAndZoomOutCell
            case .swingAndZoomOut:
                cell = swingAndZoomOutCell
            case .twitter:
                cell = twitterCell
            case .woobleAndZoomOut:
                cell = wobbleAndZoomOutCell
            default:
                cell = UITableViewCell()
        }
        cell.accessoryType = .checkmark
        cell.tintColor = State.shared.currentColor
    }
    
    func updateAndSaveAnimationType(toAnimationType type: SplashAnimationType) {
        State.shared.splashAnimationType = type
        switchAnimationTypeCellsVisually(toAnimationType: type)
        
        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "NoShadowAppIcon")!,
                                                      iconInitialSize: CGSize(width: 70, height: 70),
                                                      backgroundColor: State.shared.currentColor).withPresetAnimationType()
        
        
        //Adds the revealing splash view as a sub view
        self.view.addSubview(revealingSplashView)
        
        let window = UIApplication.shared.keyWindow
        window?.addSubview(revealingSplashView)
        
        //Starts animation
        revealingSplashView.duration = 2.0
        revealingSplashView.startAnimation() {}
    }
    
    func setUpDoneButton(withColor color: UIColor, onFields fields: [UITextField]) {
        for field in fields {
            let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
            doneToolbar.barStyle       = UIBarStyle.default
            let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            let done: UIBarButtonItem  = UIBarButtonItem(title: NSLocalizedString("done", comment: "Done"), style: UIBarButtonItemStyle.done, target: self, action: #selector(self.doneButtonAction))
            done.tintColor = color
            
            var items = [UIBarButtonItem]()
            items.append(flexSpace)
            items.append(done)
            
            doneToolbar.items = items
            doneToolbar.sizeToFit()
            
            field.inputAccessoryView = doneToolbar
        }
    }
    
    @objc func doneButtonAction() {
        numberOfResultsField.resignFirstResponder()
    }
    
    @IBAction func fieldTouchDown(_ sender: UITextField) {
        sender.animateButtonPress(withBorderColor: State.shared.currentColor, width: 2.0, andDuration: 0.1)
    }
    
    @IBAction func fieldEditingDidEnd(_ sender: UITextField) {
        sender.animateButtonRelease(withBorderColor: State.shared.currentColor, width: 2.0, andDuration: 0.1)
    }
    
    @IBAction func numberOfResultsFieldEdited(_ sender: UITextField) {
        if var numberOfResults = Int(sender.text!) {
            if numberOfResults > 10000 {
                numberOfResults = 10000
            } else if numberOfResults < 1 {
                numberOfResults = 1
            }
            numberOfResultsField.text = String(numberOfResults)
            State.shared.numberOfMapResults = numberOfResults
        } else {
            numberOfResultsField.text = String(State.shared.numberOfMapResults)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var url: URL?
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        switch cell {
            case openAQCell:
                url = URL(string: "https://openaq.org/")!
            case swiftSpinnerCell:
                url = URL(string: "https://github.com/icanzilb/SwiftSpinner")!
            case chartsCell:
                url = URL(string: "https://github.com/danielgindi/Charts")!
            case dropperCell:
                url = URL(string: "https://github.com/kirkbyo/Dropper")!
            case swiftRaterCell:
                url = URL(string: "https://github.com/takecian/SwiftRater")!
            case bryxBannerCell:
                url = URL(string: "https://github.com/bryx-inc/BRYXBanner")!
            case revealingSplashViewCell:
                url = URL(string: "https://github.com/PiXeL16/RevealingSplashView")!
            case dtmHeatmapCell:
                url = URL(string: "https://github.com/PhilippMatthes/DTMHeatmap")!
            case gitHubCell:
                url = URL(string: "https://github.com/PhilippMatthes/no2")!
            case issueCell:
                url = URL(string: "https://github.com/PhilippMatthes/no2/issues")!
            
            case popAndZoomOutCell:
                updateAndSaveAnimationType(toAnimationType: .popAndZoomOut)
            case rotateOutCell:
                updateAndSaveAnimationType(toAnimationType: .rotateOut)
            case squeezeAndZoomOutCell:
                updateAndSaveAnimationType(toAnimationType: .squeezeAndZoomOut)
            case swingAndZoomOutCell:
                updateAndSaveAnimationType(toAnimationType: .swingAndZoomOut)
            case twitterCell:
                updateAndSaveAnimationType(toAnimationType: .twitter)
            case wobbleAndZoomOutCell:
                updateAndSaveAnimationType(toAnimationType: .woobleAndZoomOut)
            
            default:
                return
        }
        
        if let url = url {
            let svc = SFSafariViewController(url: url, tintColor: State.shared.currentColor)
            present(svc, animated: true, completion: nil)
        }
        self.tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
    }
    
    
}
