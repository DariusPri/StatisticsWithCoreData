//
//  Duomenys+CoreDataProperties.swift
//  Uzduotis
//
//  Created by Darius on 6/27/16.
//  Copyright © 2016 DariusPri. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Duomenys {

    @NSManaged var id: NSNumber?
    @NSManaged var lytis: String?
    @NSManaged var gimimo_data: NSDate?
    @NSManaged var gimimo_valst: String?
    @NSManaged var data_nuo: NSDate?
    @NSManaged var seim_padet: String?
    @NSManaged var viso_vaiku: NSNumber?
    @NSManaged var sen: Seniunijos?

}
