//
//  MyTasksVC.swift
//  UTime
//
//  Created by Jack Maloney on 5/18/21.
//

import UIKit
import Foundation
import CoreData

let dateFormatter = DateFormatter()

class MyTasksVC: UIViewController{

    @IBOutlet weak var tableView: UITableView!
    
    //reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //list of all of the events in chonological order
    var allEvents:[Event] = []
    
    //list of days that have events
    var uniqueDaysWithEvents:[String] = []

    //2d array of events organzied by day
    var eventsByDay:[[Event]] = []


    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        //removes deviding lines from table view
        tableView.separatorStyle = .none
        
        //removes scroll bar
        tableView.showsVerticalScrollIndicator = false
        
        //get items from core data
        fetchEvents()
    }
    
    func fetchEvents()
    {
        //fetch the data from core data to display in the table view
        do
        {
            dateFormatter.dateFormat = "yyyy-M-dd"
            //list to store the events
            var daysWithEvents:[String] = []

            let request = Event.fetchRequest() as NSFetchRequest
            
            let sort = NSSortDescriptor(key: "startTime", ascending: true)
            request.sortDescriptors = [sort]
            
            //load events from core data into events list
            self.allEvents = try context.fetch(request)
            
            for event in allEvents
            {
                let startTime = event.startTime ?? Date()
                daysWithEvents.append(dateFormatter.string(from: startTime))
            }
            
            uniqueDaysWithEvents = Array(Set(daysWithEvents))
            
            uniqueDaysWithEvents.sort()
            
            for day in uniqueDaysWithEvents
            {
                var tempArray:[Event] = []
                
                for event in allEvents
                {
                    let date = dateFormatter.string(from: event.startTime ?? Date())
                    
                    if(date == day)
                    {
                        tempArray.append(event)
                    }
                }
                eventsByDay.append(tempArray)
                tempArray.removeAll()
            }
            
            DispatchQueue.main.async
            {
                self.tableView.reloadData()
            }
        }
        catch
        {
            
        }
    }
    
   //func getDates() ->
}

extension Array where Element: Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            guard !uniqueValues.contains(item) else { return }
            uniqueValues.append(item)
        }
        return uniqueValues
    }
}

extension MyTasksVC: UITableViewDelegate, UITableViewDataSource
{

    //add title above events
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        dateFormatter.dateFormat = "EEEE, MMMM dd"
        let title = self.uniqueDaysWithEvents[section]
        return(title)
        
        /*dateFormatter.dateFormat = "YYYY-mm-DD"
        let rawDate = self.uniqueDaysWithEvents[section]
        let convertedDate = dateFormatter.date(from: rawDate)
        dateFormatter.dateFormat = "EEEE, MMMM dd"
        
        let title = dateFormatter.string(from: convertedDate ?? Date())
        
        return(title)*/
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return(50)
    }
    
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.systemBackground
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.gray
        //header.textLabel?.textAlignment = NSTextAlignment.center;
    }

    //changes cell's height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return(uniqueDaysWithEvents.count)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return eventsByDay[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        // Create Date Formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm" //MMM d, YYYY,

        //creates cell object for table
        let cell = tableView.dequeueReusableCell(withIdentifier: "Event") as! EventTVC
        
        //round the cell
        cell.eventView.layer.cornerRadius = 30
        
        //get the start time of the event and cast it as a string
        let startTimeString = dateFormatter.string(from: eventsByDay[indexPath.section][indexPath.row].startTime ?? Date())
        
        //display the event title
        cell.eventTitleLabel.text = eventsByDay[indexPath.section][indexPath.row].title
        
        //display the event's start time
        cell.eventTimeLabel.text = startTimeString
        
        return cell

    }
    
    
    //swipe for delete
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let action = UIContextualAction(style: .destructive, title: "Delete"){(action, view, completionHandler ) in
            
            //which event to remove
            let eventToRemove = self.eventsByDay[indexPath.section][indexPath.row]
            
            //remove person
            self.context.delete(eventToRemove)
            
            //save the data
            do
            {
                try self.context.save()
            }
            catch
            {
                //errors
            }
            
            self.fetchEvents()
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    //tapping on events
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // Create Date Formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, YYYY, hh:mm"
        
        //selected event
        let event = eventsByDay[indexPath.section][indexPath.row]
        
        let startTimeString = dateFormatter.string(from: event.startTime ?? Date())
        let endTimeString = dateFormatter.string(from: event.endTime ?? Date())

        
        //create alert
        let alert = UIAlertController(title: event.title, message: event.eventDescrip! + "\n" + startTimeString + "->" + endTimeString, preferredStyle: .alert)
        
        // Create the ok button action
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            NSLog("OK Pressed")
        }
        //add ok buttom to alert
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
}
