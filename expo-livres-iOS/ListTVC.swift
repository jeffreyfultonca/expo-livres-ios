//
//  ListTVC.swift
//  expo-livres-iOS
//
//  Created by Jeffrey Fulton on 2015-08-09.
//  Copyright (c) 2015 Jeffrey Fulton. All rights reserved.
//

import UIKit

class ListTVC: UIViewController,
    UITableViewDelegate,
    UITableViewDataSource,
    ScannerVCDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    var scannedBooks = [Book]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 74.5
    }
    
    override func viewDidAppear(animated: Bool) {
        if UserInfo.isNotValid {
            self.performSegueWithIdentifier("showUserInfo", sender: self)
        }
    }

    // MARK: - Table view data source

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if scannedBooks.isEmpty {
            return 1 // No items message
            
        } else {
            return scannedBooks.count + 1 // Add for SwipeMessage Cell
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if scannedBooks.isEmpty { // No items message
            let cell = tableView.dequeueReusableCellWithIdentifier("emptyListCell", forIndexPath: indexPath) as! EmptyListCell
            return cell
            
        } else if indexPath.row == scannedBooks.count { // Swipe left message
            let cell = tableView.dequeueReusableCellWithIdentifier("swipeMessageCell", forIndexPath: indexPath) as! SwipeMessageCell
            return cell
            
        } else { // Item
            let cell = tableView.dequeueReusableCellWithIdentifier("itemCell", forIndexPath: indexPath) as! ItemCell
            
            let book = scannedBooks[indexPath.row]
            
            cell.titleLabel.text = book.title
            cell.isbnLabel.text = "isbn: \(book.sku)"
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if scannedBooks.isEmpty {
            return tableView.bounds.height - tableView.contentInset.top
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    // Override to support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.row != scannedBooks.count
    }

    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            scannedBooks.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            // Reload first row to display No items message
            if scannedBooks.isEmpty {
                let noItemsIndexPath = NSIndexPath(forRow: 0, inSection: 0)
                tableView.reloadRowsAtIndexPaths([noItemsIndexPath] , withRowAnimation: UITableViewRowAnimation.Fade)
            }
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    // MARK: - Actions
    
    @IBAction func userInfoPressed(sender: AnyObject) {
        performSegueWithIdentifier("showUserInfo", sender: sender)
    }
    
    // MARK: - Scanner Delegate
    
    func scannerSuccessfullyScannedSku(sku: String) {
        
        self.dismissViewControllerAnimated(true) {
            if let scannedBook = LibraryService.bookWithSku(sku) {
                self.scannedBooks.append(scannedBook)
                
                let newItemIndexPath = NSIndexPath(forRow: self.scannedBooks.count - 1, inSection: 0)
                self.tableView.insertRowsAtIndexPaths([newItemIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                
                let lastIndexPath = NSIndexPath(forRow: self.scannedBooks.count, inSection: 0)
                if self.scannedBooks.count == 1 {
                    self.tableView.reloadRowsAtIndexPaths([lastIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                }
                self.tableView.scrollToRowAtIndexPath(lastIndexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
                
            } else {
                let alertController = UIAlertController(
                    title: "Oops!",
                    message: "We're sorry, isbn: \(sku) not found. Please try again or bring book to front desk.",
                    preferredStyle: UIAlertControllerStyle.Alert
                )
                
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(okAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showScanner" {
            let scannerVC = segue.destinationViewController as! ScannerVC
            scannerVC.delegate = self
        }
    }
}
