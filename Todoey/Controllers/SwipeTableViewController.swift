//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Raeein Bagheri on 2022-01-31.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit

class SwipeTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    //MARK: - Table view datasource methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
     
            // Perform the deletion
            let result = self?.delete(at: indexPath) ?? false
            // Signal that the handler succeeded
            completionHandler(result)
        }
     
        action.image = UIImage(systemName: "trash")
     
        // Create configuration
        let configuration = UISwipeActionsConfiguration(actions: [action])
     
        return configuration
     
    }
    func delete(at indexPath: IndexPath) -> Bool {
        return true
    }
    
    
}
