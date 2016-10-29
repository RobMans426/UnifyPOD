//
//  PODClient.swift
//  UnifyPOD
//
//  Created by Shawn Henck on 1/25/16.
//  Copyright © 2016 Adrenaline. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

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

class PODClient : NSObject,  URLSessionDelegate {
    
    static let instance = PODClient()
    let fetchMOC = DataController().managedObjectContext
    
    var apiKey : String = ""
    var apiBase : String = "https://unify.adrenalineamp.com/api"
    var mandrillKey : String = ""
    
    var ENVIRONMENT : String = "PROD"
    
    var categories : Array<Category> = Array()
    var categoryIcons : Array<CategoryIcon> = Array()
    
    private override init() {
        
        let dict = Bundle.main.infoDictionary
        
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
    
    func register(accessToken:String, branchId:String, completion:  @escaping (_ completed:Bool, _ branchName:String?) -> Void ) {
        
        let endpoint = URL(string: "\(apiBase)/register/\(branchId)/\(accessToken)")
        
        debugPrint("Endpoint:\(endpoint!)")
        
        
        var request = URLRequest(url: endpoint!)
        
        let session = createSession()
        
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            
            do {
                
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                if(error == nil) {
                    
                    let json = JSON(data: data!)
                    
                    //look for status...
                    if json["status"] != JSON.null {
                        if( json["status"] == "failure" ) {
                            completion(false, nil)
                            return;
                        }
                    }
                    
                    debugPrint(json)
                    
                    self.apiKey = json["key"].string!
                    
                    completion(true, json["name"].string)
                    
                }
                else {
                    
                    debugPrint(error?.localizedDescription)
                    
                    completion(false, nil)
                }
                
                
            }
            
        })
        
        task.resume()
        
        self.sendHitDetails { (success) in
            self.clearCoreData()
            debugPrint("Hits Sent to API!")
        }
        
        self.sendDocsEmailed { (success) in
            self.clearCoreEmailedData()
            debugPrint("Emailed Docs Sent to API!")
        }
        
        self.sendDocsPrinted { (success) in
            self.clearCorePrintedData()
            debugPrint("Printed Docs Sent to API!")
        }

        
    }
    
    func loadVideo( branchId:String,  completion:@escaping (_ completed:Bool) -> Void  ) {
        
        let endpoint = URL(string: "\(apiBase)/attractloop/\(branchId)")
        
        debugPrint("Endpoint:\(endpoint!)")
        
        
        var request = URLRequest(url: endpoint!)
        let session = createSession()
        
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            
            do {
                
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                if(error == nil) {
                    
                    let json = JSON(data: data!)
                    
                    debugPrint(json)
                    
                    let videoURL = json["url"].string!
                    
                    debugPrint("Video URL: \(videoURL)")
                    
                    let url = URL(string: videoURL)
                    let tmpFile = "attract_loop.mp4"
                    let task = self.createDownloadTask(url: url!, tmpFile: tmpFile, completionHandler: {(completeion:Bool) -> Void in
                        
                        completion(true)
                        
                    })
                    task.resume()
                    
                    
                }
                else {
                    
                    debugPrint(error?.localizedDescription)
                    
                    completion(false)
                }
                
                
            }
            
        })
        
        task.resume()
        
    }
    
    func loadIcons(branchId:String,  completion: @escaping (_ completed:Bool) -> Void  ) {
        
        let endpoint = URL(string: "\(apiBase)/icons/\(branchId)")
        
        debugPrint("Endpoint:\(endpoint!)")
        
        
        var request = URLRequest(url: endpoint!)
        let session = createSession()
        
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(self.apiKey, forHTTPHeaderField: "X-API-KEY")
        
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            
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
                        
                        let url = URL(string: iconCat.url!)
                        var tmpFile = ""
                        if( iconCat.color == "W"  ) {
                            tmpFile = "cat_\(iconCat.categoryId!)_selected.png"
                        } else {
                            tmpFile = "cat_\(iconCat.categoryId!).png"
                        }
                        
                        let task = self.createDownloadTask(url: url!, tmpFile: tmpFile, completionHandler: {(completeion:Bool) -> Void in
                        
                        })
                        task.resume()
                    }
                    
                    completion(true )
                    
                }
                else {
                    
                    debugPrint(error?.localizedDescription)
                    
                    completion(false)
                }
                
                
            }
            
        })
        
        task.resume()
        
    }
    
    func loadDocumentTree(branchId: String, completion:@escaping (_ completed:Bool) -> Void ) {
        
        let endpoint = URL(string: "\(apiBase)/categories/\(branchId)")
        
        debugPrint("Endpoint:\(endpoint!)")
        
        
        var request = URLRequest(url: endpoint!)
        let session = createSession()
        
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //var products = Array<Service>()
        
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            
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
                        
                        let tasks = self.getCategoryDocumentDownloadTasks( cats: self.categories )
                        for task in tasks {
                            task.resume()
                        }
                    }
                    
                    
                    
                    
                    completion(true)
                    
                }
                else {
                    
                    //debugPrint(error?.localizedDescription)
                    
                    //debugPrint("Try local storage...")
                    self.loadCategoriesFromLocal()
                    if( self.categories.count > 0 ) {
                        completion(true)
                    } else {
                        completion(false)
                    }
                    
                }
                
                
            } /* catch {
                print(error)
            } */
            
        })
        
        task.resume()
        
    }
    
    private func getCategoryDocumentDownloadTasks(cats: Array<Category>) -> Array<URLSessionDataTask> {
        
        var tasks : Array<URLSessionDataTask> = Array()
        
        //start grabbing o pdfs...
        for cat in cats {
            
            if( cat.content != nil ) {
                
                let url = URL(string: cat.content!.url!)
                let tmpFile = "\(cat.id!).pdf"
                let task = self.createDownloadTask(url: url!, tmpFile: tmpFile, completionHandler: {(completeion:Bool) -> Void in
                    
                })
                
                tasks.append( task )
                
            }
            
            if( cat.categories?.count > 0 ) {

                tasks.append(contentsOf: self.getCategoryDocumentDownloadTasks(cats: cat.categories!))
            
            }
        }
        
        return tasks
        
    }
    
    private func loadCategoriesFromLocal() {
        
        let path =  Bundle.main.path(forResource: "test", ofType: "json")!
        let json = JSON(data: try! Data(contentsOf: URL(fileURLWithPath: path)))
        
        //debugPrint(json)
        
        if let cArray = json["categories"].array {
            for catJSON in cArray {
                
                let cat = Category(json: catJSON)
                categories.append( cat )
            }
        }

        
    }
    
    func sendEmail(recipient:String, documentURL: String, completion: @escaping (_ completed:Bool) -> Void  ) {
        
        var jsonPost : JSON = ["key":self.mandrillKey]
        
        let jsonEmail : JSON = ["email":recipient,"type":"to"]
        var emailArray = Array<JSON>()
        emailArray.append( jsonEmail )
        
        var message = JSON(["to":JSON(emailArray)])
        message["from_email"] = "no-reply@unifyfcu.com"
        //message["from_email"] = "no-reply@western.org"
        message["subject"] = "Your Requested UNIFY Financial Credit Union Product Sheet"
        
        
        let messageHTML = "Hi There!<br><br>Thank you for stopping by our UNIFY branch today. Below is a link with the information you requested while exploring our Products & Services kiosk.<br><br>If you have questions or need additional information, please phone our 24/7 Contact Center at 877.254.9328. Or visit us at UnifyFCU.com.<br><br>We look forward to seeing you again soon!<br /><br /><a href='\(documentURL)'>\(documentURL)</a>"
        let messageText = "Hi There!\n\n  Thanks for stopping by our UNIFY branch today. Below is a link with the information you requested while exploring our Products & Services kiosk.\n\nIf you have questions or need additional information, please phone our 24/7 Contact Center at 877.254.9328. Or visit us at UnifyFCU.com.\n\nWe look forward to seeing you again soon!\n\n\(documentURL)"
        
        message["html"].string = messageHTML
        message["text"].string = messageText
        
        jsonPost["message"] = message
        jsonPost["template_content"] = []
        
        debugPrint(jsonPost)
        
        let endpoint = URL(string: "https://mandrillapp.com/api/1.0/messages/send.json" )
        
        var request = URLRequest(url: endpoint!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = Foundation.URLSession.shared
        
        request.httpMethod = "POST"
        
        
        do {
            
            try request.httpBody = jsonPost.rawData()
            
            
            let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
                
                debugPrint( String(data: data!, encoding: String.Encoding.utf8) )
                
                if( error != nil ) {
                    debugPrint("Error: \(error?.localizedDescription)")
                    completion(false)
                } else {
                    
                    completion(true)
                    
                }
                
                
                
            })
            
            task.resume()
            
            
            
        } catch {
            print(error)
        }
    }
    
    func sendEmailSendGrid(recipient:String, documentURL: String, completion:@escaping (_ completed:Bool) -> Void  ) {
        
        let endpoint = URL(string: "https://api.sendgrid.com/api/mail.send.json" )
        
        var request = URLRequest(url: endpoint!)
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = Foundation.URLSession.shared
        
        let subject = "Unify Doc Request"
        
        let postString = "from=noreply@dragonarmy.com&to=\(recipient)&html=\(documentURL)&subject=\(subject)"
        
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        request.setValue("Bearer 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", forHTTPHeaderField: "Authorization")
        
        
            
            let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
                
                debugPrint( String(data: data!, encoding: String.Encoding.utf8) )
                
                if( error != nil ) {
                    debugPrint("Error: \(error?.localizedDescription)")
                    completion(false)
                } else {
                    
                    completion(true)
                    
                }
                
                
                
            })
            
            task.resume()
            
    }

    
    func createDownloadTask(url: URL, tmpFile: String, completionHandler : @escaping (_ success:Bool) -> Void ) -> URLSessionDataTask {
        
        var request = URLRequest(url: url)
        let session = createSession()
        
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            
            do {
                if(error == nil) {
                    
                    //write data to file
                    let tempDir = NSTemporaryDirectory()
                    let fileManager = FileManager.default
                    
                    let fullPath = "\(tempDir)\(tmpFile)"
                    let file = FileHandle(forWritingAtPath:tmpFile)
                    
                    debugPrint("Writing to File \(file) : \(fullPath)")
                    
                    if  file == nil {
                        fileManager.createFile(atPath: fullPath, contents: data, attributes: nil)
                    } else {
                        file!.write(data!)
                    }
                    
                    file?.closeFile()
                    
                    completionHandler(true)
                }
                else {
                    
                    debugPrint(error?.localizedDescription)
                    completionHandler(false)
                }
                
            } /*catch {
                print(error)
                completionHandler(false)
            }*/
            
        })
        
        return task
    }
    
    func downloadFile(url: URL, tmpFile: String, completionHandler : @escaping (_ success:Bool) -> Void ) {
        
        let task = self.createDownloadTask(url: url, tmpFile: tmpFile, completionHandler: completionHandler)
        task.resume()
        
    }
    
    func downloadData(url: URL, completionHandler:@escaping (_ data: Data?) -> Void ) {
        
        var request = URLRequest(url: url)
        let session = createSession()
        
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            
            if( error != nil ) {
                debugPrint("ERROR: downloadData: \(error?.localizedDescription)")
            }
            
            completionHandler(data)
            
        })

        task.resume()
    }

    
    private func createSession() -> Foundation.URLSession  {
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        return session
    }
    
    /* Delegate Methods */
    private func urlSession(session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        debugPrint("Did Receve Challenge")
        let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)//[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
        completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential,credential)
        
    }
   
    func sendHitDetails(completionHandler: @escaping (_ success: Bool?) -> Void) {
        
        let endpoint = URL(string: "\(apiBase)/hits.php")
        var request = URLRequest(url: endpoint!)
        let session = createSession()
        let data : JSON = self.fetchHits()
        
        request.httpMethod = "POST"
        
        do {
            
            try request.httpBody = data.rawData()
           
            let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
                
                if( error != nil ) {
                    debugPrint("ERROR: downloadData: \(error?.localizedDescription)")
                    completionHandler( false)
                } else {
                    
                    completionHandler( true)
                    
                }
                
            })
            
            task.resume()
            
            
        } catch {
            print(error)
        }
        
    }
    
    
    func sendDocsEmailed(completionHandler: @escaping (_ success: Bool?) -> Void) {
        
        let endpoint = URL(string: "\(apiBase)/emails.php")
        var request = URLRequest(url: endpoint!)
        let session = createSession()
        let data : JSON = self.fetchEmailedDocs()
        
        request.httpMethod = "POST"
        
        do {
            
            try request.httpBody = data.rawData()
            
            let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
                
                if( error != nil ) {
                    debugPrint("ERROR: downloadData: \(error?.localizedDescription)")
                    completionHandler(false)
                } else {
                    
                    completionHandler( true)
                    
                }
                
            })
            
            task.resume()
            
            
        } catch {
            print(error)
        }
        
    }
    
    
    func sendDocsPrinted(completionHandler: @escaping (_ success: Bool?) -> Void) {
        
        let endpoint = URL(string: "\(apiBase)/prints.php")
        var request = URLRequest(url: endpoint!)
        let session = createSession()
        let data : JSON = self.fetchPrintedDocs()
        
        request.httpMethod = "POST"
        
        do {
            
            try request.httpBody = data.rawData()

            let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
                
                if( error != nil ) {
                    debugPrint("ERROR: downloadData: \(error?.localizedDescription)")
                    completionHandler(false)
                } else {
                    
                    completionHandler(true)
                    
                }
                
            })
            
            task.resume()
            
            
        } catch {
            print(error)
        }
        
    }
    
    
    
    func fetchHits() -> JSON {
        
        var jsonHitsArray = Array<JSON>()
        let fetchRequestViews: NSFetchRequest<PageViews> = PageViews.fetchRequest()
        let hitsData = NSMutableData()
        var dataDict = [String : String]()
        
        do {
            let fetchedPageHits = try fetchMOC.fetch(fetchRequestViews as! NSFetchRequest<NSFetchRequestResult>) as! [PageViews]
            
            
            //log all page hits
            for views in fetchedPageHits {
                
                if (views.branchId != nil && views.documentName != nil && views.documentURL != nil) {
                    
                    dataDict["id"] = String(describing: views.id!)
                    dataDict["branch_id"] = views.branchId
                    dataDict["name"] = views.documentName
                    dataDict["url"] = views.documentURL
                    
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: dataDict, options: JSONSerialization.WritingOptions.prettyPrinted)
                        
                        hitsData.append(jsonData)
                        
                        
                        jsonHitsArray.append(JSON(data: jsonData))
                        
                    } catch let error as NSError {
                        debugPrint(error)
                    }
                    
                }
                
            }
            
            let jsonDict = JSON(["hits" : JSON(jsonHitsArray)])
            
            
            //return the dictionary in JSON encoded format
            return jsonDict
            
        } catch {
            fatalError("An error has occurred: \(error)")
        }
        
    }
    
    
    func fetchPrintedDocs() -> JSON {
        
        var jsonPrintedArray = Array<JSON>()
        let fetchRequestPrints: NSFetchRequest<PrintedDocs> = PrintedDocs.fetchRequest()
        
        let printedData = NSMutableData()
        var dataPrintedDict = [String : String]()
        
        do {
            let fetchedPagePrints = try fetchMOC.fetch(fetchRequestPrints as! NSFetchRequest<NSFetchRequestResult>) as! [PrintedDocs]
            
            
            //log all page prints
            for prints in fetchedPagePrints {
                
                if (prints.branchId != nil && prints.documentName != nil && prints.documentURL != nil) {
                    
                    dataPrintedDict["id"] = String(describing: prints.id!)
                    dataPrintedDict["branch_id"] = prints.branchId
                    dataPrintedDict["name"] = prints.documentName
                    dataPrintedDict["url"] = prints.documentURL
                    
                    do {
                        let jsonPrintedData = try JSONSerialization.data(withJSONObject: dataPrintedDict, options: JSONSerialization.WritingOptions.prettyPrinted)
                        
                        printedData.append(jsonPrintedData)
                        
                        
                        jsonPrintedArray.append(JSON(data: jsonPrintedData))
                        
                    } catch let error as NSError {
                        debugPrint(error)
                    }
                    
                }
                
            }
            
            let jsonPrintedDict = JSON(["prints" : JSON(jsonPrintedArray)])
            
            
            //return the dictionary in JSON encoded format
            return jsonPrintedDict
            
        } catch {
            fatalError("An error has occurred: \(error)")
        }
        
    }
    
    
    func fetchEmailedDocs() -> JSON {
        
        var jsonEmailedArray = Array<JSON>()
        let fetchRequestPrints: NSFetchRequest<EmailedDocs> = EmailedDocs.fetchRequest()
        
        let emailedData = NSMutableData()
        var dataEmailedDict = [String : String]()
        
        do {
            let fetchedPageEmails = try fetchMOC.fetch(fetchRequestPrints as! NSFetchRequest<NSFetchRequestResult>) as! [EmailedDocs]
            
            
            //log all page emails
            for emails in fetchedPageEmails {
                
                if (emails.branchId != nil && emails.documentName != nil && emails.documentURL != nil) {
                    
                    dataEmailedDict["id"] = String(describing: emails.id!)
                    dataEmailedDict["branch_id"] = emails.branchId
                    dataEmailedDict["name"] = emails.documentName
                    dataEmailedDict["url"] = emails.documentURL
                    
                    do {
                    
                        let jsonEmailedData = try JSONSerialization.data(withJSONObject: dataEmailedDict, options: JSONSerialization.WritingOptions.prettyPrinted)
                        
                        emailedData.append(jsonEmailedData)
                        
                        
                        jsonEmailedArray.append(JSON(data: jsonEmailedData))
                        
                    } catch let error as NSError {
                        debugPrint(error)
                    }
                    
                }
                
            }
            
            let jsonEmailedDict = JSON(["emails" : JSON(jsonEmailedArray)])
            //            debugPrint("FINAL JSON: \(jsonDict)")
            
            //return the dictionary in JSON encoded format
            return jsonEmailedDict
            
        } catch {
            fatalError("An error has occurred: \(error)")
        }
        
    }
    
    
    
    
    func clearCoreData() {
        
        let fetchRequest: NSFetchRequest<PageViews> = PageViews.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        
        do {
            
            try fetchMOC.execute(batchDeleteRequest)
            
        } catch {
            
            fatalError("An error has occurred: \(error)")
        }
        
    }
    
    func clearCorePrintedData() {
        
        let fetchRequest: NSFetchRequest<PrintedDocs> = PrintedDocs.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        
        do {
            
            try fetchMOC.execute(batchDeleteRequest)
            
        } catch {
            
            fatalError("An error has occurred: \(error)")
        }
        
    }
    
    
    func clearCoreEmailedData() {
        
        let fetchRequest: NSFetchRequest<EmailedDocs> = EmailedDocs.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        
        do {
            
            try fetchMOC.execute(batchDeleteRequest)
            
        } catch {
            
            fatalError("An error has occurred: \(error)")
        }
        
    }
}
