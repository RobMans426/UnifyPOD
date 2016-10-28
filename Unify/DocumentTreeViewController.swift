//
//  DocumentTreeViewController.swift
//  UnifyPOD
//
//  Created by Shawn Henck on 1/26/16.
//  Copyright © 2016 Adrenaline. All rights reserved.
//

import Foundation
import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

class DocumentTreeViewController : BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var documentTableView: UITableView!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var setupButton: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var headerSectionIcon: UIImageView!
    @IBOutlet weak var scrollForMoreView: UIView!
    
    var category : Category?
    
    fileprivate var categories : Array<Category>?
    
    fileprivate var content : Array<Category>?
    
    fileprivate var displayCategories = true
    
    override func getGAIName() -> String? {
        
        if (category?.label != nil) {
            return "Category - \(category!.label!)"
        }
        else {
            return "Document Tree"
        }
    }
      
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(DocumentTreeViewController.appTimeout), name: NSNotification.Name(rawValue: "KioskApplicationTimeout"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DocumentTreeViewController.returnToMain), name: NSNotification.Name(rawValue: "DocumentTreeReturnToMain"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DocumentTreeViewController.closeModals), name: NSNotification.Name(rawValue: "DocumentTreeCloseModals"), object: nil)
        
        self.documentTableView.delegate = self
        self.documentTableView.dataSource = self
        
        loadData();
    }
    
    func loadData(){
        if( category == nil ) {
            
            self.categories = PODClient.instance.categories
            self.backButton.isHidden = true
            
        } else {
            
            headerLabel.text = category!.label
            if( self.category?.categories != nil ) {
                
                self.categories = category?.categories
                
            }
        }
        
        self.documentTableView.reloadData();
        
        if( (displayCategories && self.categories?.count > 4 ) || (!displayCategories && self.content?.count > 4 )) {
            
            self.scrollForMoreView.isHidden = false
        } else {
            self.scrollForMoreView.isHidden = true
        }
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background_pattern")!)

    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver( self )
    }
    
    override func appTimeout() {
        self.returnToMain()
        debugPrint("App Timeout: Call Start Attract Loop")
        self.startAttractLoop()
    }
    
    func returnToMain() {
        
        debugPrint("Return To Main")
        
        //check if modal up
        if( super.isModalUp() ) {
            debugPrint("Close Modal")
            self.dismiss(animated: false, completion: {})
            super.setIsModalUp( false )
        }
        
        self.dismiss(animated: false, completion: {
            self.navigationController?.dismiss(animated: true, completion: nil )
        })
        
    }
    
    func closeModals() {
        debugPrint("Notification Close Modals")
        //check if modal up
        if( super.isModalUp() ) {
            
            self.dismiss(animated: false, completion: {
                super.setIsModalUp( false )
            })
            
        }
    }
    
    @IBAction func clickBack(_ sender: AnyObject) {
        
        //come from left...
        let transition = CATransition()
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        transition.isRemovedOnCompletion = true
        
        self.view.window?.layer.add(transition, forKey: kCATransition)
        
        let sb = UIStoryboard(name: "DocumentTree", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "DocumentTreeViewController") as! DocumentTreeViewController
        vc.category = category!.parent
        
        self.navigationController?.pushViewController( vc, animated: false)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : DocumentTreeSectionCell?
        
        let selectedBackgroundView = UIView()
        
        let category = self.categories![(indexPath as NSIndexPath).row]
        
        var categoryParent = category
        while categoryParent.parent != nil {
            categoryParent = categoryParent.parent!
        }
        
        if( category.content == nil ) {
            
            if(category.parent == nil) {
                
                cell = tableView.dequeueReusableCell(withIdentifier: "DocumentTreeMainSectionCell")! as? DocumentTreeSectionCell
                
                cell!.sectionTitle.text = category.label
                let iconFile = "\(NSTemporaryDirectory())cat_\(category.id!).png"
                cell!.sectionIcon.image = UIImage(contentsOfFile: iconFile)
                
                // Main menu
                cell!.backgroundColor = UIColor(patternImage: UIImage(named: "cell_bg_black_2048")!)       //Image tiles, but needs to be larger
                selectedBackgroundView.backgroundColor = UIColor(red: 87.0/255, green: 170.0/255, blue: 220.0/255, alpha: 1.0)
                self.documentTableView.separatorColor = UIColor(red: 78.0/255, green: 80.0/255, blue: 88.0/255, alpha: 1.0)
                self.headerSectionIcon.isHidden = true

            }
            else
            {
                
                // Sub Category
                debugPrint("Subcategory")
                cell = tableView.dequeueReusableCell(withIdentifier: "DocumentTreeSubSectionCell")! as? DocumentTreeSectionCell
                
                cell!.sectionTitle.text = category.label
                
                cell!.backgroundColor = UIColor(patternImage: UIImage(named: "cell_bg_blue_2048")!)
                selectedBackgroundView.backgroundColor = UIColor(red: 53.0/255, green: 139.0/255, blue: 191.0/255, alpha: 1.0)
                self.documentTableView.separatorColor = UIColor(red: 202.0/255, green: 228.0/255, blue: 244.0/255, alpha: 1.0)
                let iconFile = "\(NSTemporaryDirectory())cat_\(categoryParent.id!)_selected.png"
                self.headerSectionIcon.image = UIImage(contentsOfFile: iconFile)
            }
            
            cell!.backgroundView?.contentMode = UIViewContentMode.topLeft
            
            
            
        } else {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "DocumentTreeLeafCell")! as? DocumentTreeSectionCell
            
            cell!.sectionTitle.text = category.label
            
            // Document
            cell!.backgroundColor = UIColor(patternImage: UIImage(named: "cell_bg_purple_2048")!)
            selectedBackgroundView.backgroundColor = UIColor(red: 96.0/255, green: 86.0/255, blue: 154.0/255, alpha: 1.0)
            self.documentTableView.separatorColor = UIColor(red: 215.0/255, green: 212.0/255, blue: 233.0/255, alpha: 1.0)
            let iconFile = "\(NSTemporaryDirectory())cat_\(categoryParent.id!)_selected.png"
            self.headerSectionIcon.image = UIImage(contentsOfFile: iconFile)
            
        }
        cell!.selectedBackgroundView = selectedBackgroundView
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.categories!.count
        
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        
        let cell = tableView.cellForRow(at: indexPath) as! DocumentTreeSectionCell
        
        let category = self.categories![(indexPath as NSIndexPath).row]
        
        if( category.parent == nil && cell.sectionIcon != nil ) {
            debugPrint("Switch Icon:")
            let iconFile = "\(NSTemporaryDirectory())cat_\(category.id!)_selected.png"
            cell.sectionIcon.image = UIImage(contentsOfFile: iconFile)
        }
        
        
        return true
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! DocumentTreeSectionCell
        
        let category = self.categories![(indexPath as NSIndexPath).row]
        
        if( category.parent == nil && cell.sectionIcon != nil) {
            let iconFile = "\(NSTemporaryDirectory())cat_\(category.id!).png"
            cell.sectionIcon.image = UIImage(contentsOfFile: iconFile)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //return height to be 25% of table height
        return tableView.frame.height/4
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        debugPrint("didDeselectRowAtIndexPath")
        
        let category = self.categories![(indexPath as NSIndexPath).row]
        
        if(  category.content == nil && category.categories?.count > 0 ) {
            
            let category = self.categories![(indexPath as NSIndexPath).row]
            
            debugPrint( "Tapped \(category.label)" )
            
            let sb = UIStoryboard(name: "DocumentTree", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "DocumentTreeViewController") as! DocumentTreeViewController
            vc.category = category
            
            self.navigationController?.pushViewController( vc, animated: true)
            
        } else if( category.content != nil ) {
            
            debugPrint( "Tapped For Content \(category.label)" )
            
            //present in modal
            
            let sb = UIStoryboard(name: "DocumentTree", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "PDFViewController") as! PDFViewController
            
            vc.isModalInPopover = true
            vc.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            vc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            
            let pdfFile = "\(NSTemporaryDirectory())\(category.id!).pdf"
            
            vc.pdfURL = URL(fileURLWithPath: pdfFile)
            vc.content = category
            
            self.present(vc, animated: true, completion: {
                super.setIsModalUp( true )
            })
            
        } else {
            debugPrint("Dead end category.  No children or content.")
        }
    }
    
    @IBAction func clickSetup(_ sender: AnyObject) {
        showSetup()
    }
    
}
