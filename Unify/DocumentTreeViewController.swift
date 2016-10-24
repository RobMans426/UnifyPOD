//
//  DocumentTreeViewController.swift
//  UnifyPOD
//
//  Created by Shawn Henck on 1/26/16.
//  Copyright © 2016 Adrenaline. All rights reserved.
//

import Foundation
import UIKit

class DocumentTreeViewController : BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var documentTableView: UITableView!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var setupButton: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var headerIconTemp: UIImageView!
    @IBOutlet weak var headerSectionIcon: UIImageView!
    @IBOutlet weak var scrollForMoreView: UIView!
    
    var category : Category?
    
    private var categories : Array<Category>?
    
    private var content : Array<Category>?
    
    private var displayCategories = true
    
    override func getGAIName() -> String? {
        
        if (category?.label != nil) {
            return "Category - \(category!.label!)"
        }
        else {
            return "Document Tree"
        }
    }
      
    override func viewDidLoad() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appTimeout", name: "KioskApplicationTimeout", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "returnToMain", name: "DocumentTreeReturnToMain", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "closeModals", name: "DocumentTreeCloseModals", object: nil)
        
        self.documentTableView.delegate = self
        self.documentTableView.dataSource = self
        
        loadData();
    }
    
    func loadData(){
        if( category == nil ) {
            
            self.categories = PODClient.instance.categories
            self.backButton.hidden = true
            
        } else {
            
            headerLabel.text = category!.label
            if( self.category?.categories != nil ) {
                
                self.categories = category?.categories
                
            }
        }
        
        self.documentTableView.reloadData();
        
        if( (displayCategories && self.categories?.count > 4 ) || (!displayCategories && self.content?.count > 4 )) {
            
            self.scrollForMoreView.hidden = false
        } else {
            self.scrollForMoreView.hidden = true
        }
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background_pattern")!)

    }
    
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver( self )
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
            self.dismissViewControllerAnimated(false, completion: {})
            super.setIsModalUp( false )
        }
        
        self.dismissViewControllerAnimated(false, completion: {
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil )
        })
        
    }
    
    func closeModals() {
        debugPrint("Notification Close Modals")
        //check if modal up
        if( super.isModalUp() ) {
            
            self.dismissViewControllerAnimated(false, completion: {
                super.setIsModalUp( false )
            })
            
        }
    }
    
    @IBAction func clickBack(sender: AnyObject) {
        
        //come from left...
        let transition = CATransition()
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        transition.removedOnCompletion = true
        
        self.view.window?.layer.addAnimation(transition, forKey: kCATransition)
        
        let sb = UIStoryboard(name: "DocumentTree", bundle: nil)
        let vc = sb.instantiateViewControllerWithIdentifier("DocumentTreeViewController") as! DocumentTreeViewController
        vc.category = category!.parent
        
        self.navigationController?.pushViewController( vc, animated: false)
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell : DocumentTreeSectionCell?
        
        let selectedBackgroundView = UIView()
        
        let category = self.categories![indexPath.row]
        
        var categoryParent = category
        while categoryParent.parent != nil {
            categoryParent = categoryParent.parent!
        }
        
        if( category.content == nil ) {
            
            
            
            
            if(category.parent == nil) {
                
                cell = tableView.dequeueReusableCellWithIdentifier("DocumentTreeMainSectionCell")! as! DocumentTreeSectionCell
                
                cell!.sectionTitle.text = category.label
                let iconFile = "\(NSTemporaryDirectory())cat_\(category.id!).png"
                cell!.sectionIcon.image = UIImage(contentsOfFile: iconFile)
                
                // Main menu
                
                cell!.backgroundColor = UIColor(patternImage: UIImage(named: "cell_bg_black_2048")!)       //Image tiles, but needs to be larger
                selectedBackgroundView.backgroundColor = UIColor(red: 87.0/255, green: 170.0/255, blue: 220.0/255, alpha: 1.0)
                self.documentTableView.separatorColor = UIColor(red: 78.0/255, green: 80.0/255, blue: 88.0/255, alpha: 1.0)
                self.headerSectionIcon.hidden = true

            }
            else
            {
                
                // Sub Category
                debugPrint("Subcategory")
                cell = tableView.dequeueReusableCellWithIdentifier("DocumentTreeSubSectionCell")! as! DocumentTreeSectionCell
                
                cell!.sectionTitle.text = category.label
                
                cell!.backgroundColor = UIColor(patternImage: UIImage(named: "cell_bg_blue_2048")!)
                selectedBackgroundView.backgroundColor = UIColor(red: 53.0/255, green: 139.0/255, blue: 191.0/255, alpha: 1.0)
                self.documentTableView.separatorColor = UIColor(red: 202.0/255, green: 228.0/255, blue: 244.0/255, alpha: 1.0)
                let iconFile = "\(NSTemporaryDirectory())cat_\(categoryParent.id!)_selected.png"
                self.headerSectionIcon.image = UIImage(contentsOfFile: iconFile)
            }
            
            cell!.backgroundView?.contentMode = UIViewContentMode.TopLeft
            
            
            
        } else {
            
            cell = tableView.dequeueReusableCellWithIdentifier("DocumentTreeLeafCell")! as! DocumentTreeSectionCell
            
            //let category = self.content![indexPath.row]
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.categories!.count
        
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! DocumentTreeSectionCell
        
        let category = self.categories![indexPath.row]
        
        if( category.parent == nil && cell.sectionIcon != nil ) {
            debugPrint("Switch Icon:")
            let iconFile = "\(NSTemporaryDirectory())cat_\(category.id!)_selected.png"
            cell.sectionIcon.image = UIImage(contentsOfFile: iconFile)
        }
        
        
        return true
    }
    
    func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! DocumentTreeSectionCell
        
        let category = self.categories![indexPath.row]
        
        if( category.parent == nil && cell.sectionIcon != nil) {
            let iconFile = "\(NSTemporaryDirectory())cat_\(category.id!).png"
            cell.sectionIcon.image = UIImage(contentsOfFile: iconFile)
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        //return height to be 25% of table height
        return tableView.frame.height/4
        
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        debugPrint("didDeselectRowAtIndexPath")
        
        let category = self.categories![indexPath.row]
        
        if(  category.content == nil && category.categories?.count > 0 ) {
        //if( displayCategories ) {
            
            let category = self.categories![indexPath.row]
            
            debugPrint( "Tapped \(category.label)" )
            
            let sb = UIStoryboard(name: "DocumentTree", bundle: nil)
            let vc = sb.instantiateViewControllerWithIdentifier("DocumentTreeViewController") as! DocumentTreeViewController
            vc.category = category
            
            self.navigationController?.pushViewController( vc, animated: true)
            
        //} else {
        } else if( category.content != nil ) {
            
            //let content = self.content![indexPath.row]
            let content = category.content!
            
            debugPrint( "Tapped For Content \(category.label)" )
            
            //present in modal
            
            let sb = UIStoryboard(name: "DocumentTree", bundle: nil)
            let vc = sb.instantiateViewControllerWithIdentifier("PDFViewController") as! PDFViewController
            
            vc.modalInPopover = true
            vc.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
            vc.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
            
            let urlPath = "Untitleddocument"  //content.url!
            let pdfFile = "\(NSTemporaryDirectory())\(category.id!).pdf"
            
            vc.pdfURL = NSURL(fileURLWithPath: pdfFile)
            vc.content = category
            
            self.presentViewController(vc, animated: true, completion: {
                super.setIsModalUp( true )
            })
            
        } else {
            debugPrint("Dead end category.  No children or content.")
        }
    }
    
    @IBAction func clickSetup(sender: AnyObject) {
        showSetup()
    }
    
}