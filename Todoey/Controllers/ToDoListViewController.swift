import UIKit
import CoreData

class ToDoListViewController: UITableViewController, UITextFieldDelegate {
    
    var alertActionAdd = UIAlertAction()
    var itemArray = [Item]()
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = item.title
        cell.contentConfiguration = content
        
        //        item.done ? (cell.accessoryType = .checkmark) : (cell.accessoryType = .none)
        cell.accessoryType = (item.done ? .checkmark : .none)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //          to update
        //        itemArray[indexPath.row].setValue("Completed", forKey: "title")
        
        //to delete
        //        context.delete(itemArray[indexPath.row])
        //        itemArray.remove(at: indexPath.row)
        
//        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        itemArray[indexPath.row].done.toggle()
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add new Items to the list
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        alertActionAdd = UIAlertAction(title: "Add Item", style: .default) { action in
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            self.saveItems()
            
            
        }
        alertActionAdd.isEnabled = false
        
        let alertActionDismiss = UIAlertAction(title: "Cancel", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addTextField { alertTextField in
            alertTextField.delegate = self
            alertTextField.placeholder = "Create New Item"
            alertTextField.autocapitalizationType = .words
            textField = alertTextField
        }
        alert.addAction(alertActionAdd)
        alert.addAction(alertActionDismiss)
        
        self.present(alert, animated: true) {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissOnTapOutside)))
        }
        
    }
    
    @objc func dismissOnTapOutside() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let userEnteredString = textField.text
        let newString = (userEnteredString! as NSString).replacingCharacters(in: range, with: string) as NSString
        //        newString != "" ? (alertActionAdd.isEnabled = true) : (alertActionAdd.isEnabled = false)
        alertActionAdd.isEnabled = (newString != "" ? true : false)
        return true
    }
    //MARK: - Core Data functionalities
    
    func saveItems() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context\(error)")
        }
        self.tableView.reloadData()
    }
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])

        } else {
            request.predicate = categoryPredicate
        }

        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context\(error)")
        }
        self.tableView.reloadData()
    }
    
}
//MARK: - Search bar methods
extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        loadItems(with: request , predicate: predicate)
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}


