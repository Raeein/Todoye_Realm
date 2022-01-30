import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    var addAction = UIAlertAction()
    var categories = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()

    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = categories[indexPath.row].name
        cell.contentConfiguration = content
        
        return cell
        
    }

    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error saving category \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    func loadCategories() {
        
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        
        do{
            categories = try context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
       
        tableView.reloadData()
        
    }
    
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            
            self.categories.append(newCategory)
            
            self.saveCategories()
            
        }
        
        let alertDismiss = UIAlertAction(title: "Cancel", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        addAction.isEnabled = false
        alert.addAction(addAction)
        alert.addAction(alertDismiss)
        
        alert.addTextField { (field) in
            field.delegate = self
            textField = field
            textField.placeholder = "Add a new category"
        }
        
        present(alert, animated: true) {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissOnTapOutside)))
        }
        
    }
    @objc func dismissOnTapOutside() {
        self.dismiss(animated: true, completion: nil)
    }

}

extension CategoryViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let userEnteredString = textField.text
        let newString = (userEnteredString! as NSString).replacingCharacters(in: range, with: string) as NSString
        //        newString != "" ? (alertActionAdd.isEnabled = true) : (alertActionAdd.isEnabled = false)
        addAction.isEnabled = (newString != "" ? true : false)
        return true
    }
}
