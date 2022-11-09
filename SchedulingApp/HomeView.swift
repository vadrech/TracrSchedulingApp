//
//  HomeView.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 6/30/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//
 
import Foundation
import UIKit
import SwiftUI
import GoogleSignIn
import GoogleAPIClientForREST
import WidgetKit
 
extension Calendar {
    static let gregorian = Calendar(identifier: .gregorian)
}
 
extension Date {
    var startOfWeek: Date? {
        return Calendar.gregorian.date(from: Calendar.gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
    }
}
 
struct PageViewControllerWeeks: UIViewControllerRepresentable {
    @Binding var nthdayfromnow: Int
    
    var viewControllers: [UIViewController]
 
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal)
        
        pageViewController.dataSource = context.coordinator
        
        return pageViewController
    }
    
    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        pageViewController.setViewControllers([viewControllers[Int(Double(self.nthdayfromnow / 7).rounded(.down))]], direction: .forward, animated: true)
    }
    
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PageViewControllerWeeks
 
        init(_ pageViewController: PageViewControllerWeeks) {
            self.parent = pageViewController
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let index = parent.viewControllers.firstIndex(of: viewController) else {
                 return nil
            }
            
            if index == 0 {
                return nil
            }
 
            return parent.viewControllers[index - 1]
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let index = parent.viewControllers.firstIndex(of: viewController) else {
                return nil
            }
            
            if index + 1 == parent.viewControllers.count {
                return nil
            }
            
            return parent.viewControllers[index + 1]
        }
    }
}
class WeeklyBlockViewDateSelector: ObservableObject {
    @Published var dateIndex: Int = 0
  //  @Published var alertView: AlertView = .none
}
 
struct WeeklyBlockView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    @FetchRequest(entity: Subassignmentnew.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Subassignmentnew.startdatetime, ascending: true)])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    
    @Binding var nthdayfromnow: Int
    @Binding var lastnthdayfromnow: Int
    @Binding var increased: Bool
    @Binding var stopupdating: Bool
    
    @Binding var NewAssignmentPresenting: Bool
    
    @State var noClassesAlert = false
    var refreshview: Bool = false
    let datenumberindices: [Int]
    let datenumbersfromlastmonday: [String]
    let datesfromlastmonday: [Date]
    @ObservedObject var dateselector: WeeklyBlockViewDateSelector = WeeklyBlockViewDateSelector()
    
    @EnvironmentObject var masterRunning: MasterRunning
    
    func getassignmentsbydate(index: Int) -> [String] {
        // now shows subassignments
        var ans: [String] = []
        for subassignment in subassignmentlist
        {
            let diff = Calendar.current.isDate(Date(timeInterval: 0, since: self.datesfromlastmonday[self.datenumberindices[index]]), equalTo: Date(timeInterval: 0, since: subassignment.startdatetime), toGranularity: .day)
            if (diff)
            {
                ans.append(subassignment.color)
            }
        }

//        for assignment in assignmentlist {
//
//            if (assignment.completed == false)
//            {
//                let diff = Calendar.current.isDate(Date(timeInterval: 0, since: self.datesfromlastmonday[self.datenumberindices[index]]), equalTo: Date(timeInterval: 0, since: assignment.duedate), toGranularity: .day)
//                if (diff == true)
//                {
//                    ans.append(assignment.color)
//                }
//
//            }
//        }
        return ans
    }
    
    func getassignmentsbydateindex(index: Int, index2: Int) -> String {
        if (index2 < self.getassignmentsbydate(index: index).count)
        {
            return self.getassignmentsbydate(index: index)[index2]
        }
    
        return "zero"
        
    }
    
    func getoffsetfromindex(assignmentsindex: Int, index: Int) -> CGFloat {
        let length = getassignmentsbydate(index: index).count-1
        if (length == 0 || length == -1) {
            return CGFloat(0)
        }
        if (length == 1) {
            return 7*CGFloat(assignmentsindex)-3.5
        }
        if (length == 2) {
            return 7*CGFloat(assignmentsindex)-7
        }
        if (length == 3) {
            return 7*CGFloat(assignmentsindex)-10.5
        }
        if (length == 4) {
            return 7*CGFloat(assignmentsindex)-14
        }
        if (length == 5) {
            return 7*CGFloat(assignmentsindex)-17.5
        }
        
        return CGFloat(7*CGFloat(assignmentsindex)-(3.5*CGFloat(length)))
    }
    
    func GetColorFromRGBCode(rgbcode: String, number: Int = 1) -> Color {
        if number == 1 {
            return Color(.sRGB, red: Double(rgbcode[9..<14])!, green: Double(rgbcode[15..<20])!, blue: Double(rgbcode[21..<26])!, opacity: 1)
        }
        
        return Color(.sRGB, red: Double(rgbcode[36..<41])!, green: Double(rgbcode[42..<47])!, blue: Double(rgbcode[48..<53])!, opacity: 1)
    }

    
    var body: some View {
        ZStack {
            HStack(spacing: (UIScreen.main.bounds.size.width / 29)) {
                ForEach(self.datenumberindices.indices) { index in
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color("datenumberred")).frame(width: (UIScreen.main.bounds.size.width / 29) * 3, height: (UIScreen.main.bounds.size.width / 29) * 3).opacity(self.datenumberindices[index] == self.nthdayfromnow ? 1 : 0)
                            
                            let calendar = Calendar.current
                            
//                            calendar.date(byAdding: .day, value: 1, to: Date().startOfWeek!)!
                            
                            Text(self.datenumbersfromlastmonday[self.datenumberindices[index]]).font(.system(size: (UIScreen.main.bounds.size.width / 29) * (4 / 3))).fontWeight(self.datenumberindices[index] == Calendar.current.dateComponents([.day], from: calendar.date(byAdding: .day, value: 1, to: Date().startOfWeek!)! > Date() ? calendar.date(byAdding: .day, value: -6, to: Date().startOfWeek!)! : calendar.date(byAdding: .day, value: 1, to: Date().startOfWeek!)!, to: Date()).day! ? .bold : .regular)
                        }.contextMenu {
                            Button(action: {
                                    self.classlist.count > 0 ? self.NewAssignmentPresenting.toggle() : self.noClassesAlert.toggle()
                                dateselector.dateIndex = self.datenumberindices[index]
                            }) {
                                Text("Add Assignment")
                                Image(systemName: "doc.plaintext")
                            }
                        }.onTapGesture {
                            withAnimation(.spring()) {
                                self.nthdayfromnow = self.datenumberindices[index]
                                self.stopupdating = true
                                
                                if self.lastnthdayfromnow > self.nthdayfromnow {
                                    self.increased = false
                                }
                                
                                else if self.lastnthdayfromnow < self.nthdayfromnow {
                                    self.increased = true
                                }
                                
                                self.lastnthdayfromnow = self.nthdayfromnow
                                
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(300)) {
                                    self.stopupdating = false
                                }
                            }
                        }
                        ZStack {
                            ForEach(self.getassignmentsbydate(index: index).indices, id: \.self) { index2 in
                                if (self.getassignmentsbydateindex(index: index, index2: index2) == "zero")
                                {
                                    
                                }
                                else
                                {
                                    Circle().fill(self.getassignmentsbydateindex(index: index, index2: index2).contains("rgbcode") ? GetColorFromRGBCode(rgbcode: self.getassignmentsbydateindex(index: index, index2: index2)) : Color(self.getassignmentsbydateindex(index: index, index2: index2))).frame(width: 5, height:  5).offset(x: self.getoffsetfromindex(assignmentsindex: index2, index: index))
                                }
                            }
                        }
                        Spacer()
                    }
                }
                
            }
            .sheet(isPresented: $NewAssignmentPresenting, content: { NewAssignmentModalView(NewAssignmentPresenting: self.$NewAssignmentPresenting, selectedClass: 0, preselecteddate: dateselector.dateIndex).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning)}).alert(isPresented: $noClassesAlert) {
                Alert(title:  Text("No Classes Added"), message: Text("Add a Class First"))
            }.padding(.horizontal, (UIScreen.main.bounds.size.width / 29))

        }
    }
}
 
struct DummyPageViewControllerForDates: UIViewControllerRepresentable {
    @Binding var increased: Bool
    @Binding var stopupdating: Bool

    var viewControllers: [UIViewController]
 
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal)
        
        return pageViewController
    }
    
    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        pageViewController.setViewControllers([viewControllers[0]], direction: (self.increased ? .forward : .reverse), animated: self.stopupdating)//reverse/forward based on change
    }
    
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: DummyPageViewControllerForDates
 
        init(_ pageViewController: DummyPageViewControllerForDates) {
            self.parent = pageViewController
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard parent.viewControllers.firstIndex(of: viewController) != nil else {
                 return nil
            }
            
            return nil
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard parent.viewControllers.firstIndex(of: viewController) != nil else {
                return nil
            }
            
            return nil
        }
    }
}

struct SubassignmentAddTimeAction: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    
    @FetchRequest(entity: Subassignmentnew.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Subassignmentnew.startdatetime, ascending: true)])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    
    @FetchRequest(entity: AddTimeLog.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \AddTimeLog.name, ascending: true)])
    var addtimeloglist: FetchedResults<AddTimeLog>
    
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [])
    var classlist: FetchedResults<Classcool>
    
    @EnvironmentObject var addTimeSubassignment: AddTimeSubassignment
    @EnvironmentObject var actionViewPresets: ActionViewPresets

    @EnvironmentObject var masterRunning: MasterRunning
    
    @State var subPageType: String = "Reschedule All?"
    
    @State var uniformlistviewshows = false
    
    func GetColorFromRGBCode(rgbcode: String, number: Int = 1) -> Color {
        if number == 1 {
            return Color(.sRGB, red: Double(rgbcode[9..<14])!, green: Double(rgbcode[15..<20])!, blue: Double(rgbcode[21..<26])!, opacity: 1)
        }
        
        return Color(.sRGB, red: Double(rgbcode[36..<41])!, green: Double(rgbcode[42..<47])!, blue: Double(rgbcode[48..<53])!, opacity: 1)
    }

    var body: some View {
        HStack {
            Text("Reschedule Task").font(.system(size: 14)).fontWeight(.light)
            Spacer()
            Button(action: {
                actionViewPresets.actionViewOffset = UIScreen.main.bounds.size.width
                actionViewPresets.actionViewHeight = 1
                actionViewPresets.actionViewType = ""
            }, label: {
                Image(systemName: "xmark").font(.system(size: 11)).foregroundColor(self.colorScheme == .light ? Color.black : Color.white)
            })
        }.frame(width: UIScreen.main.bounds.size.width - 75).onAppear {
            let defaults = UserDefaults.standard

            let specificworktimes = defaults.object(forKey: "specificworktimes") as? Bool ?? true
            if (specificworktimes) {
                self.uniformlistviewshows = false
            }
            else {
                self.uniformlistviewshows = true
            }
        }
        
        Spacer()
        
        VStack {
            HStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous).fill(addTimeSubassignment.subassignmentcolor.contains("rgbcode") ? GetColorFromRGBCode(rgbcode: addTimeSubassignment.subassignmentcolor) : Color(addTimeSubassignment.subassignmentcolor)).frame(width: 30, height: 30).overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black, lineWidth: 0.6)
                )
                
                Spacer().frame(width: 15)
                
                VStack {
                    HStack {
                        Text(addTimeSubassignment.subassignmentname).font(.system(size: 17)).fontWeight(.medium)
                        
                        Spacer()
                        
                        if uniformlistviewshows {
                            Text(addTimeSubassignment.subassignmentdatetext).font(.system(size: 15)).fontWeight(.light)
                        }
                    }
                    
                    if !uniformlistviewshows {
                        Spacer().frame(height: 6)
                        
                        HStack {
                            Text(addTimeSubassignment.subassignmentstarttimetext + " - " + addTimeSubassignment.subassignmentendtimetext).font(.system(size: 15)).fontWeight(.light)
                            
                            Spacer()
                            
                            Text(addTimeSubassignment.subassignmentdatetext).font(.system(size: 15)).fontWeight(.light)
                            
                            Spacer().frame(width: 15)
                        }
                    }
                }
            }.frame(width: UIScreen.main.bounds.size.width - 75)
            
            Spacer().frame(height: 15)
        }
        
        if self.subPageType == "Reschedule All?" {
            VStack {
                HStack {
                    Text("Would you like to reschedule the entire task, or only a part of the task?").font(.system(size: 16)).fontWeight(.light).lineLimit(2)
                    
                    Spacer()
                }.frame(width: UIScreen.main.bounds.size.width - 75)
            }
            
            Spacer()
            
            Rectangle().fill(Color.gray).frame(width: UIScreen.main.bounds.size.width-75, height: 1)
            
            HStack {
                Button(action: {
                    let newAddTimeLog = AddTimeLog(context: self.managedObjectContext)

                    newAddTimeLog.name = self.subassignmentlist[addTimeSubassignment.subassignmentindex].assignmentname
                    newAddTimeLog.length = Int64(addTimeSubassignment.subassignmentlength)
                    newAddTimeLog.color = self.subassignmentlist[addTimeSubassignment.subassignmentindex].color
                    newAddTimeLog.starttime = self.subassignmentlist[addTimeSubassignment.subassignmentindex].startdatetime
                    newAddTimeLog.endtime = self.subassignmentlist[addTimeSubassignment.subassignmentindex].enddatetime
                    newAddTimeLog.date = self.subassignmentlist[addTimeSubassignment.subassignmentindex].assignmentduedate
                    newAddTimeLog.completionpercentage = 0
                    
                    actionViewPresets.actionViewOffset = UIScreen.main.bounds.size.width
                    actionViewPresets.actionViewHeight = 1
                    actionViewPresets.actionViewType = ""
                    
                    self.managedObjectContext.delete(self.subassignmentlist[addTimeSubassignment.subassignmentindex])
                    
                    //assignment specific
                    masterRunning.uniqueAssignmentName = addTimeSubassignment.subassignmentname
                    print("A2")
                    masterRunning.masterRunningNow = true
                    masterRunning.displayText = true
                    
                    do {
                        try self.managedObjectContext.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                }) {
                    Text("Entire Task").font(.system(size: 17)).fontWeight(.semibold).foregroundColor(Color.red).frame(width: (UIScreen.main.bounds.size.width - 80) / 2, height: 25)
                }
                
                Spacer()
                
                Rectangle().fill(Color.gray).frame(width: 1, height: 25)
                
                Spacer()
                
                Button(action: {
                    self.subPageType = "Reschedule Part"
                    actionViewPresets.actionViewHeight = 280
                    
                }) {
                    Text("Part of Task").font(.system(size: 17)).fontWeight(.semibold).frame(width: (UIScreen.main.bounds.size.width - 80) / 2, height: 25)
                }
            }.padding(.vertical, 8).padding(.bottom, -3)
        }
        
        else if self.subPageType == "Reschedule Part" {
            VStack {
                HStack {
                    Text("How much of the task did you complete?").font(.system(size: 16)).fontWeight(.light)
                    
                    Spacer()
                }.frame(width: UIScreen.main.bounds.size.width - 75)
                
                Section {
                    Slider(value: $addTimeSubassignment.subassignmentcompletionpercentage, in: 0...100)
                }.frame(width: UIScreen.main.bounds.size.width - 75)
                
                Text("\(addTimeSubassignment.subassignmentcompletionpercentage.rounded(.down), specifier: "%.0f")%")
                Text("≈ \(Int((addTimeSubassignment.subassignmentcompletionpercentage / 100) * Double(addTimeSubassignment.subassignmentlength) / 5) * 5) minutes").fontWeight(.light)
            }
            
            Spacer()
            
            Rectangle().fill(Color.gray).frame(width: UIScreen.main.bounds.size.width-75, height: 1)
    //        if masterRunning.masterRunningNow {
    //            MasterClass()
    //        }
            Button(action: {
                let newAddTimeLog = AddTimeLog(context: self.managedObjectContext)

                newAddTimeLog.name = self.subassignmentlist[addTimeSubassignment.subassignmentindex].assignmentname
                newAddTimeLog.length = Int64(addTimeSubassignment.subassignmentlength)
                newAddTimeLog.color = self.subassignmentlist[addTimeSubassignment.subassignmentindex].color
                newAddTimeLog.starttime = self.subassignmentlist[addTimeSubassignment.subassignmentindex].startdatetime
                newAddTimeLog.endtime = self.subassignmentlist[addTimeSubassignment.subassignmentindex].enddatetime
                newAddTimeLog.date = self.subassignmentlist[addTimeSubassignment.subassignmentindex].assignmentduedate
                newAddTimeLog.completionpercentage = addTimeSubassignment.subassignmentcompletionpercentage
                
                actionViewPresets.actionViewOffset = UIScreen.main.bounds.size.width
                actionViewPresets.actionViewHeight = 1
                //following line not there before: watch for bugs!
                actionViewPresets.actionViewType = ""
                
                self.managedObjectContext.delete(self.subassignmentlist[addTimeSubassignment.subassignmentindex])
                
                var lastTaskAndCompleted = false
                
                for (_, element) in self.assignmentlist.enumerated() {
                    if (element.name == addTimeSubassignment.subassignmentname) {
                        let minutescompleted = (addTimeSubassignment.subassignmentcompletionpercentage / 100) * Double(addTimeSubassignment.subassignmentlength)
                        let minutescompletedroundeddown = Int(minutescompleted / 5) * 5
                        element.timeleft -= Int64(minutescompletedroundeddown)
                        element.progress = Int64((Double(element.totaltime - element.timeleft)/Double(element.totaltime)) * 100)
                        
                        if element.progress == 100 {
                            element.completed = true
                            lastTaskAndCompleted = true
                            
                            for classity in self.classlist {
                                if (classity.originalname == element.subject) {
                                    classity.assignmentnumber -= 1
                                }
                            }
                        }
                    }
                }
                //assignment specific
                
                if !lastTaskAndCompleted {
                    masterRunning.uniqueAssignmentName = addTimeSubassignment.subassignmentname
                    print("A")
                    masterRunning.masterRunningNow = true
                    masterRunning.displayText = true
                }
                
                do {
                    try self.managedObjectContext.save()
                } catch {
                    print(error.localizedDescription)
                }
            }) {
                Text("Done").font(.system(size: 17)).fontWeight(.semibold).frame(width: UIScreen.main.bounds.size.width-80, height: 25)
            }.padding(.vertical, 8).padding(.bottom, -3)
        }
    }
}

struct SubassignmentBacklogAction: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @EnvironmentObject var addTimeSubassignmentBacklog: AddTimeSubassignmentBacklog
    @EnvironmentObject var actionViewPresets: ActionViewPresets
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    
    @FetchRequest(entity: Subassignmentnew.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Subassignmentnew.startdatetime, ascending: true)])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [])
    var classlist: FetchedResults<Classcool>
    
    @State var subPageType: String = "Introduction"
    @State var subassignmentcompletionpercentage: Double = 0
    @State var nthTask: Int = 1
    
    @EnvironmentObject var masterRunning: MasterRunning
    
    @State var uniformlistviewshows = false

    func GetColorFromRGBCode(rgbcode: String, number: Int = 1) -> Color {
        if number == 1 {
            return Color(.sRGB, red: Double(rgbcode[9..<14])!, green: Double(rgbcode[15..<20])!, blue: Double(rgbcode[21..<26])!, opacity: 1)
        }
        
        return Color(.sRGB, red: Double(rgbcode[36..<41])!, green: Double(rgbcode[42..<47])!, blue: Double(rgbcode[48..<53])!, opacity: 1)
    }
    
    var body: some View {
        if self.subPageType == "What is this?" {
            HStack {
                Text("Tasks Backlog").font(.system(size: 14)).fontWeight(.light)
                Spacer()
                Button(action: {
                    actionViewPresets.actionViewOffset = UIScreen.main.bounds.size.width
                    actionViewPresets.actionViewHeight = 1
                    actionViewPresets.actionViewType = ""
                }, label: {
                    Image(systemName: "xmark").font(.system(size: 11)).foregroundColor(self.colorScheme == .light ? Color.black : Color.white)
                })
            }.frame(width: UIScreen.main.bounds.size.width - 75)
            
            Spacer()
            
            HStack {
                Text("The Tasks Backlog keeps track of all the tasks which you have not swiped left to complete. Here, you can keep track of your backlog, and update progress on these tasks so that they are rescheduled. You can additionally swipe tasks from the past to the right to reschedule them.").font(.system(size: 15)).fontWeight(.light).minimumScaleFactor(0.7)

                Spacer()
            }.frame(width: UIScreen.main.bounds.size.width - 75)
            
            Spacer()
            
            VStack {
                ZStack {
                    HStack {
                        ZStack {
                            Rectangle().fill(Color.blue).frame(width: 2*(UIScreen.main.bounds.size.width - 75)/3, height: 30)
                            Image(systemName: "timer").resizable().frame(width: 16, height: 16).offset(x: (-(UIScreen.main.bounds.size.width - 75)/3) + 16)
                        }
                        Spacer()
                    }.frame(width: UIScreen.main.bounds.size.width - 75)
                    
                    HStack {
                        Spacer()
                        ZStack {
                            RoundedRectangle(cornerRadius: 6, style: .continuous).fill(LinearGradient(gradient: Gradient(colors: [Color("one"), Color("very_light_gray")]), startPoint: .leading, endPoint: .trailing)).frame(width: 3*(UIScreen.main.bounds.size.width - 75)/4, height: 30)
                            Image(systemName: "arrow.right").resizable().frame(width: 24, height: 16).offset(x: -10)
                        }
                    }.frame(width: UIScreen.main.bounds.size.width - 75)
                }
                
                Spacer().frame(height: 8)
                
                ZStack {
                    HStack {
                        Spacer()
                        ZStack {
                            Rectangle().fill(Color("fourteen")).frame(width: 2*(UIScreen.main.bounds.size.width - 75)/3, height: 30)
                            Image(systemName: "checkmark.circle").resizable().frame(width: 16, height: 16).offset(x: ((UIScreen.main.bounds.size.width - 75)/3) - 16)
                        }
                    }.frame(width: UIScreen.main.bounds.size.width - 75)
                    
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6, style: .continuous).fill(LinearGradient(gradient: Gradient(colors: [Color("very_light_gray"), Color("twelve")]), startPoint: .leading, endPoint: .trailing)).frame(width: 3*(UIScreen.main.bounds.size.width - 75)/4, height: 30)
                            Image(systemName: "arrow.left").resizable().frame(width: 24, height: 16).offset(x: 10)
                        }
                        Spacer()
                    }.frame(width: UIScreen.main.bounds.size.width - 75)
                }
            }
            
            Spacer()
            
            Rectangle().fill(Color.gray).frame(width: UIScreen.main.bounds.size.width-75, height: 1)
            
            Button(action: {
                self.subPageType = "Introduction"
                
                if self.addTimeSubassignmentBacklog.backlogList.count == 0 {
                    actionViewPresets.actionViewHeight = 150
                }
                
                UserDefaults.standard.set(true, forKey: "launchedBacklogBefore")
            }) {
                Text("Okay, Got it!").font(.system(size: 17)).fontWeight(.semibold).foregroundColor(Color.green).frame(width: UIScreen.main.bounds.size.width-80, height: 25)
            }.padding(.vertical, 8).padding(.bottom, -3)
        }
        
        else if self.subPageType == "Introduction" || (actionViewPresets.actionViewHeight != 280 && actionViewPresets.actionViewHeight != 281) {
            //301 = MUST case
            if actionViewPresets.actionViewHeight == 301 {
                HStack {
                    Text(addTimeSubassignmentBacklog.backlogList.count != 1 ? "Tasks Backlog - \(addTimeSubassignmentBacklog.backlogList.count) Tasks" : "Tasks Backlog - \(addTimeSubassignmentBacklog.backlogList.count) Task").font(.system(size: 14)).fontWeight(.light)
                    Spacer()
                    Text("Must Update Progress").font(.system(size: 14)).fontWeight(.light).foregroundColor(.red)
                    Spacer().frame(width: 10)
                    Button(action: {
                        ()
//                        actionViewPresets.actionViewOffset = UIScreen.main.bounds.size.width
//                        actionViewPresets.actionViewHeight = 1
//                        actionViewPresets.actionViewType = ""
                    }, label: {
                        Image(systemName: "xmark").font(.system(size: 11)).foregroundColor(.gray).opacity(0.6)
                    })
                }.frame(width: UIScreen.main.bounds.size.width - 75)
            }
            
            else {
                HStack {
                    Text(addTimeSubassignmentBacklog.backlogList.count != 1 ? "Tasks Backlog - \(addTimeSubassignmentBacklog.backlogList.count) Tasks" : "Tasks Backlog - \(addTimeSubassignmentBacklog.backlogList.count) Task").font(.system(size: 14)).fontWeight(.light)
                    Spacer()
                    Button(action: {
                        actionViewPresets.actionViewOffset = UIScreen.main.bounds.size.width
                        actionViewPresets.actionViewHeight = 1
                        actionViewPresets.actionViewType = ""
                    }, label: {
                        Image(systemName: "xmark").font(.system(size: 11)).foregroundColor(self.colorScheme == .light ? Color.black : Color.white)
                    })
                }.frame(width: UIScreen.main.bounds.size.width - 75)
            }
            
            Spacer().onAppear {
                let defaults = UserDefaults.standard

                let specificworktimes = defaults.object(forKey: "specificworktimes") as? Bool ?? true
                if (specificworktimes) {
                    self.uniformlistviewshows = false
                }
                else {
                    self.uniformlistviewshows = true
                }
                
                let launchedBacklogBefore = UserDefaults.standard.bool(forKey: "launchedBacklogBefore")
                if !launchedBacklogBefore {
                    self.subPageType = "What is this?"
                }
            }
            
            if addTimeSubassignmentBacklog.backlogList.count > 0 {
                VStack {
                    HStack {
                        Text("You have the following tasks in your backlog:").font(.system(size: 16)).fontWeight(.light)

                        Spacer()
                    }.frame(width: UIScreen.main.bounds.size.width - 75)

                    Spacer().frame(height: 15)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(0..<addTimeSubassignmentBacklog.backlogList.count) { subassignmentindex in
                                let subassignmentcolortemp = addTimeSubassignmentBacklog.backlogList[subassignmentindex]["subassignmentcolor"] ?? "datenumberred"

                                ZStack {
                                    RoundedRectangle(cornerRadius: 3, style: .continuous).fill(subassignmentcolortemp.contains("rgbcode") ? GetColorFromRGBCode(rgbcode: subassignmentcolortemp) : Color(subassignmentcolortemp)).frame(width: 130, height: 90)

                                    VStack {
                                        Text(addTimeSubassignmentBacklog.backlogList[subassignmentindex]["subassignmentname"] ?? "FAIL").font(.system(size: 16)).fontWeight(.semibold).frame(width: 120).lineLimit(1)

                                        Text(addTimeSubassignmentBacklog.backlogList[subassignmentindex]["subassignmentdatetext"] ?? "FAIL").font(.footnote).fontWeight(.light)
                                    }
                                }.padding(.trailing, 4)
                            }
                        }
                    }.padding(.all, 4).frame(width: UIScreen.main.bounds.size.width - 75, height: 100).animation(.spring())

                    //older version
//                    ScrollView() {
//                        ForEach(0..<addTimeSubassignmentBacklog.backlogList.count) { subassignmentindex in
//                            HStack {
//                                let subassignmentcolortemp = addTimeSubassignmentBacklog.backlogList[subassignmentindex]["subassignmentcolor"] ?? "datenumberred"
//                                RoundedRectangle(cornerRadius: 3, style: .continuous).fill(subassignmentcolortemp.contains("rgbcode") ? GetColorFromRGBCode(rgbcode: subassignmentcolortemp) : Color(subassignmentcolortemp)).frame(width: 12, height: 12).overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.black, lineWidth: 0.6)
//                                )
//
//                                Spacer().frame(width: 15)
//
//                                Text(addTimeSubassignmentBacklog.backlogList[subassignmentindex]["subassignmentname"] ?? "FAIL").font(.system(size: 17)).fontWeight(.medium)
//
//                                Spacer()
//
//                                Text(addTimeSubassignmentBacklog.backlogList[subassignmentindex]["subassignmentdatetext"] ?? "FAIL").font(.system(size: 15)).fontWeight(.light)
//                            }.padding(.horizontal, 10).frame(width: UIScreen.main.bounds.size.width - 75, height: 25)
//                        }
//                    }.frame(height: CGFloat(min((addTimeSubassignmentBacklog.backlogList.count * 32), 90)))

                    HStack {
                        Text("Click Continue to update your progress on these tasks.").font(.system(size: 16)).fontWeight(.light)

                        Spacer()
                    }.frame(width: UIScreen.main.bounds.size.width - 75)
                }
                
                Spacer()
                
                Rectangle().fill(Color.gray).frame(width: UIScreen.main.bounds.size.width-75, height: 1)
                
                Button(action: {
                    self.subPageType = "Tasks"
                    //MUST case
                    if actionViewPresets.actionViewHeight == 301 {
                        actionViewPresets.actionViewHeight = 281
                    }
                    
                    else {
                        actionViewPresets.actionViewHeight = 280
                    }
                }) {
                    Text("Continue").font(.system(size: 17)).fontWeight(.semibold).frame(width: UIScreen.main.bounds.size.width-80, height: 25)
                }.padding(.vertical, 8).padding(.bottom, -3)
            }
            
            else {
                VStack {
                    HStack {
                        Text("You have 0 tasks in your backlog!").font(.system(size: 18)).fontWeight(.light)
                        
                        Spacer()
//                        insert image
                    }.frame(width: UIScreen.main.bounds.size.width - 75)
                }
                
                Spacer()
                
                Rectangle().fill(Color.gray).frame(width: UIScreen.main.bounds.size.width-75, height: 1)
                
                Button(action: {
                    actionViewPresets.actionViewOffset = UIScreen.main.bounds.size.width
                    actionViewPresets.actionViewHeight = 1
                    actionViewPresets.actionViewType = ""
                }) {
                    Text("Okay!").font(.system(size: 17)).fontWeight(.semibold).foregroundColor(Color.green).frame(width: UIScreen.main.bounds.size.width-80, height: 25)
                }.padding(.vertical, 8).padding(.bottom, -3)
            }
        }
        
        else if self.subPageType == "Tasks" {
            if actionViewPresets.actionViewHeight == 281 {
                HStack {
                    Text("Tasks Backlog (\(self.nthTask)/\(addTimeSubassignmentBacklog.backlogList.count + self.nthTask - 1))").font(.system(size: 14)).fontWeight(.light)
                    Spacer()
                    Text("Must Update Progress").font(.system(size: 14)).fontWeight(.light).foregroundColor(.red)
                    Spacer().frame(width: 10)
                    Button(action: {
                        ()
//                        actionViewPresets.actionViewOffset = UIScreen.main.bounds.size.width
//                        actionViewPresets.actionViewHeight = 1
//                        actionViewPresets.actionViewType = ""
//
//                        self.subPageType = ""
                    }, label: {
                        Image(systemName: "xmark").font(.system(size: 11)).foregroundColor(.gray).opacity(0.6)
                    })
                }.frame(width: UIScreen.main.bounds.size.width - 75)
            }
            
            else {
                HStack {
                    Text("Tasks Backlog (\(self.nthTask)/\(addTimeSubassignmentBacklog.backlogList.count + self.nthTask - 1))").font(.system(size: 14)).fontWeight(.light)
                    Spacer()
                    Button(action: {
                        actionViewPresets.actionViewOffset = UIScreen.main.bounds.size.width
                        actionViewPresets.actionViewHeight = 1
                        actionViewPresets.actionViewType = ""
                        
                        self.subPageType = ""
                    }, label: {
                        Image(systemName: "xmark").font(.system(size: 11)).foregroundColor(self.colorScheme == .light ? Color.black : Color.white)
                    })
                }.frame(width: UIScreen.main.bounds.size.width - 75)
            }
            
            Spacer()
            
            VStack {
                HStack {
                    let subassignmentcolortemp2 = addTimeSubassignmentBacklog.backlogList[0]["subassignmentcolor"] ?? "one"
                    RoundedRectangle(cornerRadius: 6, style: .continuous).fill(subassignmentcolortemp2.contains("rgbcode") ? GetColorFromRGBCode(rgbcode: subassignmentcolortemp2) : Color(subassignmentcolortemp2)).frame(width: 30, height: 30).overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black, lineWidth: 0.6)
                    )

                    Spacer().frame(width: 15)
                    
                    VStack {
                        HStack {
                            Text(addTimeSubassignmentBacklog.backlogList[0]["subassignmentname"] ?? "FAIL").font(.system(size: 17)).fontWeight(.medium)

                            Spacer()
                            
                            if uniformlistviewshows {
                                Text(addTimeSubassignmentBacklog.backlogList[0]["subassignmentdatetext"] ?? "FAIL").font(.system(size: 15)).fontWeight(.light)

                                Spacer().frame(width: 15)
                            }
                        }

                        if !uniformlistviewshows {
                            Spacer().frame(height: 6)

                            HStack {
                                Text((addTimeSubassignmentBacklog.backlogList[0]["subassignmentstarttimetext"] ?? "FAIL") + " - " + (addTimeSubassignmentBacklog.backlogList[0]["subassignmentendtimetext"] ?? "FAIL")).font(.system(size: 15)).fontWeight(.light)
                                
                                Spacer()

                                Text(addTimeSubassignmentBacklog.backlogList[0]["subassignmentdatetext"] ?? "FAIL").font(.system(size: 15)).fontWeight(.light)

                                Spacer().frame(width: 15)
                            }
                        }
                    }
                }.frame(width: UIScreen.main.bounds.size.width - 75)

                Spacer().frame(height: 15)

                HStack {
                    Text("How much of the task did you complete?").font(.system(size: 16)).fontWeight(.light)

                    Spacer()
                }.frame(width: UIScreen.main.bounds.size.width - 75)

                Section {
                    Slider(value: self.$subassignmentcompletionpercentage, in: 0...100)
                }.frame(width: UIScreen.main.bounds.size.width - 75)

                Text("\(self.subassignmentcompletionpercentage.rounded(.down), specifier: "%.0f")%")
                Text("≈ \(Int((self.subassignmentcompletionpercentage / 100) * (Double(addTimeSubassignmentBacklog.backlogList[0]["subassignmentlength"] ?? "0") ?? 0) / 5) * 5) minutes").fontWeight(.light)
            }
            
            Spacer()
            
            Rectangle().fill(Color.gray).frame(width: UIScreen.main.bounds.size.width-75, height: 1)
            
            Button(action: {
                let newAddTimeLog = AddTimeLog(context: self.managedObjectContext)

                newAddTimeLog.name = addTimeSubassignmentBacklog.backlogList[0]["subassignmentname"] ?? "FAIL"
                newAddTimeLog.length = Int64(addTimeSubassignmentBacklog.backlogList[0]["subassignmentlength"] ?? "0") ?? 0
                newAddTimeLog.color = addTimeSubassignmentBacklog.backlogList[0]["subassignmentcolor"] ?? "one"
                newAddTimeLog.starttime = self.subassignmentlist[0].startdatetime
                newAddTimeLog.endtime = self.subassignmentlist[0].enddatetime
                newAddTimeLog.date = self.subassignmentlist[0].assignmentduedate
                newAddTimeLog.completionpercentage = self.subassignmentcompletionpercentage
                
                self.nthTask += 1

                if addTimeSubassignmentBacklog.backlogList.count == 1 {
                    actionViewPresets.actionViewOffset = UIScreen.main.bounds.size.width
                    actionViewPresets.actionViewHeight = 1
                    self.subPageType = ""
                    self.nthTask = 1
                    masterRunning.displayText = true
                }

                self.managedObjectContext.delete(self.subassignmentlist[0])
                
                var lastTaskAndCompleted = false
                
                for (_, element) in self.assignmentlist.enumerated() {
                    if (element.name == addTimeSubassignmentBacklog.backlogList[0]["subassignmentname"] ?? "FAIL") {
                        let lengthAsDouble = Double((addTimeSubassignmentBacklog.backlogList[0]["subassignmentlength"] ?? "0.0").replacingOccurrences(of: "[^\\.\\d+]", with: "", options: [.regularExpression])) ?? 0.0
                        let minutescompleted = (self.subassignmentcompletionpercentage / 100) * lengthAsDouble
                        let minutescompletedroundeddown = Int(minutescompleted / 5) * 5
                        
                        element.timeleft -= Int64(minutescompletedroundeddown)
                        element.progress = Int64((Double(element.totaltime - element.timeleft)/Double(element.totaltime)) * 100)
                        
                        if element.progress == 100 {
                            element.completed = true
                            lastTaskAndCompleted = true
                            
                            for classity in self.classlist {
                                if (classity.originalname == element.subject) {
                                    classity.assignmentnumber -= 1
                                }
                            }
                        }
                    }
                }

                do {
                    try self.managedObjectContext.save()
                } catch {
                    print(error.localizedDescription)
                }
                
                self.subassignmentcompletionpercentage = 0
                
                if !lastTaskAndCompleted {
                    masterRunning.uniqueAssignmentName = addTimeSubassignmentBacklog.backlogList[0]["subassignmentname"] ?? "FAIL"
                    print("B")
                    masterRunning.masterRunningNow = true
                }
                
                addTimeSubassignmentBacklog.backlogList.remove(at: 0)
                //assignment specific
                
            }) {
                Text(addTimeSubassignmentBacklog.backlogList.count > 1 ? "Next" : "Done").font(.system(size: 17)).fontWeight(.semibold).frame(width: UIScreen.main.bounds.size.width-80, height: 25)
            }.padding(.vertical, 8).padding(.bottom, -3)
        }
        
//        if masterRunning.masterRunningNow {
//            MasterClass()
//        }
    }
}

struct NoClassesOrFreetime: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var actionViewPresets: ActionViewPresets

//    @EnvironmentObject var masterRunning: MasterRunning
//
//    func GetColorFromRGBCode(rgbcode: String, number: Int = 1) -> Color {
//        if number == 1 {
//            return Color(.sRGB, red: Double(rgbcode[9..<14])!, green: Double(rgbcode[15..<20])!, blue: Double(rgbcode[21..<26])!, opacity: 1)
//        }
//
//        return Color(.sRGB, red: Double(rgbcode[36..<41])!, green: Double(rgbcode[42..<47])!, blue: Double(rgbcode[48..<53])!, opacity: 1)
//    }
    @State var NewSheetPresenting = false
    
    @Binding var noclasses: Bool
    @Binding var nofreetime: Bool
    @Binding var subpage: String
    
    var body : some View {
        VStack {
            HStack {
                Text("Quick Setup – Reminder").font(.system(size: subpage == "None" ? 29 : 20)).fontWeight(.light)
                Spacer()
            }.padding(.all, 5).padding(.horizontal, subpage == "None" ? 0 : 19)
            
            if subpage == "None" {
                VStack(spacing: 5) {
                    HStack {
                        Text("In order to plan your schedule, you need to first add your free times and add at least one class.").font(.system(size: 14)).fontWeight(.light)
                        Spacer()
                    }.padding(.horizontal, 5)
                    HStack {
                        Text("You can do this by holding the blue Add button and selecting 'Free Time' and 'Class'").font(.system(size: 14)).fontWeight(.semibold)
                        Spacer()
                    }.padding(.horizontal, 5)
                }
            }
            
            Spacer()
            
            HStack {
                Image(systemName: "clock").resizable().scaledToFit().frame(width: subpage == "None" ? 23 : 15)
                Spacer().frame(width: subpage == "None" ? 30 : 15)
                Text("Free Time").font(.system(size: subpage == "None" ? 21 : 15)).fontWeight(.light)
                Spacer()
                if nofreetime {
                    Image(systemName: "xmark").foregroundColor(.red)
                }
                else {
                    Image(systemName: "checkmark").foregroundColor(.green)
                }
            }.padding(.all, subpage == "None" ? 10 : 5).padding(.horizontal, subpage == "None" ? 10 : 30)
            
            HStack {
                Image(systemName: "folder").resizable().scaledToFit().frame(width: subpage == "None" ? 23 : 15)
                Spacer().frame(width: subpage == "None" ? 30 : 15)
                Text("Classes").font(.system(size: subpage == "None" ? 21 : 15)).fontWeight(.light)
                Spacer()
                if noclasses {
                    Image(systemName: "xmark").foregroundColor(.red)
                }
                else {
                    Image(systemName: "checkmark").foregroundColor(.green)
                }
            }.padding(.all, subpage == "None" ? 10 : 5).padding(.horizontal, subpage == "None" ? 10 : 30)
            
            Spacer()
            
            if subpage == "None" {
                HStack {
                    NavigationLink(destination:
                                    TutorialView().navigationTitle("Tutorial").navigationBarTitleDisplayMode(.inline)//.edgesIgnoringSafeArea(.all)//.padding(.top, -40)
                    ) {
                        HStack {
                            Text("Head to Tutorial").font(.system(size: 17)).fontWeight(.semibold).frame(width: (UIScreen.main.bounds.size.width - 80) / 2, height: 25)
                        }.frame(height: 40)
                    }
                    
                    Spacer()
                    
                    Rectangle().fill(Color.gray).frame(width: 1, height: 25)
                    
                    Spacer()
                    
                    Button(action: {
                        actionViewPresets.actionViewOffset = UIScreen.main.bounds.size.width
                        actionViewPresets.actionViewHeight = 1
                        actionViewPresets.actionViewType = ""
                    }) {
                        Text("Okay, Got it!").font(.system(size: 17)).fontWeight(.semibold).foregroundColor(Color.green).frame(width: (UIScreen.main.bounds.size.width - 80) / 2, height: 25)
                    }
                }.padding(.vertical, 8).padding(.bottom, -3)
            }
            
//            if subpage == "Class" {
//                NewClassModalView(NewClassPresenting: self.$NewSheetPresenting).environment(\.managedObjectContext, self.managedObjectContext)
//            }
        }.frame(width: subpage == "None" ? UIScreen.main.bounds.size.width-60 : UIScreen.main.bounds.size.width)
    }
}

struct ActionView: View {
    @EnvironmentObject var actionViewPresets: ActionViewPresets
    @EnvironmentObject var addTimeSubassignmentBacklog: AddTimeSubassignmentBacklog
    
    @Environment(\.managedObjectContext) var managedObjectContext
 
    @FetchRequest(entity: Subassignmentnew.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Subassignmentnew.startdatetime, ascending: true)])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    
    @FetchRequest(entity: Freetime.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Freetime.startdatetime, ascending: true)])
    var freetimelist: FetchedResults<Freetime>
    
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [])
    var classlist: FetchedResults<Classcool>
    
    @State var nofreetime: Bool = false
    @State var noclasses: Bool = false
    
    @State var subpageSetup: String = "None"
    
    func initialize() {
        addTimeSubassignmentBacklog.backlogList = []

        let timeformatter = DateFormatter()
        timeformatter.dateFormat = "HH:mm"

        let shortdateformatter = DateFormatter()
        shortdateformatter.timeStyle = .none
        shortdateformatter.dateStyle = .short
        
        var longDueSubassignment = false
        
        for (_, subassignment) in subassignmentlist.enumerated() {
            if subassignment.enddatetime < Date() {
                var tempAddTimeSubassignment: [String: String] = ["throwawaykey": "throwawayvalue"]

                tempAddTimeSubassignment["subassignmentname"] = subassignment.assignmentname
                tempAddTimeSubassignment["subassignmentlength"] = String(Calendar.current.dateComponents([.minute], from: subassignment.startdatetime, to: subassignment.enddatetime).minute!)
                tempAddTimeSubassignment["subassignmentcolor"] = subassignment.color
                tempAddTimeSubassignment["subassignmentstarttimetext"] = timeformatter.string(from: subassignment.startdatetime)
                tempAddTimeSubassignment["subassignmentendtimetext"] = timeformatter.string(from: subassignment.enddatetime)
                tempAddTimeSubassignment["subassignmentdatetext"] = shortdateformatter.string(from: subassignment.startdatetime)

                addTimeSubassignmentBacklog.backlogList.append(tempAddTimeSubassignment)
                
                let calendar = Calendar.current
                
                //set to 3?
                if calendar.date(byAdding: .day, value: 3, to: subassignment.enddatetime)! < Date() {
                    longDueSubassignment = true
                }
            }
        }

        //probably have to change these constraints set to 5?
        if ((addTimeSubassignmentBacklog.backlogList.count >= 5) || longDueSubassignment) && (actionViewPresets.actionViewHeight == 0) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1000)) {
                actionViewPresets.actionViewOffset = 0
                actionViewPresets.actionViewType = "SubassignmentBacklogAction"
                actionViewPresets.actionViewHeight = CGFloat(301)
                //older version:
//                actionViewPresets.actionViewHeight = CGFloat(200 + min((addTimeSubassignmentBacklog.backlogList.count * 32), 90))
            }
        }
        
        //Dealing with No Classes/Freetime
//        if freetimelist.isEmpty {
//            nofreetime = true
//        }
        
//        else {
//            nofreetime = false
//        }
//
//        if classlist.isEmpty {
//            noclasses = true
//        }
//
//        else {
//            noclasses = false
//        }
        
//        if (nofreetime || noclasses) && subpageSetup == "None" {
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(0)) {
//                actionViewPresets.actionViewOffset = 0
//                actionViewPresets.actionViewType = "NoClassesOrFreetime"
//                actionViewPresets.actionViewHeight = CGFloat(330)
//            }
//        }
    }
    
    var body: some View {
        VStack {
            if actionViewPresets.actionViewType == "SubassignmentAddTimeAction" {
                SubassignmentAddTimeAction()
            }
            
            else if actionViewPresets.actionViewType == "SubassignmentBacklogAction" {
                SubassignmentBacklogAction()
            }
            
//            else if actionViewPresets.actionViewType == "NoClassesOrFreetime" {
//                NoClassesOrFreetime(noclasses: $noclasses, nofreetime: $nofreetime, subpage: $subpageSetup)
//            }
        }.onAppear(perform: initialize).padding(.all, 15).frame(maxWidth: UIScreen.main.bounds.size.width, maxHeight: actionViewPresets.actionViewHeight).background(Color("very_light_gray")).cornerRadius(18).padding(.all, 15)
    }
}

struct TimeIndicator: View {
    @Binding var dateForTimeIndicator: Date
    
    var body: some View {
        VStack {
            Spacer().frame(height: 19)
            HStack(spacing: 0) {
                Circle().fill(Color("datenumberred")).frame(width: 12, height: 12)
                Rectangle().fill(Color("datenumberred")).frame(width: UIScreen.main.bounds.size.width-36, height: 2)
                
            }.padding(.top, (CGFloat(Calendar.current.dateComponents([.second], from: Calendar.current.startOfDay(for: dateForTimeIndicator), to: dateForTimeIndicator).second!).truncatingRemainder(dividingBy: 86400))/3600 * 60)
            Spacer()
        }
    }
}

struct HomeBodyView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @EnvironmentObject var addTimeSubassignment: AddTimeSubassignment
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    @EnvironmentObject var changingDate: DisplayedDate
    @FetchRequest(entity: Freetime.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Freetime.startdatetime, ascending: true)])
    var freetimelist: FetchedResults<Freetime>
 
    @FetchRequest(entity: Subassignmentnew.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Subassignmentnew.startdatetime, ascending: true)])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.completed, ascending: true), NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    
    var datesfromlastmonday: [Date] = []
    var daytitlesfromlastmonday: [String] = []
    var datenumbersfromlastmonday: [String] = []
    
    var daytitleformatter: DateFormatter
    var datenumberformatter: DateFormatter
    var formatteryear: DateFormatter
    var formattermonth: DateFormatter
    var formatterday: DateFormatter
    var timeformatter: DateFormatter
    
    let daysoftheweekabr = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    @State var nthdayfromnow: Int = Calendar.current.dateComponents([.day], from: Calendar.current.date(byAdding: .day, value: 1, to: Date().startOfWeek!)! > Date() ? Calendar.current.date(byAdding: .day, value: -6, to: Date().startOfWeek!)! : Calendar.current.date(byAdding: .day, value: 1, to: Date().startOfWeek!)!, to: Date()).day!
    
    @State var nthweekfromnow: Int = 0
    
    @State var selecteddaytitle: Int = 0
    
    var hourformatter: DateFormatter
    var minuteformatter: DateFormatter
    var shortdateformatter: DateFormatter
    @State var subassignmentassignmentname: String = ""
    @State var subassignmentstartdatetime: Date = Date(timeIntervalSince1970: 0)
    @State var subassignmentenddatetime: Date = Date(timeIntervalSince1970: 0)
    
    @State var selectedColor: String = "one"
    
    @State var lastnthdayfromnow: Int
    @State var increased = true
    @Binding var uniformlistviewshows: Bool
    @State var stopupdating = false
    @Binding var NewAssignmentPresenting: Bool
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
 
    @State var timezoneOffset: Int = TimeZone.current.secondsFromGMT()
    @State var showeditassignment: Bool = false
    @ObservedObject var sheetnavigator: SheetNavigatorEditClass = SheetNavigatorEditClass()
    
    @State var dateForTimeIndicator = Date()
    @State var scrolling = false
    @State var hidingupcoming = false
    @State var upcomingoffset = 0
    @State var refreshID = UUID()
    @State var workhourstapped: Bool = false
  //  @State var daytitlesexpanded: [Bool] = [true for i in 0...daytitles]
    
    @EnvironmentObject var masterRunning: MasterRunning
    let assignmenttypes = ["Homework", "Study", "Test", "Essay", "Presentation/Oral", "Exam", "Report/Paper"]

    init(uniformlistshows: Binding<Bool>, NewAssignmentPresenting2: Binding<Bool>) {
        self._uniformlistviewshows = uniformlistshows
        self._NewAssignmentPresenting = NewAssignmentPresenting2
 
        self._lastnthdayfromnow = self._nthdayfromnow
        
        daytitleformatter = DateFormatter()
        daytitleformatter.dateFormat = "EEEE, d MMMM"
        
        datenumberformatter = DateFormatter()
        datenumberformatter.dateFormat = "d"
        
        formatteryear = DateFormatter()
        formatteryear.dateFormat = "yyyy"
        
        formattermonth = DateFormatter()
        formattermonth.dateFormat = "MM"
        
        formatterday = DateFormatter()
        formatterday.dateFormat = "dd"
        hourformatter = DateFormatter()
        minuteformatter = DateFormatter()
        self.hourformatter.dateFormat = "HH"
        self.minuteformatter.dateFormat = "mm"
        timeformatter = DateFormatter()
        timeformatter.dateFormat = "HH:mm"

        shortdateformatter = DateFormatter()
        shortdateformatter.timeStyle = .none
        shortdateformatter.dateStyle = .short

        self.selectedColor  = "one"
        
        let calendar = Calendar.current
        
        let lastmondaydate = calendar.date(byAdding: .day, value: 1, to: Date().startOfWeek!)! > Date() ? calendar.date(byAdding: .day, value: -6, to: Date().startOfWeek!)! : calendar.date(byAdding: .day, value: 1, to: Date().startOfWeek!)!
        
        for eachdayfromlastmonday in 0...27 {
            self.datesfromlastmonday.append(calendar.date(byAdding: .day, value: eachdayfromlastmonday, to: lastmondaydate)!)
            
            self.daytitlesfromlastmonday.append(daytitleformatter.string(from: calendar.date(byAdding: .day, value: eachdayfromlastmonday, to: lastmondaydate)!))
            
            self.datenumbersfromlastmonday.append(datenumberformatter.string(from: calendar.date(byAdding: .day, value: eachdayfromlastmonday, to: lastmondaydate)!))
        }

    }
    
    func upcomingDisplayTime() -> String {

        
        let minuteval = Calendar.current
            .dateComponents([.minute], from: Date(timeIntervalSinceNow: TimeInterval(0)), to: subassignmentlist[self.getsubassignment()].startdatetime)
        .minute!
 
        if (minuteval > 720 ) {
            return "No Upcoming Subassignments"
        }
        if (minuteval < 60) {
            return "In " + String(minuteval) + " min: "
        }
        if (minuteval >= 60 && minuteval < 120) {
            return "In 1 h " + String(minuteval-60) + " min: "
        }
        return "In " + String(minuteval/60) + " h " + String(minuteval%60) + " min: "
    }
    
    func getsubassignment() -> Int {

        var minuteval: Int = 0
        for (index, _) in subassignmentlist.enumerated() {
            
            minuteval = Calendar.current
                .dateComponents([.minute], from: Date(timeIntervalSinceNow: TimeInterval(0)), to: subassignmentlist[index].startdatetime)
            .minute!
            if (minuteval > 0)
            {
                return index
            }
            
        }
        return -1
    }
    
    func isSameDay(date1: Date, date2: Date) -> Bool {
        let diff = Calendar.current.dateComponents([.day], from: date1, to: date2)
        if diff.day == 0 {
            return true
        } else {
            return false
        }
    }
    
    func getassignmentindex() -> Int {
        for (index, assignment) in assignmentlist.enumerated() {
            if (assignment.name == sheetnavigator.selectededitassignment)
            {
                return index
            }
        }
        return 0
    }
    
    func getNextColor(currentColor: String) -> Color {
        let colorlist = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "one"]
        let existinggradients = ["one", "two", "three", "five", "six", "eleven","thirteen", "fourteen", "fifteen"]
        if (existinggradients.contains(currentColor)) {
            return Color(currentColor + "-b")
        }
        for color in colorlist {
            if (color == currentColor) {
                return Color(colorlist[colorlist.firstIndex(of: color)! + 1])
            }
        }
        return Color("one")
    }
    
    func GetColorFromRGBCode(rgbcode: String, number: Int = 1) -> Color {
        if number == 1 {
            return Color(.sRGB, red: Double(rgbcode[9..<14])!, green: Double(rgbcode[15..<20])!, blue: Double(rgbcode[21..<26])!, opacity: 1)
        }
        
        return Color(.sRGB, red: Double(rgbcode[36..<41])!, green: Double(rgbcode[42..<47])!, blue: Double(rgbcode[48..<53])!, opacity: 1)
    }
    func getcorrespondingassignment() -> Assignment
    {
        for assignment in assignmentlist
        {
            if (assignment.name == self.subassignmentassignmentname)
            {
                return assignment
            }
        }
        for assignment in assignmentlist
        {
            if (assignment.name == getnowtext(kind: 2))
            {
                return assignment
            }
        }
        return assignmentlist[0]
    }
    func getnowtext(kind: Int) -> String
    {
        for subassignment in subassignmentlist
        {
            if (subassignment.startdatetime <= Date() && subassignment.enddatetime >= Date())
            {
                if kind == 1 {
                    return "NOW"
                }
                
                else {
                    return subassignment.assignmentname
                }
            }
        }
        
        for subassignment in subassignmentlist {
            if subassignment.startdatetime >= Date() {
                if kind == 1 {
                    return "COMING UP"
                }
                
                else {
                    return subassignment.assignmentname
                }
            }
        }
        
        if (kind==1)
        {
            return "TODAY"
        }
        else
        {
            return "No Tasks"
        }
    }
    
    func getnowdates(start: Bool) -> Date {
        for subassignment in subassignmentlist
        {
            if (subassignment.startdatetime <= Date() && subassignment.enddatetime >= Date())
            {
                if start {
                    return subassignment.startdatetime
                }
                
                else {
                    return subassignment.enddatetime
                }
            }
        }
        
        for subassignment in subassignmentlist {
            if subassignment.startdatetime >= Date() {
                if start {
                    return subassignment.startdatetime
                }
                
                else {
                    return subassignment.enddatetime
                }
            }
        }
        
        return Date()
    }
    func possiblesubassignment() -> Bool
    {
        for subassignment in subassignmentlist
        {
            if (subassignment.startdatetime > Date())
            {
                return true
            }
        }
        return false
    }
    func isVisibleFreetime(freetime: Freetime, dateObject: Date) -> Bool
    {
        let boollist = [freetime.sunday, freetime.monday, freetime.tuesday, freetime.wednesday, freetime.thursday, freetime.friday, freetime.saturday]
        return boollist[(Calendar.current.component(.weekday, from: Calendar.current.date(byAdding: .day, value: 0, to: dateObject)!) - 1)]
        
        
    }

    
    var body: some View {
        VStack {
            if (!self.uniformlistviewshows) {
                VStack {
                    HStack(spacing: (UIScreen.main.bounds.size.width / 29)) {
                        ForEach(self.daysoftheweekabr.indices) { dayofthweekabrindex in
                            Text(self.daysoftheweekabr[dayofthweekabrindex]).font(.system(size: (UIScreen.main.bounds.size.width / 25))).fontWeight(.light).frame(width: (UIScreen.main.bounds.size.width / 29) * 3)
                        }
                    }.padding(.horizontal, (UIScreen.main.bounds.size.width / 29))
                    if #available(iOS 14.0, *) {
                        TabView() {
                            WeeklyBlockView(nthdayfromnow: self.$nthdayfromnow, lastnthdayfromnow: self.$lastnthdayfromnow, increased: self.$increased, stopupdating: self.$stopupdating, NewAssignmentPresenting: $NewAssignmentPresenting, datenumberindices: [0, 1, 2, 3, 4, 5, 6], datenumbersfromlastmonday: self.datenumbersfromlastmonday, datesfromlastmonday: self.datesfromlastmonday).environment(\.managedObjectContext, self.managedObjectContext).tag(0)
                            WeeklyBlockView(nthdayfromnow: self.$nthdayfromnow, lastnthdayfromnow: self.$lastnthdayfromnow, increased: self.$increased, stopupdating: self.$stopupdating, NewAssignmentPresenting: $NewAssignmentPresenting, datenumberindices: [7, 8, 9, 10, 11, 12, 13], datenumbersfromlastmonday: self.datenumbersfromlastmonday, datesfromlastmonday: self.datesfromlastmonday).environment(\.managedObjectContext, self.managedObjectContext).tag(1)
                            WeeklyBlockView(nthdayfromnow: self.$nthdayfromnow, lastnthdayfromnow: self.$lastnthdayfromnow, increased: self.$increased, stopupdating: self.$stopupdating, NewAssignmentPresenting: $NewAssignmentPresenting, datenumberindices:  [14, 15, 16, 17, 18, 19, 20], datenumbersfromlastmonday: self.datenumbersfromlastmonday, datesfromlastmonday: self.datesfromlastmonday).environment(\.managedObjectContext, self.managedObjectContext).tag(2)
                            WeeklyBlockView(nthdayfromnow: self.$nthdayfromnow, lastnthdayfromnow: self.$lastnthdayfromnow, increased: self.$increased, stopupdating: self.$stopupdating, NewAssignmentPresenting: $NewAssignmentPresenting, datenumberindices: [21, 22, 23, 24, 25, 26, 27], datenumbersfromlastmonday: self.datenumbersfromlastmonday, datesfromlastmonday: self.datesfromlastmonday).environment(\.managedObjectContext, self.managedObjectContext).tag(3)
                        }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)).frame(height: 70)
                    } else {
                        PageViewControllerWeeks(nthdayfromnow: $nthdayfromnow, viewControllers: [UIHostingController(rootView: WeeklyBlockView(nthdayfromnow: self.$nthdayfromnow, lastnthdayfromnow: self.$lastnthdayfromnow, increased: self.$increased, stopupdating: self.$stopupdating, NewAssignmentPresenting: $NewAssignmentPresenting, datenumberindices: [0, 1, 2, 3, 4, 5, 6], datenumbersfromlastmonday: self.datenumbersfromlastmonday, datesfromlastmonday: self.datesfromlastmonday).environment(\.managedObjectContext, self.managedObjectContext)), UIHostingController(rootView: WeeklyBlockView(nthdayfromnow: self.$nthdayfromnow, lastnthdayfromnow: self.$lastnthdayfromnow, increased: self.$increased, stopupdating: self.$stopupdating,NewAssignmentPresenting: $NewAssignmentPresenting, datenumberindices: [7, 8, 9, 10, 11, 12, 13], datenumbersfromlastmonday: self.datenumbersfromlastmonday, datesfromlastmonday: self.datesfromlastmonday).environment(\.managedObjectContext, self.managedObjectContext)), UIHostingController(rootView: WeeklyBlockView(nthdayfromnow: self.$nthdayfromnow, lastnthdayfromnow: self.$lastnthdayfromnow, increased: self.$increased, stopupdating: self.$stopupdating,NewAssignmentPresenting: $NewAssignmentPresenting, datenumberindices: [14, 15, 16, 17, 18, 19, 20], datenumbersfromlastmonday: self.datenumbersfromlastmonday, datesfromlastmonday: self.datesfromlastmonday).environment(\.managedObjectContext, self.managedObjectContext)), UIHostingController(rootView: WeeklyBlockView(nthdayfromnow: self.$nthdayfromnow, lastnthdayfromnow: self.$lastnthdayfromnow, increased: self.$increased, stopupdating: self.$stopupdating, NewAssignmentPresenting: $NewAssignmentPresenting, datenumberindices: [21, 22, 23, 24, 25, 26, 27], datenumbersfromlastmonday: self.datenumbersfromlastmonday, datesfromlastmonday: self.datesfromlastmonday).environment(\.managedObjectContext, self.managedObjectContext))]).id(UUID()).frame(height: 70).padding(.bottom, -10)
                    }

                    if #available(iOS 14.0, *) {
                        TabView(selection: self.$nthdayfromnow) {
                            ForEach(daytitlesfromlastmonday.indices) {
                                index in
                                Text(daytitlesfromlastmonday[index]).font(.title).fontWeight(.medium).tag(index)//.frame(height: 40)
                            }
                        }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)).frame(height: 40).disabled(true)//.animation(.spring())
                        
                    } else {
                        DummyPageViewControllerForDates(increased: self.$increased, stopupdating: self.$stopupdating, viewControllers: [UIHostingController(rootView: Text(daytitlesfromlastmonday[self.nthdayfromnow]).font(.title).fontWeight(.medium))]).frame(width: UIScreen.main.bounds.size.width-40, height: 40)
                    }
            

                        ZStack {
                            ZStack {

                                RoundedRectangle(cornerRadius: 0, style: .continuous).fill(LinearGradient(gradient: Gradient(colors: [Color("gradientA"), Color("gradientB")]), startPoint: .leading, endPoint: .trailing))

                   
                                    
                                   VStack {
                                            VStack {
                                                HStack {
                                                    Text(subassignmentassignmentname == "" ? (subassignmentlist.count == 0 ? "TODAY" : getnowtext(kind: 1)) : "SELECTED").fontWeight(.light).font(.system(size: 15))
                                                    Spacer()
                                                }
                                                
                                                Spacer()
                                            }.frame(height: 15)
                                            
                                            Spacer()
                                            
                                            VStack {
                                                HStack {
                                                    Text(subassignmentassignmentname == "" ? (subassignmentlist.count == 0 ? "No Tasks" : getnowtext(kind: 2)) : self.subassignmentassignmentname).fontWeight(.bold).font(.system(size: 25)).lineLimit(2).allowsTightening(true)
                                                    
                                                    Spacer()
                                                    VStack {
                                                        Spacer()
                                                        if (possiblesubassignment() || subassignmentassignmentname != "")
                                                        {
                                                            Text(subassignmentassignmentname == "" ? (subassignmentlist.count == 0 ? "" : "Due: " + shortdateformatter.string(from: getcorrespondingassignment().duedate) ) : "Due: " + shortdateformatter.string(from: getcorrespondingassignment().duedate)).fontWeight(.bold).font(.caption)
                                                        }
                                                    }
                                                }
                                                
                                                Spacer()
                                            }
                                            
                                            VStack {
                                                if (possiblesubassignment()  || subassignmentassignmentname != "")
                                                {
                                                    HStack {
                                                        Text(subassignmentassignmentname == "" ? (subassignmentlist.count == 0 ? "" : timeformatter.string(from: getnowdates(start: true)) + " - " + timeformatter.string(from: getnowdates(start: false))) : timeformatter.string(from: subassignmentstartdatetime) + " - " + timeformatter.string(from: subassignmentenddatetime)).fontWeight(.light).font(.caption)
                                                        Spacer()
                                                        Text(subassignmentassignmentname == "" ? (subassignmentlist.count == 0 ? "" : shortdateformatter.string(from: getnowdates(start: true))) : shortdateformatter.string(from: subassignmentstartdatetime)).fontWeight(.light).font(.caption)
                                                    }
                                                }
                                            }.frame(height: 15)
                                            
                                            Spacer()
                                            
                                            HStack(alignment: .center) {
                                                ZStack {
                                            
                                                        RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.white).frame(width: (UIScreen.main.bounds.size.width - 32), height: 15)
                                              
                                                    HStack
                                                    {
                                                        if (subassignmentlist.count != 0 && subassignmentassignmentname != "")
                                                        {
                                                         //   Text("hello")
                                                            ZStack {
                                                                if ((CGFloat(getcorrespondingassignment().totaltime - getcorrespondingassignment().timeleft) + CGFloat(Calendar.current.dateComponents([.minute], from: self.subassignmentstartdatetime, to: self.subassignmentenddatetime).minute!))/CGFloat(getcorrespondingassignment().totaltime) > 0.99) {
                                                                    RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.green).frame(width: UIScreen.main.bounds.size.width - 32, height: 15).blur(radius: 2)
                                                                    RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.white).frame(width: UIScreen.main.bounds.size.width - 32, height: 15).blur(radius: 4)
                                                                }
                                                                    
                                                                RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.green).frame(width: CGFloat((CGFloat(getcorrespondingassignment().totaltime - getcorrespondingassignment().timeleft) + CGFloat(Calendar.current.dateComponents([.minute], from: self.subassignmentstartdatetime, to: self.subassignmentenddatetime).minute!))/CGFloat(getcorrespondingassignment().totaltime) * (UIScreen.main.bounds.size.width-32)), height: 15)

                                                            }
                                                            
                                                            if ((CGFloat(getcorrespondingassignment().totaltime - getcorrespondingassignment().timeleft) + CGFloat(Calendar.current.dateComponents([.minute], from: self.subassignmentstartdatetime, to: self.subassignmentenddatetime).minute!))/CGFloat(getcorrespondingassignment().totaltime) < 0.99)
                                                            {
                                                                Spacer()
                                                            }
                                                        }
                                                    }
                                                    
                                                    HStack {
                                                        if (possiblesubassignment() || subassignmentassignmentname != "")
                                                        {
                                                            RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.blue).frame(width: subassignmentlist.count == 0 ? 0 :  CGFloat(CGFloat(getcorrespondingassignment().progress)/100 * (UIScreen.main.bounds.size.width - 32)), height: 15)
                                                            if (subassignmentlist.count != 0 && getcorrespondingassignment().progress != 100)
                                                            {
                                                                Spacer()
                                                            }
                                                        }
                                                    }.frame(width:  (UIScreen.main.bounds.size.width - 32))
                                                }
                                            }
                                        }.padding(.all, 16)

                            

                            }.frame(width: UIScreen.main.bounds.size.width, height: 100).padding(10).animation(.spring()).offset(y:-CGFloat(upcomingoffset))
                            HStack {

                                Spacer()
                                Button(action:{
                                    self.hidingupcoming.toggle()
                                    if (self.hidingupcoming)
                                    {
                                        upcomingoffset = Int(UIScreen.main.bounds.size.height)
                                    }
                                    else
                                    {
                                        upcomingoffset = 0
                                    }
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: self.hidingupcoming ? 2.5 : 2.5, style: .continuous).fill(Color.blue).frame(width: 15, height: self.hidingupcoming ? 15 : 15)
                                        Image(systemName: "chevron.up").resizable().aspectRatio(contentMode: .fit).frame(width: 8).foregroundColor(colorScheme == .light ? Color.white : Color.black)
                                    }
                                }.rotationEffect(Angle(degrees: self.hidingupcoming ? 180 : 0), anchor: .center).animation(.spring()).padding(.trailing, 15)
                            }.padding(.top, self.hidingupcoming ? -100 : -55)
                        }.frame(width: UIScreen.main.bounds.size.width).animation(.spring()).padding(.top, 5)
                                                    
                VStack {
                    ScrollView(showsIndicators: false) {
                        ZStack {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach((0...24), id: \.self) { hour in
                                        HStack {
                                            Text(String(format: "%02d", hour)).font(.system(size: 13)).frame(width: 20, height: 20)
                                            Rectangle().fill(Color.gray).frame(width: UIScreen.main.bounds.size.width-50, height: 0.5)
                                        }
//                                        if masterRunning.masterRunningNow {
//                                            MasterClass()
//                                        }
                                    }.frame(height: 50).animation(.spring())
                                }
                            }

                            HStack(alignment: .top) {
                                Spacer()
                                VStack {
                                    Spacer().frame(height: 25)
                                    
                                    ZStack(alignment: .topTrailing) {
                                        ForEach(freetimelist)
                                        {
                                            freetime in
                                            if (isVisibleFreetime(freetime: freetime, dateObject: self.datesfromlastmonday[self.nthdayfromnow]))
                                            {
                                               // Rectangle().fill(Color.green).frame(width: UIScreen.main.bounds.size.width-50, height: 5).padding(.top,CGFloat(Calendar.current.dateComponents([.second], from: Calendar.current.startOfDay(for: freetime.startdatetime), to: freetime.startdatetime).second!).truncatingRemainder(dividingBy: 86400)/3600 * 60 ).padding(.trailing, 10)
                                               // Rectangle().fill(Color.green).frame(width: UIScreen.main.bounds.size.width-50, height: 5).padding(.top,CGFloat(Calendar.current.dateComponents([.second], from: Calendar.current.startOfDay(for: freetime.enddatetime), to: freetime.enddatetime).second!).truncatingRemainder(dividingBy: 86400)/3600 * 60 - 5 ).padding(.trailing, 10)
                                                Rectangle().strokeBorder(Color("freetimeblue"), style: StrokeStyle(lineWidth: 1))
                                                    .background(Rectangle().fill(Color("freetimeblue")).opacity(0.43)).frame(width: workhourstapped ? UIScreen.main.bounds.size.width-44 : 5, height: CGFloat(Calendar.current.dateComponents([.second], from:freetime.startdatetime, to: freetime.enddatetime).second!).truncatingRemainder(dividingBy: 86400)/3600 * 60).padding(.top,CGFloat(Calendar.current.dateComponents([.second], from: Calendar.current.startOfDay(for: freetime.startdatetime), to: freetime.startdatetime).second!).truncatingRemainder(dividingBy: 86400)/3600 * 60 ).padding(.trailing, workhourstapped ? 5 : UIScreen.main.bounds.size.width-44).onTapGesture {
                                                        withAnimation(.spring())
                                                        {
                                                            workhourstapped.toggle()
                                                        }
                                                    }
                                                if (workhourstapped)
                                                {
                                                    Rectangle().fill(Color("freetimeblue")).frame(width: 90, height: 20).padding(.top, CGFloat(Calendar.current.dateComponents([.second], from: Calendar.current.startOfDay(for: freetime.enddatetime), to: freetime.enddatetime).second!).truncatingRemainder(dividingBy: 86400)/3600 * 60).padding(.trailing, 5).opacity(0.43)
                                                    Text("Work Hours").font(.system(size: 10)).fontWeight(.bold).frame(width: 70).padding(.top, CGFloat(Calendar.current.dateComponents([.second], from: Calendar.current.startOfDay(for: freetime.enddatetime), to: freetime.enddatetime).second!).truncatingRemainder(dividingBy: 86400)/3600 * 60 + 3).padding(.trailing, 15)
                                                    
                                                }
                                            }
                                            
                                        }.animation(.spring())
                                        ForEach(subassignmentlist) { subassignment in

                                            if (self.shortdateformatter.string(from: subassignment.startdatetime) == self.shortdateformatter.string(from: self.datesfromlastmonday[self.nthdayfromnow])) {
                                                IndividualSubassignmentView(subassignment2: subassignment, fixedHeight: false, showeditassignment: self.$showeditassignment, selectededitassignment: self.$sheetnavigator.selectededitassignment, isrepeated: false, subassignmentassignmentname2: self.$subassignmentassignmentname, refreshID2: self.$refreshID).padding(.top, CGFloat(Calendar.current.dateComponents([.second], from: Calendar.current.startOfDay(for: subassignment.startdatetime), to: subassignment.startdatetime).second!).truncatingRemainder(dividingBy: 86400)/3600 * 60).onTapGesture {
                                                    if (self.subassignmentstartdatetime == subassignment.startdatetime)
                                                    {
                                                        self.subassignmentassignmentname = "";
                                                        self.subassignmentstartdatetime = Date(timeIntervalSince1970: 0)
                                                        self.subassignmentenddatetime = Date(timeIntervalSince1970: 0)
                                                    }
                                                    else
                                                    {
                                                        self.subassignmentassignmentname = subassignment.assignmentname
                                                        self.subassignmentstartdatetime = subassignment.startdatetime
                                                        self.subassignmentenddatetime = subassignment.enddatetime
                                                    }
                                                    self.selectedColor = subassignment.color

                                                }
                                                    //was +122 but had to subtract 2*60.35 to account for GMT + 
                                            }
                                        }.animation(.spring())

                                    }
                                    Spacer()
                                }
                            }

                            if (Calendar.current.isDate(self.datesfromlastmonday[self.nthdayfromnow], equalTo: Date(timeIntervalSinceNow: TimeInterval(0)), toGranularity: .day)) {
                                TimeIndicator(dateForTimeIndicator: self.$dateForTimeIndicator).onReceive(timer) { input in
                                    self.dateForTimeIndicator = input
                                }
                            }
                        }
                    }
                }.padding(.top, self.hidingupcoming ? -100 : 0).animation(.spring())
            }//.transition(.move(edge: .leading)).animation(.spring())
        }
        else {
            VStack {
                HStack {
                    Text("Tasks").font(.largeTitle).bold()
                    Spacer()
                }.padding(.all, 10).padding(.leading, 10)
                ZStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 0, style: .continuous).fill(LinearGradient(gradient: Gradient(colors: [Color("gradientA"), Color("gradientB")]), startPoint: .leading, endPoint: .trailing))
                            
                           VStack {
                                    VStack {
                                        HStack {
                                            Text(subassignmentassignmentname == "" ? "SELECT A TASK FOR INFORMATION" : "SELECTED").fontWeight(.light).font(.system(size: 15))
                                            Spacer()
                                        }
                                        
                                        Spacer()
                                    }.frame(height: 15)
                                    
                                    Spacer()
                                    
                                    VStack {
                                        HStack {
                                            Text(subassignmentassignmentname == "" ? "No Task Selected" : self.subassignmentassignmentname).fontWeight(.bold).font(.system(size: 25)).lineLimit(2).allowsTightening(true)
                                            
                                            Spacer()
                                            if (possiblesubassignment() || subassignmentassignmentname != "")
                                            {
                                                VStack {
                                                    Spacer()
                                                    Text(subassignmentassignmentname == "" ? "" : "Due: " +  shortdateformatter.string(from: getcorrespondingassignment().duedate)).fontWeight(.bold).font(.caption)
                                                }
                                            }
                                        }
                                        
                                        Spacer()
                                    }
                                    
//                                    VStack {
//                                        HStack {
//                                            Spacer()
//                                            Text(subassignmentassignmentname == "" ? "" : shortdateformatter.string(from: getcorrespondingassignment().duedate)).fontWeight(.light).font(.caption)
//                                        }
//                                    }.frame(height: 15)
                                    
                                    Spacer()
                                    
                                    HStack(alignment: .center) {
                                        ZStack {
                                    
                                                RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.white).frame(width: (UIScreen.main.bounds.size.width - 32), height: 15)
                                      
                                            
                                            
                                            HStack {
                                                if (possiblesubassignment() || subassignmentassignmentname != "")
                                                {
                                                    RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.blue).frame(width: self.subassignmentassignmentname == "" ? 0 :  CGFloat(CGFloat(getcorrespondingassignment().progress)/100 * (UIScreen.main.bounds.size.width - 32)), height: 15)
                                                    if (subassignmentlist.count != 0 && getcorrespondingassignment().progress != 100)
                                                    {
                                                        Spacer()
                                                    }
                                                }
                                            }.frame(width:  (UIScreen.main.bounds.size.width - 32))
                                        }
                                    }
                                }.padding(.all, 16)
                    }.frame(width: UIScreen.main.bounds.size.width, height: 100).padding(10).animation(.spring()).offset(y:-CGFloat(upcomingoffset))
                    HStack {
                        Spacer()
                        Button(action:{
                            self.hidingupcoming.toggle()
                            if (self.hidingupcoming)
                            {
                                upcomingoffset = Int(UIScreen.main.bounds.size.height)
                            }
                            else
                            {
                                upcomingoffset = 0
                            }
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: self.hidingupcoming ? 2.5 : 2.5, style: .continuous).fill(Color.blue).frame(width: 15, height: self.hidingupcoming ? 15 : 15)
                                Image(systemName: "chevron.up").resizable().aspectRatio(contentMode: .fit).frame(width: 8).foregroundColor(colorScheme == .light ? Color.white : Color.black)
                            }
                        }.rotationEffect(Angle(degrees: self.hidingupcoming ? 180 : 0), anchor: .center).animation(.spring()).padding(.trailing, 15)
                    }.padding(.top, self.hidingupcoming ? -100 : -50)
                }.frame(width: UIScreen.main.bounds.size.width).animation(.spring())

                ScrollView {

                    let calendar = Calendar.current

                ForEach(0 ..< daytitlesfromlastmonday.count) { daytitle in
                    if (Calendar.current.dateComponents([.day], from: calendar.date(byAdding: .day, value: 1, to: Date().startOfWeek!)! > Date() ? calendar.date(byAdding: .day, value: -6, to: Date().startOfWeek!)! : calendar.date(byAdding: .day, value: 1, to: Date().startOfWeek!)!, to: Date()).day! <= daytitle)
                    {
                        SubassignmentListView(daytitle: self.daytitlesfromlastmonday[daytitle],  daytitlesfromlastmonday: self.daytitlesfromlastmonday, datesfromlastmonday: self.datesfromlastmonday, subassignmentassignmentname: self.$subassignmentassignmentname, selectedcolor: self.$selectedColor, showeditassignment: self.$showeditassignment, selectededitassignment: self.$sheetnavigator.selectededitassignment, refreshID2: self.$refreshID).animation(.spring())//.id(refreshID)
                    }
                }.animation(.spring())//.id(refreshID)
                    
                if subassignmentlist.count == 0 {
                    VStack {
                        Spacer()
                        Text("No Tasks").font(.title2).fontWeight(.bold)
                        HStack {
                            Text("Add an Assignment using the").foregroundColor(.gray).fontWeight(.semibold)
                            RoundedRectangle(cornerRadius: 3, style: .continuous).fill(Color.blue).frame(width: 15, height: 15).overlay(
                                ZStack {
                                    Image(systemName: "plus").resizable().font(Font.title.weight(.bold)).foregroundColor(Color.white).frame(width: 9, height: 9)
                                }
                            )
                        }
                        Text("button for TRACR to schedule new tasks").foregroundColor(.gray).fontWeight(.semibold).multilineTextAlignment(.center)
                        Spacer()
                    }.frame(height: UIScreen.main.bounds.size.height/2)
                    
//                    Spacer().frame(height: 100)
//                    Image(colorScheme == .light ? "emptyassignment" : "emptyassignmentdark").resizable().aspectRatio(contentMode: .fit).frame(width: UIScreen.main.bounds.size.width-100)//.frame(width: UIScreen.main.bounds.size.width, alignment: .center)//.offset(x: -20)
//                    Text("No Tasks!").font(.system(size: 40)).frame(width: UIScreen.main.bounds.size.width - 40, height: 100, alignment: .center).multilineTextAlignment(.center)
                }

                }.padding(.top, self.hidingupcoming ? -100 : 0).animation(.spring())
            }//.transition(.move(edge: .leading)).animation(.spring())
        }
        }.sheet(isPresented: $showeditassignment, content: {
                    EditAssignmentModalView(NewAssignmentPresenting: self.$showeditassignment, selectedassignment: self.getassignmentindex(), assignmentname: self.assignmentlist[self.getassignmentindex()].name, timeleft: Int(self.assignmentlist[self.getassignmentindex()].timeleft), duedate: self.assignmentlist[self.getassignmentindex()].duedate, iscompleted: self.assignmentlist[self.getassignmentindex()].completed, gradeval: Int(self.assignmentlist[self.getassignmentindex()].grade), assignmentsubject: self.assignmentlist[self.getassignmentindex()].subject, assignmenttype: self.assignmenttypes.firstIndex(of: self.assignmentlist[self.getassignmentindex()].type)!).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning)})
        .onAppear
        {
            let defaults = UserDefaults.standard
         //   let lastlauncheddate = defaults.object(forKey: "lastlauncheddate") as? Date ?? Date(timeIntervalSince1970: 0)
            let specificworktimes = defaults.object(forKey: "specificworktimes") as? Bool ?? true
            refreshID = UUID()
            if (specificworktimes)
            {
                self.uniformlistviewshows = false
            }
            else
            {
                self.uniformlistviewshows = true
            }
        }
    }
    func getsubassignmentsondate(dayIndex: Int) -> Bool {
        for subassignment in subassignmentlist {
            if (self.shortdateformatter.string(from: subassignment.startdatetime) == self.shortdateformatter.string(from: self.datesfromlastmonday[dayIndex])) {
                
                  return true  //was +122 but had to subtract 2*60.35 to account for GMT + 2
            }
 
        }
        return false
    }
}
 
struct SubassignmentListView: View {
    @FetchRequest(entity: Subassignmentnew.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Subassignmentnew.startdatetime, ascending: true)])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    var daytitle: String
    var daytitlesfromlastmonday: [String]
    var datesfromlastmonday: [Date]
    
    @Binding var subassignmentassignmentname: String
    @Binding var selectedcolor: String
    @Binding var showeditassignment: Bool
    @Binding var selectededitassignment: String
    @Binding var refreshID: UUID
    var shortdateformatter: DateFormatter
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var masterRunning: MasterRunning
    
    init(daytitle: String, daytitlesfromlastmonday: [String], datesfromlastmonday: [Date], subassignmentassignmentname: Binding<String>, selectedcolor: Binding<String>, showeditassignment: Binding<Bool>, selectededitassignment: Binding<String>, refreshID2: Binding<UUID>)
    {
        self.daytitle = daytitle

        self._subassignmentassignmentname = subassignmentassignmentname
        self._selectedcolor = selectedcolor
        self._showeditassignment = showeditassignment
        self._selectededitassignment = selectededitassignment
        shortdateformatter = DateFormatter()
        shortdateformatter.timeStyle = .none
        shortdateformatter.dateStyle = .short
        self.daytitlesfromlastmonday = daytitlesfromlastmonday
        self.datesfromlastmonday = datesfromlastmonday
        self._refreshID = refreshID2
    }
    
    func getcurrentdatestring() -> String {
        for (index, value) in daytitlesfromlastmonday.enumerated() {
            if (value == daytitle) {
                return self.shortdateformatter.string(from: self.datesfromlastmonday[index])
            }
        }
        return ""
    }
    func isrepeatedsubassignment(assignmentname: String) -> Bool {
        var counter = 0
        for subassignment in subassignmentlist {
            if (subassignment.assignmentname == assignmentname && self.shortdateformatter.string(from: subassignment.startdatetime) == self.getcurrentdatestring())
            {
                counter += 1
            }
        }
        if (counter >= 2)
        {
            return true
        }
        return false
    }
    func isfirstofgroup(subassignment3: Subassignmentnew) -> Bool {
        for subassignment in subassignmentlist {
            if (subassignment3.assignmentname == subassignment.assignmentname &&  self.shortdateformatter.string(from: subassignment.startdatetime) == self.getcurrentdatestring() )
            {
                if (subassignment.startdatetime == subassignment3.startdatetime)
                {
                    return true
                }
                return false
            }
        }
        return false
    }
    func getnumberofsubassignment() -> Int
    {
        var count = 0
        for subassignment in subassignmentlist
        {
            if (self.shortdateformatter.string(from: subassignment.startdatetime) == self.getcurrentdatestring())
            {
                if (isrepeatedsubassignment(assignmentname: subassignment.assignmentname))
                {
                    if (isfirstofgroup(subassignment3: subassignment))
                    {
                        count += 1
                    }
                }
                else
                {
                    count += 1
                }
            }
        }
        return count
    }
    
    @State var tasksThereBool: Bool = false
    
    func tasksThereFunc() {
        for subassignment in subassignmentlist
        {
            if (self.shortdateformatter.string(from: subassignment.startdatetime) == self.getcurrentdatestring())
            {
                tasksThereBool = true
                return
            }
        }
        tasksThereBool = false
    }
    func tasksNotThereFunc()
    {
        tasksThereBool = false
    }
    @State var showingsubassignments: Bool = true
    
    var body: some View {
      //  ScrollView {
        
        if tasksThereBool && getnumberofsubassignment() != 0 {
            Button(action:
            {
                withAnimation(.spring())
                {
                    showingsubassignments.toggle()
                }
            })
            {
                HStack {
                    Spacer().frame(width: 10)
                    Text(daytitle).font(.system(size: 20)).foregroundColor(daytitlesfromlastmonday.firstIndex(of: daytitle) == Calendar.current.dateComponents([.day], from: Calendar.current.date(byAdding: .day, value: 1, to: Date().startOfWeek!)! > Date() ? Calendar.current.date(byAdding: .day, value: -6, to: Date().startOfWeek!)! : Calendar.current.date(byAdding: .day, value: 1, to: Date().startOfWeek!)!, to: Date()).day! ? Color.blue : Color("blackwhite")).fontWeight(.bold)
                    Spacer()
                    Text("("+String(getnumberofsubassignment())+")").font(.system(size: 15)).fontWeight(.light).foregroundColor(colorScheme == .light ? Color.black : Color.white)
                    Image(systemName: "chevron.down").resizable().foregroundColor(colorScheme == .light ? Color.black : Color.white).frame(width: 15, height: 10).rotationEffect(Angle(degrees: self.showingsubassignments ? 0 : -90), anchor: .center).padding(.trailing, 10)
                }.frame(width: UIScreen.main.bounds.size.width, height: 40).background(Color("add_overlay_bg"))
            }
        }
        
//        else {
//            Rectangle().fill(Color.black).frame(height: 1).padding(.all, 0).position(x: 0, y: 0)
//        }
        if (showingsubassignments)
        {
            ForEach(subassignmentlist) {
                subassignment in
                if (self.shortdateformatter.string(from: subassignment.startdatetime) == self.getcurrentdatestring()) {
                    if (isrepeatedsubassignment(assignmentname: subassignment.assignmentname))
                    {
                        if (isfirstofgroup(subassignment3: subassignment))
                        {
                            IndividualSubassignmentView(subassignment2: subassignment, fixedHeight: true, showeditassignment: self.$showeditassignment, selectededitassignment: self.$selectededitassignment, isrepeated: true, subassignmentassignmentname2: self.$subassignmentassignmentname, refreshID2: self.$refreshID).onTapGesture {
                                selectedcolor = subassignment.color
                                if (self.subassignmentassignmentname == subassignment.assignmentname)
                                {
                                    self.subassignmentassignmentname = "";
                                }
                                else
                                {
                                    self.subassignmentassignmentname = subassignment.assignmentname
                                }
                                
                            }.onAppear(perform: tasksThereFunc)//.onDisappear(perform: tasksNotThereFunc)//.id(refreshID)
                        }
                    }
                    else
                    {
                        IndividualSubassignmentView(subassignment2: subassignment, fixedHeight: true, showeditassignment: self.$showeditassignment, selectededitassignment: self.$selectededitassignment, isrepeated: false, subassignmentassignmentname2: self.$subassignmentassignmentname, refreshID2: self.$refreshID).onTapGesture {
                            selectedcolor = subassignment.color
                            if (self.subassignmentassignmentname == subassignment.assignmentname)
                            {
                                self.subassignmentassignmentname = "";
                            }
                            else
                            {
                                self.subassignmentassignmentname = subassignment.assignmentname
                            }
                            
                        }.onAppear(perform: tasksThereFunc)//.onDisappear(perform: tasksNotThereFunc)//.id(refreshID)
                    }//was +122 but had to subtract 2*60.35 to account for GMT + 2
                }
                
            }.animation(.spring())
        }
        
//        if masterRunning.masterRunningNow {
//            MasterClass()
//        }
    }
    func computesubassignmentlength(subassignment: Subassignmentnew) -> Int
    {
        let diffComponents = Calendar.current.dateComponents([.minute], from: subassignment.startdatetime, to: subassignment.enddatetime)
        return diffComponents.minute!
    }
}
 
 //not used
struct UpcomingSubassignmentProgressBar: View {
    @ObservedObject var assignment: Assignment
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.white).frame(width:  150, height: 10)
            HStack {
                RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.blue).frame(width:  CGFloat(CGFloat(assignment.progress)/100*150), height:10, alignment: .leading).animation(.spring())
                if (assignment.progress != 100) {
                    Spacer()
                }
            }
        }
    }
}
 
 
struct IndividualSubassignmentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    
    @FetchRequest(entity: Subassignmentnew.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Subassignmentnew.startdatetime, ascending: true)])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    @FetchRequest(entity: Freetime.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Freetime.startdatetime, ascending: true)])
    var freetimelist: FetchedResults<Freetime>
    
    @FetchRequest(entity: AssignmentTypes.entity(), sortDescriptors: [])

    var assignmenttypeslist: FetchedResults<AssignmentTypes>
    
    var starttime, endtime, color, name, duedate: String
    var actualstartdatetime, actualenddatetime, actualduedate: Date
    @State var isDragged: Bool = false
    @State var isDraggedleft: Bool = false
    @State var deleted: Bool = false
    @State var deleteonce: Bool = true
    @State var incompleted: Bool = false
    @State var incompletedonce: Bool = true
    @State var dragoffset = CGSize.zero
    @State var weeklyminutesworked: Int = 0
    @State var isrepeated: Bool
    @State var showingstats: Bool = false
    var fixedHeight: Bool
    
    var subassignmentlength: Int
 
    var subassignment: Subassignmentnew
    
    @EnvironmentObject var addTimeSubassignment: AddTimeSubassignment
    @EnvironmentObject var actionViewPresets: ActionViewPresets
    
    @Binding var showeditassignment: Bool
    @Binding var selectededitassignment: String
    @Binding var subassignmentassignmentname: String
    @Binding var refreshID: UUID
    
    @EnvironmentObject var masterRunning: MasterRunning
    
    let screenval = -UIScreen.main.bounds.size.width
    
    var shortdateformatter: DateFormatter
    
    init(subassignment2: Subassignmentnew, fixedHeight: Bool, showeditassignment: Binding<Bool>, selectededitassignment: Binding<String>, isrepeated: Bool, subassignmentassignmentname2: Binding<String>, refreshID2: Binding<UUID>) {

        self._showeditassignment = showeditassignment
        self._selectededitassignment = selectededitassignment
        self._subassignmentassignmentname = subassignmentassignmentname2
        self._refreshID = refreshID2
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        self.starttime = formatter.string(from: subassignment2.startdatetime)
        self.endtime = formatter.string(from: subassignment2.enddatetime)

        let formatter2 = DateFormatter()
        formatter2.dateStyle = .short
        formatter2.timeStyle = .none
        self.color = subassignment2.color
        self.name = subassignment2.assignmentname
        self.actualstartdatetime = subassignment2.startdatetime
        self.actualenddatetime = subassignment2.enddatetime
        self.actualduedate = subassignment2.assignmentduedate
        self.duedate = formatter2.string(from: subassignment2.assignmentduedate)
        let diffComponents = Calendar.current.dateComponents([.minute], from: self.actualstartdatetime, to: self.actualenddatetime)
        subassignmentlength = diffComponents.minute!
        subassignment = subassignment2
        self.fixedHeight = fixedHeight
        self._isrepeated = State(initialValue: isrepeated)
        shortdateformatter = DateFormatter()
        shortdateformatter.timeStyle = .none
        shortdateformatter.dateStyle = .short
    }
    
    func getgrouplength() -> Int {
        var totallength = 0
        for subassignment2 in subassignmentlist {
            if (Calendar.current.startOfDay(for: subassignment2.startdatetime) == Calendar.current.startOfDay(for: self.actualstartdatetime) && self.name == subassignment2.assignmentname)
            {
                totallength += Calendar.current.dateComponents([.minute], from: subassignment2.startdatetime, to: subassignment2.enddatetime).minute!
            }
        }
        return totallength
    }
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
 
    func GetColorFromRGBCode(rgbcode: String, number: Int = 1) -> Color {
        if number == 1 {
            return Color(.sRGB, red: Double(rgbcode[9..<14])!, green: Double(rgbcode[15..<20])!, blue: Double(rgbcode[21..<26])!, opacity: 1)
        }
        
        return Color(.sRGB, red: Double(rgbcode[36..<41])!, green: Double(rgbcode[42..<47])!, blue: Double(rgbcode[48..<53])!, opacity: 1)
    }


    
    var body: some View {
        ZStack {
//            if (showingstats)
//            {
//                RoundedRectangle(cornerRadius: 10, style: .continuous)
//                    .foregroundColor(color.contains("rgbcode") ? GetColorFromRGBCode(rgbcode: color) : Color(color))
//                    .frame(width: 150, height: 100).offset(y: 100)
//           // RoundedRectangle(cornerSize: 10, style: .continuous).fill(color.contains("rgbcode") ? GetColorFromRGBCode(rgbcode: color) : Color(color)).frame(width: 150).offset(y: 100)
//            VStack(alignment: .leading) {
//                ForEach(self.assignmentlist) { assignment in
//                    if (assignment.name == self.name) {
//                      //  Text(assignment.name).font(.system(size: 15)).fontWeight(.bold).multilineTextAlignment(.leading).lineLimit(nil).frame(width: 150, height: 25, alignment: .topLeading)
//                        Text("Due Date: " + self.shortdateformatter.string(from: assignment.duedate)).font(.system(size: 12)).frame(height:15)
//                        Text("Type: " + assignment.type).font(.system(size: 12)).frame(height:15)
//                        UpcomingSubassignmentProgressBar(assignment: assignment).frame(height:10)
//                    }
//                }
//            }.frame(width: 150).offset(y: 100)
//            }
            VStack {
               if (isDragged) {
                   ZStack {
                        HStack {
                            Rectangle().fill(Color("fourteen")) .frame(width: UIScreen.main.bounds.size.width-20, height: fixedHeight ? 70 : 58 +    CGFloat(Double(((Double(subassignmentlength)-60)/60))*60)).offset(x: self.fixedHeight ? UIScreen.main.bounds.size.width - 10 + self.dragoffset.width : UIScreen.main.bounds.size.width-30+self.dragoffset.width)
                        }
                        HStack {
                            Spacer()

                                Text("Complete").foregroundColor(Color.white).frame(width:self.dragoffset.width < -110 ? self.fixedHeight ? 100 : 120 : 120).offset(x: self.dragoffset.width < -110 ? 0: self.fixedHeight ? self.dragoffset.width + 120 : self.dragoffset.width + 110)
                        }
                    }
                }
                if (isDraggedleft) {
                    ZStack {
                        HStack {
                            Rectangle().fill(Color.blue) .frame(width: UIScreen.main.bounds.size.width-20, height: fixedHeight ? 70 : 58 +  CGFloat(Double(((Double(subassignmentlength)-60)/60))*60)).offset(x: self.fixedHeight ? screenval+10+self.dragoffset.width : -UIScreen.main.bounds.size.width-20+self.dragoffset.width)
                        }
                        
                        HStack {
                            Text("Reschedule").foregroundColor(Color.white).frame(width:120).offset(x: self.dragoffset.width > 150 ? self.fixedHeight ? -120 : -150 : self.fixedHeight ? self.dragoffset.width - 270 : self.dragoffset.width-300)
                            Image(systemName: "timer").foregroundColor(Color.white).frame(width:50).offset(x: self.dragoffset.width > 150 ? self.fixedHeight ? -150 : -180 : self.fixedHeight ? self.dragoffset.width - 300 : self.dragoffset.width-330)
                        }
                    }
                }
            }
            
            VStack {
                if (fixedHeight)
                {
                    Text(self.name).fontWeight(.bold).frame(width: self.fixedHeight ? UIScreen.main.bounds.size.width-40 :  UIScreen.main.bounds.size.width-80, alignment: .topLeading)
                    Spacer().frame(height: 10)
                    if (self.isrepeated)
                    {
                        Text((self.getgrouplength()/60 == 0 ? "" : (self.getgrouplength()/60 == 1 ? "1 hour " : String(self.getgrouplength()/60) + " hours "))  + (self.getgrouplength() % 60 == 0 ? "" : String(self.getgrouplength() % 60) + " minutes")).frame(width:  self.fixedHeight ? UIScreen.main.bounds.size.width-40 :  UIScreen.main.bounds.size.width-80, alignment: .topLeading)
                    }
                    else
                    {
                        Text((self.subassignmentlength/60 == 0 ? "" : (self.subassignmentlength/60 == 1 ? "1 hour " : String(self.subassignmentlength/60) + " hours ")) + (self.subassignmentlength % 60 == 0 ? "" : String(self.subassignmentlength % 60) + " minutes")).frame(width:  self.fixedHeight ? UIScreen.main.bounds.size.width-40 :  UIScreen.main.bounds.size.width-80, alignment: .topLeading)
                    }
                }
                else
                {
                    if (subassignmentlength < 30)
                    {
                        HStack{
                            Text(self.name).font(.system(size:  38 + CGFloat(Double(((Double(subassignmentlength)-60)/60))*60) < 40 ? 12 : 15)).fontWeight(.bold).frame(width: self.fixedHeight ? UIScreen.main.bounds.size.width-40 :  UIScreen.main.bounds.size.width-80, alignment: .topLeading).padding(.top, 5)

                            
                        //    Text(self.starttime + " - " + self.endtime).font(.system(size:  38 + CGFloat(Double(((Double(subassignmentlength)-60)/60))*60.35) < 40 ? 12 : 15)).frame(width: self.fixedHeight ? UIScreen.main.bounds.size.width-40 :  UIScreen.main.bounds.size.width-80, alignment: .topLeading)
                            
                        }
                    }
                    else
                    {
                        Text(self.name).font(.system(size:  38 + CGFloat(Double(((Double(subassignmentlength)-60)/60))*60) < 40 ? 12 : 15)).fontWeight(.bold).frame(width: self.fixedHeight ? UIScreen.main.bounds.size.width-40 :  UIScreen.main.bounds.size.width-80, alignment: .topLeading).padding(.top, 5)

                        
                      // Text(self.starttime + " - " + self.endtime).font(.system(size:  38 + CGFloat(Double(((Double(subassignmentlength)-60)/60))*60.35) < 40 ? 12 : 15)).frame(width: self.fixedHeight ? UIScreen.main.bounds.size.width-40 :  UIScreen.main.bounds.size.width-80, alignment: .topLeading)
                    }
                }

                Spacer()

            }.frame(height: fixedHeight ? 50 : max(CGFloat(Double(((Double(subassignmentlength))/60))*60-24), CGFloat(60/2-24))).padding(12).background(color.contains("rgbcode") ? GetColorFromRGBCode(rgbcode: color) : Color(color)).cornerRadius(10).contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous)).offset(x: self.dragoffset.width).contextMenu {
                Button(action: {
                    self.showeditassignment = true
                    self.selectededitassignment = subassignment.assignmentname
                })
                {
                        Text("Edit Assignment")
                        Image(systemName: "pencil.circle")
                }

                
            }.gesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
                .onChanged { value in
                    self.dragoffset = value.translation
                    if (self.dragoffset.width > 0 && actualstartdatetime > Date())
                    {
                        self.dragoffset = .zero
                    }
                    if (self.dragoffset.width < 0) {
                        self.isDraggedleft = false
                        self.isDragged = true
                        self.incompleted = false
                    }
                    else if (self.dragoffset.width > 0) {
                        self.isDragged = false
                        self.isDraggedleft = true
                        self.deleted = false
                    }
                    

                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1000)) {
                        self.dragoffset = .zero
                    }
                }
                .onEnded { value in
                    
                    if (self.dragoffset.width < -UIScreen.main.bounds.size.width * 1/2) {
                        self.deleted = true
                    }
                    else if (self.dragoffset.width > UIScreen.main.bounds.size.width * 1/2) {
                        self.incompleted = true
                    }
                    self.dragoffset = .zero

                    if (self.incompleted == true) {
                        if (self.incompletedonce == true) {
                            
                            actionViewPresets.actionViewOffset = 0
                            actionViewPresets.actionViewHeight = 220
                            actionViewPresets.actionViewType = "SubassignmentAddTimeAction"
                            addTimeSubassignment.subassignmentname = self.name
                            if (isrepeated)
                            {
                                addTimeSubassignment.subassignmentlength = self.getgrouplength()
                            }
                            else
                            {
                                addTimeSubassignment.subassignmentlength = self.subassignmentlength
                            }
                            addTimeSubassignment.subassignmentcolor = self.color
                            addTimeSubassignment.subassignmentstarttimetext = self.starttime
                            addTimeSubassignment.subassignmentendtimetext = self.endtime
                            addTimeSubassignment.subassignmentdatetext = self.shortdateformatter.string(from: self.actualstartdatetime)
                            addTimeSubassignment.subassignmentcompletionpercentage = 0
                            
                            for (index, element) in self.subassignmentlist.enumerated() {
                                if (element.startdatetime == self.actualstartdatetime && element.assignmentname == self.name) {
                                    addTimeSubassignment.subassignmentindex = index
                                }
                            }
                            self.subassignmentassignmentname = ""
                        }
                    }
                    
                    else if (self.deleted == true) {
                        if (self.deleteonce == true) {
                            self.deleteonce = false
                            for (_, element) in self.assignmentlist.enumerated() {
                                if (element.name == self.name) {
                                    var minutes = self.subassignmentlength
                                    if (isrepeated)
                                    {
                                        minutes = self.getgrouplength()
                                    }
                                    else
                                    {
                                        minutes = self.subassignmentlength
                                    }
                                    
                                    element.timeleft -= Int64(minutes)
                                    weeklyminutesworked += minutes
                                    withAnimation(.spring()) {
                                        if (element.totaltime != 0) {
                                            element.progress = Int64((Double(element.totaltime - element.timeleft)/Double(element.totaltime)) * 100)
                                        }
                                        else {
                                            element.progress = 100
                                        }
                                    }
                                    if (element.timeleft == 0) {
                                        element.completed = true
                                        for classity in self.classlist {
                                            if (classity.originalname == element.subject) {
                                                classity.assignmentnumber -= 1
                                            }
                                        }
                                    }
                                }
                            }
                            for (index, element) in self.subassignmentlist.enumerated() {
                                if (isrepeated)
                                {
                                    if (Calendar.current.startOfDay(for: element.startdatetime) == Calendar.current.startOfDay(for: self.actualstartdatetime) && element.assignmentname == self.name)
                                    {
                                        self.managedObjectContext.delete(self.subassignmentlist[index])
                                    }
                                }
                                else
                                {
                                    if (element.startdatetime == self.actualstartdatetime && element.assignmentname == self.name) {
                                        self.managedObjectContext.delete(self.subassignmentlist[index])
                                    }
                                }
                            }
                            self.subassignmentassignmentname = ""
                            refreshID = UUID()
                            do {
                                try self.managedObjectContext.save()
                            } catch {
                                print(error.localizedDescription)
                            }
                            simpleSuccess()
                            WidgetCenter.shared.reloadTimelines(ofKind: "Today's Tasks")
                          // masterRunning.masterRunningNow = true
                          //  masterRunning.displayText = true
                        }
                    }
                }).animation(.spring())
        }.frame(width: UIScreen.main.bounds.size.width-40).onAppear
        {
          
        }.onDisappear {
            self.dragoffset.width = 0
            let defaults = UserDefaults.standard
            let val = defaults.object(forKey: "weeklyminutesworked") as! Int
                
            defaults.set(val+weeklyminutesworked, forKey: "weeklyminutesworked")
        }
    }
}

enum ModalView {
    case grade
    case freetime
    case assignment
    case classity
    case none
}

class SheetNavigator: ObservableObject {
    @Published var modalView: ModalView = .none
    @Published var alertView: AlertView = .none
}
enum AlertView {
    case none
    case noclass
    case noassignment
}
struct HomeView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject var googleDelegate: GoogleDelegate
    @EnvironmentObject var addTimeSubassignmentBacklog: AddTimeSubassignmentBacklog

    @State var NewAssignmentPresenting = false
    @State var NewClassPresenting = false
    @State var NewOccupiedtimePresenting = false
    @State var NewFreetimePresenting = false
    @State var NewGradePresenting = false
    @State var noAssignmentsAlert = false
    
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
 
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.name, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    
    @FetchRequest(entity: Freetime.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Freetime.startdatetime, ascending: true)])
    var freetimelist: FetchedResults<Freetime>
    
    @State var noClassesAlert = false
    
    @State var noCompletedAlert = false
    @EnvironmentObject var actionViewPresets: ActionViewPresets
    
    @State var uniformlistshows: Bool
    @State var showingSettingsView = false
    @State var modalView: ModalView = .none
    @State var alertView: AlertView = .noclass
    @State var NewSheetPresenting = false
    @State var NewAlertPresenting = false
    @ObservedObject var sheetNavigator = SheetNavigator()
    @State var showpopup: Bool = false
    @State var widthAndHeight: CGFloat = 50
    @State var countnewassignments: Int = 0
    
    init() {
        let defaults = UserDefaults.standard
        let viewtype = defaults.object(forKey: "savedtoggleview") as? Bool ?? false
        _uniformlistshows = State(initialValue: viewtype)
    }
    
    @EnvironmentObject var masterRunning: MasterRunning
    
    @State var BacklogTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    @State var elapsedTime = 0
    @State var backlogWiggle = 0.0
    
    @ViewBuilder
    private func sheetContent() -> some View {        
        if (self.sheetNavigator.modalView == .freetime) {
            NewFreetimeModalView(NewFreetimePresenting: self.$NewSheetPresenting).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning)
        }
        else if (self.sheetNavigator.modalView == .assignment)
        {
            //NewAssignmentModalView(NewAssignmentPresenting: self.$NewSheetPresenting, selectedClass: 0, preselecteddate: -1).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning)
            NewGoogleAssignmentModalView(NewAssignmentPresenting: self.$NewSheetPresenting, selectedClass: 0, preselecteddate: -1).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning).environmentObject(googleDelegate)
        }
        else if (self.sheetNavigator.modalView == .classity)
        {
            NewClassModalView(NewClassPresenting: self.$NewSheetPresenting).environment(\.managedObjectContext, self.managedObjectContext)
        }
        else if (self.sheetNavigator.modalView == .grade)
        {
            NewGradeModalView(NewGradePresenting: self.$NewSheetPresenting, classfilter: -1).environment(\.managedObjectContext, self.managedObjectContext)
        }
        else
        {
            NewGoogleAssignmentModalView(NewAssignmentPresenting: self.$NewSheetPresenting, selectedClass: 0, preselecteddate: -1).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning).environmentObject(googleDelegate)

        }
    }
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    var body: some View {
        NavigationView {
            if #available(iOS 14.0, *) {
                ZStack {
//                    NavigationLink(destination: EmptyView()) {
//                        EmptyView()
//                    }
                    NavigationLink(destination: SettingsView(), isActive: self.$showingSettingsView)
                        { EmptyView() }
                    HomeBodyView(uniformlistshows: self.$uniformlistshows, NewAssignmentPresenting2: $NewAssignmentPresenting).padding(.top, -40)
                    
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ZStack {
                                if (showpopup)
                                {
                                    ZStack() {
                                        Button(action:
                                        {
                                            if (classlist.count > 0)
                                            {
                                                self.sheetNavigator.modalView = .assignment
                                                self.NewSheetPresenting = true
//                                                self.NewAssignmentPresenting = true
                                           //     print(self.sheetNavigator.modalView)
                                            }
                                            else
                                            {
                                                self.sheetNavigator.alertView = .noclass
                                                self.NewAlertPresenting = true
                                            }
                                            countnewassignments = 0
                                            
                                        })
                                        {
                                              ZStack {
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .foregroundColor(Color.blue)
                                                  .frame(width: widthAndHeight, height: widthAndHeight)
                                                Image(systemName: "doc.plaintext")
                                                  .resizable().scaledToFit()
                                               //   .aspectRatio(contentMode: .fit)
                                                    //.padding(.bottom, 20).padding(.trailing, 100)
                                                 // .frame(width: widthAndHeight, height: widthAndHeight)
                                                    .foregroundColor(.white).frame(width: widthAndHeight-20, height: widthAndHeight-20)
                                                if (countnewassignments > 0)
                                                {
                                                    VStack
                                                    {
                                                        HStack
                                                        {
                                                            Spacer()
                                                            ZStack
                                                            {
                                                                Circle().fill(Color.red).frame(width: 15, height: 15)
                                                                Text(String(countnewassignments)).foregroundColor(Color.white).font(.system(size: 10)).frame(width: 15, height: 15)
                                                            }.offset(x: 5, y: -5)
                                                        }
                                                        Spacer()
                                                    }
                                                }
                                              }.frame(width: widthAndHeight, height: widthAndHeight)
                                        }.offset(x: -70, y: 10).shadow(radius: 5).opacity(classlist.count == 0 ? 0.5 : 1)
                                        Button(action:
                                        {
                                            self.sheetNavigator.modalView = .classity
                                            self.NewSheetPresenting = true
                                            self.NewClassPresenting = true
                                            
                                        })
                                        {
                                              ZStack {
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .foregroundColor(Color.blue)
                                                  .frame(width: widthAndHeight, height: widthAndHeight)
                                                Image(systemName: "folder")
                                                  .resizable().scaledToFit()

                                                    .foregroundColor(.white).frame(width: widthAndHeight-20, height: widthAndHeight-20)
                                                if (classlist.count == 0)
                                                {
                                                    VStack
                                                    {
                                                        HStack
                                                        {
                                                            Spacer()
                                                            Circle().fill(Color.red).frame(width: 15, height: 15).offset(x: 5, y: -5)
                                                        }
                                                        Spacer()
                                                    }
                                                }
                                              }.frame(width: widthAndHeight, height: widthAndHeight)
                                        }.offset(x: -130, y: 10).shadow(radius: 5)

                                        Button(action:
                                        {
//                                            if (self.getcompletedAssignments())
//                                            {
                                                self.sheetNavigator.modalView = .grade
                                                self.NewSheetPresenting = true
//                                            }
//                                            else
//                                            {
//                                                self.sheetNavigator.alertView = .noassignment
//                                                self.NewAlertPresenting = true
//                                            }
                                            
                                        })
                                        {
                                              ZStack {
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .foregroundColor(Color.blue)
                                                  .frame(width: widthAndHeight, height: widthAndHeight)
                                                Image(systemName: "percent")
                                                  .resizable().scaledToFit()
                                               //   .aspectRatio(contentMode: .fit)
                                                    //.padding(.bottom, 20).padding(.trailing, 100)
                                                 // .frame(width: widthAndHeight, height: widthAndHeight)
                                                    .foregroundColor(.white).frame(width: widthAndHeight-20, height: widthAndHeight-20)
                                              }.frame(width: widthAndHeight, height: widthAndHeight)
                                        }.offset(x: -190, y: 10).shadow(radius: 5).opacity(classlist.count == 0 ? 0.5 : 1) //.opacity(!self.getcompletedAssignments() ? 0.5: 1)
                                    }.transition(.scale)
                                  }
                                
                                Button(action: {
     
                                    withAnimation(.spring())
                                    {
                                        self.showpopup.toggle()
                                    }
                                    simpleSuccess()

                                    
                                }) {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous).fill(showpopup ? Color.blue : Color.blue).frame(width: 70, height: 70).opacity(1).padding(20).overlay(
                                        ZStack {
                                            //Circle().strokeBorder(Color.black, lineWidth: 0.5).frame(width: 50, height: 50)
                                            Image(systemName: "plus").resizable().foregroundColor(Color.white).frame(width: 30, height: 30).rotationEffect(Angle(degrees: showpopup ? 315 : 0))
                                            if (classlist.count == 0)
                                            {
                                                VStack
                                                {
                                                    HStack
                                                    {
                                                        Spacer()
                                                        Circle().fill(Color.red).frame(width: 20, height: 20).offset(x: -12, y: 12)
                                                    }
                                                    Spacer()
                                                }
                                            }
                                        }
                                    )
                                }.buttonStyle(PlainButtonStyle()).shadow(radius: 5)
                            }.sheet(isPresented: $NewSheetPresenting, content: sheetContent ).alert(isPresented: $NewAlertPresenting) {
                                Alert(title: self.sheetNavigator.alertView == .noassignment ? Text("No Assignments Completed") : Text("No Classes Added"), message: self.sheetNavigator.alertView == .noassignment ? Text("Complete an Assignment First") : Text("Add a Class First"))
                            }
                        }
                    }
               
                    VStack {
                        Spacer()
                        
                        ActionView().offset(y: actionViewPresets.actionViewOffset).animation(.spring())
                        //could change from spring to something else to avoid blocky animation
                    }.frame(width: UIScreen.main.bounds.size.width).background((actionViewPresets.actionViewOffset <= 110 ? Color(UIColor.label).opacity(self.colorScheme == .light ? 0.3 : 0.05) : Color.clear).edgesIgnoringSafeArea(.all))
                }.navigationBarItems(leading:
                    HStack(spacing: UIScreen.main.bounds.size.width / 4.5) {
                        Button(action: {self.actionViewPresets.actionViewHeight < 10 ? self.showingSettingsView = true : ()}) {
                            ZStack {
                                Image(systemName: "gear").resizable().scaledToFit().foregroundColor(colorScheme == .light ? Color.black : Color.white).font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
                                
                                if self.freetimelist.isEmpty {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            ZStack {
                                                Circle().fill(Color.red).frame(width: 14, height: 14)
                                            }.offset(x: 3, y: -3)
                                        }

                                        Spacer()
                                    }
                                }
                            }
                        }.padding(.leading, 2.0)

                        Image(self.colorScheme == .light ? "Tracr" : "TracrDark").resizable().scaledToFit().frame(width: UIScreen.main.bounds.size.width / 3.5).offset(y: 5)
                        
                        let launchedBacklogBefore = UserDefaults.standard.bool(forKey: "launchedBacklogBefore")
                        
                        Button(action: {
                            if actionViewPresets.actionViewType == "" {
                                var actionViewHeight: CGFloat = 150
                                
                                if self.addTimeSubassignmentBacklog.backlogList.count > 0 {
                                    actionViewHeight = CGFloat(300)
//                                    older version
//                                    actionViewHeight = CGFloat(200 + min((addTimeSubassignmentBacklog.backlogList.count * 32), 90))
                                }
                                
                                if !launchedBacklogBefore {
                                    actionViewHeight = CGFloat(300)
                                }
                                
                                actionViewPresets.actionViewOffset = 0
                                actionViewPresets.actionViewType = "SubassignmentBacklogAction"
                                actionViewPresets.actionViewHeight = actionViewHeight
                            }
                            
                            else if actionViewPresets.actionViewType == "SubassignmentBacklogAction" {
                                if actionViewPresets.actionViewHeight != 281 && actionViewPresets.actionViewHeight != 301 {
                                    actionViewPresets.actionViewOffset = UIScreen.main.bounds.size.width
                                    actionViewPresets.actionViewType = ""
                                    actionViewPresets.actionViewHeight = 1
                                }
                            }
                        }) {
                            //.font(Font.title.weight(.medium))
                            Image(systemName: self.addTimeSubassignmentBacklog.backlogList.count > 0 ? "tray.full.fill" : "tray.fill").resizable().scaledToFit().foregroundColor(colorScheme == .light ? Color.black : Color.white).frame(width: UIScreen.main.bounds.size.width / 12).overlay(
                                ZStack {
                                    if !launchedBacklogBefore {
                                        VStack {
                                            HStack {
                                                Spacer()
                                                ZStack {
                                                    Circle().fill(Color.red).frame(width: 19, height: 19)
                                                }.offset(x: 6, y: -6)
                                            }
                                            
                                            Spacer()
                                        }
                                    }
                                    
                                    else if (self.addTimeSubassignmentBacklog.backlogList.count > 0) {
                                        VStack {
                                            HStack {
                                                Spacer()
                                                ZStack {
                                                    Circle().fill(Color.red).frame(width: 19, height: 19)
                                                    Text(String(self.addTimeSubassignmentBacklog.backlogList.count)).foregroundColor(Color.white).font(.system(size: 11)).frame(width: 18, height: 18)
                                                }.offset(x: 6, y: -6)
                                            }
                                            
                                            Spacer()
                                        }
                                    }
                                }
                            ).rotationEffect(Angle(degrees: self.backlogWiggle)).animation(Animation.easeInOut(duration: 0.12)).onReceive(self.BacklogTimer, perform: { _ in
                                self.elapsedTime += 2

                                let wiggleInterval = 16 - (2 * self.addTimeSubassignmentBacklog.backlogList.count)

                                if (self.addTimeSubassignmentBacklog.backlogList.count > 0) && (actionViewPresets.actionViewHeight < 10) && (self.elapsedTime % wiggleInterval == 0) {
                                    self.backlogWiggle = -15.0

                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(130)) {
                                            self.backlogWiggle = 15.0
                                    }

                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(260)) {
                                            self.backlogWiggle = 0.0
                                    }
                                }
                            })
                        }
                    }//.frame(height: 40)
                )
            }
        }.navigationViewStyle(StackNavigationViewStyle())
        .onDisappear() {
            let defaults = UserDefaults.standard
            self.showingSettingsView = false
            defaults.set(self.uniformlistshows, forKey: "savedtoggleview")
            self.showpopup = false
        }.onAppear() {
            let defaults = UserDefaults.standard
            let lastlauncheddate = defaults.object(forKey: "lastlauncheddate") as? Date ?? Date(timeIntervalSince1970: 0)
            let specificworktimes = defaults.object(forKey: "specificworktimes") as? Bool ?? true
            if (specificworktimes)
            {
                uniformlistshows = false
            }
            else
            {
                uniformlistshows = true
            }
         //   let lastlauncheddate = Date(timeIntervalSince1970: 0)

    
        //    GIDSignIn.sharedInstance().restorePreviousSignIn()
            countnewassignments = 0
    
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1000)) {
               // print(googleDelegate.signedIn)
    
    
                if (googleDelegate.signedIn)
                {
                   // print("kewl")
                    var idlist: [String] = []
                    for classity in classlist
                    {
                        if (classity.googleclassroomid != "")
                        {
                            idlist.append(classity.googleclassroomid)
                        }
                    }
                  //  print(idlist)
                    let service = GTLRClassroomService()
                    //crashed here homeview
                    service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
    
                    for idiii in idlist {

                        let assignmentsquery = GTLRClassroomQuery_CoursesCourseWorkList.query(withCourseId: idiii)
                        //let workingdate = Date(timeIntervalSinceNow: -3600*24*7)
                        let dayformatter = DateFormatter()
                        let monthformatter = DateFormatter()
                        let yearformatter = DateFormatter()
                        yearformatter.dateFormat = "yyyy"
                        monthformatter.dateFormat = "MM"
                        dayformatter.dateFormat = "dd"
                        assignmentsquery.pageSize = 1000
                        service.executeQuery(assignmentsquery, completionHandler: {(ticket, stuff, error) in
                            if (stuff as? GTLRClassroom_ListCourseWorkResponse != nil)
                            {
                                let assignmentsforid = stuff as! GTLRClassroom_ListCourseWorkResponse

                                if assignmentsforid.courseWork != nil {
                                    for assignment in assignmentsforid.courseWork! {
                                      //  print(assignment.creationTime!.date.description)
                                        if (assignment.creationTime!.date > lastlauncheddate)
                                        {
                                            countnewassignments += 1
                                        }
                                    }
                                }
                            }
                                //assignmentsforclass[idiii.1] = vallist
                        })

                        
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(3000)) {
                //print("Homeview", countnewassignments)
                defaults.set(countnewassignments, forKey: "countnewassignments")
                defaults.set(Date(), forKey: "lastlauncheddate")
            }
        }
    }
    
    func getcompletedAssignments() -> Bool {
        for assignment in assignmentlist {
            if (assignment.completed == true && assignment.grade == 0) {
                return true;
            }
        }
        return false
    }
}
 
 
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
          
        return HomeView().environment(\.managedObjectContext, context).environmentObject(AddTimeSubassignment()).environment(\.managedObjectContext, context).environmentObject(ActionViewPresets()).environment(\.managedObjectContext, context).environmentObject(AddTimeSubassignmentBacklog()).environment(\.managedObjectContext, context)
    }
}
