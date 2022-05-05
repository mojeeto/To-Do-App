//
//  ViewController.swift
//  To-Do App
//
//  Created by Mojtaba Nouri on 04/05/2022.
//

import UIKit
import CoreData

class ToDoTableViewController: UITableViewController {
    
    var allData = [Categories(): [Items]()]
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    
    //MARK: - manipulation coredata
    func saveData() {
//        save data on core data
        do { try context.save() } catch { print("Error while saveing data, \(error)") }
    }
    
    func loadData(withCategory category: Categories, predicate: NSPredicate = NSPredicate(value: true)) {
//        create request
        let request: NSFetchRequest<Items> = Items.fetchRequest()
//        compact all predicate
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "category.name MATCHES %@", category.name!), predicate])
//        try fetch data from core data
        do { allData[category] = try context.fetch(request) } catch { print("Error while fetchData, \(error)") }
    }
    
    
    //MARK: - navigation buttons action
    @IBAction func aboutButton(_ sender: UIBarButtonItem) {
//        go to about screen
        performSegue(withIdentifier: "goToAbout", sender: self)
    }
    
    @IBAction func addToDoButton(_ sender: UIBarButtonItem) {
    }
    
}

