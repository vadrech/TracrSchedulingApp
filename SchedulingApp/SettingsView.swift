//
//  SettingsView.swift
//  SchedulingApp
//
//  Created by Charan Vadrevu on 06.08.20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import GoogleSignIn
import GoogleAPIClientForREST

struct PageViewControllerTutorial: UIViewControllerRepresentable {
    @Binding var tutorialPageNum: Int
    
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
        pageViewController.setViewControllers([viewControllers[self.tutorialPageNum]], direction: .reverse, animated: true)
    }
    
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PageViewControllerTutorial
 
        init(_ pageViewController: PageViewControllerTutorial) {
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

struct TutorialPageView: View {
    var tutorialScreenshot: String
    var tutorialTitle: String
    var tutorialInstructions1: String
    var tutorialInstructions2: String
    var tutorialInstructions3: String
    var tutorialInstructions4: String
    var tutorialInstructions5: String
    var tutorialposition: [(CGFloat, CGFloat)]
    
    var body: some View {
        VStack {
            ZStack {
                Image(self.tutorialScreenshot).resizable().aspectRatio(contentMode: .fit).frame(height: (UIScreen.main.bounds.size.height / 2) - 20)
//                ForEach(0..<tutorialposition.count)
//                {
//                    coordinatesIndex in
//
//                    Image(systemName: String(coordinatesIndex+1) + ".circle.fill").foregroundColor(Color("thirteen")).position(x: tutorialposition[coordinatesIndex].0, y: tutorialposition[coordinatesIndex].1)
//
//                }
            }
            
            Rectangle().frame(width: UIScreen.main.bounds.size.width - 40, height: 1)
             
            Spacer().frame(height: 15)
            
            HStack {
                Image("TracrIcon").resizable().aspectRatio(contentMode: .fit).frame(width: 40, height: 40).cornerRadius(5)
                Spacer().frame(width: 15)
                Text(self.tutorialTitle).font(.title).fontWeight(.light)
                Spacer()
            }.padding(.leading, 20).padding(.bottom, 10)
            
            ScrollView(.vertical, showsIndicators: false) {
//            VStack(spacing: 5) {
                HStack(alignment: .top) {
                    Image(systemName: "1.circle.fill").foregroundColor(tutorialInstructions1 == "" ? Color.clear : Color("thirteen"))//.frame( alignment: .topLeading)
                    Spacer().frame(width: 15)
                    Text(tutorialInstructions1).fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                Spacer().frame(height: 5)
                HStack(alignment: .top) {
                    Image(systemName: "2.circle.fill").foregroundColor(tutorialInstructions2 == "" ? Color.clear : Color("thirteen"))
                    Spacer().frame(width: 15)
                    Text(tutorialInstructions2).fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                Spacer().frame(height: 5)
                HStack(alignment: .top) {
                    Image(systemName: "3.circle.fill").foregroundColor(tutorialInstructions3 == "" ? Color.clear : Color("thirteen"))
                    Spacer().frame(width: 15)
                    Text(tutorialInstructions3).fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                Spacer().frame(height: 5)
                HStack(alignment: .top) {
                    Image(systemName: "4.circle.fill").foregroundColor(tutorialInstructions4 == "" ? Color.clear : Color("thirteen"))
                    Spacer().frame(width: 15)
                    Text(tutorialInstructions4).fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                Spacer().frame(height: 5)
                HStack(alignment: .top) {
                    Image(systemName: "5.circle.fill").foregroundColor(tutorialInstructions5 == "" ? Color.clear : Color("thirteen"))
                    Spacer().frame(width: 15)
                    Text(tutorialInstructions5).fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                Spacer().frame(height: 35)
            }.padding(.leading, 35).padding(.trailing, 20).padding(.bottom, 5) // was 120 for bottom
        }//.padding(.top, -100)
    }
}

struct TutorialFirstPageView: View {
    @Binding var tutorialPageSelected: Int
    
    let TutorialTitles: [String] = ["Home Tab", "Tasks", "Reschedule Tasks", "Add Button", "Adding a Class","Adding an Assignment", "Adding Work Hours", "Classes Tab", "Inside a Class", "Assignments Tab", "Progress Tab", "Progress of Individual Classes", "Google Classroom"]
    let TutorialImages: [String] = ["house", "house.fill", "tray.full", "plus.square", "folder.badge.plus","text.badge.plus", "calendar.badge.plus", "folder", "folder.circle", "doc.plaintext", "chart.bar", "percent", "Google Classroom Square Logo"]
    func getrandomcolor() -> Color
    {
        let colorlist = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen"]
        let randomInt = Int.random(in: 0..<15)
        return Color(colorlist[randomInt])
    }
    var body: some View {
//        ZStack {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Spacer().frame(height: 20)
                HStack(spacing: 23) {
                    Image("TracrIcon").resizable().aspectRatio(contentMode: .fit).frame(width: 80, height: 80).cornerRadius(10)
                    
                    Text("Tutorial").font(.largeTitle).fontWeight(.light)
                }.padding(.horizontal, 40)
                
                Spacer().frame(height: 10)
                
                ForEach(1..<14) { tag in
                    Button(action: {
                        withAnimation(.spring()) {
                            self.tutorialPageSelected = tag
                        }
                    })
                    {
                        HStack {
                            if (tag == 13)
                            {
                                Image("Google Classroom Square Logo").resizable().aspectRatio(contentMode: .fit).foregroundColor(getrandomcolor()).frame(height: 40)
                            }
                            else
                            {
                                Image(systemName: TutorialImages[tag-1]).resizable().aspectRatio(contentMode: .fit).foregroundColor(getrandomcolor()).frame(height: 40)
                            }
                            Spacer().frame(width: 20)
                            VStack {
                                HStack {
                                    Text(TutorialTitles[tag-1]).fontWeight(.bold).font(.system(size: 20)).lineLimit(1).minimumScaleFactor(0.6)
                                    Spacer()
                                }
                            }.frame(width: UIScreen.main.bounds.size.width - 136)
                        }.padding(.horizontal, 40)
                    }

                }
                Spacer().frame(height: 20)
             //   Spacer().frame(height:20)
            }
        }
//        }
    }
}

struct TutorialView: View {
    @State var tutorialPageSelected: Int = 0
    
    var body: some View {
        VStack {
            if #available(iOS 14.0, *) {
                TabView(selection: $tutorialPageSelected) {
                    Group {
                        TutorialFirstPageView(tutorialPageSelected: self.$tutorialPageSelected).tag(0)
                        TutorialPageView(tutorialScreenshot: "Home View 1", tutorialTitle: "Home Tab", tutorialInstructions1: "The Preview Bar shows the next upcoming Task.", tutorialInstructions2: "If you tap on a Task, the Preview Bar will show details about the assignment to which the Task belongs, such as the due date and the Progress Bar", tutorialInstructions3: "Holding a date will allow you to add an Assignment that has a due date set to that date.", tutorialInstructions4: "If you have completed a Task, swipe from right to left on it.", tutorialInstructions5: "", tutorialposition: []).tag(1)
                        TutorialPageView(tutorialScreenshot: "Home view 2", tutorialTitle: "Tasks", tutorialInstructions1: "To see this view, change your scheduling options from 'specific times' to 'daily checklist'.", tutorialInstructions2: "Instead of telling you exactly when to complete the Tasks, this view only shows you how long Tasks are and the days when they should be copmleted.", tutorialInstructions3: "", tutorialInstructions4: "", tutorialInstructions5: "", tutorialposition: []).tag(2)
                        TutorialPageView(tutorialScreenshot: "Home View 1.1", tutorialTitle: "Reschedule Tasks", tutorialInstructions1: "If you couldn't complete a past Task or you weren't available to, swipe from left to right and select the percentage of the Task you were able to complete.", tutorialInstructions2: "The top right button allows you to reschedule all past unfinished tasks by stating the percentage of the allocated work you completed.", tutorialInstructions3: "", tutorialInstructions4: "", tutorialInstructions5: "", tutorialposition: []).tag(3)
                        TutorialPageView(tutorialScreenshot: "Add button screenshot", tutorialTitle: "Add Button", tutorialInstructions1: "Tap the add button to see the options for adding an assignment, a class, or a grade (from right to left).", tutorialInstructions2: "Tap the add button again to hide the options.", tutorialInstructions3: "", tutorialInstructions4: "", tutorialInstructions5: "", tutorialposition: []).tag(4)
                        TutorialPageView(tutorialScreenshot: "Adding class", tutorialTitle: "Adding a Class", tutorialInstructions1: "Select your specific Class if you're an IB student and input your class name otherwise.", tutorialInstructions2: "If you have logged in to Google Classroom, then you can link this TRACR Class to your Google Class.", tutorialInstructions3: "Choose your preferred color to be displayed for your Class and its Assignments or create your own custom gradient.", tutorialInstructions4: "", tutorialInstructions5: "", tutorialposition: []).tag(5)
                        TutorialPageView(tutorialScreenshot: "Adding assignment", tutorialTitle: "Adding an Assignment", tutorialInstructions1: "Classroom Assignments are taken from your linked Google Classroom account to help you add assignments.", tutorialInstructions2: "Assignment Length is your estimation of how long it will take to complete the assignment. Remember: Experience will help you estimate better.", tutorialInstructions3: "", tutorialInstructions4: "", tutorialInstructions5: "", tutorialposition: []).tag(6)
                        TutorialPageView(tutorialScreenshot: "Adding free time", tutorialTitle: "Adding Work Hours", tutorialInstructions1: "Tap the add button to add a new Work Hours time", tutorialInstructions2: "Select when you would like your Work Hours time to repeat by selecting the days above.", tutorialInstructions3: "Press in one of the green areas, then drag on the boundaries of the to adjust the time and duration of the Work Hours time.", tutorialInstructions4: "To delete a Work Hours time, swipe from right to left.", tutorialInstructions5: "", tutorialposition: []).tag(7)
                    }
                    
                    Group {
                        TutorialPageView(tutorialScreenshot: "Classes view", tutorialTitle: "Classes Tab", tutorialInstructions1: "Hold a Class and tap 'Add Assignment' to add an Assignment for that Class.", tutorialInstructions2: "Hold a Class, and tap 'Delete Class' to delete it.", tutorialInstructions3: "Tap on a Class to see a list of all its Assignments and other details.", tutorialInstructions4: "Clicking on the Class will show assignments for that Class.", tutorialInstructions5: "", tutorialposition: []).tag(8)
                        TutorialPageView(tutorialScreenshot: "Inside classes view", tutorialTitle: "Inside a Class", tutorialInstructions1: "Inside a Class, Assignments for that Class are shown.", tutorialInstructions2: "Tap on the 'Edit' button (top-right corner) to edit specific Class details.", tutorialInstructions3: "Swipe assignments from right to left to complete them.", tutorialInstructions4: "Tap on an Assignment to expand and show detailed information about Tasks for that assignment.", tutorialInstructions5: "Tap on the Edit button on the Assignment to edit Assignment details.", tutorialposition: []).tag(9)
                        TutorialPageView(tutorialScreenshot: "Assignments view", tutorialTitle: "Assignments Tab", tutorialInstructions1: "Tap the top-right button to toggle Completed Assignments.", tutorialInstructions2: "The blue progress bar shows your progress for the completion of the Assignment.", tutorialInstructions3: "Swipe from right to left on Assignments to complete them.", tutorialInstructions4: "Tap on an Assignment to expand and show detailed information about Tasks for that assignment.", tutorialInstructions5: "Tap on the Edit button on the assignment to edit Assignment details.", tutorialposition: []).tag(10)
                        TutorialPageView(tutorialScreenshot: "Progress View", tutorialTitle: "Progress Tab", tutorialInstructions1: "The Graph shows your grades for all your classes over time.", tutorialInstructions2: "Select which Class you want to appear on the Graph.",tutorialInstructions3: "The yellow box shows during which times you reschedule Tasks.", tutorialInstructions4: "Hold a Class to add a Grade for that specific Class.", tutorialInstructions5: "Tap on a Class to see detailed information and statistics on your Grades for that Class.", tutorialposition: []).tag(11)
                        TutorialPageView(tutorialScreenshot: "Inside Progress View", tutorialTitle: "Progress of Individual Classes", tutorialInstructions1: "Inside a Class, a bar graph displays your grades over time for that Class.", tutorialInstructions2: "Underneath, there are a range of interesting statistics and insights to highlight your progress relative to global statistics (only for IB).", tutorialInstructions3: "At the bottom, there is a list of all the Completed Assignments for this Class.", tutorialInstructions4: "", tutorialInstructions5: "", tutorialposition: []).tag(12)
                        TutorialPageView(tutorialScreenshot: "GCTutorial", tutorialTitle: "Google Classroom", tutorialInstructions1: "Here you can view all your classes from google classroom", tutorialInstructions2: "Tap on a class here to link it to one of your TRACR classes", tutorialInstructions3: "Colored classes have been linked to TRACR classes and grey classes have not been linked.", tutorialInstructions4: "Linking to Google Classroom allows you to add assignments directly from Google Classroom", tutorialInstructions5: "", tutorialposition: []).tag(13)
                    }
                }.tabViewStyle(PageTabViewStyle()).indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: self.tutorialPageSelected == 0 ? .never : .always))
            } else {
                EmptyView()
                // Fallback on earlier versions
            }//.frame(height: UIScreen.main.bounds.size.height-200)//.padding(.top, -60)
        }.toolbar
        {
            ToolbarItem(placement: .navigationBarLeading)
            {
                Text("")
            }
            ToolbarItem(placement: .navigationBarTrailing)
            {
                Button(action:
                {
                    withAnimation(.spring())
                    {
//                        print(UIDevice.current.hasNotch)
                        tutorialPageSelected = 0
                    }
                })
                {
                    if (tutorialPageSelected != 0)
                    {
                        Text("Contents")
                    }
                }
            }
        }
    }
}


struct SyllabusView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State var selectedsyllabus: Int = 0
    @State var mainsyllabus: Int = 0
    var mainsyllabuslist: [String] = ["None", "IB"]
    @State var isIB: Bool = false
    var syllabuslist: [String] = ["Percentage-based", "Letter-based", "Number-based"]
    var badlettergrades: [String] = ["E", "F"]
    @State var selectedbadlettergrade: Int = 0
    @State private var gradingschemes: [String] = []
    var goodnumbergrades: [Int] = [4, 5, 6, 7, 8, 9, 10]
    @State var selectedgoodnumbergrade: Int = 0
    @State var refreshID: UUID = UUID()
    
    @State var MainSyllabusChanged: Bool = false
    @State var addinggradingscheme: Bool = false
    @State var showinginfo: Bool
    

    
    var body: some View {
        Form {
            if (showinginfo)
            {
                HStack {
                    Text("If you follow the International Baccalaureate, select the IB syllabus to gain access to IB classes and the class statistics.").fontWeight(.light).foregroundColor(Color("darkgray"))

                    Spacer()
                }
                .listRowInsets(EdgeInsets())
                .background(Color(UIColor.systemGroupedBackground))
            }
            Section(header: Text("Main Syllabus"), footer: Text(mainsyllabus == 1 ? "Use the International Baccalaureate's Subject Choices" : "No Main Syllabus").font(.footnote))
            {
                Picker(selection: $mainsyllabus, label: Text("Main Syllabus")) {
                    ForEach(0..<mainsyllabuslist.count) { mainsyllabusindex in
                        Text(mainsyllabuslist[mainsyllabusindex])
                    }
                }.pickerStyle(SegmentedPickerStyle()).id(refreshID)
                
//                Toggle(isOn: $isIB) {
//                    Text("International Baccalaureate (IB)")
//                }
            }
//            .onChange(of: self.mainsyllabus) { _ in
//                print("sfsf")
//                self.MainSyllabusChanged = true
//            }
//            Section
//            {
//                Text("My Grading Schemes:").font(.title2)
//                List
//                {
//                    ForEach(gradingschemes, id: \.self)
//                    {
//                        gradingscheme in
//                        HStack
//                        {
//                            if (gradingscheme[0..<1] == "P")
//                            {
//                                Text("Percentage-based")
//                            }
//                            else if (gradingscheme[0..<1] == "L")
//                            {
//                                Text("Letter-based: " + String(gradingscheme[1..<gradingscheme.count]))
//                            }
//                            else
//                            {
//                                Text("Number-based: " + String(gradingscheme[1..<gradingscheme.count]))
//                            }
//
//                       //     Text(gradingscheme)
//                            Spacer()
//                          //  Image(systemName: "chevron.left").foregroundColor(Color.gray)
//                        }
//                    }
////                    .onDelete { indexSet in
////                        for index in indexSet {
////                            gradingschemes.remove(at: index)
////                        }
////                   }
//                }
//            }
//            Section
//            {
//                Button(action:{
//                    withAnimation(.spring())
//                    {
//                        addinggradingscheme.toggle()
//                    }
//                })
//                {
//                    Text("Add Custom Grading Scheme")
//                }
//            }
            if (addinggradingscheme)
            {
                Section
                {
                    Picker(selection: $selectedsyllabus, label: Text("Grading Scheme")) {
                        ForEach(0..<syllabuslist.count) {
                            val in
                            Text(syllabuslist[val])


                        }
                    }.pickerStyle(WheelPickerStyle())
                }
                
                Section
                {

                    if (selectedsyllabus == 1)
                    {
                        HStack
                        {
                            Text("Best Grade")
                            Spacer()
                            Text("A").foregroundColor(Color.gray)
                        }
                        VStack
                        {
                            HStack
                            {
                                Text("Worst Grade:")
                                Spacer()
                            }
                            Picker(selection: $selectedbadlettergrade, label: Text("Worst Grade"))
                            {
                                ForEach(0..<badlettergrades.count)
                                {
                                    val in
                                    Text(badlettergrades[val])
                                }
                            }.pickerStyle(SegmentedPickerStyle())
                        }
                    }
                    if (selectedsyllabus == 2)
                    {
                        HStack
                        {
                            Text("Worst Grade")
                            Spacer()
                            Text("1").foregroundColor(Color.gray)
                        }
                        VStack
                        {
                            HStack
                            {
                                Text("Best Grade:")
                                Spacer()
                            }
                            Picker(selection: $selectedgoodnumbergrade, label: Text("Best Grade"))
                            {
                                ForEach(0..<goodnumbergrades.count)
                                {
                                    val in
                                    Text(String(goodnumbergrades[val]))
                                }
                            }.pickerStyle(WheelPickerStyle())
                        }
                    }
                }
                Section
                {
                    Button(action:
                    {
                        if (selectedsyllabus == 0)
                        {
                            gradingschemes.append("P")
                            //print("P")
                        }
                        else if (selectedsyllabus == 1)
                        {
                            gradingschemes.append("LA-" + badlettergrades[selectedbadlettergrade])
                          //  print("LA-" + badlettergrades[selectedbadlettergrade])
                        }
                        else
                        {
                            gradingschemes.append("N1-" + String(goodnumbergrades[selectedgoodnumbergrade]))
                            //print("N1-" + String(goodnumbergrades[selectedgoodnumbergrade]))
                        }
                        addinggradingscheme = false
                    })
                    {
                        Text("Save Grading Scheme")
                    }
                }
            }

            }.navigationTitle("Syllabus").navigationBarTitleDisplayMode(.large).onAppear()
        {
            let defaults = UserDefaults.standard
            
            let value = defaults.object(forKey: "savedgradingschemes") as? [String] ?? []
            gradingschemes = value

            let ibval = defaults.object(forKey: "isIB") as? Bool ?? false
            isIB = ibval
            if (ibval)
            {
                mainsyllabus = 1
            }
            else
            {
                mainsyllabus = 0
            }
         //   print(gradingschemes)
        //    print(gradingscheme)
//            let ibval = defaults.object(forKey: "isIB") as? Bool ?? false
//            isIB = ibval

        //    refreshID = UUID()
//            if MainSyllabusChanged {
//                print("YAH")
//                isIB = mainsyllabus == 1 ? true : false
//                MainSyllabusChanged = false
//            }
//
//            else {
//                mainsyllabus = isIB ? 1 : 0
//            }
         //   print(ibval)
           // print(gradingscheme, ibval)
          //  selectedsyllabus = 1

        }.onDisappear()
        {
            let defaults = UserDefaults.standard
//            isIB = mainsyllabus == 1 ? true : false
            if (mainsyllabus == 1)
            {
                isIB = true
            }
            else
            {
                isIB = false
            }
            defaults.set(isIB, forKey: "isIB")
            defaults.set(gradingschemes, forKey: "savedgradingschemes")

//            if (selectedsyllabus == 0)
//            {
//                defaults.set("P", forKey: "savedgradingschemes")
//                //print("P")
//            }
//            else if (selectedsyllabus == 1)
//            {
//                defaults.set("LA-" + badlettergrades[selectedbadlettergrade], forKey: "savedgradingscheme")
//              //  print("LA-" + badlettergrades[selectedbadlettergrade])
//            }
//            else
//            {
//                defaults.set("N1-" + String(goodnumbergrades[selectedgoodnumbergrade]), forKey: "savedgradingscheme")
//                //print("N1-" + String(goodnumbergrades[selectedgoodnumbergrade]))
//            }
//            //defaults.set("hello", forKey: "savedbreakvalue")
        }.toolbar
        {
            ToolbarItem(placement: .navigationBarLeading)
            {
                Text("")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action:{
                    withAnimation(.spring())
                    {
                        showinginfo.toggle()
                    }
                })
                {
                    Image(systemName: showinginfo ? "info.circle.fill" : "info.circle").resizable().scaledToFit().frame(height: 20)
                }
                
            }
            
        }
        
    }
}

struct SettingsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var googleDelegate: GoogleDelegate

    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    
    @FetchRequest(entity: Freetime.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Freetime.startdatetime, ascending: true)])
    var freetimelist: FetchedResults<Freetime>
    @FetchRequest(entity: Subassignmentnew.entity(), sortDescriptors: [])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    @FetchRequest(entity: AssignmentTypes.entity(), sortDescriptors: [])
    
    var assignmenttypeslist: FetchedResults<AssignmentTypes>
    @FetchRequest(entity: AddTimeLog.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \AddTimeLog.name, ascending: true)])
    var addtimeloglist: FetchedResults<AddTimeLog>
    
    @State var cleardataalert = false
    
    @State var tutorialPageNum = 0
    
    @EnvironmentObject var masterRunning: MasterRunning
    
    @State var easteregg1: Bool = false
    @State var easteregg2: Bool = false
    @State var easteregg3: Bool = false
    @State var specificworkhoursview: Bool = true
    @State var specificworkhoursviewcounter: Int = 0
    @State var pickertext: [String] = ["Specific Times", "Daily Checklist"]
    @State var showingAlert: Bool = false
    
    var body: some View {
//        ZStack {
        Form {
            List {
                Section {
                    NavigationLink(destination: PreferencesView()) {
//                     ZStack {
////                      //  RoundedRectangle(cornerRadius: 10, style: .continuous)
////                         .fill(Color("twelve"))
////                            .frame(width: UIScreen.main.bounds.size.width - 40, height: (80))
//
//                        HStack {
//                         Text("Preferences").font(.system(size: 24)).fontWeight(.bold).frame(height: 40)
//                            Spacer()
//
//                        }.padding(.horizontal, 25)
//                     }
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color.green).frame(width:40, height:40)
                                Image(systemName: "slider.horizontal.3").resizable().frame(width:25, height:25)
                            }
                            Spacer().frame(width:20)
                            Text("Type Sliders").font(.system(size:20))
                        }.frame(height:40)
                    }
               // Divider().frame(width:UIScreen.main.bounds.size.width-40, height: 2)
                
                    NavigationLink(destination: NotificationsView()) {
//                    ZStack {
//
////                       RoundedRectangle(cornerRadius: 10, style: .continuous)
////                        .fill(Color("fifteen"))
////                           .frame(width: UIScreen.main.bounds.size.width - 40, height: (80))
//
//
//                       HStack {
//                        Text("Notifications").font(.system(size: 24)).fontWeight(.bold).frame(height: 40)
//                           Spacer()
//
//                       }.padding(.horizontal, 25)
//                    }
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color.red).frame(width: 40, height: 40)

                                Image(systemName: "app.badge").resizable().frame(width: 25, height: 25)
                            }
                            
                            Spacer().frame(width: 20)
                            Text("Notifications").font(.system(size: 20))
                        }.frame(height: 40)
                    }
               // Divider().frame(width:UIScreen.main.bounds.size.width-40, height: 2)

                    NavigationLink(destination: HelpCenterView()) {
//                     ZStack {
//
////                        RoundedRectangle(cornerRadius: 10, style: .continuous)
////                         .fill(Color("fourteen"))
////                            .frame(width: UIScreen.main.bounds.size.width - 40, height: (80))
//
//
//                        HStack {
//                         Text("FAQ").font(.system(size: 24)).fontWeight(.bold).frame(height: 40)
//                            Spacer()
//
//                        }.padding(.horizontal, 25)
//                     }
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color.yellow).frame(width:40, height:40)
                                Image(systemName: "questionmark").resizable().frame(width:15, height:25)
                            }
                            Spacer().frame(width:20)
                            Text("FAQ").font(.system(size:20))
                        }.frame(height:40)
                    }

                
//
//                NavigationLink(destination: Text("email and team")) {
//                     ZStack {
//
//                        RoundedRectangle(cornerRadius: 10, style: .continuous)
//                         .fill(Color.orange)
//                            .frame(width: UIScreen.main.bounds.size.width - 40, height: (80))
//
//
//                        HStack {
//                         Text("About us").font(.system(size: 24)).fontWeight(.bold).frame(height: 80)
//                            Spacer()
//
//                        }.padding(.horizontal, 25)
//                     }
//                }
                }
                
                Section {
                        NavigationLink(destination:
                                        TutorialView().navigationTitle("Tutorial").navigationBarTitleDisplayMode(.inline)//.edgesIgnoringSafeArea(.all)//.padding(.top, -40)
                        ) {
                            HStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color.orange).frame(width:40, height:40)
                                    Image(systemName: "info.circle").resizable().frame(width:25, height:25)
                                }
                                Spacer().frame(width:20)
                                Text("Tutorial").font(.system(size:20))
                            }.frame(height:40)
                        }
//                    }
//                    else {
//                        NavigationLink(destination:
//
//                            EmptyView()
//                            PageViewControllerTutorial(tutorialPageNum: self.$tutorialPageNum, viewControllers: [UIHostingController(rootView: TutorialPageView(tutorialScreenshot: "Tutorial1", tutorialTitle: "Adding Free Time", tutorialInstructions1: "This shows the next upcoming task and a detailed description.", tutorialInstructions2: "If you click on a task, it will divide the pinned box and show details of the assignment e.g. Due Date, Progress Bar, Assignment name and Class name.", tutorialInstructions3: "If you click on a task, it will divide the pinned box and show details of the assignment e.g. Due Date, Progress Bar, Assignment name and Class name.")), UIHostingController(rootView: TutorialPageView(tutorialScreenshot: "Tutorial2", tutorialTitle: "Doing This", tutorialInstructions1: "Do this kinda, needs fixing.", tutorialInstructions2: "Do this kinda, needs fixing.", tutorialInstructions3: "")), UIHostingController(rootView: TutorialPageView(tutorialScreenshot: "Tutorial3", tutorialTitle: "Sie Posel", tutorialInstructions1: "Do this kinda, needs fixing.", tutorialInstructions2: "", tutorialInstructions3: "")), UIHostingController(rootView: TutorialPageViewLastPage(tutorialPageNum: self.$tutorialPageNum))]).navigationTitle("Tutorial").id(UUID()).frame(height: UIScreen.main.bounds.size.height)
   
                        
//                        ) {
//
//                            HStack {
//                                ZStack {
//                                    RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color.orange).frame(width:40, height:40)
//                                    Image(systemName: "info.circle").resizable().frame(width:25, height:25)
//                                }
//                                Spacer().frame(width:20)
//                                Text("Tutorial").font(.system(size:20))
//                            }.frame(height:40)
//
//                        }
//
//                    }
                }
        
                
                Section {
                    NavigationLink(destination:
                        Form
                        {

//                            Section
//                            {
                            HStack {
                                Text("Your Work Hours will determine when TRACR can schedule your tasks. If you want tasks to be scheduled at specific times within the day, select the Specific Times option. If you instead want a general daily checklist of tasks, select the Daily Checklist option.").fontWeight(.light).foregroundColor(Color("darkgray"))

                                Spacer()
                            }
                            .listRowInsets(EdgeInsets())
                            .background(Color(UIColor.systemGroupedBackground))
                                
//                                Text("Note: TRACR will only schedule tasks during you Work Hours, so make sure to include all the times when you can work.").fontWeight(.light)
//                                Spacer().frame(height: 10)
//                            }
                            Section {
                                HStack
                                {
                                    VStack
                                    {
                                        Image("Home View 1").resizable().scaledToFit().frame(width: UIScreen.main.bounds.size.width/2-50)
                                        Divider().frame(height: 1)
                                        Text("Specific Times").fontWeight(.semibold).frame(width: UIScreen.main.bounds.size.width/2-50, height: 50)
                                    }
                                    Spacer()
                                    VStack
                                    {
                                        Image("Home view 2").resizable().scaledToFit().frame(width: UIScreen.main.bounds.size.width/2-50)
                                        Divider().frame(height: 1)
                                        Text("Daily Checklist").fontWeight(.semibold).frame(width: UIScreen.main.bounds.size.width/2-50, height: 50)
                                    }
                                }
                            }
                            Section(header: Text("Options"))
                            {
                                Picker(selection: $specificworkhoursviewcounter, label: Text("Scheduling Options")) {
                                    ForEach(0..<2) { mainsyllabusindex in
                                        Text(pickertext[mainsyllabusindex])
                                    }
                                }.pickerStyle(SegmentedPickerStyle())
                                .onChange(of: self.specificworkhoursviewcounter) { _ in
                                    if (specificworkhoursviewcounter == 0)
                                    {
                                        showingAlert = true
                                    }
                                }
//                                Toggle(isOn: $specificworkhoursview)
//                                {
//                                    Text("Specifc Work Hours View").fontWeight(.bold)
//                                }.onChange(of: self.specificworkhoursview) { _ in
//                                    if (specificworkhoursview)
//                                    {
//                                        showingAlert = true
//                                    }
//                                }
                            }
                            
                        }.navigationTitle("Scheduling Options").alert(isPresented:$showingAlert) {
                            Alert(
                                title: Text("Deletion of work hours"),
                                message: Text("This will delete all current work hours. New work hours will need to be created in settings."),
                                primaryButton: .destructive(Text("Delete")) {
                                    print("Deleting...")
                                    for (index, _) in freetimelist.enumerated()
                                    {
                                        self.managedObjectContext.delete(self.freetimelist[index])
                                    }
                                    do {
                                        try self.managedObjectContext.save()
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                },
                                secondaryButton: .cancel() {
                                    specificworkhoursview = false
                                    specificworkhoursviewcounter = 1
                                }
                            )
                        }
                        .onAppear
                        {
                            let defaults = UserDefaults.standard
                            specificworkhoursview = defaults.object(forKey: "specificworktimes") as? Bool ?? true
                            if (specificworkhoursview)
                            {
                                specificworkhoursviewcounter = 0
                            }
                            else
                            {
                                specificworkhoursviewcounter = 1
                            }
                        }.onDisappear
                        {
                            let defaults = UserDefaults.standard
                            let defaultsWidget = UserDefaults(suiteName: "group.com.schedulingapp.tracrwidget")
                            
                            if (specificworkhoursviewcounter == 0)
                            {
                                specificworkhoursview = true
                            }
                            else
                            {
                                specificworkhoursview = false
                            }
                            defaults.set(specificworkhoursview, forKey: "specificworktimes")
                            defaultsWidget?.set(specificworkhoursview, forKey: "specificworktimes")
                        }
                    )
                    {
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color("two")).frame(width:40, height:40)
                                ZStack {
                                    Image(systemName: "calendar").resizable().frame(width:25, height:25)
                                    HStack
                                    {
                                        VStack
                                        {
                                            Spacer()
                                            ZStack
                                            {
                                                Circle().fill(Color("two")).frame(width: 14, height: 14).offset(x: -4, y:4)
                                                Image(systemName: "gear").resizable().frame(width: 12, height: 12).offset(x: -4, y: 4)
                                            }
                                            
                                        }
                                        Spacer()
                                    }.frame(width: 25, height: 25)
                                }
                            }
                            Spacer().frame(width:20)
                            Text("Scheduling Options").font(.system(size:20))
                        }.frame(height:40)
                        
                    }
                    NavigationLink(destination:
                                    WorkHours().environment(\.managedObjectContext, self.managedObjectContext)
                    ) {
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.freetimelist.isEmpty ? Color.red : Color.blue).frame(width:40, height:40)

                                Image(systemName: self.freetimelist.isEmpty ? "calendar.badge.exclamationmark" : "calendar").resizable().frame(width: self.freetimelist.isEmpty ? 29 : 25, height:25).offset(x: self.freetimelist.isEmpty ? 2 : 0)
                            }
                            Spacer().frame(width:20)
                            Text("Work Hours").font(.system(size:20))
                        }.frame(height:40)
                    }
                }

                Section {
                    NavigationLink(destination:
                                    SyllabusView(showinginfo: false)
                    ) {
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color.purple).frame(width:40, height:40)
                                Image(systemName: "doc.plaintext").resizable().frame(width:25, height:25)
                            }
                            Spacer().frame(width:20)
                            Text("Syllabus").font(.system(size:20))
                        }.frame(height:40)
                    }
                }
                Section
                {
                    NavigationLink(destination:
                        OverallGoogleView()
                    ) {
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color.yellow).frame(width:40, height:40)
                                Image("Google Classroom Square Logo").resizable().frame(width: 35, height: 35)
                            }
                            Spacer().frame(width:20)
                            Text("Google Classroom").font(.system(size:20))
                        }.frame(height:40)
                    }
                    
                }

                Section {
//                    HStack {
//                        Text("Version:")
//                        Spacer()
//                        Text("Developer's Beta 0.9").foregroundColor(.gray)
//                    }.contentShape(Rectangle()).onTapGesture(count: 5, perform: {
//                        self.easteregg1 = true
//                    })
//
//                    if self.easteregg1 {
//                        VStack {
//                            Text("Hello.").fontWeight(.regular)
//                        }
//                    }

                    
                    Button(action: {
                        self.cleardataalert.toggle()
                    }) {
                        Text("Clear All Data").foregroundColor(Color.red)
                    }.alert(isPresented:$cleardataalert) {
                        Alert(title: Text("Are you sure you want to clear all data?"), message: Text("You cannot undo this operation."), primaryButton: .destructive(Text("Clear All Data")) {
                            self.delete()
                        }, secondaryButton: .cancel())
                    }
                }
            }
        }.navigationTitle("Settings")
//                if masterRunning.masterRunningNow {
//                    MasterClass()
//                }
    //            NavigationLink(destination: EmptyView()) {
    //                EmptyView()
    //            }.opacity(0)
    }
    
    func delete() -> Void {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100)) {
            if (self.subassignmentlist.count > 0) {
                for (index, _) in self.subassignmentlist.enumerated() {
                     self.managedObjectContext.delete(self.subassignmentlist[index])
                }
            }

            for (_, element) in self.assignmenttypeslist.enumerated() {
                element.rangemin = 60
                element.rangemax = 180
            }
            
            if (self.assignmentlist.count > 0) {
                for (index, _) in self.assignmentlist.enumerated() {
                     self.managedObjectContext.delete(self.assignmentlist[index])
                }
            }
            if (self.classlist.count > 0) {
                for (index, _) in self.classlist.enumerated() {
                     self.managedObjectContext.delete(self.classlist[index])
                }
            }
            for (index, _) in self.freetimelist.enumerated() {
                 self.managedObjectContext.delete(self.freetimelist[index])
            }
            for (index, _) in self.addtimeloglist.enumerated()
            {
                self.managedObjectContext.delete(self.addtimeloglist[index])
            }
            GIDSignIn.sharedInstance().signOut()
            
            
            googleDelegate.signedIn = false
            
            let defaults = UserDefaults.standard
            defaults.set([], forKey: "savedgoogleclasses")
            defaults.set([], forKey: "savedgoogleclassesids")
            
            
            
            
            let boollist: [Bool] = [true, false, false, false, false, false, false]
            for i in 0...4
            {
                let newFreetime = Freetime(context: self.managedObjectContext)
                newFreetime.startdatetime = Date(timeInterval: TimeInterval(3600*16), since: Calendar.current.startOfDay(for: Date(timeIntervalSince1970: 0)))
                newFreetime.enddatetime = Date(timeInterval: TimeInterval(3600*20), since: Calendar.current.startOfDay(for: Date(timeIntervalSince1970: 0)))
                newFreetime.tempstartdatetime = newFreetime.startdatetime
                newFreetime.tempenddatetime = newFreetime.enddatetime
                newFreetime.monday = boollist[i]
                newFreetime.sunday = boollist[(i+1)%7]
                newFreetime.saturday = boollist[(i+2)%7]
                newFreetime.friday = boollist[(i+3)%7]
                newFreetime.thursday = boollist[(i+4)%7]
                newFreetime.wednesday = boollist[(i+5)%7]
                newFreetime.tuesday = boollist[(i+6)%7]
                do {
                    try self.managedObjectContext.save()
                    //print("AssignmentTypes rangemin/rangemax changed")
                } catch {
                    print(error.localizedDescription)
                }
            }

            do {
                try self.managedObjectContext.save()
                //print("AssignmentTypes rangemin/rangemax changed")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct HelpCenterView: View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    let faqtitles = ["What are Type Sliders?", "How can I link my Account to Google Classroom?", "How can I clear my data?", "Data Usage", "Track your Performance"]
    let faqtext = ["What are Type Sliders?": "Type Sliders is a tool that allows you to set a range of time you want to spend per session for an assignment, depending on the type of assignment eg.essay, exam,presentation. To access this feature, go to the home screen, and click on the settings logo on the top-left corner.", "How can I link my Account to Google Classroom?" : "TRACR has a distinguished feature that allows you to connect to your Google Classroom account, so that your classes added in TRACR are linked to your Google Classroom classes, making adding assignments much easier. To connect to Google Classroom, add a class, and click on the blue button stating: “Link to a Google Classroom class +.", "How can I clear my data?" : "Go to the home screen, and click on the settings logo on the top-left corner. And at the bottom of the settings page you will find a red button called “Clear All Data”. However, note that clearing data is irreversible, so the cleared data can not be restored.","Data Usage" : "No user data is used nor collected by TRACR and the app does not require wifi to be used.For more information see the privacy policy at the TRACR website.", "Track your Performance": "TRACR has a feature that allows you to put your grades, allowing you to see long-term progress."]
    let heights = ["What are Type Sliders?" : 50  , "How can I link my Account to Google Classroom?" : 50, "How can I clear my data?" : 75, "Data Usage" : 50, "Track your Performance" : 100]
    let colors = ["What are Type Sliders?" : "one", "How can I link my Account to Google Classroom?" : "two", "How can I clear my data?" : "three", "Data Usage" : "four", "Track your Performance" : "fifteen"]
    
    @State private var selection: Set<String> = ["What are Type Sliders?", "How can I link my Account to Google Classroom?", "How can I clear my data?", "Data Usage", "Track your Performance"]

    private func selectDeselect(_ singularassignment: String) {
        if selection.contains(singularassignment) {
            selection.remove(singularassignment)
        } else {
            selection.insert(singularassignment)
        }
    }
    
    var body: some View {
            VStack {
                ScrollView(.vertical, showsIndicators: false, content: {
                    Spacer().frame(height: 20)
                    ForEach(self.faqtitles,  id: \.self) {
                        title in
                        VStack {
        
                            Button(action: {
                                self.selectDeselect(title)
                                
                                
                            }) {
                                HStack {
                                    Text(title).foregroundColor(.black).fontWeight(.bold)
                                    Spacer()
                                    Image(systemName: self.selection.contains(title) ? "chevron.down" : "chevron.up").foregroundColor(Color.black)
                                }.padding(10).background(Color(self.colors[title]!)).frame(width: UIScreen.main.bounds.size.width-20).cornerRadius(10)
                            }
                        
                            if (self.selection.contains(title))
                            {
                                Text(self.faqtext[title]!).multilineTextAlignment(.leading).lineLimit(nil).frame(width: UIScreen.main.bounds.size.width - 40, alignment: .topLeading)
                            }
                        }
                    }.animation(.spring())
                    Spacer().frame(height: 20)
                }).animation(.spring())
            }.navigationBarItems(trailing: Button(action: {
                if (self.selection.count < 5) {
                    for title in self.faqtitles {
                        if (!self.selection.contains(title)) {
                            self.selection.insert(title)
                        }
                    }
                }
                else {
                    self.selection.removeAll()
                }
                
            }, label: {selection.count == 5 ? Text("Collapse All"): Text("Expand All")})).navigationTitle("FAQ").navigationBarTitleDisplayMode(.inline)
        
    }
}


struct TypeSlidersAnimationView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    let demoMaxWidth = UIScreen.main.bounds.size.width/2 - 30
    
    @State var essayDemoWidth: CGFloat = 50
    @State var essayDemoOffset1: CGFloat = 15 //rectangle
    @State var essayDemoOffset2: CGFloat = -10 //circle 1
    @State var essayDemoOffset3: CGFloat = 40 //circle 2
    
    @State var subassignmentDemoHeight: CGFloat = 120 //subassignment
    @State var subassignmentDemoOffset: CGFloat = 0 //subassignment
    
    @State var backgroungdDemoOpacity: Double = 0.3
    @State var playButtonOpacity: Double = 1.0
    
    var body: some View {
        ZStack {
            HStack(spacing: 5) {
                VStack(spacing: 5) {
                    HStack {
                        Text("Essay")
                        Spacer()
                    }

                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color("add_overlay_bg")).frame(width: self.demoMaxWidth, height: 20, alignment: .leading).overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Color.black, lineWidth: 0.5).frame(width: UIScreen.main.bounds.size.width/2 - 30, height: 20, alignment: .leading)
                        )

                        Rectangle().fill(Color.green).frame(width: self.essayDemoWidth, height: 19).offset(x: self.essayDemoOffset1)

                        Circle().fill(Color.white).frame(width: 30, height: 30).shadow(radius: 2).offset(x: self.essayDemoOffset2)

                        Circle().fill(Color.white).frame(width: 30, height: 30).shadow(radius: 2).offset(x: self.essayDemoOffset3)
                    }

                    VStack(spacing: 5) {
                        HStack {
                            Text("Exam")
                            Spacer()
                        }

                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color("add_overlay_bg")).frame(width: self.demoMaxWidth, height: 20, alignment: .leading).overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Color.black, lineWidth: 0.5).frame(width: UIScreen.main.bounds.size.width/2 - 30, height: 20, alignment: .leading)
                            )

                            Rectangle().fill(Color.green).frame(width: 0.45 * self.demoMaxWidth, height: 19).offset(x: -0.15 * self.demoMaxWidth)

                            Circle().fill(Color.white).frame(width: 30, height: 30).shadow(radius: 2).offset(x: -0.35 * self.demoMaxWidth)

                            Circle().fill(Color.white).frame(width: 30, height: 30).shadow(radius: 2).offset(x: 0.1 * self.demoMaxWidth)
                        }

                        HStack {
                            Text("Homework")
                            Spacer()
                        }

                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color("add_overlay_bg")).frame(width: self.demoMaxWidth, height: 20, alignment: .leading).overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Color.black, lineWidth: 0.5).frame(width: UIScreen.main.bounds.size.width/2 - 30, height: 20, alignment: .leading)
                            )

                            Rectangle().fill(Color.green).frame(width: 0.45 * self.demoMaxWidth, height: 19).offset(x: -0.15 * self.demoMaxWidth)

                            Circle().fill(Color.white).frame(width: 30, height: 30).shadow(radius: 2).offset(x: -0.35 * self.demoMaxWidth)

                            Circle().fill(Color.white).frame(width: 30, height: 30).shadow(radius: 2).offset(x: 0.1 * self.demoMaxWidth)
                        }
                    }.blur(radius: 2)
                }.frame(width: UIScreen.main.bounds.size.width/2 - 15)

                Rectangle().foregroundColor(.gray).frame(width: 0.5, height: 170)

                VStack {
                    ZStack {
                        VStack() {
                            ForEach((8...12), id: \.self) { hour in
                                HStack {
                                    Text(String(format: "%02d", hour)).font(.system(size: 10)).frame(width: 20, height: 20)
                                    Rectangle().fill(Color.gray).frame(width: self.demoMaxWidth - 25, height: 0.3)
                                }
                            }
                        }
                        
                        RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color("three")).frame(width: self.demoMaxWidth - 30, height: self.subassignmentDemoHeight).offset(x: 25, y: self.subassignmentDemoOffset)

                        HStack {
                            Text("English Essay").font(.footnote)

                            Spacer()
                        }.frame(width: self.demoMaxWidth - 30).offset(x: 33, y: -45)
                    }
                }.frame(width: UIScreen.main.bounds.size.width/2 - 15)
            }.opacity(self.backgroungdDemoOpacity).frame(width: UIScreen.main.bounds.size.width - 10).padding(.horizontal, 5)
                                            
            Button(action: {
                if self.playButtonOpacity == 1 {
                    withAnimation(Animation.easeInOut(duration: 0.2)) {
                        self.backgroungdDemoOpacity = 1.0
                        self.playButtonOpacity = 0.0
                    }

                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(300)) {
                        withAnimation(Animation.easeInOut(duration: 0.9)) {
                            self.essayDemoWidth = 90
                            self.essayDemoOffset1 = -5
                            self.essayDemoOffset2 = -50
                        }
                    }

                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1300)) {
                        withAnimation(Animation.easeInOut(duration: 0.8)) {
                            self.essayDemoWidth = 50
                            self.essayDemoOffset1 = -25
                            self.essayDemoOffset3 = 0
                        }
                    }

                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(2900)) {
                        withAnimation(Animation.easeInOut(duration: 1.0)) {
                            self.subassignmentDemoHeight = 40
                            self.subassignmentDemoOffset = -40
                        }
                    }

                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(4500)) {
                        withAnimation(Animation.easeInOut(duration: 0.9)) {
                            self.essayDemoWidth = 90
                            self.essayDemoOffset1 = -5
                            self.essayDemoOffset3 = 40
                        }
                    }

                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(5400)) {
                        withAnimation(Animation.easeInOut(duration: 0.8)) {
                            self.essayDemoWidth = 50
                            self.essayDemoOffset1 = 15
                            self.essayDemoOffset2 = -10
                        }
                    }

                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(6800)) {
                        withAnimation(Animation.easeInOut(duration: 1.0)) {
                            self.subassignmentDemoHeight = 120
                            self.subassignmentDemoOffset = 0
                        }
                    }

                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(8200)) {
                        withAnimation(Animation.easeInOut(duration: 0.2)) {
                            self.backgroungdDemoOpacity = 0.3
                            self.playButtonOpacity = 1.0
                        }
                    }
                }
            }) {
                VStack(spacing: 6) {
                    Image(systemName: "play.fill").resizable().foregroundColor((self.colorScheme == .light) ? .black : .white).frame(width: 20, height: 25)
                    Text("Watch Demo").fontWeight(.bold).foregroundColor((self.colorScheme == .light) ? .black : .white)
                }.opacity(self.playButtonOpacity)
            }
        }
    }
}

struct PreferencesView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: AssignmentTypes.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \AssignmentTypes.type, ascending: true)])
    var assignmenttypeslist: FetchedResults<AssignmentTypes>
    @State private var typeval: Int = 150
    @State private var selection: Set<String> = []
 
    private func selectDeselect(_ singularassignment: String) {
        if selection.contains(singularassignment) {
            selection.remove(singularassignment)
        } else {
            selection.insert(singularassignment)
        }
    }
    
    @EnvironmentObject var masterRunning: MasterRunning
    
    let assignmenttypes = ["Homework", "Study", "Test", "Essay", "Presentation/Oral", "Exam", "Report/Paper"]
    
    @State var RandomTogglerForLogic: Bool = true
    
    var body: some View {
        VStack {
            //Text(String(assignmenttypeslist.count))
          //  Form {
                ScrollView(showsIndicators: false) {
                    if (self.selection.contains("show")) {
                        Text("Drag on the Type Sliders to adjust your preferred task length for each assignment type. TRACR will then schedule tasks which best fit your preferences and assignments.").multilineTextAlignment(.leading).minimumScaleFactor(0.8).frame(width: UIScreen.main.bounds.size.width - 40, alignment: .topLeading)
                        
                        Divider().frame(width: UIScreen.main.bounds.size.width-40, height: 2).padding(.all, 3)
                        
                        TypeSlidersAnimationView().scaleEffect(0.95).padding(.vertical, 5)
                        
                        Divider().frame(width: UIScreen.main.bounds.size.width-40, height: 2).padding(.all, 3)
                    }

                    
//                        Button(action: {
//                            self.selectDeselect("show")
//                        }) {
//                            HStack {
//                                Text("What is this?").foregroundColor(.black).fontWeight(.bold)
//                                Spacer()
//                                Image(systemName: self.selection.contains("show") ? "chevron.down" : "chevron.up").foregroundColor(Color.black)
//                            }.padding(10).background(Color("two")).frame(width: UIScreen.main.bounds.size.width-20).cornerRadius(10)
//                        }.animation(.spring())
//
//                        if (self.selection.contains("show")) {
//                            Text("These are the Type Sliders. You can drag on the Type Sliders to adjust your preferred task length for each assignment type. For example, you can set your preferred task length for essays to 30 to 60 minutes. Then, if possible, the tasks created for Essay assignments will be between 30 and 60 minutes long. ").multilineTextAlignment(.leading).lineLimit(nil).frame(width: UIScreen.main.bounds.size.width - 40, height: 200, alignment: .topLeading).animation(.spring())
//                            Divider().frame(width: UIScreen.main.bounds.size.width-40, height: 2).animation(.spring())
//                        }
//                    DetailBreakView()
                    ForEach(self.assignmenttypeslist) { assignmenttype in
                        DetailPreferencesView(assignmenttype: assignmenttype)
                    }//.animation(.spring())
                }//.animation(.spring())
           // }.navigationTitle("Preferences")
        }.onAppear {
            self.RandomTogglerForLogic.toggle()
        }.onDisappear {
            masterRunning.masterRunningNow = true
            print("J")
        }.navigationTitle("Type Sliders").navigationBarTitleDisplayMode(.large).toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("")
            }
        }//.navigationTitle("Type Sliders")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading)
            {
                Text("")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action:{
                    withAnimation(Animation.spring()) {
                        self.selectDeselect("show")
                    }
                }) {
                    Image(systemName: self.selection.contains("show") ? "info.circle.fill" : "info.circle").resizable().scaledToFit().frame(height: 20)
                }
                
            }
        }
    }
}


struct DetailBreakView: View {
    @State var breakvalue: Double
    init() {
        let defaults = UserDefaults.standard
        let breakval = defaults.object(forKey: "savedbreakvalue") as? Int ?? 10
        _breakvalue = State(initialValue: Double(breakval)/5)
        
    }
    var body: some View {
        VStack {
     //   Divider().frame(width: UIScreen.main.bounds.size.width-60, height: 2)
        Text("Break").font(.title).frame(width: UIScreen.main.bounds.size.width-40, alignment: .leading)
        
        Slider(value: $breakvalue, in: 1...4).frame(width: UIScreen.main.bounds.size.width-60)
        HStack {
            Text("Time: " + String(Int(5*Int(breakvalue))) + " minutes")
            Spacer()
        }.frame(width: UIScreen.main.bounds.size.width-60, height: 30)
        Divider().frame(width: UIScreen.main.bounds.size.width-60, height: 2)
        }.onDisappear {
            let defaults = UserDefaults.standard
            defaults.set(Int(5*Int(breakvalue)), forKey: "savedbreakvalue")
        }
    }
}
struct DetailPreferencesView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    var assignmenttype: AssignmentTypes
    @FetchRequest(entity: AssignmentTypes.entity(),
                  sortDescriptors: [])

    var assignmenttypeslist: FetchedResults<AssignmentTypes>
    @State var currentdragoffsetmin = CGSize.zero
    @State var currentdragoffsetmax = CGSize.zero
    @State var newdragoffsetmax = CGSize.zero
    @State private var typeval: Double = 0
    @State private var typeval2: Double = 0
    @State private var newdragoffsetmin = CGSize.zero
    @State private var textvaluemin = 0
    @State private var textvaluemax = 0

    @EnvironmentObject var masterRunning: MasterRunning

    @State var rectangleWidth = UIScreen.main.bounds.size.width - 60;
    
    init(assignmenttype: AssignmentTypes) {
        self.assignmenttype = assignmenttype
    }
    
    func setValues() -> Bool {
        self.typeval = Double(assignmenttype.rangemin)
        self.typeval2 = Double(assignmenttype.rangemax)
        return true;
    }
    
    var body: some View {
        VStack {
            Text(assignmenttype.type).font(.title).frame(width: UIScreen.main.bounds.size.width-40, alignment: .leading)
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color("add_overlay_bg")).frame(width: self.rectangleWidth, height: 20, alignment: .leading).overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Color.black, lineWidth: 0.5).frame(width: self.rectangleWidth, height: 20, alignment: .leading)
                )
                Rectangle().fill(Color.green).frame(width: max(self.currentdragoffsetmax.width - self.currentdragoffsetmin.width, 0), height: 19).offset(x: getrectangleoffset())
                
                VStack {
                    Circle().fill(Color.white).frame(width: 30, height: 30).shadow(radius: 2)
                    Text(textvaluemin == 0 ? String(roundto15minutes(roundvalue: getmintext())) : String(textvaluemin))

                }.offset(x:  self.currentdragoffsetmin.width, y: 15)
                    // 3.
                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { value in
                           // print(value.translation.width)

                            self.currentdragoffsetmin = CGSize(width: value.translation.width + self.newdragoffsetmin.width, height: value.translation.height + self.newdragoffsetmin.height)
                            
                            if (self.currentdragoffsetmin.width < -1*self.rectangleWidth/2)
                            {
                                self.currentdragoffsetmin.width = -1*self.rectangleWidth/2
                            }
                            if (self.currentdragoffsetmin.width > self.rectangleWidth/2)
                            {
                                self.currentdragoffsetmin.width = self.rectangleWidth/2
                            }
                            if (self.currentdragoffsetmin.width > self.currentdragoffsetmax.width)
                            {
                                self.currentdragoffsetmin.width = self.currentdragoffsetmax.width
                            }
                            if (self.currentdragoffsetmax.width - self.currentdragoffsetmin.width < self.rectangleWidth/9 + 1)
                            {
                             //   print("success1")
                                self.currentdragoffsetmin.width = self.currentdragoffsetmax.width - self.rectangleWidth/9 - 1
                            }

                    }   // 4.
                        .onEnded { value in
                           self.currentdragoffsetmin = CGSize(width: value.translation.width + self.newdragoffsetmin.width, height: value.translation.height + self.newdragoffsetmin.height)
                            if (self.currentdragoffsetmin.width < -1*self.rectangleWidth/2)
                            {
                                self.currentdragoffsetmin.width = -1*self.rectangleWidth/2
                            }
                            if (self.currentdragoffsetmin.width > self.rectangleWidth/2)
                            {
                                self.currentdragoffsetmin.width = self.rectangleWidth/2
                            }
                            if (self.currentdragoffsetmin.width > self.currentdragoffsetmax.width)
                            {
                                self.currentdragoffsetmin.width = self.currentdragoffsetmax.width
                            }
                            if (self.currentdragoffsetmax.width - self.currentdragoffsetmin.width < self.rectangleWidth/9 + 1)
                            {
                             //   print("success2")
                                self.currentdragoffsetmin.width = self.currentdragoffsetmax.width - self.rectangleWidth/9 - 1
                            }

                            self.newdragoffsetmin = self.currentdragoffsetmin
                            
                        }
                )
                VStack {
                    Circle().fill(Color.white).frame(width: 30, height: 30).shadow(radius: 2)
                    Text(textvaluemax == 0 ? String(roundto15minutes(roundvalue: getmaxtext())) : String(textvaluemax))
                }.offset(x:  self.currentdragoffsetmax.width, y: 15)
                     // 3.
                     .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                         .onChanged { value in
                            // print(value.translation.width)

                             self.currentdragoffsetmax = CGSize(width: value.translation.width + self.newdragoffsetmax.width, height: value.translation.height + self.newdragoffsetmax.height)
                             
                             if (self.currentdragoffsetmax.width < -1*self.rectangleWidth/2)
                             {
                                 self.currentdragoffsetmax.width = -1*self.rectangleWidth/2
                             }
                             if (self.currentdragoffsetmax.width > self.rectangleWidth/2)
                             {
                                 self.currentdragoffsetmax.width = self.rectangleWidth/2
                             }
                            if (self.currentdragoffsetmax.width < self.currentdragoffsetmin.width)
                            {
                                self.currentdragoffsetmax.width = self.currentdragoffsetmin.width
                            }
                            if (self.currentdragoffsetmax.width - self.currentdragoffsetmin.width < self.rectangleWidth/9 + 1)
                            {
                                self.currentdragoffsetmax.width = self.currentdragoffsetmin.width + self.rectangleWidth/9 + 1
                            }

                     }   // 4.
                         .onEnded { value in
                            self.currentdragoffsetmax = CGSize(width: value.translation.width + self.newdragoffsetmax.width, height: value.translation.height + self.newdragoffsetmax.height)
                             if (self.currentdragoffsetmax.width < -1*self.rectangleWidth/2)
                             {
                                 self.currentdragoffsetmax.width = -1*self.rectangleWidth/2
                             }
                             if (self.currentdragoffsetmax.width > self.rectangleWidth/2)
                             {
                                 self.currentdragoffsetmax.width = self.rectangleWidth/2
                             }
                            if (self.currentdragoffsetmax.width < self.currentdragoffsetmin.width)
                            {
                                self.currentdragoffsetmax.width = self.currentdragoffsetmin.width
                            }
                            if (self.currentdragoffsetmax.width - self.currentdragoffsetmin.width < self.rectangleWidth/9 + 1)
                            {
                                self.currentdragoffsetmax.width = self.currentdragoffsetmin.width + self.rectangleWidth/9 + 1
                            }

                            self.newdragoffsetmax = self.currentdragoffsetmax
                         }
                 )

            }
//                HStack {
//                   // Text("Min: " + String(roundto15minutes(roundvalue: getmintext()))).frame(width: rectangleWidth/2)
//                 //   Text("Max: " + String(roundto15minutes(roundvalue: getmaxtext()))).frame(width: rectangleWidth/2)
//                }
            Spacer().frame(height: 30)
            HStack {
//                   Spacer().frame(width: 5)
                HStack(spacing: rectangleWidth/9 - 1) {
                    
                    ForEach(0 ..< 10)
                    {
                        value in
                        Rectangle().frame(width: 1, height: 10)
                    }
                }
            }
            RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.black).frame(width: self.rectangleWidth, height: 1, alignment: .leading).offset(y: -8)
            HStack {
                Text("30m").font(.system(size: 10)).offset(x: 5)
                Spacer()
                Text("300m").font(.system(size: 10))
            }.frame(width: rectangleWidth+30).offset(y: -5)
            Spacer().frame(height: 30)
            Divider().frame(width: rectangleWidth, height: 2)

        }.padding(10).onAppear {
            self.typeval = Double(self.assignmenttype.rangemin)
            self.typeval2 = Double(self.assignmenttype.rangemax)
            self.currentdragoffsetmin.width = ((CGFloat(self.assignmenttype.rangemin)-165)/135)*self.rectangleWidth/2
            self.currentdragoffsetmax.width = ((CGFloat(self.assignmenttype.rangemax)-165)/135)*self.rectangleWidth/2
            self.newdragoffsetmin.width = ((CGFloat(self.assignmenttype.rangemin)-165)/135)*self.rectangleWidth/2
            self.newdragoffsetmax.width = ((CGFloat(self.assignmenttype.rangemax)-165)/135)*self.rectangleWidth/2
        }.onDisappear {
//                self.assignmenttype.rangemin = Int64(self.typeval)
//                self.assignmenttype.rangemax = Int64(self.typeval2)
            if (self.textvaluemin == 0) {
                self.assignmenttype.rangemin  = Int64(self.roundto15minutes(roundvalue: self.getmintext()))
            }
            else {
                self.assignmenttype.rangemin = Int64(self.textvaluemin)
            }
            if (self.textvaluemax == 0) {
                self.assignmenttype.rangemax  = Int64(self.roundto15minutes(roundvalue: self.getmaxtext()))
            }
            else {
                self.assignmenttype.rangemax = Int64(self.textvaluemax)
            }
            do {
                try self.managedObjectContext.save()
                //print("AssignmentTypes rangemin/rangemax changed")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func roundto15minutes(roundvalue: Int) -> Int {
        if (roundvalue % 15 <= 7) {
            return roundvalue - (roundvalue % 15)
        }
        else {
            return roundvalue + 15 - (roundvalue % 15)
        }
    }
    func getrectangleoffset() -> CGFloat {
        return -1*((self.currentdragoffsetmax.width-self.currentdragoffsetmin.width)/2 - (self.currentdragoffsetmin.width))+max(self.currentdragoffsetmax.width - self.currentdragoffsetmin.width, 0)
    }
    func getmintext() -> Int {
        return 165 + Int((self.currentdragoffsetmin.width/(rectangleWidth/2))*135)
    }
    func getmaxtext() -> Int {
        return 165 + Int((self.currentdragoffsetmax.width/(rectangleWidth/2))*135)
    }
}

struct NotificationsView: View {
    let beforeassignmenttimes = ["At Start", "5 minutes", "10 minutes", "15 minutes", "30 minutes"]
    @State var selectedbeforeassignment = 0
    @State var selectedbeforebreak = 0
    let beforebreaktimes = [0,5, 10, 15, 30]
    @State var atassignmentstart = false
    @State var atbreakstart = false
    @State var atassignmentend = false
    @State private var selection: Set<String> = ["None"]
    @State private var selection2: Set<String> = ["None"]
    @State var atbreakend = false
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var masterRunning: MasterRunning

    private func selectDeselect(_ singularassignment: String) {
        if selection.contains(singularassignment) {
            selection.remove(singularassignment)
        } else {
            selection.insert(singularassignment)
        }
    }
    private func selectDeselect2(_ singularassignment: String) {
        if selection2.contains(singularassignment) {
            selection2.remove(singularassignment)
        } else {
            selection2.insert(singularassignment)
        }
    }
    var body: some View {
        // NavigationView {
          //  VStack {
                //Text("hello")
                    //NavigationView {
        VStack {
            //Spacer()
                        Form {
                       //     Text("Before Tasks").font(.title)
                            Section(header: Text("Before Tasks").font(.system(size: 20))) {
                                List {
                                    HStack {
                                         Button(action: {
                                            if (!self.selection.contains("None")) {
                                                self.selection.removeAll()
                                                self.selectDeselect("None")
                                            }
                                             
                                         }) {
                                             Text("None")//.foregroundColor(.black)
                                         }
                                        
                                         if (self.selection.contains("None")) {
                                             Spacer()
                                             Image(systemName: "checkmark").foregroundColor(.blue)
                                         }
                                     }
                                    ForEach(self.beforeassignmenttimes,  id: \.self) { repeatoption in
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Button(action: {self.selectDeselect(repeatoption)
                                                    if (self.selection.count==0) {
                                                        self.selectDeselect("None")
                                                    }
                                                    else if (self.selection.contains("None")) {
                                                        self.selectDeselect("None")
                                                    }
                                                    
                                                }) {
                                                    Text(repeatoption)//.foregroundColor(.black)
                                                }
                                                if (self.selection.contains(repeatoption)) {
                                                    Spacer()
                                                    Image(systemName: "checkmark").foregroundColor(.blue)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                       //     Text("Before Break").font(.title)
                            Section(header: Text("Before End of Tasks").font(.system(size: 20))) {
                                List {
                                    HStack {
                                         Button(action: {
                                            if (!self.selection2.contains("None")) {
                                                self.selection2.removeAll()
                                                self.selectDeselect2("None")
                                            }
                                             
                                         }) {
                                             Text("None")//.foregroundColor(.black)
                                         }
                                        
                                         if (self.selection2.contains("None")) {
                                             Spacer()
                                             Image(systemName: "checkmark").foregroundColor(.blue)
                                         }
                                     }
                                    ForEach(self.beforeassignmenttimes,  id: \.self) { repeatoption in
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Button(action: {self.selectDeselect2(repeatoption)
                                                    if (self.selection2.count==0) {
                                                        self.selectDeselect2("None")
                                                    }
                                                    else if (self.selection2.contains("None")) {
                                                        self.selectDeselect2("None")
                                                    }
                                                    
                                                }) {
                                                    Text(repeatoption)//.foregroundColor(.black)
                                                }
                                                if (self.selection2.contains(repeatoption)) {
                                                    Spacer()
                                                    Image(systemName: "checkmark").foregroundColor(.blue)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            

                        }.navigationTitle("Notifications").navigationBarTitleDisplayMode(.inline)
        }.onAppear() {
            let defaults = UserDefaults.standard
            let array = defaults.object(forKey: "savedassignmentnotifications") as? [String] ?? ["At Start"]
            self.selection = Set(array)
            let array2 = defaults.object(forKey: "savedbreaknotifications") as? [String] ?? ["None"]
            self.selection2 = Set(array2)
        }.onDisappear() {
            let defaults = UserDefaults.standard
            let array = Array(self.selection)
            defaults.set(array, forKey: "savedassignmentnotifications")
            let array2 = Array(self.selection2)
            defaults.set(array2, forKey: "savedbreaknotifications")
            
            masterRunning.onlyNotifications = true
//            masterRunning.onlyNotifications = true
        }
                   // }
               // }//.navigationBarItems(leading: Text("H")).navigationTitle("Notifications", displayMode: .inline)
        //}
    }
}
