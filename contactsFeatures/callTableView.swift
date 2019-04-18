//
//  callTableView.swift
//  contactsFeatures
//
//  Created by phoebe on 3/24/19.
//  Copyright © 2019 phoebe. All rights reserved.
//

import UIKit
import Contacts
class callTableViewController : UIViewController,UITableViewDataSource,UITableViewDelegate {
    var callArray = [CONTACTS]()
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(callArray.count)
        return callArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
        cell.textLabel?.text = callArray[indexPath.row].fullname
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(callArray[indexPath.row].number)
        let url : NSURL = URL(string: "telprompt://\(callArray[indexPath.row].number)")! as NSURL
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
    
}
