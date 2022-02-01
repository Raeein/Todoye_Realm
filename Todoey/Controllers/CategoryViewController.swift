import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    lazy var realm = try! Realm()
    
    var addAction = UIAlertAction()
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        loadCategories()
        tableView.rowHeight = 80.0
    }
    

    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  categories?.count ?? 1
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Gets the super classes cell and its functionalities
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
            
            var content = cell.defaultContentConfiguration()
            content.text = categories?[indexPath.row].name ?? "No Categories Added"
        
            guard let categoryColor = UIColor(hexString: category.color) else {fatalError()}
            cell.backgroundColor = categoryColor
            content.textProperties.color = ContrastColorOf(categoryColor, returnFlat: true)
            cell.contentConfiguration = content
        }
        
        
        return cell
        
    }
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    
    //MARK: - Data Manipulation Methods
    
    func save(category: Category) {
        do {
            try realm.write({
                realm.add(category)
            })
        } catch {
            print("Error saving category \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    func loadCategories() {
        
        categories = realm.objects(Category.self)
        tableView.reloadData()
        
    }
    override func delete(at indexPath: IndexPath) -> Bool {
        //         Check if there is a category at provided row
        guard let category = categories?[indexPath.row] else {
            return false
        }
        
        // Delete data from persistent storage
        do {
            // Open transaction
            try realm.write {
                realm.delete(category)
            }
            
        } catch {
            fatalError("Error deleting Category: \(error)")
        }
        
        tableView.reloadData()
        
        return true
    }
    
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat().hexValue()
            self.save(category: newCategory)
            
        }
        
        let alertDismiss = UIAlertAction(title: "Cancel", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        addAction.isEnabled = false
        
        alert.addTextField { (field) in
            field.delegate = self
            field.placeholder = "Add a new category"
            field.autocapitalizationType = .words
            textField = field
            
        }
        alert.addAction(addAction)
        alert.addAction(alertDismiss)
        
        present(alert, animated: true) {
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
}



