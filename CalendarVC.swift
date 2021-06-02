//
//  CalendarVC.swift
//  UTime
//
//  Created by Jack Maloney on 5/17/21.
//

import UIKit
import FSCalendar
import Foundation
import CoreData

class CalendarVC: UIViewController, FSCalendarDelegate, FSCalendarDataSource
{

    @IBOutlet weak var fsCalednar: FSCalendar!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var eventsInMonth:[Event]?
    
    let dateFormatter = DateFormatter()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        fsCalednar.delegate = self
        fsCalednar.dataSource = self
        
        fsCalednar.appearance.headerMinimumDissolvedAlpha = 0.0;
        
        
        //set the starting date for the data pull from core data as the first date of the month
        let startingMonth = getStartingMonth()
        
        fetchEvents(startOfMonth: startingMonth)
    }
    
    func fetchEvents(startOfMonth: Date)
    {
        //fetch the data from core data to display in the table view
        do
        {
            let endOfMonth = getLastDayInMonth(startingDate: startOfMonth)
            
            let request = Event.fetchRequest() as NSFetchRequest

            let pred = NSPredicate(format: "startTime >= %@ AND endTime <= %@", argumentArray: [startOfMonth, endOfMonth])
            
            request.predicate = pred
            
            self.eventsInMonth = try context.fetch(request)
            
            DispatchQueue.main.async
            {
                self.fsCalednar.reloadData()
            }
        }
        catch
        {
            
        }
    }
    
    func getStartingMonth() -> Date
    {
        //set the starting date for the data pull from core data as the first date of the month
        dateFormatter.dateFormat = "yyyy-M-dd hh:mm:ss"

        let currentDate = Date()
        let month = Calendar.current.component(.month, from: currentDate)
        let year = Calendar.current.component(.year, from: currentDate)
        
        var stringDate = String(year)
        stringDate += "-"
        stringDate += String(month)
        stringDate += "-01 00:00:00"

        print(stringDate)
        let startingMonth = dateFormatter.date(from: stringDate) ?? Date()
        print(startingMonth)
        return(startingMonth)
        
    }
    func getLastDayInMonth(startingDate: Date) -> Date
    {
    
        //TODO: Deal with leap years
        //still doesnt work
        
        //returns the last day in the month
        
        //set date format
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"

        
        let month = Calendar.current.component(.month, from: startingDate)
        let year = Calendar.current.component(.year, from: startingDate)
        
        var dateString = String(year)
        
        if month == 2
        {
            dateString += "-"
            dateString += String(month)
            dateString += "-28 23:59:59"
        }
        else if month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12
        {
            dateString += "-"
            dateString += String(month)
            dateString += "-31 23:59:59"
        }
        else
        {
            dateString += "-"
            dateString += String(month)
            dateString += "-30 23:59:59"
        }
    
        
        print(dateString)
        
        let lastDayInMonth = dateFormatter.date(from: dateString) ?? Date()
        
        print(lastDayInMonth)
        return(lastDayInMonth)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition)
    {
        //returns the day clicked on by the user
        //print(eventsInMonth?.count)
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        print("Date Selected: \(dateFormatter.string(from: date))")
        self.performSegue(withIdentifier: "showDayVC", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detail = segue.destination as? DayVC {
            detail.selectedDate = fsCalednar.selectedDate
            detail.events = eventsInMonth
         }
    }
    
    
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int
    {
        //dots under days if they have events
        //idea: only have a dot under a day if something is due that day
        return(0)
    }
    func calendarCurrentPageDidChange(_ calendar: FSCalendar)
    {
        let currentPageDate = calendar.currentPage
        fetchEvents(startOfMonth: currentPageDate)
    }
    
}
