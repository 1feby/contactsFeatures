//
//  smsTableView.swift
//  contactsFeatures
//
//  Created by phoebe on 4/11/19.
//  Copyright © 2019 phoebe. All rights reserved.
//


import UIKit
import Contacts
class smsTableViewController : UIViewController,UITableViewDataSource,UITableViewDelegate {
    var smsArray = [CONTACTS]()
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return smsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "smsCell", for: indexPath)
        cell.textLabel?.text = smsArray[indexPath.row].fullname
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url : NSURL = URL(string: "sms://\(smsArray[indexPath.row].number)")! as NSURL
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
}
