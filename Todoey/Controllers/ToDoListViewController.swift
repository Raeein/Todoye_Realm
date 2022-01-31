import UIKit
import RealmSwift

class ToDoListViewController: UITableViewController, UITextFieldDelegate {
    let realm = try! Realm()
    var alertActionAdd = UIAlertAction()
    var toDoItems: Results<Item>?
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        //Look at this
        if let item = toDoItems?[indexPath.row] {
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            cell.contentConfiguration = content
            cell.accessoryType = (item.done ? .checkmark : .none)
        } else {
            var content = cell.defaultContentConfiguration()
            content.text = "No Items Added"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //          to update
        //        itemArray[indexPath.row].setValue("Completed", forKey: "title")
        
        //to delete
        //        context.delete(itemArray[indexPath.row])
        //        itemArray.remove(at: indexPath.row)
        
        //        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        //        toDoItems[indexPath.row].done.toggle()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add new Items to the list
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        alertActionAdd = UIAlertAction(title: "Add Item", style: .default) { action in
            
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write({
                        let newItem = Item()
                        newItem.title = textField.text!
                        currentCategory.items.append(newItem)
                    })
                } catch {
                    print("Error saving new Items, \(error)")
                }
                
            }
            self.tableView.reloadData()
            
            
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
    

    func loadItems() {
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
    }
    
}
//MARK: - Search bar methods
extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadItems()
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


