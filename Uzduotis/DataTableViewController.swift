//
//  DataTableViewController.swift
//  Uzduotis
//
//  Created by Darius on 7/1/16.
//  Copyright © 2016 DariusPri. All rights reserved.
//

import UIKit
import CoreData

class DataTableViewController: UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    var firstTask: [String: [Int]] = [:]
    var firstTaskSorted = [(String, [Int])]()
    var secondTask = ""
    var thirdTask = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateForm = NSDateFormatter()
        dateForm.dateFormat = "yyyy-MM-dd"
        var predicate = NSPredicate()

        // Task 1. Looping through 12 months of 2014 and creating a
        // predicate which is used to get data from DB
        
        for i in 1 ... 12 {
            let month = String(format: "%02d", i)
            let startDate = dateForm.dateFromString("2014-"+month+"-01")
            let endDate = getLastDayOfTheMonth(startDate!)
            let predicate = NSPredicate(format: "data_nuo <= %@ AND data_nuo >= %@ AND sen.seniunija.count>0", endDate, startDate!)
            let monthData = getDataFromDB(predicate)
            for data in monthData {
                if (firstTask[data.seniunija] == nil) {
                    firstTask[data.seniunija] = []
                }
                firstTask[data.seniunija]?.append(data.count)
            }
        }
        firstTaskSorted = firstTask.sort{ $0.0 < $1.0 } // data sorted by Alphabet
        
        // Task 2
        
        let ageGreaterThan18 = dateForm.dateFromString("1996-01-01")
        let ageLessThan25 = dateForm.dateFromString("1989-01-01")
        let alreadyLivingBy2014 = dateForm.dateFromString("2015-01-01")
        predicate = NSPredicate(format: "gimimo_data < %@ AND gimimo_data >= %@ AND data_nuo < %@ AND sen.seniunija.count > 0", ageGreaterThan18!, ageLessThan25!, alreadyLivingBy2014!)
        let peopleData = getDataFromDB(predicate)
        let newdict = peopleData.sort{$0.1 > $1.1}
        secondTask = newdict.first!.0

        // Task 3. Having in mind that pension age for men and women will be 60 by the year 2020
        
        let pensionAge = dateForm.dateFromString("1960-01-01")
        predicate = NSPredicate(format: "gimimo_data < %@ AND sen.seniunija.count > 0", pensionAge!)
        let pensionData = getDataFromDB(predicate)
        let pensionDict = pensionData.sort{$0.1 > $1.1}
        thirdTask = pensionDict.first!.0
        
      
    }
    
    
    
    func getDataFromDB(predicate: NSPredicate) -> [(seniunija: String, count: Int)] {
        
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("Duomenys", inManagedObjectContext: managedObjectContext!)
        fetchRequest.resultType = .DictionaryResultType
        fetchRequest.entity = entityDescription
        let countExpression = NSExpression(format: "count:(id)")
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = "count"
        expressionDescription.expression = countExpression
        expressionDescription.expressionResultType = NSAttributeType.Integer32AttributeType
        fetchRequest.propertiesToFetch = ["sen.seniunija", expressionDescription]
        fetchRequest.propertiesToGroupBy = ["sen.seniunija"]
        fetchRequest.predicate = predicate
        var data:[(seniunija: String, count: Int)] = []
        
        do {
            let result = try managedObjectContext!.executeFetchRequest(fetchRequest)
            
            guard let resultDict = result as? [[String: AnyObject]] else {
                return data
            }
            for resultRow in resultDict {
                let count = resultRow["count"]! as! Int
                let seniun = resultRow["sen.seniunija"] as! String
                data.append((seniunija: seniun, count: count))
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        return data
        
    }
    
    
    // Inserting data to the table
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell = UITableViewCell()
        
        if(indexPath.section == 0) {
            cell = tableView.dequeueReusableCellWithIdentifier("duomenysCell", forIndexPath: indexPath)
            let text:String =  firstTaskSorted[indexPath.row].0
            (cell.viewWithTag(100) as! UILabel).text = text
            
            for i in 1 ... 12 {
                let label = cell.viewWithTag(i) as! UILabel
                label.text = String(firstTaskSorted[indexPath.row].1[i-1])
            }
        }
        if(indexPath.section == 1) {
            cell = tableView.dequeueReusableCellWithIdentifier("simpleCell", forIndexPath: indexPath)
            (cell.viewWithTag(100) as! UILabel).text = secondTask
            
        }
        if(indexPath.section == 2) {
            cell = tableView.dequeueReusableCellWithIdentifier("simpleCell", forIndexPath: indexPath)
            (cell.viewWithTag(100) as! UILabel).text = thirdTask
        }
        return cell
        
    }
    
    
    
    
    
    func getLastDayOfTheMonth(date: NSDate) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let comps2 = NSDateComponents()
        comps2.month = 1
        comps2.day = -1
        return calendar.dateByAddingComponents(comps2, toDate: date, options: [])!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? Array(firstTask.keys).count : 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let number = String(section+1)
        return number+" užduotis"
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.section == 0 ? 140 : 40
    }
    
}


