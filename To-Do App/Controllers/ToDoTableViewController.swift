//
//  ViewController.swift
//  To-Do App
//
//  Created by Mojtaba Nouri on 04/05/2022.
//

import UIKit
import CoreData

class ToDoTableViewController: UITableViewController {
    
    var branches = [Branch]()
    var items = [Item]()
    
    var allData = [[Branch](): [Item]()]
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.sectionHeaderTopPadding = 5
        loadData()
    }
    
    
    //MARK: - Table View Data Source Method
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var counter = 0
        let specifiedBranch = branches[section]
        for item in items {
            if item.branch == specifiedBranch {
                counter += 1
            }
        }
        return counter
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let specifiedBranch = branches[indexPath.section]
        let itemsOfBranch = getItemsOfSpecifiedBranch(name: specifiedBranch.name!)
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCellView", for: indexPath)
        cell.textLabel?.text = itemsOfBranch[indexPath.row].title
        cell.accessoryType = itemsOfBranch[indexPath.row].isDone ? .checkmark : .none
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return branches.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return getNamesOfBranchs()[section]
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = .label
        header.textLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }

    //MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let specifiedBranch = branches[indexPath.section]
        let itemsOfBranch = getItemsOfSpecifiedBranch(name: specifiedBranch.name!)
        itemsOfBranch[indexPath.row].isDone = !itemsOfBranch[indexPath.row].isDone
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let specifiedBranch = branches[indexPath.section]
        let targetItem = getItemsOfSpecifiedBranch(name: specifiedBranch.name!)[indexPath.row]
        
        if editingStyle == .delete {
            for i in 0..<items.count {
                if items[i].branch?.name == specifiedBranch.name {
                    if items[i] == targetItem {
                        context.delete(targetItem)
                        items.remove(at: i)
                        saveData()
                        break
                    }
                }
            }
        }
    }
    
    
    //MARK: - manipulation coredata
    func saveData() {
//        save data on core data
        do {
            try context.save()
            tableView.reloadData()
        } catch { print("Error while saveing data, \(error)") }
    }
    
    func loadData(_ predicate: NSPredicate = NSPredicate(value: true)) {
        let requestBranch: NSFetchRequest<Branch> = Branch.fetchRequest()
        let requestItem: NSFetchRequest<Item> = Item.fetchRequest()
        requestItem.predicate = predicate
        
        do {
            branches = try context.fetch(requestBranch)
            items = try context.fetch(requestItem)
            tableView.reloadData()
        }catch {
            print("Error while get all branchs and items, \(error)")
        }

    }
    
    
    //MARK: - navigation buttons action
    @IBAction func aboutButton(_ sender: UIBarButtonItem) {
//        go to about screen
        performSegue(withIdentifier: "goToAbout", sender: self)
    }
    
    @IBAction func addToDoButton(_ sender: UIBarButtonItem) {

        let alertController = UIAlertController(title: "Add ToDo/Branch", message: nil, preferredStyle: .alert)
        alertController.addTextField { uiTextField in
            uiTextField.placeholder = "To-Do Name"
        }
        alertController.addTextField { uiTextField in
            uiTextField.placeholder = "Branch Name"
        }
        
        let alertAction = UIAlertAction(title: "Add", style: .default) { uIAlertAction in
            if let textField = alertController.textFields {
                if let todoName = textField[0].text, let branchName = textField[1].text {
                    if todoName != "" && branchName != "" {
                        self.addCategory(withName: branchName.uppercased())
                        self.addTodo(to: branchName.uppercased(), withTitle: todoName)
                        self.saveData()
                    }
                }
            }
        }
        let alertCancel = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(alertAction)
        alertController.addAction(alertCancel)
        present(alertController, animated: true)
    }
    
    
    @IBAction func deleteCategoryButton(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Delete Category", message: nil, preferredStyle: .alert)
        alertController.addTextField { uiTextField in
            uiTextField.placeholder = "Branch Name"
        }
        let alertAction = UIAlertAction(title: "Delete", style: .destructive) { uiAlertAction in
            if let textField = alertController.textFields {
                if let branchName = textField[0].text {
                    if branchName != "" {
                        self.deleteCategory(withName: branchName.uppercased())
                        alertController.resignFirstResponder()
                    }
                }
            }
        }
        let alertCancel = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(alertAction)
        alertController.addAction(alertCancel)
        alertController.becomeFirstResponder()
        present(alertController, animated: true)
    }
    
    func addTodo(to branchName: String, withTitle itemTitle: String) {
//        for add todo to specified category
//        first of all we have to check is category exist or not
//        then if exist add todo to specified category
        if itemTitle != "" && branchName != "" {
            if let branch = checkBranchExists(withName: branchName) {
                let newItem = Item(context: context)
                newItem.title = itemTitle
                newItem.isDone = false
                newItem.branch = branch
                items.append(newItem)
                saveData()
            }
        }
        
    }
    func addCategory(withName branchName: String) {
        if branchName != "" {
            if checkBranchExists(withName: branchName) == nil {
                let newBranch = Branch(context: context)
                newBranch.name = branchName
                branches.append(newBranch)
                saveData()
            }
        }
    }
    
    
    //MARK: - utils methods
    
    func getNamesOfBranchs() -> [String] {
        var allBranchTitle: [String] = []
        for branch in branches {
            allBranchTitle.append(branch.name!)
        }
        return allBranchTitle
    }
    
    func getItemsOfSpecifiedBranch(name: String) -> [Item] {
        var itemsOfBranch = [Item]()
        for item in items {
            if item.branch?.name == name {
                itemsOfBranch.append(item)
            }
        }
        return itemsOfBranch
    }
    
    func deleteCategory(withName branchName: String) {
        if let targetBranch = checkBranchExists(withName: branchName) {
            items = items.filter{ item in
                if item.branch?.name == branchName {
                    context.delete(item)
                    return false
                }
                return true
            }
            branches = branches.filter { branch in branch != targetBranch }
            context.delete(targetBranch)
            saveData()
        }
    }
    
    func checkBranchExists(withName name: String) -> Branch? {
        for branch in branches {
            if branch.name == name {
                return branch
            }
        }
        return nil
    }
    
}



extension ToDoTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var predicate: NSPredicate?
        if searchText != "" {
            predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
        } else {
            searchBar.resignFirstResponder()
        }
        loadData(predicate ?? NSPredicate(value: true))
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
