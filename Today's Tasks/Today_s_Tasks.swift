//
//  Today_s_Tasks.swift
//  Today's Tasks
//
//  Created by Charan Vadrevu on 02.04.21.
//  Copyright © 2021 Tejas Krishnan. All rights reserved.
//

import WidgetKit
import SwiftUI
import Foundation
import UIKit
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()

    private init() {}

    var managedObjectContext: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }

    var workingContext: NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = self.managedObjectContext
        return context
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.schedulingapp.tracrwidget")!
        let storeURL = containerURL.appendingPathComponent("ClassModel.sqlite")
        let description = NSPersistentStoreDescription(url: storeURL)

        let container = NSPersistentContainer(name: "ClassModel")
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
                fatalError(error.localizedDescription)
            }
        })
        
        return container
    }()

    func saveContext() {
        self.managedObjectContext.performAndWait {
            if self.managedObjectContext.hasChanges {
                do {
                    try self.managedObjectContext.save()
                    print("Main context saved")
                } catch (let error) {
                    print(error)
                    fatalError(error.localizedDescription)
                }
            }
        }
    }

    func saveWorkingContext(context: NSManagedObjectContext) {
        do {
            try context.save()
            print("Working context saved")
            saveContext()
        } catch (let error) {
            print(error)
            fatalError(error.localizedDescription)
        }
    }
}


struct TasksProvider: TimelineProvider {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    //all functions create and return entries as quickly as possible
    //all the data will be sent from this struct to the entries, which will then be sent to the View.
        //therefore, CoreData stuff will be from read here and sent as variables to the entry --> View.
    
    func getSAandAList() -> ([Subassignmentnew], [Assignment]) {
        var subassignmentlist: [Subassignmentnew] {
            let request1 = NSFetchRequest<Subassignmentnew>(entityName: "Subassignmentnew")
            request1.sortDescriptors = [NSSortDescriptor(keyPath: \Subassignmentnew.startdatetime, ascending: true)]
            
            do {
                return try CoreDataStack.shared.managedObjectContext.fetch(request1)
            } catch {
                print(error.localizedDescription)
                return []
            }
        }
        
        var assignmentlist: [Assignment] {
            let request2 = NSFetchRequest<Assignment>(entityName: "Assignment")
            request2.sortDescriptors = [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)]
            
            do {
                return try CoreDataStack.shared.managedObjectContext.fetch(request2)
            } catch {
                print(error.localizedDescription)
                return []
            }
        }
        
        return (subassignmentlist, assignmentlist)
    }
    
    func getProgress(assignmentlist: [Assignment], subassignmentname: String, subassignmentlength: Int) -> (Int64, Int64) {
        for (index, _) in assignmentlist.enumerated() {
            if subassignmentname == assignmentlist[index].name {
                return (assignmentlist[index].progress, (Int64(Double(Double(subassignmentlength) / Double(assignmentlist[index].totaltime)) * 100)))
            }
        }
        
        return (0, 0)
    }
    
    func getClass(assignmentlist: [Assignment], subassignmentname: String) -> String {
        for (index, _) in assignmentlist.enumerated() {
            if subassignmentname == assignmentlist[index].name {
                return assignmentlist[index].subject
            }
        }
        
        return "NA"
    }
    
    func getDueDate(assignmentlist: [Assignment], subassignmentname: String) -> String {
        let shortdateformatter = DateFormatter()
        shortdateformatter.dateFormat = "HH:mm"
        
        for (index, _) in assignmentlist.enumerated() {
            if subassignmentname == assignmentlist[index].name {
                return shortdateformatter.string(from: assignmentlist[index].duedate)
            }
        }
        
        return "NA"
    }
    
    func dateToTime(date: Date) -> String {
        let shortdateformatter = DateFormatter()
        shortdateformatter.dateFormat = "HH:mm"
        return shortdateformatter.string(from: date)
    }
    
    
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date(), isPlaceholder: true, headerText: "", largeBodyText: "", smallBodyText1: "", smallBodyText2: "", progressCount: 0, minorProgressCount: 0, schedule: [])
    }
    
    //sometimes in the preview
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let defaults = UserDefaults(suiteName: "group.com.schedulingapp.tracrwidget")
        let specificworkhoursview = defaults?.object(forKey: "specificworktimes") as? Bool ?? true
        
        let (subassignmentlist, assignmentlist) = getSAandAList()

        let nowDate: Date = Date()
        let tomorrowDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
        
        var scheduleArray: [TodaysScheduleEntry] = []
        
        for (index, _) in subassignmentlist.enumerated() {
            if (subassignmentlist[index].enddatetime > nowDate) && (subassignmentlist[index].startdatetime < tomorrowDate) {
                scheduleArray.append(TodaysScheduleEntry(taskName: subassignmentlist[index].assignmentname, className: getClass(assignmentlist: assignmentlist, subassignmentname: subassignmentlist[index].assignmentname)))
            }
        }
        
        var entry: SimpleEntry = SimpleEntry(date: Date(), isPlaceholder: false, headerText: "TODAY", largeBodyText: "No Tasks Scheduled", smallBodyText1: "", smallBodyText2: "", progressCount: 100, minorProgressCount: 0, schedule: [TodaysScheduleEntry(taskName: "", className: ""), TodaysScheduleEntry(taskName: "", className: ""), TodaysScheduleEntry(taskName: "", className: ""), TodaysScheduleEntry(taskName: "", className: ""), TodaysScheduleEntry(taskName: "", className: ""), TodaysScheduleEntry(taskName: "", className: "")])
        
        if subassignmentlist.count > 0 {
            for (index, _) in subassignmentlist.enumerated() {
                if (subassignmentlist[index].enddatetime > nowDate) && (subassignmentlist[index].startdatetime < tomorrowDate) {
                    let startdatetime = subassignmentlist[index].startdatetime
                    let largeBodyText = subassignmentlist[index].assignmentname
                    var (progressCount, minorProgressCount) = getProgress(assignmentlist: assignmentlist, subassignmentname: subassignmentlist[index].assignmentname, subassignmentlength: Calendar.current.dateComponents([.minute], from: subassignmentlist[index].startdatetime, to: subassignmentlist[index].enddatetime).minute!)
                    
                    if progressCount > 101 {
                        progressCount = 0
                    }
                    
                    if minorProgressCount > 101 {
                        progressCount = 0
                    }
                    
                    let smallBodyText1 = "\(dateToTime(date: subassignmentlist[index].startdatetime)) - \(dateToTime(date: subassignmentlist[index].enddatetime))"
                    
                    if specificworkhoursview {
                        if startdatetime < nowDate {
                            entry = SimpleEntry(date: nowDate, isPlaceholder: false, headerText: "NOW", largeBodyText: largeBodyText, smallBodyText1: smallBodyText1, smallBodyText2: "", progressCount: progressCount, minorProgressCount: minorProgressCount, schedule: scheduleArray)
                        }
                        
                        else {
                            entry = SimpleEntry(date: nowDate, isPlaceholder: false, headerText: "COMING UP", largeBodyText: largeBodyText, smallBodyText1: smallBodyText1, smallBodyText2: "", progressCount: progressCount, minorProgressCount: 0, schedule: scheduleArray)
                        }
                    }
                    
                    else {
                        entry = SimpleEntry(date: nowDate, isPlaceholder: false, headerText: "TODAY", largeBodyText: largeBodyText, smallBodyText1: "", smallBodyText2: "", progressCount: progressCount, minorProgressCount: minorProgressCount, schedule: scheduleArray)
                    }
                    
                    break
                }
            }
        }

        completion(entry)
    }
    
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let defaults = UserDefaults(suiteName: "group.com.schedulingapp.tracrwidget")
        let specificworkhoursview = defaults?.object(forKey: "specificworktimes") as? Bool ?? true
        
        let (subassignmentlist, assignmentlist) = getSAandAList()
        var entries: [SimpleEntry] = []

        let nowDate: Date = Date()
        let tomorrowDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
        
        var scheduleArray: [TodaysScheduleEntry] = []
        
        if subassignmentlist.count > 0 {
            for (index, _) in subassignmentlist.enumerated() {
                if (subassignmentlist[index].enddatetime > Calendar.current.startOfDay(for: Date())) && (subassignmentlist[index].startdatetime < tomorrowDate) {
                    scheduleArray.append(TodaysScheduleEntry(taskName: subassignmentlist[index].assignmentname, className: getClass(assignmentlist: assignmentlist, subassignmentname: subassignmentlist[index].assignmentname)))
                }
            }
            
            var lastSAEndDate = nowDate
            
            for (index, _) in subassignmentlist.enumerated() {
                if (subassignmentlist[index].enddatetime > nowDate) && (subassignmentlist[index].startdatetime < tomorrowDate) {
                    let startdatetime = subassignmentlist[index].startdatetime
                    let largeBodyText = subassignmentlist[index].assignmentname
                    var (progressCount, minorProgressCount) = getProgress(assignmentlist: assignmentlist, subassignmentname: subassignmentlist[index].assignmentname, subassignmentlength: Calendar.current.dateComponents([.minute], from: subassignmentlist[index].startdatetime, to: subassignmentlist[index].enddatetime).minute!)
                    let smallBodyText1 = "\(dateToTime(date: subassignmentlist[index].startdatetime)) - \(dateToTime(date: subassignmentlist[index].enddatetime))"
                    
                    if progressCount > 101 {
                        progressCount = 0
                    }
                    
                    if minorProgressCount > 101 {
                        progressCount = 0
                    }
                    print("ASDASFAFD")
                    print(progressCount, minorProgressCount)
                    
                    if specificworkhoursview {
                        if startdatetime < nowDate {
                            entries.append(SimpleEntry(date: startdatetime, isPlaceholder: false, headerText: "NOW", largeBodyText: largeBodyText, smallBodyText1: smallBodyText1, smallBodyText2: "", progressCount: progressCount, minorProgressCount: minorProgressCount, schedule: scheduleArray))
                        }
                        
                        else {
                            entries.append(SimpleEntry(date: lastSAEndDate, isPlaceholder: false, headerText: "COMING UP", largeBodyText: largeBodyText, smallBodyText1: smallBodyText1, smallBodyText2: "", progressCount: progressCount, minorProgressCount: 0, schedule: scheduleArray))
                            
                            entries.append(SimpleEntry(date: startdatetime, isPlaceholder: false, headerText: "NOW", largeBodyText: largeBodyText, smallBodyText1: smallBodyText1, smallBodyText2: "", progressCount: progressCount, minorProgressCount: minorProgressCount, schedule: scheduleArray))
                        }
                        
                        lastSAEndDate = subassignmentlist[index].enddatetime
                        
                        if index == subassignmentlist.count - 1 {
                            entries.append(SimpleEntry(date: subassignmentlist[index].enddatetime, isPlaceholder: false, headerText: "TODAY", largeBodyText: "No Tasks Scheduled", smallBodyText1: "Have a Great Day!", smallBodyText2: "", progressCount: 100, minorProgressCount: 0, schedule: scheduleArray))
                        }
                    }
                    
                    else {
                        entries.append(SimpleEntry(date: Date(), isPlaceholder: false, headerText: "TODAY", largeBodyText: largeBodyText, smallBodyText1: "See Tasks", smallBodyText2: "", progressCount: progressCount, minorProgressCount: minorProgressCount, schedule: scheduleArray))
                    }
                }
            }
        }
        
        if scheduleArray.count == 0 {
            entries.append(SimpleEntry(date: Date(), isPlaceholder: false, headerText: "TODAY", largeBodyText: "No Tasks Scheduled", smallBodyText1: "Have a Great Day!", smallBodyText2: "", progressCount: 100, minorProgressCount: 0, schedule: []))
        }
        
        let timeline = Timeline(entries: entries, policy: .after(tomorrowDate))
        completion(timeline)
    }
}

struct TodaysScheduleEntry {
    var taskName: String
    var className: String
    //left out for now
//    var classGradient: LinearGradient
}

struct SimpleEntry: TimelineEntry {
    //entry Date
    let date: Date
    
    //if isPlaceholder, then display the animated RoundedRectangles
    let isPlaceholder: Bool
    
    //normally headerText = "NOW" or "UPCOMING", but alternatively could be "DEADLINE"...
    //could later be used for other notifications – new GClassroom assignments...
    let headerText: String
    
    //normally largeBodyText = "[TASK NAME]", but alternatively could be something else
    let largeBodyText: String
    
    //normally smallBodyText1 = "[Time Left]", but alternatively could be something else
    let smallBodyText1: String
    
    //normally not used, but can be used as largeBodyText2 = "[Start - End Time]"...
    let smallBodyText2: String
    
    //if progress bar shown, then progressCount relevant (medium and large views)
    let progressCount: Int64
    
    //if progress bar shown, and if NOW, then minorProgressBar also shown (medium and large views)
    let minorProgressCount: Int64
    
    //background gradient, normally based on class colours
    //left out for now
//    let bgGradient: LinearGradient
    
    //not used if family != .large, else uses taskName, className, and classGradient properties
    let schedule: [TodaysScheduleEntry]
}

struct TodaysTasksSmallPlaceholderView: View {
    let geometry: GeometryProxy
    
    let placeholderGradient: LinearGradient = LinearGradient(gradient: Gradient(colors: [Color("gradientD"), Color("gradientC")]), startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        VStack {
            HStack {
                RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/4, height: 15).opacity(0.07)
                
                Spacer()
            }
            
            Spacer()
            
            VStack {
                HStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/1.18, height: 26).opacity(0.12)
                    
                    Spacer()
                }
                
                HStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/1.48, height: 26).opacity(0.12)
                    
                    Spacer()
                }
                
                HStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/1.28, height: 26).opacity(0.12)
                    
                    Spacer()
                }
            }
                        
            Spacer()
            
            HStack {
                RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/1.4, height: 15).opacity(0.09)

                Spacer()
            }
        }.padding(.all, 16).background(LinearGradient(gradient: Gradient(colors: [Color("gradientA"), Color("gradientB")]), startPoint: .top, endPoint: .bottom)).frame(width: geometry.size.width, height: geometry.size.height)
    }
}

struct TodaysTasksSmallView: View {
    var entry: TasksProvider.Entry
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var bgGradient: LinearGradient
    
    init(entryParameter: TasksProvider.Entry) {
        entry = entryParameter
        
        if entry.headerText == "TODAY" {
            bgGradient = LinearGradient(gradient: Gradient(colors: [Color("gradientE"), Color("gradientF")]), startPoint: .top, endPoint: .bottom)
        }
        
        else if entry.headerText == "COMING UP" {
            bgGradient = LinearGradient(gradient: Gradient(colors: [Color("gradientG"), Color("gradientH")]), startPoint: .top, endPoint: .bottom)
        }
        
        else {
            bgGradient = LinearGradient(gradient: Gradient(colors: [Color("gradientA"), Color("gradientB")]), startPoint: .top, endPoint: .bottom)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            if entry.isPlaceholder {
                TodaysTasksSmallPlaceholderView(geometry: geometry)
            }
            
            else {
                VStack {
                    VStack {
                        HStack {
                            Text(entry.headerText).fontWeight(.light).font(.caption2)
                            Spacer()
                        }
                        
                        Spacer()
                    }.frame(height: 15)
                    
                    VStack {
                        HStack {
                            Text(entry.largeBodyText).fontWeight(.bold).font(.system(size: 25)).lineLimit(entry.largeBodyText == "No Tasks Scheduled" ? 2 : 3).allowsTightening(true).minimumScaleFactor(0.7)
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    
                    VStack {
                        Spacer()
                        
                        HStack {
                            Text(entry.smallBodyText1).fontWeight(.regular).font(.caption2)
                            Spacer()
                            Text(entry.smallBodyText2).fontWeight(.light).font(.caption2)
                        }
                    }.frame(height: 15)
                }.padding(.all, 16).background(self.bgGradient).frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

struct TodaysTasksMediumPlaceholderView: View {
    let geometry: GeometryProxy
    
    let placeholderGradient: LinearGradient = LinearGradient(gradient: Gradient(colors: [Color("gradientD"), Color("gradientC")]), startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        VStack {
            HStack {
                RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/4, height: 15).opacity(0.07)

                Spacer()
            }
            
            Spacer()
            
            VStack {
                HStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/1.18, height: 30).opacity(0.12)
                    
                    Spacer()
                }
                
                HStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/1.48, height: 30).opacity(0.12)
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            HStack {
                RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/4, height: 16).opacity(0.09)

                Spacer()
            }
            
            Spacer()
            
            ZStack {
                HStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color("gradientC")).frame(width: (geometry.size.width - 32), height: 15)
                    
                    Spacer()
                }
                
                HStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color("gradientD")).frame(width: CGFloat(0.78 * (geometry.size.width - 32)), height: 15)
                    
                    Spacer()
                }
            }.opacity(0.15)
        }.padding(.all, 16).background(LinearGradient(gradient: Gradient(colors: [Color("gradientA"), Color("gradientB")]), startPoint: .top, endPoint: .bottom)).frame(width: geometry.size.width, height: geometry.size.height)
    }
}


struct TodaysTasksMediumView: View {
    var entry: TasksProvider.Entry
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var bgGradient: LinearGradient
    
    init(entryParameter: TasksProvider.Entry) {
        entry = entryParameter
        
        if entry.headerText == "TODAY" {
            bgGradient = LinearGradient(gradient: Gradient(colors: [Color("gradientE"), Color("gradientF")]), startPoint: .top, endPoint: .bottom)
        }
        
        else if entry.headerText == "COMING UP" {
            bgGradient = LinearGradient(gradient: Gradient(colors: [Color("gradientG"), Color("gradientH")]), startPoint: .top, endPoint: .bottom)
        }
        
        else {
            bgGradient = LinearGradient(gradient: Gradient(colors: [Color("gradientA"), Color("gradientB")]), startPoint: .top, endPoint: .bottom)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            if entry.isPlaceholder {
                TodaysTasksMediumPlaceholderView(geometry: geometry)
            }
            
            else {
                VStack {
                    VStack {
                        HStack {
                            Text(entry.headerText).fontWeight(.light).font(.caption2)
                            Spacer()
                        }
                        
                        Spacer()
                    }.frame(height: 15)
                    
                    Spacer()
                    
                    VStack {
                        HStack {
                            Text(entry.largeBodyText).fontWeight(.bold).font(.system(size: 25)).lineLimit(2).allowsTightening(true)
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    
                    VStack {
                        HStack {
                            Text(entry.smallBodyText1).fontWeight(.regular).font(.caption2)
                            Spacer()
                            Text(entry.smallBodyText2).fontWeight(.light).font(.caption2)
                        }
                    }.frame(height: 15)
                    
                    Spacer()
                    
                    HStack(alignment: .center) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.white).frame(width: (geometry.size.width - 32), height: 15)
                            
                            HStack {
//                                if Double(entry.progressCount + entry.minorProgressCount)/100 > 0.98 {
//                                    Spacer()
//                                }
                                
//                                if entry.minorProgressCount != 0 {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.green).frame(width:  CGFloat(CGFloat(entry.progressCount + entry.minorProgressCount)/100 * (geometry.size.width - 32)), height: 15)
//                                }
                                
                                if Double(entry.progressCount + entry.minorProgressCount)/100 < 0.98 {
                                    Spacer()
                                }
                            }
                            
                            HStack {
                                RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color("progressBlue")).frame(width:  CGFloat(CGFloat(entry.progressCount)/100 * (geometry.size.width - 32)), height: 15)
                                
                                if entry.progressCount != 100 {
                                    Spacer()
                                }
                            }.frame(width: (geometry.size.width - 32))
                        }
                    }
                }.padding(.all, 16).background(self.bgGradient).frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

struct TodaysTasksLargePlaceholderView: View {
    let geometry: GeometryProxy
    
    let placeholderGradient: LinearGradient = LinearGradient(gradient: Gradient(colors: [Color("gradientD"), Color("gradientC")]), startPoint: .topLeading, endPoint: .bottomTrailing)

    var body: some View {
        VStack {
            VStack {
                HStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/4, height: 15).opacity(0.07)

                    Spacer()
                }
                
                Spacer()
                
                VStack {
                    HStack {
                        RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/1.18, height: 30).opacity(0.12)
                        
                        Spacer()
                    }
                    
                    HStack {
                        RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/1.48, height: 30).opacity(0.12)
                        
                        Spacer()
                    }
                }
                
                Spacer()
                
                HStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/4, height: 16).opacity(0.09)

                    Spacer()
                }
                
                Spacer()
                
                ZStack {
                    HStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color("gradientC")).frame(width: (geometry.size.width - 32), height: 15)
                        
                        Spacer()
                    }
                    
                    HStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color("gradientD")).frame(width: CGFloat(0.78 * (geometry.size.width - 32)), height: 15)
                        
                        Spacer()
                    }
                }.opacity(0.15)
            }.frame(height: (geometry.size.height * 0.35))
            
            Spacer()
            
            Divider().padding(.vertical, 5)
            
            Spacer()
            
            VStack {
                HStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/3, height: 28).opacity(0.10)
                    
                    Spacer()
                }
                                    
                ForEach(0..<3, id: \.self) { scheduleEntryIndex in
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 7, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/2, height: (geometry.size.height-32)/8).opacity(0.07)
                        }

                        Spacer()

                        ZStack {
                            RoundedRectangle(cornerRadius: 7, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/2, height: (geometry.size.height-32)/8).opacity(0.07)
                        }
                    }
                }
            }
        }.padding(.all, 16).background(LinearGradient(gradient: Gradient(colors: [Color("gradientA"), Color("gradientB")]), startPoint: .top, endPoint: .bottom)).frame(width: geometry.size.width, height: geometry.size.height)
    }
}

struct TodaysTasksLargeView: View {
    var entry: TasksProvider.Entry
    @Environment(\.colorScheme) var colorScheme: ColorScheme
        
    var bgGradient: LinearGradient
    
    init(entryParameter: TasksProvider.Entry) {
        entry = entryParameter
        
        if entry.headerText == "TODAY" {
            bgGradient = LinearGradient(gradient: Gradient(colors: [Color("gradientE"), Color("gradientF")]), startPoint: .top, endPoint: .bottom)
        }
        
        else if entry.headerText == "COMING UP" {
            bgGradient = LinearGradient(gradient: Gradient(colors: [Color("gradientG"), Color("gradientH")]), startPoint: .top, endPoint: .bottom)
        }
        
        else {
            bgGradient = LinearGradient(gradient: Gradient(colors: [Color("gradientA"), Color("gradientB")]), startPoint: .top, endPoint: .bottom)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            if entry.isPlaceholder {
                TodaysTasksLargePlaceholderView(geometry: geometry)
            }
            
            else {
                VStack {
                    VStack {
                        VStack {
                            HStack {
                                Text(entry.headerText).fontWeight(.light).font(.caption2)
                                Spacer()
                            }
                            
                            Spacer()
                        }.frame(height: 15)
                        
                        Spacer()
                        
                        VStack {
                            HStack {
                                Text(entry.largeBodyText).fontWeight(.bold).font(.system(size: 25)).lineLimit(2).allowsTightening(true)
                                
                                Spacer()
                            }
                            
                            Spacer()
                        }
                        
                        VStack {
                            HStack {
                                Text(entry.smallBodyText1).fontWeight(.regular).font(.caption2)
                                Spacer()
                                Text(entry.smallBodyText2).fontWeight(.light).font(.caption2)
                            }
                        }.frame(height: 15)
                        
                        Spacer()
                        
                        HStack(alignment: .center) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.white).frame(width: (geometry.size.width - 32), height: 15)
                                
                                HStack {
//                                    if Double(entry.progressCount + entry.minorProgressCount)/100 > 0.98 {
//                                        Spacer()
//                                    }
                                    
//                                    if entry.minorProgressCount != 0 {
                                        RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.green).frame(width:  CGFloat(CGFloat(entry.progressCount + entry.minorProgressCount)/100 * (geometry.size.width - 32)), height: 15)
//                                    }
                                    
                                    if Double(entry.progressCount + entry.minorProgressCount)/100 < 0.98 {
                                        Spacer()
                                    }
                                }
                                
                                HStack {
                                RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color("progressBlue")).frame(width:  CGFloat(CGFloat(entry.progressCount)/100 * (geometry.size.width - 32)), height: 15)
                                    
                                    if entry.progressCount != 100 {
                                        Spacer()
                                    }
                                }.frame(width: (geometry.size.width - 32))
                            }
                        }
                    }.frame(height: (geometry.size.height * 0.35))
                    
                    Spacer()
                    
                    Divider().padding(.vertical, 5)
                    
                    Spacer()
                    
                    VStack {
                        HStack {
                            Text("Today's Tasks").fontWeight(.semibold).font(.title3)
                            Spacer()
                        }
                                            
                        ForEach(0..<3, id: \.self) { scheduleEntryIndex in
                            HStack {
                                ZStack {
                                    let n = 2 * scheduleEntryIndex

                                    if (n < entry.schedule.count) {
                                        VStack {
                                            HStack {
                                                Text(entry.schedule[n].taskName).fontWeight(.semibold).font(.body)
                                                Spacer()
                                            }.padding(.top, 6)
                                            
                                            HStack {
                                                Text(entry.schedule[n].className).fontWeight(.light).font(.caption)
                                                Spacer()
                                            }
                                            
                                            Spacer()
                                        }.frame(width: (geometry.size.width-32)/2, height: (geometry.size.height-32)/8)
                                    }
                                    
                                    else {
                                        RoundedRectangle(cornerRadius: 7, style: .continuous).fill(LinearGradient(gradient: Gradient(colors: [Color("gradientD"), Color("gradientC")]), startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: (geometry.size.width-32)/2, height: (geometry.size.height-32)/8).opacity(0.05)
                                    }
                                }

                                Spacer()

                                ZStack {
                                    let n = 2 * scheduleEntryIndex + 1

                                    if (n < entry.schedule.count) {
                                        VStack {
                                            HStack {
                                                Text(entry.schedule[n].taskName).fontWeight(.semibold).font(.body)
                                                Spacer()
                                            }.padding(.top, 6)
                                            
                                            HStack {
                                                Text(entry.schedule[n].className).fontWeight(.light).font(.caption)
                                                Spacer()
                                            }
                                            
                                            Spacer()
                                        }.frame(width: (geometry.size.width-32)/2, height: (geometry.size.height-32)/8)
                                    }
                                    
                                    else {
                                        RoundedRectangle(cornerRadius: 7, style: .continuous).fill(LinearGradient(gradient: Gradient(colors: [Color("gradientD"), Color("gradientC")]), startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: (geometry.size.width-32)/2, height: (geometry.size.height-32)/8).opacity(0.05)
                                    }
                                }
                            }
                        }
                    }
                }.padding(.all, 16).background(self.bgGradient).frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

struct TodaysTasksNAView: View {
    var body: some View {
        Text("An error occured. Please report this to tracrteam@gmail.com.")
        Text("Error 1605. Widget Family Unknown.")
    }
}

struct TodaysTasksEntryView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: TasksProvider.Entry

    @ViewBuilder
    var body: some View {
        switch family {
            case .systemSmall: TodaysTasksSmallView(entryParameter: self.entry)
            case .systemMedium: TodaysTasksMediumView(entryParameter: self.entry)
            case .systemLarge: TodaysTasksLargeView(entryParameter: self.entry)
            default: TodaysTasksNAView()
        }
    }
}

@main
struct TodaysTasks: Widget {
    let kind: String = "Today's Tasks"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TasksProvider()) { entry in
            TodaysTasksEntryView(entry: entry)
        }
        .configurationDisplayName("Today's Tasks")
        .description("Keep track of today's ongoing and upcoming tasks.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct TodaysTasksPreviews: PreviewProvider {
    static var previews: some View {
        TodaysTasksEntryView(entry: SimpleEntry(date: Date(), isPlaceholder: false, headerText: "", largeBodyText: "", smallBodyText1: "", smallBodyText2: "", progressCount: 0, minorProgressCount: 0, schedule: [TodaysScheduleEntry(taskName: "", className: "")]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
