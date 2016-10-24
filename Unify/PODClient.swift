//
//  PODClient.swift
//  UnifyPOD
//
//  Created by Shawn Henck on 1/25/16.
//  Copyright © 2016 Adrenaline. All rights reserved.
//

import Foundation
import SwiftyJSON

class PODClient : NSObject,  NSURLSessionDelegate {
    
    static let instance = PODClient()
    
    var apiKey : String = ""
    var apiBase : String = "https://unify.adrenalineamp.com/api"
    var mandrillKey : String = ""
    
    var ENVIRONMENT : String = "PROD"
    
    var categories : Array<Category> = Array()
    var categoryIcons : Array<CategoryIcon> = Array()
    
    override private init() {
        
        let dict = NSBundle.mainBundle().infoDictionary
        
        if( ENVIRONMENT == "PROD" ) {
            
            //apiBase = dict!["API_BASE"] as! String
            //apiKey = dict!["API_KEY"] as! String
            mandrillKey = dict!["MANDRILL_API_KEY"] as! String
            
        } else {
            
            //apiBase = dict!["API_BASE"] as! String
            //apiKey = dict!["API_KEY"] as! String
            mandrillKey = dict!["MANDRILL_API_KEY"] as! String
            
        }
    }
    
    func register( branchId:String, completion: (completed:Bool, branchName:String?) -> Void ) {
        
        let endpoint = NSURL(string: "\(apiBase)/register/\(branchId)")
        
        debugPrint("Endpoint:\(endpoint!)")
        
        
        let request = NSMutableURLRequest(URL: endpoint!)
        
        let session = createSession()
        
        request.HTTPMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            do {
                
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                if(error == nil) {
                    
                    let json = JSON(data: data!)
                    
                    //look for status...
                    if json["status"] != nil {
                        if( json["status"] == "failure" ) {
                            completion(completed: false, branchName: nil)
                            return;
                        }
                    }
                    
                    debugPrint(json)
                    
                    self.apiKey = json["key"].string!
                    
                    completion(completed: true, branchName: json["name"].string)
                    
                }
                else {
                    
                    debugPrint(error?.localizedDescription)
                    
                    completion(completed: false, branchName: nil)
                }
                
                
            }
            
        })
        
        task.resume()
        
    }
    
    func loadVideo( branchId:String,  completion: (completed:Bool) -> Void  ) {
        
        let endpoint = NSURL(string: "\(apiBase)/attractloop/\(branchId)")
        
        debugPrint("Endpoint:\(endpoint!)")
        
        
        let request = NSMutableURLRequest(URL: endpoint!)
        let session = createSession()
        
        request.HTTPMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            do {
                
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                if(error == nil) {
                    
                    let json = JSON(data: data!)
                    
                    debugPrint(json)
                    
                    let videoURL = json["url"].string!
                    
                    debugPrint("Video URL: \(videoURL)")
                    
                    let url = NSURL(string: videoURL)
                    let tmpFile = "attract_loop.mp4"
                    let task = self.createDownloadTask(url!, tmpFile: tmpFile, completionHandler: {(completeion:Bool) -> Void in
                        
                        completion(completed: true)
                        
                    })
                    task.resume()
                    
                    
                }
                else {
                    
                    debugPrint(error?.localizedDescription)
                    
                    completion(completed: false)
                }
                
                
            }
            
        })
        
        task.resume()
        
    }
    
    func loadIcons( branchId:String,  completion: (completed:Bool) -> Void  ) {
        
        let endpoint = NSURL(string: "\(apiBase)/icons/\(branchId)")
        
        debugPrint("Endpoint:\(endpoint!)")
        
        
        let request = NSMutableURLRequest(URL: endpoint!)
        let session = createSession()
        
        request.HTTPMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(self.apiKey, forHTTPHeaderField: "X-API-KEY")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            do {
                
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                if(error == nil) {
                    
                    let json = JSON(data: data!)
                    
                    debugPrint(json)
                    
                    if let cArray = json.array {
                        for iconJSON in cArray {
                            
                            let icon = CategoryIcon(json: iconJSON)
                            self.categoryIcons.append( icon )
                        }
                    }
                    
                    for iconCat in self.categoryIcons {
                        
                        let url = NSURL(string: iconCat.url!)
                        var tmpFile = ""
                        if( iconCat.color == "W"  ) {
                            tmpFile = "cat_\(iconCat.categoryId!)_selected.png"
                        } else {
                            tmpFile = "cat_\(iconCat.categoryId!).png"
                        }
                        
                        let task = self.createDownloadTask(url!, tmpFile: tmpFile, completionHandler: {(completeion:Bool) -> Void in
                        
                        })
                        task.resume()
                    }
                    
                    completion( completed: true )
                    
                }
                else {
                    
                    debugPrint(error?.localizedDescription)
                    
                    completion(completed: false)
                }
                
                
            }
            
        })
        
        task.resume()
        
    }
    
    func loadDocumentTree( branchId: String, completion: (completed:Bool) -> Void ) {
        
        let endpoint = NSURL(string: "\(apiBase)/categories/\(branchId)")
        
        debugPrint("Endpoint:\(endpoint!)")
        
        
        let request = NSMutableURLRequest(URL: endpoint!)
        let session = createSession()
        
        request.HTTPMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //var products = Array<Service>()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            do {
                
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                if(error == nil) {
                    
                    let json = JSON(data: data!)
                    
                    debugPrint(json)
                    
                    var tmpCategories : Array<Category> = Array()
                    
                    if let cArray = json.array {
                        
                        for catJSON in cArray {
                            
                            let cat = Category(json: catJSON)
                            tmpCategories.append( cat )
                        }
                    }
                    
                    self.categories = tmpCategories
                    debugPrint("\(self.categories.count) Categories")
                    
                    if( self.categories.count > 0 ) {
                        
                        let tasks = self.getCategoryDocumentDownloadTasks( self.categories )
                        for task in tasks {
                            task.resume()
                        }
                    }
                    
                    
                    
                    
                    completion(completed: true)
                    
                }
                else {
                    
                    //debugPrint(error?.localizedDescription)
                    
                    //debugPrint("Try local storage...")
                    self.loadCategoriesFromLocal()
                    if( self.categories.count > 0 ) {
                        completion(completed: true)
                    } else {
                        completion(completed: false)
                    }
                    
                }
                
                
            } /* catch {
                print(error)
            } */
            
        })
        
        task.resume()
        
    }
    
    private func getCategoryDocumentDownloadTasks( cats: Array<Category>) -> Array<NSURLSessionDataTask> {
        
        var tasks : Array<NSURLSessionDataTask> = Array()
        
        //start grabbing o pdfs...
        for cat in cats {
            
            if( cat.content != nil ) {
                
                let url = NSURL(string: cat.content!.url!)
                let tmpFile = "\(cat.id!).pdf"
                let task = self.createDownloadTask(url!, tmpFile: tmpFile, completionHandler: {(completeion:Bool) -> Void in
                    
                })
                
                tasks.append( task )
                
            }
            
            if( cat.categories?.count > 0 ) {
                    tasks.appendContentsOf( self.getCategoryDocumentDownloadTasks( cat.categories! ) )
            }
        }
        
        return tasks
        
    }
    
    private func loadCategoriesFromLocal() {
        
        let path =  NSBundle.mainBundle().pathForResource("test", ofType: "json")!
        let json = JSON(data: NSData(contentsOfFile: path)!)
        
        //debugPrint(json)
        
        if let cArray = json["categories"].array {
            for catJSON in cArray {
                
                let cat = Category(json: catJSON)
                categories.append( cat )
            }
        }

        
    }
    
    func sendEmail( recipient:String, documentURL: String, completion: (completed:Bool) -> Void  ) {
        
        var jsonPost : JSON = ["key":self.mandrillKey]
        
        let jsonEmail : JSON = ["email":recipient,"type":"to"]
        var emailArray = Array<JSON>()
        emailArray.append( jsonEmail )
        
        var message = JSON(["to":JSON(emailArray)])
        message["from_email"] = "no-reply@unifyfcu.com"
        //message["from_email"] = "no-reply@western.org"
        message["subject"] = "Your Requested UNIFY Financial Credit Union Product Sheet"
        
        
        let messageHTML = "Thank you for stopping by our UNIFY branch today. Here is the information you requested.Questions or need additional information? Phone our Contact Center at 877.254.9328 or visit us at UnifyFCU.com.<br /><br /><a href='\(documentURL)'>\(documentURL)</a>"
        let messageText = "Thank you for stopping by our UNIFY branch today. Here is the information you requested.Questions or need additional information? Phone our Contact Center at 877.254.9328 or visit us at UnifyFCU.com.\(documentURL)"
        
        message["html"].string = messageHTML
        message["text"].string = messageText
        
        jsonPost["message"] = message
        jsonPost["template_content"] = []
        
        debugPrint(jsonPost)
        
        let endpoint = NSURL(string: "https://mandrillapp.com/api/1.0/messages/send.json" )
        
        let request = NSMutableURLRequest(URL: endpoint!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "POST"
        
        
        do {
            
            try request.HTTPBody = jsonPost.rawData()
            
            
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                
                debugPrint( String(data: data!, encoding: NSUTF8StringEncoding) )
                
                if( error != nil ) {
                    debugPrint("Error: \(error?.localizedDescription)")
                    completion(completed: false)
                } else {
                    
                    completion(completed: true)
                    
                }
                
                
                
            })
            
            task.resume()
            
            
            
        } catch {
            print(error)
        }
    }
    
    func sendEmailSendGrid( recipient:String, documentURL: String, completion: (completed:Bool) -> Void  ) {
        
        let endpoint = NSURL(string: "https://api.sendgrid.com/api/mail.send.json" )
        
        let request = NSMutableURLRequest(URL: endpoint!)
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = NSURLSession.sharedSession()
        
        let subject = "Unify Doc Request"
        
        let postString = "from=noreply@dragonarmy.com&to=\(recipient)&html=\(documentURL)&subject=\(subject)"
        
        request.HTTPMethod = "POST"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        request.setValue("Bearer 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", forHTTPHeaderField: "Authorization")
        
        
            
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                
                debugPrint( String(data: data!, encoding: NSUTF8StringEncoding) )
                
                if( error != nil ) {
                    debugPrint("Error: \(error?.localizedDescription)")
                    completion(completed: false)
                } else {
                    
                    completion(completed: true)
                    
                }
                
                
                
            })
            
            task.resume()
            
            
            
       
    }

    
    func createDownloadTask( url: NSURL, tmpFile: String, completionHandler : (success:Bool) -> Void ) -> NSURLSessionDataTask {
        
        let request = NSMutableURLRequest(URL: url)
        let session = createSession()
        
        request.HTTPMethod = "GET"
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            do {
                if(error == nil) {
                    
                    //write data to file
                    let tempDir = NSTemporaryDirectory()
                    let fileManager = NSFileManager.defaultManager()
                    
                    let fullPath = "\(tempDir)\(tmpFile)"
                    let file = NSFileHandle(forWritingAtPath:tmpFile)
                    
                    debugPrint("Writing to File \(file) : \(fullPath)")
                    
                    if  file == nil {
                        fileManager.createFileAtPath(fullPath, contents: data, attributes: nil)
                    } else {
                        file!.writeData(data!)
                    }
                    
                    file?.closeFile()
                    
                    completionHandler(success: true)
                }
                else {
                    
                    debugPrint(error?.localizedDescription)
                    completionHandler(success: false)
                }
                
            } catch {
                print(error)
                completionHandler(success: false)
            }
            
        })
        
        return task
    }
    
    func downloadFile( url: NSURL, tmpFile: String, completionHandler : (success:Bool) -> Void ) {
        
        let task = self.createDownloadTask(url, tmpFile: tmpFile, completionHandler: completionHandler)
        task.resume()
        
    }
    
    func downloadData( url: NSURL, completionHandler: (data: NSData?) -> Void ) {
        
        let request = NSMutableURLRequest(URL: url)
        let session = createSession()
        
        request.HTTPMethod = "GET"
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            if( error != nil ) {
                debugPrint("ERROR: downloadData: \(error?.localizedDescription)")
            }
            
            completionHandler(data: data)
            
        })
        
        task.resume()
    }

    
    private func createSession() -> NSURLSession  {
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        return session
    }
    
    /* Delegate Methods */
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        
        debugPrint("Did Receve Challenge")
        let credential = NSURLCredential(trust: challenge.protectionSpace.serverTrust!)//[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential,credential)
        
    }
    
}