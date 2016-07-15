//
//  AppDelegate.swift
//  Uzduotis
//
//  Created by Darius on 6/26/16.
//  Copyright © 2016 DariusPri. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Data from .csv files already parsed to a DB. No need to parse it again.
        
        //preloadData()
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.dapri.Uzduotis" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Uzduotis", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        
        if !NSFileManager.defaultManager().fileExistsAtPath(url.path!) {
            let sourceSqliteURLs = [NSBundle.mainBundle().URLForResource("SingleViewCoreData", withExtension: "sqlite")!, NSBundle.mainBundle().URLForResource("SingleViewCoreData", withExtension: "sqlite-wal")!, NSBundle.mainBundle().URLForResource("SingleViewCoreData", withExtension: "sqlite-shm")!]
            
            let destSqliteURLs = [self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite"),
                                  self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite-wal"),
                                  self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite-shm")]
            
            var error:NSError? = nil
            for index in 0 ..< sourceSqliteURLs.count {
                do {
                    try NSFileManager.defaultManager().copyItemAtURL(sourceSqliteURLs[index], toURL: destSqliteURLs[index])
                } catch {
                    print("Something went wrong with CoreData.")
                }
            }
        }
        
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    
    
    
    
    
    // CSV Parser
    
    func parseCSV (contentsOfURL: NSURL, encoding: NSStringEncoding, error: NSErrorPointer) -> [[String]]? {
        
        let delimiter = ","
        var items = [[String]]()
        
        if let data = NSData(contentsOfURL: contentsOfURL) {
            if let content = NSString(data: data, encoding: NSUTF8StringEncoding) {
                items = []
                let lines:[String] = content.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()) as [String]
                
                for line in lines {
                    var values:[String] = []
                    if line != "" {
                        if line.rangeOfString("\"") != nil {
                            var textToScan:String = line
                            var value:NSString?
                            var textScanner:NSScanner = NSScanner(string: textToScan)
                            while textScanner.string != "" {
                                
                                if (textScanner.string as NSString).substringToIndex(1) == "\"" {
                                    textScanner.scanLocation += 1
                                    textScanner.scanUpToString("\"", intoString: &value)
                                    textScanner.scanLocation += 1
                                } else {
                                    textScanner.scanUpToString(delimiter, intoString: &value)
                                }
                                values.append(value as! String)
                                
                                if textScanner.scanLocation < textScanner.string.characters.count {
                                    textToScan = (textScanner.string as NSString).substringFromIndex(textScanner.scanLocation + 1)
                                } else {
                                    textToScan = ""
                                }
                                textScanner = NSScanner(string: textToScan)
                            }
                            
                        } else  {
                            values = line.componentsSeparatedByString(delimiter)
                        }
                        
                        var tempValues = [String]()
                        for val in values {
                            tempValues.append(val)
                        }
                        
                        items.append(tempValues)
                        tempValues = []
                    }
                }
            }
        }
        return items
    }
    
    // Makes a clean write to DB by removing all data from DB and parsing data from csv files to DB
    
    func preloadData () {
        
        removeDataFrom("Seniunijos")
        removeDataFrom("Duomenys")
        
        var error:NSError?
        var seniunijos: [String:String] = [:]
        
        if let contentsOfURL = NSBundle.mainBundle().URLForResource("seniunijos", withExtension: "csv") {
            if let items = parseCSV(contentsOfURL, encoding: NSUTF16StringEncoding, error: &error) {
                for item in items {
                    seniunijos[item[1]] = item[0]
                }
            }
        }
        
        
        
        
        if let contentsOfURL = NSBundle.mainBundle().URLForResource("registered_people", withExtension: "csv") {
            
            
            var error:NSError?
            if let items = parseCSV(contentsOfURL, encoding: NSUTF16StringEncoding, error: &error) {
                
                for item in items {
                    
                    let duom = NSEntityDescription.insertNewObjectForEntityForName("Duomenys", inManagedObjectContext: managedObjectContext) as! Duomenys
                    let seni = NSEntityDescription.insertNewObjectForEntityForName("Seniunijos", inManagedObjectContext: managedObjectContext) as! Seniunijos
                    
                    let dateForm = NSDateFormatter()
                    dateForm.dateFormat = "yyyy-MM-dd"
                    
                    duom.id = NSNumberFormatter().numberFromString(item[0])!
                    duom.lytis = item[1]
                    duom.gimimo_data = dateForm.dateFromString(item[2])
                    duom.gimimo_valst = item[3]
                    
                    if let seniun = item.atIndex(4) {
                        if let seniunija = seniunijos[seniun] {
                            seni.seniunija = seniunija
                            duom.sen = seni
                        }
                    }
                    
                    if let dataNuo = item.atIndex(5) {
                        if dateForm.dateFromString(dataNuo) != nil {
                            duom.data_nuo = dateForm.dateFromString(dataNuo)
                        }
                    }
                    
                    if let seimPad = item.atIndex(6) {
                        if seimPad == "V" || seimPad == "N" || seimPad == "I" {
                            duom.seim_padet = seimPad
                        }
                    }
                    
                    if let visoVaiku = item.atIndex(7) {
                        if NSNumberFormatter().numberFromString(visoVaiku) != nil {
                            duom.viso_vaiku = NSNumberFormatter().numberFromString(visoVaiku)
                        }
                    }
                    
                    do{
                        try managedObjectContext.save()
                    } catch let error {
                        print("Core Data Error : \(error)")
                    }
                    
                }
            }
        }
        print("Done.")
    }
    
    // Removes data from entity
    
    func removeDataFrom (entityNamed : String) {
        let fetchRequest = NSFetchRequest(entityName: entityNamed)
        
        do {
            let listOfItems = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Seniunijos]
            for listOfItem in listOfItems {
                self.managedObjectContext.deleteObject(listOfItem)
            }
        }
        catch let error as NSError {
            print("Failed to retrieve record: \(error.localizedDescription)")
        }
        
    }
}

// extension of Array to check if array is not out of bounds. Prevents from crashing

extension Array {
    func atIndex(index: Int) -> Element? {
        if index < 0 || index > self.count - 1 {
            return nil
        }
        return self[index]
    }
}

