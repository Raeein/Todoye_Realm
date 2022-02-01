import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    let realm = try! Realm()
    var addAction = UIAlertAction()
    var toDoItems: Results<Item>?
    @IBOutlet weak var searchBar: UISearchBar!
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.rowHeight = 80.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedCategory?.color {
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller doesnt exist")}
            title = selectedCategory!.name
            
            let appearance = UINavigationBarAppearance()
            
            if let navBarColor = UIColor(hexString: colorHex) {
                appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
                appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                searchBar.barTintColor = navBarColor
            }
            appearance.backgroundColor = UIColor(hexString: colorHex)
            navBar.standardAppearance = appearance;
            navBar.scrollEdgeAppearance = navBar.standardAppearance
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller doesnt exist")}
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(hexString: "31797B")
        navBar.standardAppearance = appearance;
        navBar.scrollEdgeAppearance = navBar.standardAppearance
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        //Look at this
        if let item = toDoItems?[indexPath.row] {
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(toDoItems!.count)) {
                cell.backgroundColor = color
                content.textProperties.color = ContrastColorOf(color, returnFlat: true)
            }
            
            cell.contentConfiguration = content
            cell.accessoryType = (item.done ? .checkmark : .none)
        } else {
            var content = cell.defaultContentConfiguration()
            content.text = "No Items Added"
        }
        
        return cell
    }
    

    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write({
//                    realm.delete(item)
                    item.done.toggle()
                })
            } catch { print("Error saving done status, \(error)") }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add new Items to the list
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        addAction = UIAlertAction(title: "Add Item", style: .default) { action in
            
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write({
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    })
                } catch {
                    print("Error saving new Items, \(error)")
                }
                
            }
            self.tableView.reloadData()
            
            
        }
        addAction.isEnabled = false
        
        let alertActionDismiss = UIAlertAction(title: "Cancel", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addTextField { alertTextField in
            alertTextField.delegate = self
            alertTextField.placeholder = "Create New Item"
            alertTextField.autocapitalizationType = .words
            textField = alertTextField
        }
        alert.addAction(addAction)
        alert.addAction(alertActionDismiss)
        
        self.present(alert, animated: true) {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissOnTapOutside)))
        }
        
    }
    @objc func dismissOnTapOutside() {
        self.dismiss(animated: true, completion: nil)
    }
    //MARK: - Overriding the superclasses shouldChangeCharactersIn function
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let userEnteredString = textField.text
        let newString = (userEnteredString! as NSString).replacingCharacters(in: range, with: string) as NSString
        addAction.isEnabled = (newString != "" ? true : false)
        return true
    }

    
    //MARK: - Core Data functionalities
    
    
    func loadItems() {
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
    }
    
    override func delete(at indexPath: IndexPath) -> Bool {
        //         Check if there is a category at provided row
        guard let item = toDoItems?[indexPath.row] else {
            return false
        }
        
        // Delete data from persistent storage
        do {
            // Open transaction
            try realm.write {
                realm.delete(item)
            }
            
        } catch {
            fatalError("Error deleting Category: \(error)")
        }
        
        tableView.reloadData()
        
        return true
    }
    
}
//MARK: - Search bar methods
extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            tableView.reloadData()
        }
    }

}

//MARK: - UITextFieldDelegate delegate
