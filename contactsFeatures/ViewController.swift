//
//  ViewController.swift
//  contactsFeatures
//
//  Created by phoebe on 3/24/19.
//  Copyright © 2019 phoebe. All rights reserved.
//

import UIKit
import Contacts
import EventKit
class ViewController: UIViewController {
   
    lazy var evet : EKEvent = EKEvent(eventStore: eventStore);
    var events: [EKEvent]?
    var filterdItemsArray = [CONTACTS]()
    var fetcontacts : [CONTACTS] = []
    var contactdic : [String] = []
    let fileURL = "/Users/phoebeezzat/Desktop/test.txt"
    var arrayOfStrings : [String] = []
    let eventStore : EKEventStore = EKEventStore()
    lazy var reminder : EKReminder = EKReminder(eventStore: eventStore)
    var remindersto : [EKReminder]?
    var calendars: [EKCalendar]?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    func fetchcontacts() {
        
        let ContactStore = CNContactStore()
        let keys = [CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey]
        let fetchreq = CNContactFetchRequest.init(keysToFetch: keys as [CNKeyDescriptor] )
        do{
            try ContactStore.enumerateContacts(with: fetchreq) { (contact, end) in
                let datacontant = CONTACTS(NAME: "\(contact.givenName) \(contact.familyName)", phoneNumber: contact.phoneNumbers.first?.value.stringValue ?? "")
                self.fetcontacts.append(datacontant)
                //    let dict = [ datacontant.fullname: datacontant.number]
                //    self.contactdic.append(dict)
                print(contact.givenName)
                print(contact.phoneNumbers.first?.value.stringValue ?? "")
            }}
        catch{
            print("failed to fetch")
        }
        
    }
    func filterContentForSearchText(searchText: String)  {
        filterdItemsArray = fetcontacts.filter { item in
            return item.fullname.lowercased().contains(searchText.lowercased())
        }
    }
    
    
    func searchForSimilarContacts(){
        do{
            let contents = try NSString(contentsOfFile: fileURL, encoding: String.Encoding.utf8.rawValue)
            let texttoread = contents as String
            arrayOfStrings = texttoread.components(separatedBy: " ");
            //print("bb \(arrayOfStrings.count)")
            filterContentForSearchText(searchText: arrayOfStrings[1])
            for p in 0...filterdItemsArray.count{
                print(filterdItemsArray.count)
            }
            if filterdItemsArray.count == 2 {
                print(filterdItemsArray[0].fullname)
                print(filterdItemsArray[0].number)
            }
            
            print(" the text is \(contents)")
        }catch  {
            print("An error took place: \(error)")
        }    }
    
    @IBAction func callCont(_ sender: Any) {
        fetchcontacts()
        searchForSimilarContacts()
        if filterdItemsArray.count == 1{
            let url : NSURL = URL(string: "telprompt://\(filterdItemsArray[0].number)")! as NSURL
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }else if filterdItemsArray.count > 1 {
            performSegue(withIdentifier: "callSegue", sender: self)}
        else {
            createcontactAlert(title: "not found ", message: "no matched name of contact found")
        }
    }
    func createcontactAlert (title : String , message : String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func sendSMS(_ sender: Any) {
        searchForSimilarContacts()
        if filterdItemsArray.count == 1{
            let url : NSURL = URL(string: "sms://\(filterdItemsArray[0].number)")! as NSURL
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }else if filterdItemsArray.count > 1 {
            performSegue(withIdentifier: "smsSegue", sender: self)}
        else {
            createcontactAlert(title: "not found ", message: "no matched name of contact found")
        }
    }
    
    @IBAction func add_reminder(_ sender: UIButton) {
        eventStore.requestAccess(to: EKEntityType.reminder) { (granted, error) in
            if (granted) && (error == nil) {
                print("granted \(granted)")
                let reminder:EKReminder = EKReminder(eventStore: self.eventStore)
                reminder.title = "Must do this!"
                reminder.priority = 2
                reminder.notes = "...this is a note"
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd HH:mm"
                let DateTime = formatter.date(from: "2019/03/15 05:00");
                //   let alarmTime = Date().addingTimeInterval(3*60)
                let alarm = EKAlarm(absoluteDate: DateTime!)
                reminder.addAlarm(alarm)
                
                reminder.calendar = self.eventStore.defaultCalendarForNewReminders()
                
                do {
                    try self.eventStore.save(reminder, commit: true)
                    
                } catch {
                    let alert = UIAlertController(title: "Reminder could not save", message: (error as NSError).localizedDescription, preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(OKAction)
                    
                    self.present(alert, animated: true, completion: nil)
                }
                print("Reminder saved")
            }
        }
    }
    @IBAction func remove_reminder(_ sender: UIButton) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        //let DateTime = formatter.date(from: "2019/03/15 05:00");
        //let component = DateComponents(year: 2019, month: 3, day: 15, hour: 05, minute: 00)
        let predict = eventStore.predicateForReminders(in: calendars)
        let text = "must do this"
        eventStore.fetchReminders(matching: predict) { (reminders) in
            for remind in reminders! {
                if remind.title.lowercased().contains(text.lowercased()){
                    do{
                        try self.eventStore.remove(remind, commit: true)
                        print("yes")
                    }catch{
                        let alert = UIAlertController(title: "Reminder could not find", message: (error as NSError).localizedDescription, preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(OKAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                }else{
                    print("no")
                }
            }
        }
    }
    
    @IBAction func Add_event(_ sender: UIButton) {
        eventStore.requestAccess(to: .event) { (granted, error) in
            if (granted) && (error == nil ){
                print("granted\(granted)")
                
                self.evet.title = "Add event lololololoy"
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd HH:mm"
                let startDateTime = formatter.date(from: "2019/03/15 05:00");
                self.evet.startDate = startDateTime
                let endDateTime = formatter.date(from: "2019/03/16 05:35");
                self.evet.endDate = endDateTime
                // let alaram = EKAlarm(relativeOffset: 0)
                //  evet.alarms = [alaram]
                self.evet.addAlarm(.init(relativeOffset: -5*60))
                self.evet.notes = "This is note"
                self.evet.calendar = self.eventStore.defaultCalendarForNewEvents
                do{
                    try self.eventStore.save(self.evet, span: .thisEvent)
                }catch let error as NSError{
                    let alert = UIAlertController(title: "Event could not save", message: (error as NSError).localizedDescription, preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(OKAction)
                    
                    self.present(alert, animated: true, completion: nil)
                }
                print("Save Event")
            }else{
                print ("error is \(error)")
            }
        }
    }
    @IBAction func Remove_event(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        self.calendars = eventStore.calendars(for: EKEntityType.event)
        // Create start and end date NSDate instances to build a predicate for which events to select
        let startDate = dateFormatter.date(from: "2019/03/15 04:00")
        let endDate = dateFormatter.date(from: "2019/03/17 20:00")
        let prediacte = eventStore.predicateForEvents(withStart: startDate!, end: endDate!, calendars: calendars!)
        self.events = eventStore.events(matching: prediacte)
        for i in events! {
            deleteEntry(event: i)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "callSegue"{
            let destinationVC = segue.destination as! callTableViewController
            destinationVC.callArray = filterdItemsArray
        }else if segue.identifier == "smsSegue"{
            
            let destinationVC = segue.destination as! smsTableViewController
            destinationVC.smsArray = filterdItemsArray
        }
    }
    func deleteEntry(reminder : EKReminder){
        do{
            try eventStore.remove(reminder, commit: false)
        }catch{
            print("Error while deleting Reminder: \(error.localizedDescription)")
        }
    }
}


