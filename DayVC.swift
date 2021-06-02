//
//  DayVC.swift
//  UTime
//
//  Created by Hunter Walker on 6/1/21.
//

import Foundation
import UIKit
import FSCalendar
import CoreData


class DayVC: UIViewController, FSCalendarDelegate, FSCalendarDataSource, UITableViewDelegate, UITableViewDataSource {
  
    let cellReuseIdentifier = "cell"
    var selectedDate: Date?
    var events:[Event]?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var allEvents:[Event] = []
    var uniqueDaysWithEvents:[String] = []
    var eventsByDay:[[Event]] = []
    var todaysEvents: [Event] = []
    
    @IBOutlet weak var fsCalendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    fileprivate let hoursFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fsCalendar.delegate = self
        fsCalendar.dataSource = self
        tableView.dataSource = self
        tableView.delegate = self
        
        self.fsCalendar.setScope(.week, animated: false)
        self.fsCalendar.appearance.headerDateFormat = "MM/dd/yyyy"
        self.fsCalendar.select(selectedDate)
        
        fetchEvents(forToday: selectedDate!)
        getTodaysEvents()
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor?
    {
        return UIColor.green
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition)
    {
        print("should segue to next date")
    }
    
    func fetchEvents(forToday: Date)
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
    
    func getTodaysEvents()
    {
        for x in eventsByDay {
            for i in x {
                let day = formatter.string(from: selectedDate!)
                let day2 = formatter.string(from: i.startTime ?? Date())
                if day == day2 {
                   todaysEvents.append(i)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        print("You tapped cell number \(indexPath.row). Should segue to a detail screen.")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 55
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.todaysEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell:DayCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! DayCell
        cell.myCellLabel.text = self.todaysEvents[indexPath.row].title
        cell.desc.text = self.todaysEvents[indexPath.row].eventDescrip
        
        let startTimeString = hoursFormatter.string(from: todaysEvents[indexPath.row].startTime ?? Date())
        let endTimeString = hoursFormatter.string(from: todaysEvents[indexPath.row].endTime ?? Date())
        
        cell.startTime.text = "\(startTimeString) - \(endTimeString)"
        
        return cell
    }
    
}

class DayCell: UITableViewCell {
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var myCellLabel: UILabel!
}

