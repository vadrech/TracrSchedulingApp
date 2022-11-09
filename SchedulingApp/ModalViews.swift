import Foundation
import UIKit
import SwiftUI
import GoogleSignIn
import GoogleAPIClientForREST
import WidgetKit

class TextFieldManager: ObservableObject {
    @Published var userInput = "" {
            didSet {
                if userInput.count > 35 {
                    userInput = String(userInput.prefix(35))
                }
            }
        }
    
    init(blah: String)
    {
        userInput = blah
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct SelectGoogleAssignmentView: View
{
    @EnvironmentObject var googleDelegate: GoogleDelegate

    @Environment(\.managedObjectContext) var managedObjectContext

    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    @Binding var selectedgoogleassignment: Int
    @Binding var foundassignments: [(String, String)]
    @Binding var activeselection: Bool
    @Binding var selectedclass: Int
    @Binding var assignmenttype: Int
    @Binding var nameofassignment: String
    @Binding var selectedDate: Date
    @Binding var foundassignmentdates: [Date]
    let assignmenttypes = ["Homework", "Study", "Test", "Essay", "Presentation/Oral", "Exam", "Report/Paper"]

    
    func getnontrashclasslist() -> [Int]
    {
        var classitylist: [Int] = []
        for (index, classity) in classlist.enumerated()
        {
            if (!classity.isTrash)
            {
                classitylist.append(index)
            }
        }
        return classitylist
    }
    func dostuff()
    {

        for classity in getnontrashclasslist()
        {
            if (foundassignments.count > 0)
            {
                if (classlist[classity].googleclassroomid == foundassignments[selectedgoogleassignment].1)
                {
                    selectedclass = classity
                    break
                }
            }
        }
        if (foundassignments.count > 0)
        {
            self.nameofassignment = foundassignments[selectedgoogleassignment].0
            for (index, types) in assignmenttypes.enumerated()
            {
                if (foundassignments[selectedgoogleassignment].0.lowercased().contains(types.lowercased()) )
                {
                    assignmenttype = index
                }
            }
            self.selectedDate = foundassignmentdates[selectedgoogleassignment]
         //   refreshID2 = UUID()
        }
        activeselection = false

        
    }
    
    
    func classNameWithNumber(className: String, classId: String) -> String {
        var counter = 0
        for val in 0..<foundassignments.count {
            if foundassignments[val].1 == classId {
                counter += 1
            }
        }
        return className + " (" + String(counter) + ")"
    }
    
    var body: some View
    {
        Form
        {
            if (!googleDelegate.signedIn)
            {
                HStack {
                    Text("Sign in with Google to use this feature").fontWeight(.light).foregroundColor(Color("darkgray"))
                    
                    Spacer()
                }.frame(height: 80)
                .listRowInsets(EdgeInsets())
                .background(Color(UIColor.systemGroupedBackground))
            }
            else
            {
                ForEach(classlist)
                {
                    classity in
                    if (classity.googleclassroomid != "")
                    {
                        Section(header: Text(self.classNameWithNumber(className: classity.name, classId: classity.googleclassroomid)).fontWeight(.bold).padding(10 ).font(.system(size: 20)))
                        {
                            ForEach(0 ..< foundassignments.count, id: \.self)
                            {
                                val in
                                if (foundassignments[val].1 == classity.googleclassroomid)
                                {
                                    Button(action:{
                                        selectedgoogleassignment = val
                                        dostuff()
                                    })
                                    {
                                        HStack
                                        {
                                            Text(foundassignments[val].0)//.frame(width: UIScreen.main.bounds.size.width-40, alignment: .leading).padding(.horizontal, 20)
                                            Spacer()
                                            if (selectedgoogleassignment == val)
                                            {
                                                Image(systemName: "checkmark").foregroundColor(.blue)
                                            }
                                        }
                                    }.buttonStyle(PlainButtonStyle())
                                    
                                }
                            }
                        }
                    }
                }
            }

//            ForEach(0 ..< foundassignments.count, id: \.self) {
//
//                val in
//
//                Button(action:{
//                    selectedgoogleassignment = val
//                    dostuff()
//                })
//                {
//                    HStack
//                    {
//                        Text(foundassignments[val].0)//.frame(width: UIScreen.main.bounds.size.width-40, alignment: .leading).padding(.horizontal, 20)
//                        Spacer()
//                        if (selectedgoogleassignment == val)
//                        {
//                            Image(systemName: "checkmark").foregroundColor(.blue)
//                        }
//                    }
//                }.buttonStyle(PlainButtonStyle())//.shadow(radius: 10)//.frame(height: 30)
//
//
//
//            }
        }
        
    }
}
struct NewGoogleAssignmentModalView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var googleDelegate: GoogleDelegate

    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject var changingDate: DisplayedDate
    
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    @Binding var NewAssignmentPresenting: Bool
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [])
    var assignmentslist: FetchedResults<Assignment>
    
    @State var activeselection: Bool = false
    @State var nameofassignment: String = ""
    @State private var selectedclass: Int
    @State private var preselecteddate: Int
    @State private var assignmenttype = 0
    @State private var hours = 0
    @State private var minutes = 0
    @State var selectedDate: Date
    let assignmenttypes = ["Homework", "Study", "Test", "Essay", "Presentation/Oral", "Exam", "Report/Paper"]
    let hourlist = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60]
    let minutelist = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    
    @State private var createassignmentallowed = true
    @State private var showingAlert = false
    @State private var expandedduedate = false
    @State private var startDate = Date()
    @State private var completedassignment = false
    @State private var assignmentgrade: Double = 1
    var otherclassgradesae: [String] = ["E", "D", "C", "B", "A"]
    var otherclassgradesaf: [String] = ["F", "E", "D", "C", "B", "A"]
    var formatter: DateFormatter
    @State var refreshID = UUID()
    @State var foundassignments = [(String, String)]()
    @State var foundassignmentdates = [Date]()
    @State var selectedgoogleassignment = 0
    
    @EnvironmentObject var masterRunning: MasterRunning
    @ObservedObject var textfieldmanager: TextFieldManager = TextFieldManager(blah: "")
    @State var countnewassignments = 0
    
    init(NewAssignmentPresenting: Binding<Bool>, selectedClass: Int, preselecteddate: Int) {
        self._NewAssignmentPresenting = NewAssignmentPresenting
        formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        _selectedclass = State(initialValue: selectedClass)
        self._preselecteddate = State(initialValue: preselecteddate)
                
        let lastmondaydate = Calendar.current.date(byAdding: .day, value: 1, to: Date().startOfWeek!)! > Date() ? Calendar.current.date(byAdding: .day, value: -6, to: Date().startOfWeek!)! : Calendar.current.date(byAdding: .day, value: 1, to: Date().startOfWeek!)!
            
        if (preselecteddate == -1)
        {
            self._selectedDate = State(initialValue: Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!))//bugfixtemp
        }
        else
        {
            
            if (Calendar.current.date(byAdding: .day, value: preselecteddate, to: lastmondaydate)! < Date())
            {
                self._selectedDate = State(initialValue: Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!))
            }
            else
            {
                self._selectedDate = State(initialValue: Calendar.current.date(byAdding: .day, value: preselecteddate, to: lastmondaydate)!)
            }
        }
    }
    func getnontrashclasslist() -> [Int]
    {
        var classitylist: [Int] = []
        for (index, classity) in classlist.enumerated()
        {
            if (!classity.isTrash)
            {
                classitylist.append(index)
            }
        }
        return classitylist
    }
    func getgradingscheme() -> String
    {
        if (selectedclass < classlist.count)
        {
            return classlist[selectedclass].gradingscheme
        }
        return "P"
    }
    func getgrademin() -> Double
    {
        let gradeschemeval = self.getgradingscheme()
        if (gradeschemeval[0..<1] == "L")
        {
            return 1
        }
        else if (gradeschemeval[0..<1] == "N")
        {
            return 1
        }
        else
        {
            return 1
        }
    }
    func getgrademax() -> Double
    {
        let gradeschemeval = self.getgradingscheme()
        if (gradeschemeval[0..<1] == "L")
        {
            if (gradeschemeval[3..<4] == "F")
            {
                return 6
            }
            return 5
        }
        else if (gradeschemeval[0..<1] == "N")
        {
            return Double(gradeschemeval[3..<gradeschemeval.count]) ?? 7
        }
        else
        {
            return 100
        }
        
    }
    @State var refreshID2 = UUID()
    var body: some View
    {
        NavigationView {
            Form {
                Section {
                    
//                    Picker(selection: $selectedgoogleassignment, label: Text("Google Assignment")) {
//                        ForEach(0 ..< foundassignments.count, id: \.self) {
//
//                            val in
//                            Text(foundassignments[val].0)
//
//
//                        }
//
//                    }
                    
                    TextField("Assignment Name", text: $nameofassignment).keyboardType(.webSearch).onTapGesture {
                        UIApplication.shared.endEditing()
                    }
                    
                    NavigationLink(destination: SelectGoogleAssignmentView(selectedgoogleassignment: $selectedgoogleassignment, foundassignments: $foundassignments, activeselection: $activeselection, selectedclass: $selectedclass, assignmenttype: $assignmenttype, nameofassignment: $nameofassignment, selectedDate: $selectedDate, foundassignmentdates: $foundassignmentdates).environmentObject(googleDelegate).onAppear
                    {
                        countnewassignments = 0
                    }, isActive: $activeselection)
                    {
                        HStack
                        {
                            Text("Select a Classroom assignment")
                            Spacer()
                            if (foundassignments.count > 0)
                            {
                                Text(foundassignments[selectedgoogleassignment].0).foregroundColor(Color.gray)
                            }
                            if (countnewassignments > 0)
                            {
                                Text(String(countnewassignments)).fontWeight(.bold)
                            }
                        }
                    }
//                    .onChange(of: activeselection)
//                    {
//                       // textfieldmanager.userInput = foundassignments[selectedgoogleassignment]
//                        _ in
//                        for classity in getnontrashclasslist()
//                        {
//                            if (foundassignments.count > 0)
//                            {
//                                if (classlist[classity].googleclassroomid == foundassignments[selectedgoogleassignment].1)
//                                {
//                                    selectedclass = classity
//                                    break
//                                }
//                            }
//                        }
//                        if (foundassignments.count > 0)
//                        {
//                            self.nameofassignment = foundassignments[selectedgoogleassignment].0
//                            for (index, types) in assignmenttypes.enumerated()
//                            {
//                                if (foundassignments[selectedgoogleassignment].0.lowercased().contains(types.lowercased()) )
//                                {
//                                    assignmenttype = index
//                                }
//                            }
//                            self.selectedDate = foundassignmentdates[selectedgoogleassignment]
//                         //   refreshID2 = UUID()
//                            print("hello")//  print(foundassignmentdates[selectedgoogleassignment].description)
//                        }
//
//                    }
                }
                
//                Section {
//                    Toggle(isOn: self.$completedassignment) {
//                        Text("Completed Assignment")
//                    }.onTapGesture {
//                        if (!self.completedassignment)
//                         {
//                            self.assignmentgrade = 1
//
//                          //  print(!self.iscompleted)
//                        }
//                        else
//                        {
//
//                            self.selectedDate = Date()
//                        }
//
//
//
//                    }
//                }
                
//                if (self.completedassignment)
//                {
//                    Section {
//                        VStack {
//                            //Text("Hello")
//
//                            if (self.getgradingscheme()[0..<1] == "N" || self.getgradingscheme()[0..<1] == "L")
//                            {
//                                HStack {
//                                    if (self.getgradingscheme()[0..<1] == "N")
//                                    {
//                                        Text("Grade: \(assignmentgrade.rounded(.down), specifier: "%.0f")")
//                                    }
//                                    else
//                                    {
//                                        if (self.getgradingscheme()[3..<4] == "F")
//                                        {
//                                            Text("Grade: " + otherclassgradesaf[Int(assignmentgrade.rounded(.down))-1])
//                                        }
//                                        else
//                                        {
//                                            Text("Grade: " + otherclassgradesae[Int(assignmentgrade.rounded(.down))-1])
//                                        }
//                                    }
//                                   Spacer()
//                                }.frame(height: 30)
//                                Slider(value: $assignmentgrade, in: self.getgrademin()...self.getgrademax())
//                            }
//                            else
//                            {
//                                HStack {
//                                    Text("Grade: \(assignmentgrade.rounded(.down), specifier: "%.0f")")
//                                    Spacer()
//                                }.frame(height: 30)
//                                Slider(value: $assignmentgrade, in: 1...100)
//
//                            }
//
//
//                        }
//
//                    }
//                }
                Section {
                    Picker(selection: $selectedclass, label: Text("Class")) {
                        ForEach(0 ..< getnontrashclasslist().count) {
                            if ($0 < self.getnontrashclasslist().count)
                            {
                                Text(self.classlist[self.getnontrashclasslist()[$0]].name)
                            }
                            
                        }
                    }

                }
                Section {
                    Picker(selection: $assignmenttype, label: Text("Type")) {
                        ForEach(0 ..< assignmenttypes.count) {
                            Text(self.assignmenttypes[$0])
                        }
                    }
                }
                
                Section {
                    Text("Assignment Length")
                    HStack {
                        VStack {
                            Picker(selection: $hours, label: Text("Hour")) {
                                ForEach(hourlist.indices) { hourindex in
                                    Text(String(self.hourlist[hourindex]) + (self.hourlist[hourindex] == 1 ? " hour" : " hours"))
                                 }
                             }.pickerStyle(WheelPickerStyle())
                        }.frame(minWidth: 100, maxWidth: .infinity)
                        .clipped()
                        
                        VStack {
                            if hours == 0 {
                                Picker(selection: $minutes, label: Text("Minutes")) {
                                    ForEach(minutelist[6...].indices) { minuteindex in
                                        Text(String(self.minutelist[minuteindex]) + " mins")
                                    }
                                }.pickerStyle(WheelPickerStyle())
                            }
                            
                            else {
                                Picker(selection: $minutes, label: Text("Minutes")) {
                                    ForEach(minutelist.indices) { minuteindex in
                                        Text(String(self.minutelist[minuteindex]) + " mins")
                                    }
                                }.pickerStyle(WheelPickerStyle())
                            }
                        }.frame(minWidth: 100, maxWidth: .infinity)
                        .clipped()
                    }
                }

                Section {


                    if #available(iOS 14.0, *) {
                        Button(action: {
                                self.expandedduedate.toggle()
                            

                        }) {
                            HStack {
                                Text("Due Date").foregroundColor(colorScheme == .light ? Color.black : Color.white)
                                Spacer()
                                Text(formatter.string(from: selectedDate)).foregroundColor(expandedduedate ? Color.blue: Color.gray)
                            }

                        }
                        if (expandedduedate)
                        {
                            VStack {
                                DatePicker("", selection: self.$selectedDate, in: self.completedassignment ? Date(timeIntervalSince1970: 0)... : Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)..., displayedComponents: [.date, .hourAndMinute]).animation(.spring()).datePickerStyle(WheelDatePickerStyle())//.frame(width: UIScreen.main.bounds.size.width-60, height: 100)
                            }.animation(.spring())//.id(refreshID2)
                        }

                    }
                    
                    else {
                        Button(action: {
                                self.expandedduedate.toggle()

                        }) {
                            HStack {
                                Text("Due Date").foregroundColor(Color.black)
                                Spacer()
                                Text(formatter.string(from: selectedDate)).foregroundColor(expandedduedate ? Color.blue: Color.gray)
                            }

                        }
                        if (expandedduedate)
                        {
                            VStack { //change startDate thing to the time-adjusted one (look at iOS 14 implementation
                                MyDatePicker(selection: $selectedDate, starttime: $startDate, dateandtimedisplayed: true).frame(width: UIScreen.main.bounds.size.width-40, height: 200, alignment: .center).animation(nil)
                            }.animation(nil)
                        }
                        
                    }
                }

                Section {
                    Button(action: {
                        self.createassignmentallowed = true
                        
                        for assignment in self.assignmentslist {
                            if assignment.name == self.nameofassignment {
                                self.createassignmentallowed = false
                            }
                        }
                        
                        if (self.nameofassignment == "")
                        {
                            self.createassignmentallowed = false
                        }
                        if self.createassignmentallowed {
                            if (!self.completedassignment)
                            {
                                let newAssignment = Assignment(context: self.managedObjectContext)
                                newAssignment.completed = false
                                newAssignment.grade = 0
                                newAssignment.subject = self.classlist[self.getnontrashclasslist()[self.selectedclass]].originalname
                                newAssignment.name = self.nameofassignment
                                newAssignment.type = self.assignmenttypes[self.assignmenttype]
                                newAssignment.progress = 0
                                newAssignment.duedate = self.selectedDate
                                
                                if (self.hours == 0)
                                {
                                    newAssignment.totaltime = Int64(self.minutelist[self.minutes+6])
                                }
                                else
                                {
                                    newAssignment.totaltime = Int64(60*self.hourlist[self.hours] + self.minutelist[self.minutes])
                                }
                                newAssignment.timeleft = newAssignment.totaltime
                            
                                for classity in self.classlist {
                                    if (classity.originalname == newAssignment.subject) {
                                        newAssignment.color = classity.color
                                        classity.assignmentnumber += 1
                                    }
                                }
                                do {
                                    try self.managedObjectContext.save()
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                            else
                            {
                                let newAssignment = Assignment(context: self.managedObjectContext)
                                newAssignment.completed = true
                                newAssignment.grade = Int64(self.assignmentgrade)
                                newAssignment.subject = self.classlist[self.getnontrashclasslist()[self.selectedclass]].originalname
                                newAssignment.name = self.nameofassignment
                                newAssignment.type = self.assignmenttypes[self.assignmenttype]
                                newAssignment.progress = 100
                                newAssignment.duedate = self.selectedDate
                                
                                if (self.hours == 0)
                                {
                                    newAssignment.totaltime = Int64(self.minutelist[self.minutes+6])
                                }
                                else
                                {
                                    newAssignment.totaltime = Int64(60*self.hourlist[self.hours] + self.minutelist[self.minutes])
                                }
                                newAssignment.timeleft = 0
                            
                                for classity in self.classlist {
                                    if (classity.originalname == newAssignment.subject) {
                                        newAssignment.color = classity.color
//                                        classity.assignmentnumber += 1
                                    }
                                }
                                do {
                                    try self.managedObjectContext.save()
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                            masterRunning.uniqueAssignmentName = self.nameofassignment

                            print("C")
                            masterRunning.masterRunningNow = true
                            masterRunning.displayText = true
                            

                            
                            self.NewAssignmentPresenting = false
                        }
                     
                        else {
                            self.showingAlert = true
                        }
                    }) {
                        Text("Add Assignment")
                    }
                }
            }.gesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onChanged { _ in
                UIApplication.shared.endEditing()
            }.onEnded { _ in
                UIApplication.shared.endEditing()
            }).navigationBarItems(leading:Button(action: {self.NewAssignmentPresenting = false}, label: {Text("Cancel")}) , trailing: Button(action: {
                self.createassignmentallowed = true
                
                for assignment in self.assignmentslist {
                    if assignment.name == self.nameofassignment {
                        self.createassignmentallowed = false
                    }
                }
                
                if (self.nameofassignment == "")
                {
                    self.createassignmentallowed = false
                }
                if self.createassignmentallowed {
                    if (!self.completedassignment)
                    {
                        let newAssignment = Assignment(context: self.managedObjectContext)
                        newAssignment.completed = false
                        newAssignment.grade = 0
                        newAssignment.subject = self.classlist[self.getnontrashclasslist()[self.selectedclass]].originalname
                        newAssignment.name = self.nameofassignment
                        newAssignment.type = self.assignmenttypes[self.assignmenttype]
                        newAssignment.progress = 0
                        newAssignment.duedate = self.selectedDate
                        
                        if (self.hours == 0)
                        {
                            newAssignment.totaltime = Int64(self.minutelist[self.minutes+6])
                        }
                        else
                        {
                            newAssignment.totaltime = Int64(60*self.hourlist[self.hours] + self.minutelist[self.minutes])
                        }
                        newAssignment.timeleft = newAssignment.totaltime
                    
                        for classity in self.classlist {
                            if (classity.originalname == newAssignment.subject) {
                                newAssignment.color = classity.color
                                classity.assignmentnumber += 1
                            }
                        }
                        do {
                            try self.managedObjectContext.save()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    else
                    {
                        let newAssignment = Assignment(context: self.managedObjectContext)
                        newAssignment.completed = true
                        newAssignment.grade = Int64(self.assignmentgrade)
                        newAssignment.subject = self.classlist[self.getnontrashclasslist()[self.selectedclass]].originalname
                        newAssignment.name = self.nameofassignment
                        newAssignment.type = self.assignmenttypes[self.assignmenttype]
                        newAssignment.progress = 100
                        newAssignment.duedate = self.selectedDate
                        
                        if (self.hours == 0)
                        {
                            newAssignment.totaltime = Int64(self.minutelist[self.minutes+6])
                        }
                        else
                        {
                            newAssignment.totaltime = Int64(60*self.hourlist[self.hours] + self.minutelist[self.minutes])
                        }
                        newAssignment.timeleft = 0
                    
                        for classity in self.classlist {
                            if (classity.originalname == newAssignment.subject) {
                                newAssignment.color = classity.color
//                                        classity.assignmentnumber += 1
                            }
                        }
                        do {
                            try self.managedObjectContext.save()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    masterRunning.uniqueAssignmentName = self.nameofassignment

                    print("C")
                    masterRunning.masterRunningNow = true
                    masterRunning.displayText = true
                    

                    
                    self.NewAssignmentPresenting = false
                }
             
                else {
                    self.showingAlert = true
                }
            }) {
                Text("Add")
            }).navigationTitle("Add Assignment").navigationBarTitleDisplayMode(.inline).alert(isPresented: $showingAlert) {
                Alert(title: self.nameofassignment == "" ? Text("No Assignment Name Provided") : Text("Assignment Already Exists"), message: self.nameofassignment == "" ? Text("Add an Assignment Name") : Text("Change Assignment Name"), dismissButton: .default(Text("Continue")))
            }
        }
        .onAppear
        {
            let defaults = UserDefaults.standard
            countnewassignments = defaults.object(forKey: "countnewassignments") as! Int
            GIDSignIn.sharedInstance().restorePreviousSignIn()
           
            if (googleDelegate.signedIn)
            {
                var idlist: [String] = []
                for classity in classlist
                {
                    if (classity.googleclassroomid != "")
                    {
                        idlist.append(classity.googleclassroomid)
                    }
                }
                let service = GTLRClassroomService()
                service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()

                    for idiii in idlist {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(0)) {
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
                                let assignmentsforid = stuff as! GTLRClassroom_ListCourseWorkResponse

                                if assignmentsforid.courseWork != nil {
                                    for assignment in assignmentsforid.courseWork! {
                                      //  print(assignment.title!)
                                        if (assignment.dueDate != nil)
                                        {
                                           // print(assignment.title!)
//                                        if (assignment.dueDate!.day! as! Int >= Int(dayformatter.string(from: workingdate)) ?? 0 && assignment.dueDate!.month as! Int >= Int(monthformatter.string(from: workingdate)) ?? 0 && assignment.dueDate!.year as! Int >= Int(yearformatter.string(from: workingdate)) ?? 0 )
//                                        {
                                         //   print(assignment.title!)
                                      //  }
                                            var newComponents = DateComponents()
                                            newComponents.timeZone = .current
                                            newComponents.day = Int(truncating: assignment.dueDate!.day!)
                                            newComponents.month = Int(truncating: assignment.dueDate!.month!)
                                            newComponents.year = Int(truncating: assignment.dueDate!.year!)
                                            if (assignment.dueTime != nil)
                                            {
                                                newComponents.hour = assignment.dueTime!.hours as? Int
                                                newComponents.minute = assignment.dueTime!.minutes as? Int
                                                newComponents.second = 0
                                             //   print(assignment.title!, newComponents.hour!, newComponents.minute!)
     
                                            }
                                            let cooldate = Date(timeInterval: TimeInterval(TimeZone.current.secondsFromGMT()), since: Calendar.current.date(from: newComponents)!)
                                            if (cooldate >= Date())
                                            {
                                                foundassignments.append((assignment.title!, idiii))
                                                foundassignmentdates.append(cooldate)

                                            }
                                        }
                                    }
                                }
                                //assignmentsforclass[idiii.1] = vallist
                                self.refreshID = UUID()
                            })

                        }
                    }
            }
        }.onDisappear
        {
            let defaults = UserDefaults.standard
            defaults.set(0, forKey: "countnewassignments")
        }
        
//        if masterRunning.masterRunningNow {
//            MasterClass()
//        }
    }
}
struct NewAssignmentModalView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject var changingDate: DisplayedDate
    
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    @Binding var NewAssignmentPresenting: Bool
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [])
    var assignmentslist: FetchedResults<Assignment>
    
    @State var nameofassignment: String = ""
    @State private var selectedclass: Int
    @State private var preselecteddate: Int
    @State private var assignmenttype = 0
    @State private var hours = 0
    @State private var minutes = 0
    @State var selectedDate: Date
    let assignmenttypes = ["Homework", "Study", "Test", "Essay", "Presentation/Oral", "Exam", "Report/Paper"]
    let hourlist = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60]
    let minutelist = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    
    @State private var createassignmentallowed = true
    @State private var showingAlert = false
    @State private var expandedduedate = false
    @State private var startDate = Date()
    @State private var completedassignment = false
    @State private var assignmentgrade: Double = 1
    var otherclassgradesae: [String] = ["E", "D", "C", "B", "A"]
    var otherclassgradesaf: [String] = ["F", "E", "D", "C", "B", "A"]
    var formatter: DateFormatter
    
    @EnvironmentObject var masterRunning: MasterRunning
    @ObservedObject var textfieldmanager: TextFieldManager = TextFieldManager(blah: "")

    init(NewAssignmentPresenting: Binding<Bool>, selectedClass: Int, preselecteddate: Int) {
        self._NewAssignmentPresenting = NewAssignmentPresenting
        formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        _selectedclass = State(initialValue: selectedClass)
        self._preselecteddate = State(initialValue: preselecteddate)
                
        let lastmondaydate = Calendar.current.date(byAdding: .day, value: 1, to: Date().startOfWeek!)! > Date() ? Calendar.current.date(byAdding: .day, value: -6, to: Date().startOfWeek!)! : Calendar.current.date(byAdding: .day, value: 1, to: Date().startOfWeek!)!
            
        if (preselecteddate == -1)
        {
            self._selectedDate = State(initialValue: Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!))//bugfixtemp
        }
        else
        {
            
            if (Calendar.current.date(byAdding: .day, value: preselecteddate, to: lastmondaydate)! < Date())
            {
                self._selectedDate = State(initialValue: Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!))
            }
            else
            {
                self._selectedDate = State(initialValue: Calendar.current.date(byAdding: .day, value: preselecteddate, to: lastmondaydate)!)
            }
        }
    }
    func getnontrashclasslist() -> [Int]
    {
        var classitylist: [Int] = []
        for (index, classity) in classlist.enumerated()
        {
            if (!classity.isTrash)
            {
                classitylist.append(index)
            }
        }
        return classitylist
    }
    func getgradingscheme() -> String
    {
        if (selectedclass < classlist.count)
        {
            return classlist[selectedclass].gradingscheme
        }
        return "P"
    }
    func getgrademin() -> Double
    {
        let gradeschemeval = self.getgradingscheme()
        if (gradeschemeval[0..<1] == "L")
        {
            return 1
        }
        else if (gradeschemeval[0..<1] == "N")
        {
            return 1
        }
        else
        {
            return 1
        }
    }
    func getgrademax() -> Double
    {
        let gradeschemeval = self.getgradingscheme()
        if (gradeschemeval[0..<1] == "L")
        {
            if (gradeschemeval[3..<4] == "F")
            {
                return 6
            }
            return 5
        }
        else if (gradeschemeval[0..<1] == "N")
        {
            return Double(gradeschemeval[3..<gradeschemeval.count]) ?? 7
        }
        else
        {
            return 100
        }
        
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Assignment Name", text: $textfieldmanager.userInput).keyboardType(.webSearch).onTapGesture {
                        UIApplication.shared.endEditing()
                    }
                }
                
//                Section {
//                    Toggle(isOn: self.$completedassignment) {
//                        Text("Completed Assignment")
//                    }.onTapGesture {
//                        if (!self.completedassignment)
//                         {
//                            self.assignmentgrade = 1
//
//                          //  print(!self.iscompleted)
//                        }
//                        else
//                        {
//
//                            self.selectedDate = Date()
//                        }
//
//
//
//                    }
//                }
                
                if (self.completedassignment)
                {
                    Section {
                        VStack {
                            //Text("Hello")

                            if (self.getgradingscheme()[0..<1] == "N" || self.getgradingscheme()[0..<1] == "L")
                            {
                                HStack {
                                    if (self.getgradingscheme()[0..<1] == "N")
                                    {
                                        Text("Grade: \(assignmentgrade.rounded(.down), specifier: "%.0f")")
                                    }
                                    else
                                    {
                                        if (self.getgradingscheme()[3..<4] == "F")
                                        {
                                            Text("Grade: " + otherclassgradesaf[Int(assignmentgrade.rounded(.down))-1])
                                        }
                                        else
                                        {
                                            Text("Grade: " + otherclassgradesae[Int(assignmentgrade.rounded(.down))-1])
                                        }
                                    }
                                   Spacer()
                                }.frame(height: 30)
                                Slider(value: $assignmentgrade, in: self.getgrademin()...self.getgrademax())
                            }
                            else
                            {
                                HStack {
                                    Text("Grade: \(assignmentgrade.rounded(.down), specifier: "%.0f")")
                                    Spacer()
                                }.frame(height: 30)
                                Slider(value: $assignmentgrade, in: 1...100)

                            }
                            

                        }

                    }
                }
                Section {
                    Picker(selection: $selectedclass, label: Text("Class")) {
                        ForEach(0 ..< getnontrashclasslist().count) {
                            if ($0 < self.getnontrashclasslist().count)
                            {
                                Text(self.classlist[self.getnontrashclasslist()[$0]].name)
                            }
                            
                        }
                    }
//                    ForEach(0 ..< getgradableassignments().count) {
//                        if ($0 < self.getgradableassignments().count)
//                        {
//                            Text(self.assignmentlist[self.getgradableassignments()[$0]].name)
//                        }
//                    }
                }
                Section {
                    Picker(selection: $assignmenttype, label: Text("Type")) {
                        ForEach(0 ..< assignmenttypes.count) {
                            Text(self.assignmenttypes[$0])
                        }
                    }
                }
                
                Section {
                    Text("Assignment Length")
                    HStack {
                        VStack {
                            Picker(selection: $hours, label: Text("Hour")) {
                                ForEach(hourlist.indices) { hourindex in
                                    Text(String(self.hourlist[hourindex]) + (self.hourlist[hourindex] == 1 ? " hour" : " hours"))
                                 }
                             }.pickerStyle(WheelPickerStyle())
                        }.frame(minWidth: 100, maxWidth: .infinity)
                        .clipped()
                        
                        VStack {
                            if hours == 0 {
                                Picker(selection: $minutes, label: Text("Minutes")) {
                                    ForEach(minutelist[6...].indices) { minuteindex in
                                        Text(String(self.minutelist[minuteindex]) + " mins")
                                    }
                                }.pickerStyle(WheelPickerStyle())
                            }
                            
                            else {
                                Picker(selection: $minutes, label: Text("Minutes")) {
                                    ForEach(minutelist.indices) { minuteindex in
                                        Text(String(self.minutelist[minuteindex]) + " mins")
                                    }
                                }.pickerStyle(WheelPickerStyle())
                            }
                        }.frame(minWidth: 100, maxWidth: .infinity)
                        .clipped()
                    }
                }

                Section {


                    if #available(iOS 14.0, *) {
                        Button(action: {
                                self.expandedduedate.toggle()

                        }) {
                            HStack {
                                Text("Due Date").foregroundColor(colorScheme == .light ? Color.black : Color.white)
                                Spacer()
                                Text(formatter.string(from: selectedDate)).foregroundColor(expandedduedate ? Color.blue: Color.gray)
                            }

                        }
                        if (expandedduedate)
                        {
                            VStack {
                                DatePicker("", selection: $selectedDate, in: self.completedassignment ? Date(timeIntervalSince1970: 0)... : Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)..., displayedComponents: [.date, .hourAndMinute]).animation(.spring()).datePickerStyle(WheelDatePickerStyle())
                            }.animation(.spring())
                        }

                    }
                    
                    else {
                        Button(action: {
                                self.expandedduedate.toggle()

                        }) {
                            HStack {
                                Text("Due Date").foregroundColor(Color.black)
                                Spacer()
                                Text(formatter.string(from: selectedDate)).foregroundColor(expandedduedate ? Color.blue: Color.gray)
                            }

                        }
                        if (expandedduedate)
                        {
                            VStack { //change startDate thing to the time-adjusted one (look at iOS 14 implementation
                                MyDatePicker(selection: $selectedDate, starttime: $startDate, dateandtimedisplayed: true).frame(width: UIScreen.main.bounds.size.width-40, height: 200, alignment: .center).animation(nil)
                            }.animation(nil)
                        }
                        
                    }
                }

                Section {
                    Button(action: {
                        self.createassignmentallowed = true
                        
                        for assignment in self.assignmentslist {
                            if assignment.name == self.textfieldmanager.userInput {
                                self.createassignmentallowed = false
                            }
                        }
                        
                        if (self.textfieldmanager.userInput == "")
                        {
                            self.createassignmentallowed = false
                        }

                        if self.createassignmentallowed {
                            if (!self.completedassignment)
                            {
                                let newAssignment = Assignment(context: self.managedObjectContext)
                                newAssignment.completed = false
                                newAssignment.grade = 0
                                newAssignment.subject = self.classlist[self.getnontrashclasslist()[self.selectedclass]].originalname
                                newAssignment.name = self.textfieldmanager.userInput
                                newAssignment.type = self.assignmenttypes[self.assignmenttype]
                                newAssignment.progress = 0
                                newAssignment.duedate = self.selectedDate
                                
                                if (self.hours == 0)
                                {
                                    newAssignment.totaltime = Int64(self.minutelist[self.minutes+6])
                                }
                                else
                                {
                                    newAssignment.totaltime = Int64(60*self.hourlist[self.hours] + self.minutelist[self.minutes])
                                }
                                newAssignment.timeleft = newAssignment.totaltime
                            
                                for classity in self.classlist {
                                    if (classity.originalname == newAssignment.subject) {
                                        newAssignment.color = classity.color
                                        classity.assignmentnumber += 1
                                    }
                                }
                            }
                            else
                            {
                                let newAssignment = Assignment(context: self.managedObjectContext)
                                newAssignment.completed = true
                                newAssignment.grade = Int64(self.assignmentgrade)
                                newAssignment.subject = self.classlist[self.getnontrashclasslist()[self.selectedclass]].originalname
                                newAssignment.name = self.textfieldmanager.userInput
                                newAssignment.type = self.assignmenttypes[self.assignmenttype]
                                newAssignment.progress = 100
                                newAssignment.duedate = self.selectedDate
                                
                                if (self.hours == 0)
                                {
                                    newAssignment.totaltime = Int64(self.minutelist[self.minutes+6])
                                }
                                else
                                {
                                    newAssignment.totaltime = Int64(60*self.hourlist[self.hours] + self.minutelist[self.minutes])
                                }
                                newAssignment.timeleft = 0
                            
                                for classity in self.classlist {
                                    if (classity.originalname == newAssignment.subject) {
                                        newAssignment.color = classity.color
//                                        classity.assignmentnumber += 1
                                    }
                                }
                            }
                            //assignment specific
                           
                            
                            do {
                                try self.managedObjectContext.save()
                            } catch {
                                print(error.localizedDescription)
                            }
                            masterRunning.uniqueAssignmentName = self.textfieldmanager.userInput

                            print("D")
                            masterRunning.masterRunningNow = true
                            masterRunning.displayText = true
                            
                            self.NewAssignmentPresenting = false
                        }
                     
                        else {
                            self.showingAlert = true
                        }
                    }) {
                        Text("Add Assignment")
                    }.alert(isPresented: $showingAlert) {
                        Alert(title: self.nameofassignment == "" ? Text("No Assignment Name Provided") : Text("Assignment Already Exists"), message: self.nameofassignment == "" ? Text("Add an Assignment Name") : Text("Change Assignment Name"), dismissButton: .default(Text("Continue")))
                    }
                }
                
            }.gesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onChanged { _ in
                UIApplication.shared.endEditing()
            }.onEnded { _ in
                UIApplication.shared.endEditing()
            }).navigationBarItems(trailing: Button(action: {self.NewAssignmentPresenting = false}, label: {Text("Cancel")})).navigationTitle("Add Assignment").navigationBarTitleDisplayMode(.inline)
        }
        
//        if masterRunning.masterRunningNow {
//            MasterClass()
//        }
    }
}

extension Color {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
        typealias NativeColor = UIColor
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0

        guard NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
            // You can handle the failure here as you want
            return (0, 0, 0, 0)
        }

        return (r, g, b, o)
    }
}

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }
}

struct NewClassModalView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var googleDelegate: GoogleDelegate

    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [])
    
    var classlist: FetchedResults<Classcool>

    @Binding var NewClassPresenting: Bool
    @State var classnamenonib: String = ""
    @State private var classgroupnameindex = 0
    @State private var classnameindex = 0
    @State private var classlevelindex = 0
    @State private var classtolerancedouble: Double = 3
    
    @State var isIB: Bool = false

    let subjectgroups = ["Group 1: Language and Literature", "Group 2: Language Acquisition", "Group 3: Individuals and Societies", "Group 4: Sciences", "Group 5: Mathematics", "Group 6: The Arts", "Extended Essay", "Theory of Knowledge"]
    
    let groups = [["English A: Literature", "English A: Language and Literatue", "German A: Literature", "French A: Literature", "Spanish A: Literature", "German A: Language and Literatue", "French A: Language and Literatue", "Spanish A: Language and Literatue", "Chinese A: Language and Literature", "Chinese A: Literature"], ["English B", "German B", "French B", "Spanish B", "German Ab Initio", "French Ab Initio", "Spanish Ab Initio", "English Ab Initio", "Mandarin Ab Initio", "Arabic B", "Chinese B"], ["Geography", "History", "Economics", "Psychology", "Global Politics", "Environmental Systems and Societies SL"], ["Biology", "Chemistry", "Physics", "Computer Science", "Design Technology", "Sport Science", "Environmental Systems and Societies SL"], ["Mathematics: Analysis and Approaches", "Mathematics: Applications and Interpretation"], ["Music", "Visual Arts", "Theatre", "Economics", "Psychology", "Biology", "Chemistry", "Physics"], ["Extended Essay"], ["Theory of Knowledge"]]
    
    let shortenedgroups = [["English A: Lit", "English A: Lang & Lit", "German A: Lit", "French A: Lit", "Spanish A: Lit", "German A: Lang & Lit", "French A: Lang & Lit", "Spanish A: Lang & Lit", "Chinese A: Lang & Lit", "Chinese A: Lit"], ["English B", "German B", "French B", "Spanish B", "German Ab Initio", "French Ab Initio", "Spanish Ab Initio", "English Ab Initio", "Mandarin Ab Initio", "Arabic B", "Chinese B"], ["Geography", "History", "Economics", "Psychology", "Global Politics", "ESS SL"], ["Biology", "Chemistry", "Physics", "Computer Science", "Design Technology", "Sport Science", "ESS SL"], ["Mathematics: AA", "Mathematics: AI"], ["Music", "Visual Arts", "Theatre", "Economics", "Psychology", "Biology", "Chemistry", "Physics"], ["EE"], ["TOK"]]
    
    let colorsa = ["one", "two", "three", "four", "five"]
    let colorsb = ["six", "seven", "eight", "nine", "ten"]
    let colorsc = ["eleven", "twelve", "thirteen", "fourteen", "fifteen"]
    
    @State private var coloraselectedindex: Int? = 0
    @State private var colorbselectedindex: Int?
    @State private var colorcselectedindex: Int?
    
    @State private var createclassallowed = true
    @State private var showingAlert = false
    @State var gradingscheme: Int = 0
    @State var gradingschemelist: [String] = []
    
    @State var customcolor1: Color = Color("one")
    @State var customcolor2: Color = Color("one-b")
    @State var customcolorchosen: Bool = false
    @State var linkableclasses = [(String, String)]()
    @State var linkingtogc: Bool = false
    @State var selectedgoogleclassroomclass = 0

    var body: some View {
        NavigationView {
            Form {
                Section {
                    if (self.isIB)
                    {
                        Picker(selection: $classgroupnameindex, label: Text("Subject Group: ")) {
                            ForEach(0 ..< subjectgroups.count, id: \.self) { indexg in
                                Text(self.subjectgroups[indexg]).tag(indexg)
                            }
                        }
                        
                            if classgroupnameindex == 0 {
                                Picker(selection: $classnameindex, label: Text("Subject: ")) {
                                    ForEach(0 ..< groups[0].count, id: \.self) { index in
                                        Text(self.groups[0][index]).tag(index)
                                    }
                                }
                            }

                            else if classgroupnameindex == 1 {
                                Picker(selection: $classnameindex, label: Text("Subject: ")) {
                                    ForEach(0 ..< groups[1].count, id: \.self) { index in
                                        Text(self.groups[1][index]).tag(index)
                                    }
                                }
                            }
                                    
                            else if classgroupnameindex == 2 {
                                Picker(selection: $classnameindex, label: Text("Subject: ")) {
                                    ForEach(0 ..< groups[2].count, id: \.self) { index in
                                        Text(self.groups[2][index]).tag(index)
                                    }
                                }
                            }
                                    
                            else if classgroupnameindex == 3 {
                                Picker(selection: $classnameindex, label: Text("Subject: ")) {
                                    ForEach(0 ..< groups[3].count, id: \.self) { index in
                                        Text(self.groups[3][index]).tag(index)
                                    }
                                }
                            }
                                    
                            else if classgroupnameindex == 4 {
                                Picker(selection: $classnameindex, label: Text("Subject: ")) {
                                    ForEach(0 ..< groups[4].count, id: \.self) { index in
                                        Text(self.groups[4][index]).tag(index)
                                    }
                                }
                            }
                                    
                            else if classgroupnameindex == 5 {
                                Picker(selection: $classnameindex, label: Text("Subject: ")) {
                                    ForEach(0 ..< groups[5].count, id: \.self) { index in
                                        Text(self.groups[5][index]).tag(index)
                                    }
                                }
                            }
                        
                        if !(classgroupnameindex == 6 || classgroupnameindex == 7 || (classgroupnameindex == 3 && classnameindex == 6) || (classgroupnameindex == 2 && classnameindex == 5) || (classgroupnameindex == 1 && classnameindex > 8)) {
                            Picker(selection: $classlevelindex, label: Text("Level")) {
                                Text("SL").tag(0)
                                Text("HL").tag(1)
                            }.pickerStyle(SegmentedPickerStyle())
                        }
                    }
                    else
                    {
                        TextField("Class Name", text: self.$classnamenonib).keyboardType(.default).onTapGesture {
                            UIApplication.shared.endEditing()
                        }
                    }
                }
                Section
                {
                    Button(action:{
                        withAnimation(.spring())
                        {
                            linkingtogc.toggle()
                        }
                    })
                    {
                        HStack
                        {
                            Text("Link to a Google Classroom class")
                            Spacer()
                            Image(systemName: linkingtogc ? "minus" : "plus")//.resizable().aspectRatio(.fit)
                        }
                    }
                    if (linkingtogc && linkableclasses.count > 0)
                    {
                        Picker(selection: $selectedgoogleclassroomclass, label: Text("Select GC Class"))
                        {
                            ForEach(0 ..< linkableclasses.count, id: \.self)
                            {
                                index in
                                Text(linkableclasses[index].1)
                            }
                        }
                    }
                    else if (linkingtogc)
                    {
                        Text("Sign in with Google to use this feature")
                    }
                }
                
//                Section {
//                    VStack {
//                        HStack {
//                            Text("Tolerance: \(classtolerancedouble.rounded(.down), specifier: "%.0f")")
//                            Spacer()
//                        }.frame(height: 30)
//                        Slider(value: $classtolerancedouble, in: 1...5)
//                        ZStack {
//                            Image(systemName: "circle").resizable().frame(width: 45, height: 45)
//                            HStack {
//                                Image(systemName: "circle.fill").resizable().frame(width: 5, height: 5)
//                                Spacer().frame(width: 8)
//                                Image(systemName: "circle.fill").resizable().frame(width: 5, height: 5)
//                            }.padding(.top, -8)
//                            GeometryReader { geometry in
//                                Path { path in
//                                    path.move(to: CGPoint(x: (geometry.size.width / 2) - 9, y: (geometry.size.height / 2) + 7))
//                                    path.addQuadCurve(to: CGPoint(x: (geometry.size.width / 2) + 9, y: (geometry.size.height / 2) + 7), control: CGPoint(x: (geometry.size.width / 2), y: ((geometry.size.height / 2) + 7) + CGFloat(5 * (self.classtolerancedouble - 3))))
//                                }.stroke((colorScheme == .light ? Color.black : Color.white), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
//                            }
//                        }
//                    }.padding(.bottom, 8)
//                }
                
          //      if (gradingschemelist.count > 0) {
                    Section {
                        if (isIB)
                        {
                           
                            if (groups[classgroupnameindex][classnameindex] == "Theory of Knowledge" || groups[classgroupnameindex][classnameindex] == "Extended Essay" )
                            {
                                HStack
                                {
                                    Text("Grading Scheme")
                                    Spacer()
                                    Text("Letter-based: A-E")
                                    
                                }
                            }
                            else
                            {
                                HStack
                                {
                                    Text("Grading Scheme")
                                    Spacer()
                                    Text("Number-based: 1-7")
                                    
                                }
                            }
                        }
                        else
                        {
                            Picker(selection: $gradingscheme, label: Text("Grading Scheme")) {
                                ForEach(0 ..< gradingschemelist.count) {
                                    if (gradingschemelist[$0][0..<1] == "P")
                                    {
                                        Text("Percentage-based")
                                    }
                                    else if (gradingschemelist[$0][0..<1] == "L")
                                    {
                                        Text("Letter-based: " + String(gradingschemelist[$0][1..<gradingschemelist[$0].count]))
                                    }
                                    else
                                    {
                                        Text("Number-based: " + String(gradingschemelist[$0][1..<gradingschemelist[$0].count]))
                                    }                                //Text(gradingschemelist[$0])
                                    
                                }
                            }
                        }
                    }
                   // Text("Grading Scheme: " + self.gradingscheme)
         //       }
                
                Section {
                    HStack {
                        Text("Color Presets").fontWeight(self.customcolorchosen ? .regular : .semibold)
                        
                        Spacer()
                        
                        VStack(spacing: 10) {
                            HStack(spacing: 10) {
                                ForEach(0 ..< 5) { colorindexa in
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color(self.colorsa[colorindexa])).frame(width: 25, height: 25)
                                        RoundedRectangle(cornerRadius: 5, style: .continuous).stroke(colorScheme == .light ? Color.black : Color.white
                                            , lineWidth: (self.coloraselectedindex == colorindexa ? 3 : 1)).frame(width: 25, height: 25)
                                    }.onTapGesture {
                                        self.coloraselectedindex = colorindexa
                                        self.colorbselectedindex = nil
                                        self.colorcselectedindex = nil
                                        self.customcolorchosen = false
                                    }
                                }
                            }
                            HStack(spacing: 10) {
                                ForEach(0 ..< 5) { colorindexb in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color(self.colorsb[colorindexb])).frame(width: 25, height: 25)
                                        RoundedRectangle(cornerRadius: 5, style: .continuous).stroke(colorScheme == .light ? Color.black : Color.white
                                        , lineWidth: (self.colorbselectedindex == colorindexb ? 3 : 1)).frame(width: 25, height: 25)
                                    }.onTapGesture {
                                        self.coloraselectedindex = nil
                                        self.colorbselectedindex = colorindexb
                                        self.colorcselectedindex = nil
                                        self.customcolorchosen = false
                                    }
                                }
                            }
                            HStack(spacing: 10) {
                                ForEach(0 ..< 5) { colorindexc in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color(self.colorsc[colorindexc])).frame(width: 25, height: 25)
                                        RoundedRectangle(cornerRadius: 5, style: .continuous).stroke(colorScheme == .light ? Color.black : Color.white
                                    , lineWidth: (self.colorcselectedindex == colorindexc ? 3 : 1)).frame(width: 25, height: 25)
                                    }.onTapGesture {
                                        self.coloraselectedindex = nil
                                        self.colorbselectedindex = nil
                                        self.colorcselectedindex = colorindexc
                                        self.customcolorchosen = false
                                    }
                                }
                            }
                        }
                    }.contentShape(Rectangle()).onTapGesture {
                        self.customcolorchosen = false
                    }.padding(.vertical, 10)
                    
                    VStack {
                        HStack {
                            Button(action: {
                                self.customcolorchosen.toggle()
                            }) {
                                Text("Custom Gradient").fontWeight(self.customcolorchosen ? .semibold : .regular).foregroundColor(colorScheme == .light ? Color.black : Color.white)
                            }
                            
                            Spacer()
                            
                            if self.customcolorchosen {
                                Image(systemName: "checkmark").foregroundColor(Color.green)
                            }
                        }
                        
                        if self.customcolorchosen {
                            Spacer().frame(height: 17)
                            
                            HStack {
                                VStack {
                                    ColorPicker("Color 1:", selection: $customcolor1, supportsOpacity: false)
                                }
                                
                                Spacer().frame(width: 15)
                                Rectangle().frame(width: 1)
                                Spacer().frame(width: 15)
                                
                                VStack {
                                    ColorPicker("Color 2:", selection: $customcolor2, supportsOpacity: false)
                                }
                            }.animation(.spring())
                        }
                    }.padding(.vertical, 10)
                }
                
               
                Section {
                    VStack {
                        HStack {
                            Text("Preview")
                            Spacer()
                        }
                        
                        ZStack {
                            if self.customcolorchosen {
                                RoundedRectangle(cornerRadius: 25, style: .continuous)
                                    .fill(LinearGradient(gradient: Gradient(colors: [customcolor1, customcolor2]), startPoint: .leading, endPoint: .trailing))
                                    .frame(width: UIScreen.main.bounds.size.width - 80, height: (120))
                            }
                            
                            else {
                                if self.coloraselectedindex != nil {
                                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                                        .fill(LinearGradient(gradient: Gradient(colors: [Color(self.colorsa[self.coloraselectedindex!]), getNextColor(currentColor: self.colorsa[self.coloraselectedindex!])]), startPoint: .leading, endPoint: .trailing))
                                        .frame(width: UIScreen.main.bounds.size.width - 80, height: (120))
                                }
                                else if self.colorbselectedindex != nil {
                                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                                        .fill(LinearGradient(gradient: Gradient(colors: [Color(self.colorsb[self.colorbselectedindex!]), getNextColor(currentColor: self.colorsb[self.colorbselectedindex!])]), startPoint: .leading, endPoint: .trailing))
                                        .frame(width: UIScreen.main.bounds.size.width - 80, height: (120))
                                    
                                }
                                else if self.colorcselectedindex != nil {
                                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                                        .fill(LinearGradient(gradient: Gradient(colors: [Color(self.colorsc[self.colorcselectedindex!]), getNextColor(currentColor: self.colorsc[self.colorcselectedindex!])]), startPoint: .leading, endPoint: .trailing))
                                        .frame(width: UIScreen.main.bounds.size.width - 80, height: (120))
                                }
                            }

                            VStack {
                                HStack {
                                    if (self.isIB)
                                    {
                                        Text(!(self.classgroupnameindex == 6 || self.classgroupnameindex == 7 || (self.classgroupnameindex == 3 && self.classnameindex == 6) || (self.classgroupnameindex == 2 && self.classnameindex == 5) || (self.classgroupnameindex == 1 && self.classnameindex > 8)) ? "\(self.shortenedgroups[self.classgroupnameindex][self.groups[self.classgroupnameindex].count > self.classnameindex ? self.classnameindex : 0]) \(["SL", "HL"][self.classlevelindex])" : "\(self.shortenedgroups[self.classgroupnameindex][self.groups[self.classgroupnameindex].count > self.classnameindex ? self.classnameindex : 0])").font(.system(size: 22)).fontWeight(.bold)
                                    }
                                    else
                                    {
                                        Text(self.classnamenonib).font(.system(size: 22)).fontWeight(.bold)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("No Assignments").font(.body).fontWeight(.light)
                                }
                            }.padding(.horizontal, 25)
                        }
                    }.padding(.top, 8)
                }
                
                Section {
                    Button(action: {
                        var testname = !(self.classgroupnameindex == 6 || self.classgroupnameindex == 7 || (self.classgroupnameindex == 3 && self.classnameindex == 6) || (self.classgroupnameindex == 2 && self.classnameindex == 5) || (self.classgroupnameindex == 1 && self.classnameindex > 8)) ? "\(self.groups[self.classgroupnameindex][self.classnameindex]) \(["SL", "HL"][self.classlevelindex])" : "\(self.groups[self.classgroupnameindex][self.classnameindex])"
                        
                        var shortenedtestname =  !(self.classgroupnameindex == 6 || self.classgroupnameindex == 7 || (self.classgroupnameindex == 3 && self.classnameindex == 6) || (self.classgroupnameindex == 2 && self.classnameindex == 5) || (self.classgroupnameindex == 1 && self.classnameindex > 8)) ? "\(self.shortenedgroups[self.classgroupnameindex][self.classnameindex]) \(["SL", "HL"][self.classlevelindex])" : "\(self.shortenedgroups[self.classgroupnameindex][self.classnameindex])"
                        
                        if (!self.isIB)
                        {
                            testname = self.classnamenonib
                            shortenedtestname = self.classnamenonib
                        }
                        self.createclassallowed = true
                        
                        for classity in self.classlist {
                            if (classity.name == shortenedtestname || classity.name == testname) {
                                // print("sdfds")
                                if (!classity.isTrash)
                                {
                                    self.createclassallowed = false
                                }
                            }
                        }
                        
                        if testname == "" {
                            self.createclassallowed = false
                        }

                        if self.createclassallowed {
                            let newClass = Classcool(context: self.managedObjectContext)
                            newClass.tolerance = Int64(self.classtolerancedouble.rounded(.down))
                            newClass.name = shortenedtestname
                            newClass.assignmentnumber = 0
                            newClass.originalname = testname
                            newClass.isTrash = false
                            newClass.googleclassroomid = ""
                            if (linkingtogc && linkableclasses.count > 0)
                            {
                                newClass.googleclassroomid = linkableclasses[selectedgoogleclassroomclass].0
                            }
                            if (gradingschemelist.count > 0)
                            {
                                newClass.gradingscheme = self.gradingschemelist[self.gradingscheme]
                            }
                            else
                            {
                                newClass.gradingscheme = (groups[classgroupnameindex][classnameindex] == "Extended Essay" || groups[classgroupnameindex][classnameindex] == "Theory of Knowledge" ) ? "LA-E" : "N1-7"
                            }
                         //   newClass.isarchived = false
                            
                            if self.customcolorchosen {
                                let r1 = String(format: "%.3f", abs(customcolor1.components.red))
                                let g1 = String(format: "%.3f", abs(customcolor1.components.green))
                                let b1 = String(format: "%.3f", abs(customcolor1.components.blue))
                                var r2 = String(format: "%.3f", abs(customcolor2.components.red))
                                var g2 = String(format: "%.3f", abs(customcolor2.components.green))
                                var b2 = String(format: "%.3f", abs(customcolor2.components.blue))
                                
                                if r1 == r2 {
                                    if r2 == "1.000" {
                                        r2 = String(Double(r2)! - 0.001)
                                    }
                                    
                                    else {
                                        r2 = String(Double(r2)! + 0.001)
                                    }
                                }
                                
                                else if g1 == g2 {
                                    if g2 == "1.000" {
                                        g2 = String(Double(g2)! - 0.001)
                                    }
                                    
                                    else {
                                        g2 = String(Double(g2)! + 0.001)
                                    }
                                }
                                
                                else if b1 == b2 {
                                    if b2 == "1.000" {
                                        b2 = String(Double(b2)! - 0.001)
                                    }
                                    
                                    else {
                                        b2 = String(Double(b2)! + 0.001)
                                    }
                                }
                                
                                newClass.color = "rgbcode1-\(r1)-\(g1)-\(b1)-rgbcode2-\(r2)-\(g2)-\(b2)"
                            }
                            
                            else {
                                if self.coloraselectedindex != nil {
                                    newClass.color = self.colorsa[self.coloraselectedindex!]
                                }
                                else if self.colorbselectedindex != nil {
                                    newClass.color = self.colorsb[self.colorbselectedindex!]
                                }
                                else if self.colorcselectedindex != nil {
                                    newClass.color = self.colorsc[self.colorcselectedindex!]
                                }
                            }

                            do {
                                try self.managedObjectContext.save()
                            } catch {
                                print(error.localizedDescription)
                            }
                            
                            self.NewClassPresenting = false
                        }
                            
                        else {
                            self.showingAlert = true
                        }
                    }) {
                        Text("Add Class")
                    }
                }
            }.gesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onChanged { _ in
                UIApplication.shared.endEditing()
            }.onEnded { _ in
                UIApplication.shared.endEditing()
            }).navigationBarItems(leading: Button(action: {self.NewClassPresenting = false}, label: {Text("Cancel")}), trailing:  Button(action: {
                var testname = !(self.classgroupnameindex == 6 || self.classgroupnameindex == 7 || (self.classgroupnameindex == 3 && self.classnameindex == 6) || (self.classgroupnameindex == 2 && self.classnameindex == 5) || (self.classgroupnameindex == 1 && self.classnameindex > 8)) ? "\(self.groups[self.classgroupnameindex][self.classnameindex]) \(["SL", "HL"][self.classlevelindex])" : "\(self.groups[self.classgroupnameindex][self.classnameindex])"
                
                var shortenedtestname =  !(self.classgroupnameindex == 6 || self.classgroupnameindex == 7 || (self.classgroupnameindex == 3 && self.classnameindex == 6) || (self.classgroupnameindex == 2 && self.classnameindex == 5) || (self.classgroupnameindex == 1 && self.classnameindex > 8)) ? "\(self.shortenedgroups[self.classgroupnameindex][self.classnameindex]) \(["SL", "HL"][self.classlevelindex])" : "\(self.shortenedgroups[self.classgroupnameindex][self.classnameindex])"
                
                if (!self.isIB)
                {
                    testname = self.classnamenonib
                    shortenedtestname = self.classnamenonib
                }
                self.createclassallowed = true
                
                for classity in self.classlist {
                    if (classity.name == shortenedtestname || classity.name == testname) {
                        // print("sdfds")
                        if (!classity.isTrash)
                        {
                            self.createclassallowed = false
                        }
                    }
                }
                
                if testname == "" {
                    self.createclassallowed = false
                }

                if self.createclassallowed {
                    let newClass = Classcool(context: self.managedObjectContext)
                    newClass.tolerance = Int64(self.classtolerancedouble.rounded(.down))
                    newClass.name = shortenedtestname
                    newClass.assignmentnumber = 0
                    newClass.originalname = testname
                    newClass.isTrash = false
                    newClass.googleclassroomid = ""
                    if (linkingtogc && linkableclasses.count > 0)
                    {
                        newClass.googleclassroomid = linkableclasses[selectedgoogleclassroomclass].0
                    }
                    if (gradingschemelist.count > 0)
                    {
                        newClass.gradingscheme = self.gradingschemelist[self.gradingscheme]
                    }
                    else
                    {
                        newClass.gradingscheme = (groups[classgroupnameindex][classnameindex] == "Extended Essay" || groups[classgroupnameindex][classnameindex] == "Theory of Knowledge" ) ? "LA-E" : "N1-7"
                    }
                 //   newClass.isarchived = false
                    
                    if self.customcolorchosen {
                        let r1 = String(format: "%.3f", abs(customcolor1.components.red))
                        let g1 = String(format: "%.3f", abs(customcolor1.components.green))
                        let b1 = String(format: "%.3f", abs(customcolor1.components.blue))
                        var r2 = String(format: "%.3f", abs(customcolor2.components.red))
                        var g2 = String(format: "%.3f", abs(customcolor2.components.green))
                        var b2 = String(format: "%.3f", abs(customcolor2.components.blue))
                        
                        if r1 == r2 {
                            if r2 == "1.000" {
                                r2 = String(Double(r2)! - 0.001)
                            }
                            
                            else {
                                r2 = String(Double(r2)! + 0.001)
                            }
                        }
                        
                        else if g1 == g2 {
                            if g2 == "1.000" {
                                g2 = String(Double(g2)! - 0.001)
                            }
                            
                            else {
                                g2 = String(Double(g2)! + 0.001)
                            }
                        }
                        
                        else if b1 == b2 {
                            if b2 == "1.000" {
                                b2 = String(Double(b2)! - 0.001)
                            }
                            
                            else {
                                b2 = String(Double(b2)! + 0.001)
                            }
                        }
                        
                        newClass.color = "rgbcode1-\(r1)-\(g1)-\(b1)-rgbcode2-\(r2)-\(g2)-\(b2)"
                    }
                    
                    else {
                        if self.coloraselectedindex != nil {
                            newClass.color = self.colorsa[self.coloraselectedindex!]
                        }
                        else if self.colorbselectedindex != nil {
                            newClass.color = self.colorsb[self.colorbselectedindex!]
                        }
                        else if self.colorcselectedindex != nil {
                            newClass.color = self.colorsc[self.colorcselectedindex!]
                        }
                    }

                    do {
                        try self.managedObjectContext.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                    self.NewClassPresenting = false
                }
                    
                else {
                    self.showingAlert = true
                }
            }) {
                Text("Add")
            }).navigationTitle("Add Class").navigationBarTitleDisplayMode(.inline).alert(isPresented: $showingAlert) {
                Alert(title: Text("Class Already Exists"), message: Text("Change Class"), dismissButton: .default(Text("Continue")))
            }
        }.onAppear()
        {
            let defaults = UserDefaults.standard
            let ibval = defaults.object(forKey: "isIB") as? Bool ?? false
            self.isIB = ibval
            if (!isIB)
            {
                let gradingscheme2 = defaults.object(forKey: "savedgradingschemes") as? [String] ?? []
                self.gradingschemelist = gradingscheme2
            }
            
            GIDSignIn.sharedInstance().restorePreviousSignIn()
            if (googleDelegate.signedIn)
            {
               // defaults.set(true, forKey: "accessedclassroom")
                var partiallist: [(String, String)] = []
                
                let service = GTLRClassroomService()
                service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
                
                let coursesquery = GTLRClassroomQuery_CoursesList.query()

                coursesquery.pageSize = 1000
                service.executeQuery(coursesquery, completionHandler: {(ticket, stuff, error) in
                    let stuff1 = stuff as! GTLRClassroom_ListCoursesResponse

                    for course in stuff1.courses! {
                        if course.courseState == kGTLRClassroom_Course_CourseState_Active {
                            var found = false
                            for classity in classlist
                            {
                                if (classity.googleclassroomid == course.identifier!)
                                {
                                    found = true
                                }
                            }
                            if (!found)
                            {
                                partiallist.append((course.identifier!, course.name!))
                            }
                        }
                    }
                    
                })
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(2000)) {
                    linkableclasses = partiallist
//                    print(linkableclasses)

                }
            
            }
        }
    }
    func getNextColor(currentColor: String) -> Color {
        let colorlist = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "one"]
        let existinggradients = ["one", "two", "three", "five", "six", "eleven","thirteen", "fourteen", "fifteen"]
        if (existinggradients.contains(currentColor))
        {
            return Color(currentColor + "-b")
        }
        for color in colorlist {
            if (color == currentColor)
            {
                return Color(colorlist[colorlist.firstIndex(of: color)! + 1])
            }
        }
        return Color("one")
    }
}

struct NewOccupiedtimeModalView: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    var body: some View {
        Text("new occupied time")
    }
}


struct MyDatePicker: UIViewRepresentable {
    @Binding var selection: Date
    @Binding var starttime: Date
    var dateandtimedisplayed: Bool

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIView(context: UIViewRepresentableContext<MyDatePicker>) -> UIDatePicker {
        let picker = UIDatePicker()
        picker.addTarget(context.coordinator, action: #selector(Coordinator.dateChanged), for: .valueChanged)
        picker.minuteInterval = 5
        picker.datePickerMode = dateandtimedisplayed ? .dateAndTime : .time
        picker.minimumDate = starttime
        return picker
    }

    func updateUIView(_ picker: UIDatePicker, context: UIViewRepresentableContext<MyDatePicker>) {
        picker.date = selection
        picker.minimumDate = starttime

    }

    class Coordinator {
        let datePicker: MyDatePicker
        init(_ datePicker: MyDatePicker) {
            self.datePicker = datePicker
        }

        @objc func dateChanged(_ sender: UIDatePicker) {
            datePicker.selection = sender.date
        }
    }
}

class FreeTimeNavigator: ObservableObject {
    @Published var updateview: Bool = false
}

struct NewFreetimeModalView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var repeatlist: [String] = ["Every Monday", "Every Tuesday", "Every Wednesday", "Every Thursday", "Every Friday", "Every Saturday", "Every Sunday"]
    @State private var selection: Set<String> = ["None"]
    @State var daylist: [String] = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    @FetchRequest(entity: Freetime.entity(), sortDescriptors: [])
    var freetimelist: FetchedResults<Freetime>
    @Binding var NewFreetimePresenting: Bool
    @State private var selectedstartdatetime = Date()
    @State private var selectedenddatetime = Date()
    @State private var expandedstart = false
    @State private var expandedend = false
    @State private var selectedDate = Date()
    let repeats = ["None", "Daily", "Weekly"]
    @State private var selectedrepeat = 0
    var formatter: DateFormatter
    @State var daysNum: [Int] = []
    @State private var starttime = Date(timeIntervalSince1970: 0)
    @ObservedObject var freetimenavigator: FreeTimeNavigator = FreeTimeNavigator()
    
    @EnvironmentObject var masterRunning: MasterRunning
    
    init(NewFreetimePresenting: Binding<Bool>) {
        self._NewFreetimePresenting = NewFreetimePresenting
        formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
    }
    
    private func selectDeselect(_ singularassignment: String) {
        if selection.contains(singularassignment) {
            selection.remove(singularassignment)
        } else {
            selection.insert(singularassignment)
        }
    }
    
    private func repetitionTextCreator(_ selections: Set<String>) -> String {
        var repetitionText = ""
        var weekdays = false
        var weekends = false
        if (self.selection.contains("None")) {
            repetitionText = "None"
            return repetitionText
        }
        if (self.selection.contains("Every Monday")) {
            repetitionText += "Mondays, "
        }
        if (self.selection.contains("Every Tuesday")) {
            repetitionText += "Tuesdays, "
        }
        if (self.selection.contains("Every Wednesday")) {
            repetitionText += "Wednesdays, "
        }
        if (self.selection.contains("Every Thursday")) {
            repetitionText += "Thursdays, "
        }
        if (self.selection.contains("Every Friday")) {
            repetitionText += "Fridays, "
        }
        if (self.selection.contains("Every Saturday")) {
            repetitionText += "Saturdays, "
        }
        if (self.selection.contains("Every Sunday")) {
            repetitionText += "Sundays, "
        }
        
        if repetitionText.contains("Mondays, Tuesdays, Wednesdays, Thursdays, Fridays") {
            weekdays = true
        }
        
        if repetitionText.contains("Saturdays, Sundays") {
            weekends = true
        }
                
        if weekdays || weekends {
            if weekdays && weekends {
                repetitionText = "Daily  "
            }
            
            else if weekdays {
                repetitionText = repetitionText.replacingOccurrences(of: "Mondays, Tuesdays, Wednesdays, Thursdays, Fridays", with: "Weekdays")
            }
            
            else if weekends {
                repetitionText = repetitionText.replacingOccurrences(of: "Saturdays, Sundays", with: "Weekends")
            }
        }
            
        if repetitionText == "" {
            repetitionText = "Never"
        }
            
        else {
            repetitionText = String(repetitionText.dropLast().dropLast())
        }
        
        return repetitionText
    }
    
    @State var showingfreetimedetailview = false
    
    @State private var hour = 1
    @State private var minute = 0
    @State var changeendtime = false
    @State var showingalert = false
    @State var createfreetimeallowed = true
    let minutes = [0, 15, 30, 45]

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        if #available(iOS 14.0, *) {
                            Button(action: {
                                if (!self.expandedstart)
                                {
                                    changeendtime = true
                                }
                                    self.expandedstart.toggle()

                            }) {
                                HStack {
                                    Text("Select start time").foregroundColor(colorScheme == .light ? Color.black : Color.white)
                                    Spacer()
                                    Text(formatter.string(from: selectedstartdatetime)).foregroundColor(expandedstart ? Color.blue: Color.gray)
                                }

                            }
                            if (expandedstart)
                            {
                                VStack {
                                    DatePicker("", selection: $selectedstartdatetime, in: starttime..., displayedComponents: .hourAndMinute).animation(.spring()).datePickerStyle(WheelDatePickerStyle())
                                }.animation(.spring())
                            }

                        } else {
                            Button(action: {
                                
                                if (!self.expandedstart)
                                {
                                    changeendtime = true
                                }
                                    self.expandedstart.toggle()

                            }) {
                                HStack {
                                    Text("Select start time").foregroundColor(colorScheme == .light ? Color.black : Color.white)
                                    Spacer()
                                    Text(formatter.string(from: selectedstartdatetime)).foregroundColor(expandedstart ? Color.blue: Color.gray)
                                }

                            }
                            if (expandedstart)
                            {
                                VStack {
                                    MyDatePicker(selection: $selectedstartdatetime, starttime: $starttime, dateandtimedisplayed: false).frame(width: UIScreen.main.bounds.size.width-40, height: 200, alignment: .center).animation(nil)
                                }.animation(nil)
                            }
                            
                        }
                    }
                    
                    Section {
                        if #available(iOS 14.0, *) {
                            Button(action: {
                                if (changeendtime)
                                {
                                    selectedenddatetime = Date(timeInterval: 3600, since: selectedstartdatetime)
                                    changeendtime = false
                                }
                                    self.expandedend.toggle()

                            }) {
                                HStack {
                                    Text("Select end time").foregroundColor(colorScheme == .light ? Color.black : Color.white)
                                    Spacer()
                                    Text(formatter.string(from: selectedenddatetime)).foregroundColor(expandedend ? Color.blue: Color.gray)
                                }

                            }
                            if (expandedend)
                            {
                                VStack {
                                    DatePicker("", selection: $selectedenddatetime, in: selectedstartdatetime..., displayedComponents: .hourAndMinute).animation(.spring()).datePickerStyle(WheelDatePickerStyle())
                                }.animation(.spring())
                            }

                        }
                    else {
                            Button(action: {
                                if (changeendtime)
                                {
                                    selectedenddatetime = Date(timeInterval: 3600, since: selectedstartdatetime)
                                    changeendtime = false
                                }
                                    self.expandedend.toggle()

                            }) {
                                HStack {
                                    Text("Select end time").foregroundColor(colorScheme == .light ? Color.black : Color.white)
                                    Spacer()
                                    Text(formatter.string(from: selectedenddatetime)).foregroundColor(expandedend ? Color.blue: Color.gray)
                                }

                            }
                            if (expandedend)
                            {
                                VStack {
                                    MyDatePicker(selection: $selectedenddatetime, starttime: $selectedstartdatetime, dateandtimedisplayed: false).frame(width: UIScreen.main.bounds.size.width-40, height: 200, alignment: .center).animation(nil)
                                }.animation(nil)
                            }
                            
                        }
                    }

                    Section {
                        HStack {
                            Text("Repeat").frame(height: 50)
                            Spacer()
                            
                            Text(repetitionTextCreator(self.selection)).foregroundColor(colorScheme == .light ? Color.gray : Color.white)
                        }
                    
                        List {
                            HStack {
                                 Button(action: {
                                    if (self.selection.count != 0) {
                                        freetimenavigator.updateview.toggle()
                                        self.selection.removeAll()
                                        self.selectDeselect("None")
                                    }
                                     
                                 }) {
                                    Text("None").foregroundColor(colorScheme == .light ? Color.black : Color.white).fontWeight(.light)
                                 }
                                
                                 if (self.selection.contains("None")) {
                                     Spacer()
                                     Image(systemName: "checkmark").foregroundColor(.blue)
                                 }
                             }
                            ForEach(self.repeatlist,  id: \.self) { repeatoption in
                                VStack(alignment: .leading) {
                                    HStack {
                                        Button(action: {
                                            freetimenavigator.updateview.toggle()

                                            self.selectDeselect(repeatoption)
                                            if (self.selection.count==0) {
                                                self.selectDeselect("None")
                                            }
                                            else if (self.selection.contains("None")) {
                                                self.selectDeselect("None")
                                            }
                                            
                                        }) {
                                            Text(repeatoption).foregroundColor(colorScheme == .light ? Color.black : Color.white).fontWeight(.light)
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
                    Section {
                        if (selection.contains("None"))
                        {
                            DatePicker("Select date", selection: $selectedDate, in: Date(timeIntervalSince1970: 0)..., displayedComponents: .date)
                        }
                    }
                    Section {
                        Button(action: {
                            self.createfreetimeallowed = true
                            if (self.selection.contains("None"))
                            {
                                let calendar = Calendar.current
                                let dateComponents = calendar.dateComponents([.day, .month, .year], from: self.selectedDate)
                                let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: self.selectedstartdatetime)
                                 
                                var newComponents = DateComponents()
                                newComponents.timeZone = .current
                                newComponents.day = dateComponents.day
                                newComponents.month = dateComponents.month
                                newComponents.year = dateComponents.year
                                newComponents.hour = timeComponents.hour
                                newComponents.minute = timeComponents.minute
                                newComponents.second = timeComponents.second
                                                                 
                                let timeComponents2 = calendar.dateComponents([.hour, .minute, .second], from: self.selectedenddatetime)
                                
                                var newComponents2 = DateComponents()
                                newComponents2.day = dateComponents.day
                                newComponents2.month = dateComponents.month
                                newComponents2.year = dateComponents.year
                                newComponents2.hour = timeComponents2.hour
                                newComponents2.minute = timeComponents2.minute
                                newComponents2.second = timeComponents2.second
                                
                                let startingval = calendar.date(from: newComponents)!
                                for freetime in freetimelist {
                                    if ((!freetime.monday && !freetime.tuesday && !freetime.wednesday && !freetime.thursday && !freetime.friday && !freetime.saturday && !freetime.sunday))
                                    {
                                        if (Calendar.current.startOfDay(for: startingval) == Calendar.current.startOfDay(for: freetime.startdatetime))
                                        {
                                            let setstartminutes = Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for: self.selectedstartdatetime), to: self.selectedstartdatetime).minute!
                                            let setendminutes = Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for: self.selectedenddatetime), to: self.selectedenddatetime).minute!
                                            let foundstartminutes = Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for:freetime.startdatetime), to: freetime.startdatetime).minute!
                                            let foundendminutes = Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for:freetime.enddatetime), to: freetime.enddatetime).minute!
                                            if ((setstartminutes > foundstartminutes && setstartminutes < foundendminutes) || (setendminutes > foundstartminutes && setendminutes < foundendminutes) || (setstartminutes < foundstartminutes && setendminutes > foundendminutes) || (setstartminutes == foundstartminutes && setendminutes == foundendminutes))
                                            {
                                                self.createfreetimeallowed = false
                                                break
                                            }
                                        }

                                    }
                                }
                                let dayval = self.daylist[(Calendar.current.component(.weekday, from: startingval) - 1)]
                                for freetime in freetimelist {
                                    let setstartminutes = Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for: self.selectedstartdatetime), to: self.selectedstartdatetime).minute!
                                    let setendminutes = Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for: self.selectedenddatetime), to: self.selectedenddatetime).minute!
                                    let foundstartminutes = Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for:freetime.startdatetime), to: freetime.startdatetime).minute!
                                    let foundendminutes = Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for:freetime.enddatetime), to: freetime.enddatetime).minute!
                                    if (dayval == "Sunday")
                                    {
                                        if (freetime.sunday)
                                        {
                                            if ((setstartminutes > foundstartminutes && setstartminutes < foundendminutes) || (setendminutes > foundstartminutes && setendminutes < foundendminutes) || (setstartminutes < foundstartminutes && setendminutes > foundendminutes) || (setstartminutes == foundstartminutes && setendminutes == foundendminutes))
                                            {
                                                self.createfreetimeallowed = false
                                                break
                                            }
                                        }
                                    }
                                    else if (dayval == "Monday")
                                    {
                                        if (freetime.monday)
                                        {
                                            if ((setstartminutes > foundstartminutes && setstartminutes < foundendminutes) || (setendminutes > foundstartminutes && setendminutes < foundendminutes) || (setstartminutes < foundstartminutes && setendminutes > foundendminutes) || (setstartminutes == foundstartminutes && setendminutes == foundendminutes))
                                            {
                                                self.createfreetimeallowed = false
                                                break
                                            }
                                        }
                                    }
                                    else if (dayval == "Tuesday")
                                    {
                                        if (freetime.tuesday)
                                        {
                                            if ((setstartminutes > foundstartminutes && setstartminutes < foundendminutes) || (setendminutes > foundstartminutes && setendminutes < foundendminutes) || (setstartminutes < foundstartminutes && setendminutes > foundendminutes) || (setstartminutes == foundstartminutes && setendminutes == foundendminutes))
                                            {
                                                self.createfreetimeallowed = false
                                                break
                                            }
                                        }
                                    }
                                    else if (dayval == "Wednesday")
                                    {
                                        if (freetime.wednesday)
                                        {
                                            if ((setstartminutes > foundstartminutes && setstartminutes < foundendminutes) || (setendminutes > foundstartminutes && setendminutes < foundendminutes) || (setstartminutes < foundstartminutes && setendminutes > foundendminutes) || (setstartminutes == foundstartminutes && setendminutes == foundendminutes))
                                            {
                                                self.createfreetimeallowed = false
                                                break
                                            }
                                        }
                                    }
                                    else if (dayval == "Thursday")
                                    {
                                        if (freetime.thursday)
                                        {
                                            if ((setstartminutes > foundstartminutes && setstartminutes < foundendminutes) || (setendminutes > foundstartminutes && setendminutes < foundendminutes) || (setstartminutes < foundstartminutes && setendminutes > foundendminutes) || (setstartminutes == foundstartminutes && setendminutes == foundendminutes))
                                            {
                                                self.createfreetimeallowed = false
                                                break
                                            }
                                        }
                                    }
                                    else if (dayval == "Friday")
                                    {
                                        if (freetime.friday)
                                        {
                                            if ((setstartminutes > foundstartminutes && setstartminutes < foundendminutes) || (setendminutes > foundstartminutes && setendminutes < foundendminutes) || (setstartminutes < foundstartminutes && setendminutes > foundendminutes) || (setstartminutes == foundstartminutes && setendminutes == foundendminutes))
                                            {
                                                self.createfreetimeallowed = false
                                                break
                                            }
                                        }
                                    }
                                    else if (dayval == "Saturday")
                                    {
                                        if (freetime.saturday)
                                        {
                                            if ((setstartminutes > foundstartminutes && setstartminutes < foundendminutes) || (setendminutes > foundstartminutes && setendminutes < foundendminutes) || (setstartminutes < foundstartminutes && setendminutes > foundendminutes) || (setstartminutes == foundstartminutes && setendminutes == foundendminutes))
                                            {
                                                self.createfreetimeallowed = false
                                                break
                                            }
                                        }
                                    }
                                    
                                }
                            }
                            else
                            {
                                for freetime in freetimelist {
                                    if ((freetime.monday && self.selection.contains("Every Monday")) || (freetime.tuesday && self.selection.contains("Every Tuesday")) || (freetime.wednesday && self.selection.contains("Every Wednesday")) || (freetime.thursday && self.selection.contains("Every Thursday")) || (freetime.friday && self.selection.contains("Every Friday")) || (freetime.saturday && self.selection.contains("Every Saturday")) || (freetime.sunday && self.selection.contains("Every Sunday")))
                                    {
                                        let setstartminutes = Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for: self.selectedstartdatetime), to: self.selectedstartdatetime).minute!
                                        let setendminutes = Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for: self.selectedenddatetime), to: self.selectedenddatetime).minute!
                                        let foundstartminutes = Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for:freetime.startdatetime), to: freetime.startdatetime).minute!
                                        let foundendminutes = Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for:freetime.enddatetime), to: freetime.enddatetime).minute!
                                        if ((setstartminutes > foundstartminutes && setstartminutes < foundendminutes) || (setendminutes > foundstartminutes && setendminutes < foundendminutes) || (setstartminutes < foundstartminutes && setendminutes > foundendminutes) || (setstartminutes == foundstartminutes && setendminutes == foundendminutes))
                                        {
                                            self.createfreetimeallowed = false
                                            break
                                        }
                                    }
                                }
                            }
                            if (self.createfreetimeallowed)
                            {
                                let newFreetime = Freetime(context: self.managedObjectContext)

                                if (self.selection.contains("None")) {
                                    let calendar = Calendar.current
                                    let dateComponents = calendar.dateComponents([.day, .month, .year], from: self.selectedDate)
                                    let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: self.selectedstartdatetime)
                                     
                                    var newComponents = DateComponents()
                                    newComponents.timeZone = .current
                                    newComponents.day = dateComponents.day
                                    newComponents.month = dateComponents.month
                                    newComponents.year = dateComponents.year
                                    newComponents.hour = timeComponents.hour
                                    newComponents.minute = timeComponents.minute
                                    newComponents.second = 0
                                     
                                    newFreetime.startdatetime = calendar.date(from: newComponents)!
                                    newFreetime.tempstartdatetime = calendar.date(from: newComponents)!
                                    let timeComponents2 = calendar.dateComponents([.hour, .minute, .second], from: self.selectedenddatetime)
                                    
                                    var newComponents2 = DateComponents()
                                    newComponents2.day = dateComponents.day
                                    newComponents2.month = dateComponents.month
                                    newComponents2.year = dateComponents.year
                                    newComponents2.hour = timeComponents2.hour
                                    newComponents2.minute = timeComponents2.minute
                                    newComponents2.second = 0
                                    
                                    newFreetime.enddatetime = calendar.date(from: newComponents2)!
                                    newFreetime.tempenddatetime =  calendar.date(from: newComponents2)!
                                }
     
                                else {
                                    let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: Date(timeIntervalSince1970: 0))
                                    let timeComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: self.selectedstartdatetime)
                                    let timeComponents2 = Calendar.current.dateComponents([.hour, .minute, .second], from: self.selectedenddatetime)
                                    var newComponents = DateComponents()
                                    newComponents.timeZone = .current
                                    newComponents.day = dateComponents.day
                                    newComponents.month = dateComponents.month
                                    newComponents.year = dateComponents.year
                                    newComponents.hour = timeComponents.hour
                                    newComponents.minute = timeComponents.minute
                                    newComponents.second = 0
                                    
                                    var newComponents2 = DateComponents()
                                    newComponents2.day = dateComponents.day
                                    newComponents2.month = dateComponents.month
                                    newComponents2.year = dateComponents.year
                                    newComponents2.hour = timeComponents2.hour
                                    newComponents2.minute = timeComponents2.minute
                                    newComponents2.second = 0
                                    
                                    newFreetime.startdatetime = Calendar.current.date(from: newComponents)!
                                    newFreetime.tempstartdatetime = Calendar.current.date(from: newComponents)!
                                    
                                    newFreetime.enddatetime = Calendar.current.date(from: newComponents2)!
                                    newFreetime.tempenddatetime = Calendar.current.date(from: newComponents2)!
                                }
                                
                                newFreetime.monday = false
                                newFreetime.tuesday = false
                                newFreetime.wednesday = false
                                newFreetime.thursday = false
                                newFreetime.friday = false
                                newFreetime.saturday = false
                                newFreetime.sunday = false
                                
                                if (self.selection.contains("Every Monday")) {
                                    newFreetime.monday = true
                                }
                                if (self.selection.contains("Every Tuesday"))
                                {
                                    newFreetime.tuesday = true
                                }
                                if (self.selection.contains("Every Wednesday"))
                                {
                                    newFreetime.wednesday = true
                                }
                                if (self.selection.contains("Every Thursday"))
                                {
                                    newFreetime.thursday = true
                                }
                                if (self.selection.contains("Every Friday"))
                                {
                                    newFreetime.friday = true
                                }
                                if (self.selection.contains("Every Saturday"))
                                {
                                    newFreetime.saturday = true
                                }
                                if (self.selection.contains("Every Sunday"))
                                {
                                    newFreetime.sunday = true
                                }

                                do {
                                    try self.managedObjectContext.save()
                                } catch {
                                    print(error.localizedDescription)
                                }
                                
//                                print("E")
                                //not being used
//                                masterRunning.masterRunningNow = true
                                
                                self.NewFreetimePresenting = false
                            }
                            else
                            {
                                self.showingalert = true
                            }
                        }) {
                            Text("Add Free Time")
                        }.alert(isPresented: $showingalert) {
                            Alert(title: Text("Overlapping Free Times"), message: Text("Change Free Time so it doesn't overlap with existing Free Times"), dismissButton: .default(Text("Continue")))
                        }
                    }
                }.frame(height: UIScreen.main.bounds.size.height*3/4)
                VStack {
                    Divider().frame(width: UIScreen.main.bounds.size.width-20, height: 3)
                    Spacer().frame(height:10)
                    NavigationLink(destination: FreetimeDetailView().environmentObject(self.masterRunning), isActive: self.$showingfreetimedetailview) {
                        EmptyView()
                    }
                    
                        Button(action:{self.showingfreetimedetailview.toggle()})
                        {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color("graphbackgroundtop")).frame(width: UIScreen.main.bounds.size.width-40, height: 40)
                                HStack {
                                    Text("View & Delete Free Times")
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundColor(colorScheme == .light ? Color.black : Color.white)
                                }.padding(.horizontal, 20)
                            }
                        }.buttonStyle(PlainButtonStyle()).foregroundColor(colorScheme == .light ? Color.black : Color.white).frame(width: UIScreen.main.bounds.size.width-40)
                    
                }
            }.navigationBarItems(trailing: Button(action: {self.NewFreetimePresenting = false}, label: {Text("Cancel")})).navigationTitle("Add Free Time").navigationBarTitleDisplayMode(.inline)
        }
        
//        if masterRunning.masterRunningNow {
//            MasterClass()
//        }
    }

}

struct FreetimeDetailView: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    @FetchRequest(entity: Freetime.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Freetime.startdatetime, ascending: true)])
    var freetimelist: FetchedResults<Freetime>
    var formatter: DateFormatter
    var formatter2: DateFormatter
    @State private var selection: Set<String> = []
    
    @EnvironmentObject var masterRunning: MasterRunning
    
    var daylist = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday", "One-off Dates"]
    
    init() {
        formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter2 = DateFormatter()
        formatter2.dateStyle = .short
        formatter2.timeStyle = .none
        
    }
    
    private func selectDeselect(_ singularassignment: String) {
        if selection.contains(singularassignment) {
            selection.remove(singularassignment)
        } else {
            selection.insert(singularassignment)
        }
    }
    
    var body: some View {
        List {
            VStack(alignment: .leading, spacing: 3) {
                Text("View and Delete Free Times").font(.title2)
                Text("Click on a Day to view all free times on that day. Swipe left on a freetime to delete it.").fontWeight(.light)
            }.frame(width: UIScreen.main.bounds.size.width - 20).offset(x: -10).padding(.vertical, 8)
            Group {
                Button(action: {self.selectDeselect("Monday")}) {
                    HStack {
                        Text("Monday").foregroundColor(.black).fontWeight(.bold)
                        Spacer()
                        Image(systemName: selection.contains("Monday") ? "chevron.down" : "chevron.up")
                    }.padding(10).background(Color("one")).frame(width: UIScreen.main.bounds.size.width-20).cornerRadius(10).offset(x: -10)
                }
                if (selection.contains("Monday")) {
                    ForEach(freetimelist) {
                        freetime in
                        if (freetime.monday)
                        {
                            Text(self.formatter.string(from: freetime.startdatetime) + " - " + self.formatter.string(from: freetime.enddatetime))
                        }
                    }
                    .onDelete { indexSet in
                         for index in indexSet {
                            self.freetimelist[index].monday = false
                            if (!self.freetimelist[index].monday && !self.freetimelist[index].tuesday && !self.freetimelist[index].wednesday && !self.freetimelist[index].thursday && !self.freetimelist[index].friday && !self.freetimelist[index].saturday && !self.freetimelist[index].sunday) {
                                self.managedObjectContext.delete(self.freetimelist[index])
                            }
                         }

                         do {
                             try self.managedObjectContext.save()
                         } catch {
                             print(error.localizedDescription)
                         }

                    }
                }
                Button(action: {self.selectDeselect("Tuesday")}) {
                   HStack {
                       Text("Tuesday").foregroundColor(.black).fontWeight(.bold)
                       Spacer()
                       Image(systemName: selection.contains("Tuesday") ? "chevron.down" : "chevron.up")
                   }.padding(10).background(Color("two")).frame(width: UIScreen.main.bounds.size.width-20).cornerRadius(10).offset(x: -10)
               }
                if (selection.contains("Tuesday")) {
                    ForEach(freetimelist) {
                         freetime in
                         if (freetime.tuesday) {
                             Text(self.formatter.string(from: freetime.startdatetime) + " - " + self.formatter.string(from: freetime.enddatetime))
                         }
                     }
                     .onDelete { indexSet in
                          for index in indexSet {
                              self.freetimelist[index].tuesday = false
                              if (!self.freetimelist[index].monday && !self.freetimelist[index].tuesday && !self.freetimelist[index].wednesday && !self.freetimelist[index].thursday && !self.freetimelist[index].friday && !self.freetimelist[index].saturday && !self.freetimelist[index].sunday) {
                                  self.managedObjectContext.delete(self.freetimelist[index])
                              }
                            }

                          do {
                              try self.managedObjectContext.save()
                          } catch {
                              print(error.localizedDescription)
                          }
                        
                     }
                }
                Button(action: {self.selectDeselect("Wednesday")}) {
                   HStack {
                       Text("Wednesday").foregroundColor(.black).fontWeight(.bold)
                       Spacer()
                       Image(systemName: selection.contains("Wednesday") ? "chevron.down" : "chevron.up")
                   }.padding(10).background(Color("three")).frame(width: UIScreen.main.bounds.size.width-20).cornerRadius(10).offset(x: -10)
               }
                if (selection.contains("Wednesday")) {
                    ForEach(freetimelist) {
                        freetime in
                        if (freetime.wednesday) {
                            Text(self.formatter.string(from: freetime.startdatetime) + " - " + self.formatter.string(from: freetime.enddatetime))
                        }
                    }
                    .onDelete { indexSet in
                         for index in indexSet {
                              self.freetimelist[index].wednesday = false
                              if (!self.freetimelist[index].monday && !self.freetimelist[index].tuesday && !self.freetimelist[index].wednesday && !self.freetimelist[index].thursday && !self.freetimelist[index].friday && !self.freetimelist[index].saturday && !self.freetimelist[index].sunday) {
                                  self.managedObjectContext.delete(self.freetimelist[index])
                              }
                            }

                         do {
                             try self.managedObjectContext.save()
                         } catch {
                             print(error.localizedDescription)
                         }

                    }
                }
                Button(action: {self.selectDeselect("Thursday")}) {
                       HStack {
                           Text("Thursday").foregroundColor(.black).fontWeight(.bold)
                           Spacer()
                           Image(systemName: selection.contains("Thursday") ? "chevron.down" : "chevron.up")
                       }.padding(10).background(Color("four")).frame(width: UIScreen.main.bounds.size.width-20).cornerRadius(10).offset(x: -10)
                   }
                if (selection.contains("Thursday")) {
                    ForEach(freetimelist) {
                        freetime in
                        if (freetime.thursday) {
                            Text(self.formatter.string(from: freetime.startdatetime) + " - " + self.formatter.string(from: freetime.enddatetime))
                        }
                    }
                    .onDelete { indexSet in
                         for index in indexSet {
                              self.freetimelist[index].thursday = false
                              if (!self.freetimelist[index].monday && !self.freetimelist[index].tuesday && !self.freetimelist[index].wednesday && !self.freetimelist[index].thursday && !self.freetimelist[index].friday && !self.freetimelist[index].saturday && !self.freetimelist[index].sunday) {
                                  self.managedObjectContext.delete(self.freetimelist[index])
                              }
                        }

                         do {
                             try self.managedObjectContext.save()
                         } catch {
                             print(error.localizedDescription)
                         }
                        
                    }
                }
                Button(action: {self.selectDeselect("Friday")}) {
                       HStack {
                           Text("Friday").foregroundColor(.black).fontWeight(.bold)
                           Spacer()
                           Image(systemName: selection.contains("Friday") ? "chevron.down" : "chevron.up")
                       }.padding(10).background(Color("five")).frame(width: UIScreen.main.bounds.size.width-20).cornerRadius(10).offset(x: -10)
                   }
                if (selection.contains("Friday")) {
                    ForEach(freetimelist) {
                        freetime in
                        if (freetime.friday) {
                            Text(self.formatter.string(from: freetime.startdatetime) + " - " + self.formatter.string(from: freetime.enddatetime))
                        }
                    }
                    .onDelete { indexSet in
                         for index in indexSet {
                              self.freetimelist[index].friday = false
                              if (!self.freetimelist[index].monday && !self.freetimelist[index].tuesday && !self.freetimelist[index].wednesday && !self.freetimelist[index].thursday && !self.freetimelist[index].friday && !self.freetimelist[index].saturday && !self.freetimelist[index].sunday) {
                                  self.managedObjectContext.delete(self.freetimelist[index])
                              }
                            }

                         do {
                             try self.managedObjectContext.save()
                         } catch {
                             print(error.localizedDescription)
                         }
                        
                    }
                }
            }
            Group {
                Button(action: {self.selectDeselect("Saturday")}) {
                       HStack {
                           Text("Saturday").foregroundColor(.black).fontWeight(.bold)
                           Spacer()
                           Image(systemName: selection.contains("Saturday") ? "chevron.down" : "chevron.up")
                       }.padding(10).background(Color("six")).frame(width: UIScreen.main.bounds.size.width-20).cornerRadius(10).offset(x: -10)
                   }
                if (selection.contains("Saturday")) {
                    ForEach(freetimelist) {
                        freetime in
                        if (freetime.saturday) {
                            Text(self.formatter.string(from: freetime.startdatetime) + " - " + self.formatter.string(from: freetime.enddatetime))
                        }
                    }
                    .onDelete { indexSet in
                         for index in indexSet {
                              self.freetimelist[index].saturday = false
                              if (!self.freetimelist[index].monday && !self.freetimelist[index].tuesday && !self.freetimelist[index].wednesday && !self.freetimelist[index].thursday && !self.freetimelist[index].friday && !self.freetimelist[index].saturday && !self.freetimelist[index].sunday) {
                                  self.managedObjectContext.delete(self.freetimelist[index])
                              }
                            }
                         do {
                             try self.managedObjectContext.save()
                         } catch {
                             print(error.localizedDescription)
                         }
                        
                    }
                }
                
                Button(action: {self.selectDeselect("Sunday")}) {
                       HStack {
                           Text("Sunday").foregroundColor(.black).fontWeight(.bold)
                           Spacer()
                           Image(systemName: selection.contains("Sunday") ? "chevron.down" : "chevron.up")
                       }.padding(10).background(Color("seven")).frame(width: UIScreen.main.bounds.size.width-20).cornerRadius(10).offset(x: -10)
                   }
                if (selection.contains("Sunday")) {
                    ForEach(freetimelist) {
                        freetime in
                        if (freetime.sunday) {
                            Text(self.formatter.string(from: freetime.startdatetime) + " - " + self.formatter.string(from: freetime.enddatetime))
                        }
                    }
                    .onDelete { indexSet in
                         for index in indexSet {
                              self.freetimelist[index].sunday = false
                              if (!self.freetimelist[index].monday && !self.freetimelist[index].tuesday && !self.freetimelist[index].wednesday && !self.freetimelist[index].thursday && !self.freetimelist[index].friday && !self.freetimelist[index].saturday && !self.freetimelist[index].sunday) {
                                  self.managedObjectContext.delete(self.freetimelist[index])
                              }
                            }

                         do {
                             try self.managedObjectContext.save()
                         } catch {
                             print(error.localizedDescription)
                         }
                        
                    }
                }
                Spacer()
                Button(action: {self.selectDeselect("One-off Dates")}) {
                       HStack {
                           Text("One-off Dates").foregroundColor(.black).fontWeight(.bold)
                           Spacer()
                           Image(systemName: selection.contains("One-off Dates") ? "chevron.down" : "chevron.up")
                       }.padding(10).background(Color("eight")).frame(width: UIScreen.main.bounds.size.width-20).cornerRadius(10).offset(x: -10)
                   }
                if (selection.contains("One-off Dates")) {
                    ForEach(freetimelist) {
                        freetime in
                        if (!freetime.monday && !freetime.tuesday && !freetime.wednesday && !freetime.thursday && !freetime.friday && !freetime.saturday && !freetime.sunday) {
                            HStack {
                                Text(self.formatter.string(from: freetime.startdatetime) + " - " + self.formatter.string(from: freetime.enddatetime))
                                Spacer()
                                Text(self.formatter2.string(from: freetime.startdatetime))
                            }
                        }
                    }
                    .onDelete { indexSet in
                         for index in indexSet {
                             self.managedObjectContext.delete(self.freetimelist[index])
                         }

                         do {
                             try self.managedObjectContext.save()
                         } catch {
                             print(error.localizedDescription)
                         }
                        
                    }
                }
            }
        }.onDisappear(perform: {
//            print("F")
            //not being used
//            masterRunning.masterRunningNow = true
        }).animation(.spring()).navigationBarItems(trailing: Button(action: {
            if (self.selection.count < 8) {
                for dayname in self.daylist {
                    if (!self.selection.contains(dayname)) {
                        self.selection.insert(dayname)
                    }
                }
            }
            else {
                self.selection.removeAll()
            }
        }, label: {selection.count == 8 ? Text("Collapse All"): Text("Expand All")})).navigationTitle("View & Delete Free Times").navigationBarTitleDisplayMode(.inline)
    }
}

struct NewGradeModalView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject var masterRunning: MasterRunning

    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [])
    var assignmentlist: FetchedResults<Assignment>
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    var classeslist: FetchedResults<Classcool>
    @State private var selectedassignment = 0
    @State private var assignmentgrade: Double = 1
    @State private var classfilter: Int
    @Binding var NewGradePresenting: Bool
    var otherclassgradesae: [String] = ["E", "D", "C", "B", "A"]
    var otherclassgradesaf: [String] = ["F", "E", "D", "C", "B", "A"]
    @State var newassignment: Bool = false
    var formatter: DateFormatter
    
    //add logic for when it's not possible to add grade to existing assignment so only create a new assignment with grade ----> disable the toggle with a message underneath
    init(NewGradePresenting: Binding<Bool>, classfilter: Int)
    {

        formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        self._NewGradePresenting = NewGradePresenting
        self._classfilter = State(initialValue: classfilter)
    }
    func getgradableassignments() -> [Int]
    {
     //   print(classfilter)
      //  print(classeslist[classfilter].originalname)
        var gradableAssignments: [Int] = []
        for (index, assignment) in assignmentlist.enumerated() {
            if (classfilter == -1)
            {
                if (assignment.completed == true && assignment.grade == 0)
                {

                    gradableAssignments.append(index)
        
                }
            }
            else
            {
                if (assignment.completed == true && assignment.grade == 0 && assignment.subject == classeslist[classfilter].originalname)
                {
                    gradableAssignments.append(index)
                   // print(assignment.name)
                }
            }
        }
        return gradableAssignments
    }
    func getgradingscheme(assignment: Assignment) -> String
    {
        for classity in classeslist
        {
            if (assignment.subject == classity.originalname)
            {
                return classity.gradingscheme
            }
        }
        return "P"
    }
    func getgradingschemebyclass() -> String
    {
        if (getnontrashclasslist().count == 0)
        {
            return "P"
        }
        return classeslist[getnontrashclasslist()[selectedclass]].gradingscheme
    }
    func getgrademinbyclass() -> Double
    {
        let gradeschemeval = self.getgradingschemebyclass()
        if (gradeschemeval[0..<1] == "L")
        {
            return 1
        }
        else if (gradeschemeval[0..<1] == "N")
        {
            return 1
        }
        else
        {
            return 1
        }
    }
    func getgrademaxbyclass() -> Double
    {
        let gradeschemeval = self.getgradingschemebyclass()
        if (gradeschemeval[0..<1] == "L")
        {
            if (gradeschemeval[3..<4] == "F")
            {
                return 6
            }
            return 5
        }
        else if (gradeschemeval[0..<1] == "N")
        {
            return Double(gradeschemeval[3..<gradeschemeval.count]) ?? 7
        }
        else
        {
            return 100
        }    }
    func getgrademin(assignment: Assignment) -> Double
    {
        let gradeschemeval = self.getgradingscheme(assignment: assignment)
        if (gradeschemeval[0..<1] == "L")
        {
            return 1
        }
        else if (gradeschemeval[0..<1] == "N")
        {
            return 1
        }
        else
        {
            return 1
        }
    }
    func getgrademax(assignment: Assignment) -> Double
    {
        let gradeschemeval = self.getgradingscheme(assignment: assignment)
        if (gradeschemeval[0..<1] == "L")
        {
            if (gradeschemeval[3..<4] == "F")
            {
                return 6
            }
            return 5
        }
        else if (gradeschemeval[0..<1] == "N")
        {
            return Double(gradeschemeval[3..<gradeschemeval.count]) ?? 7
        }
        else
        {
            return 100
        }
        
    }
    func getclassname() -> String{
        if (self.selectedassignment < self.getgradableassignments().count)
        {
            return self.assignmentlist[self.getgradableassignments()[self.selectedassignment]].subject
        }
        return ""
    }
    func getnontrashclasslist() -> [Int]
    {
        var classitylist: [Int] = []
        for (index, classity) in classeslist.enumerated()
        {
            if (!classity.isTrash)
            {
                classitylist.append(index)
            }
        }
        return classitylist
    }
    @State var assignmentname: String = ""
    @State var selectedclass: Int = 0
    @State var assignmenttype: Int = 0
    let assignmenttypes = ["Homework", "Study", "Test", "Essay", "Presentation/Oral", "Exam", "Report/Paper"]
    let hourlist = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60]
    let minutelist = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    @State var hours = 0
    @State var minutes = 0
    @State private var createassignmentallowed = true
    @State private var showingAlert = false
    @State private var expandedduedate = false
    @State private var startDate = Date(timeIntervalSince1970: 0)
    @State var selectedDate: Date = Date()
    var body: some View {
        NavigationView {
            Form {
                if (self.getgradableassignments().count == 0)
                {
                    HStack {
                        Text("You have no completed assignments which do not have grades. To add a grade to an assignment, swipe left on the assignment to complete it.").fontWeight(.light)
                        Spacer()
                    }.padding(.bottom, 10).listRowInsets(EdgeInsets()).background(Color(UIColor.systemGroupedBackground))
                }
                
                if (newassignment)
                {
                    Section {
                        TextField("Assignment Name", text: $assignmentname).keyboardType(.webSearch).onTapGesture {
                            UIApplication.shared.endEditing()
                        }
                    }
                
                    

                    Section {
                        VStack {
                            //Text("Hello")

                            if (self.getgradingschemebyclass()[0..<1] == "N" || self.getgradingschemebyclass()[0..<1] == "L")
                            {
                                HStack {
                                    if (self.getgradingschemebyclass()[0..<1] == "N")
                                    {
                                        Text("Grade: \(assignmentgrade.rounded(.down), specifier: "%.0f")")
                                    }
                                    else
                                    {
                                        if (self.getgradingschemebyclass()[3..<4] == "F")
                                        {
                                            Text("Grade: " + otherclassgradesaf[Int(assignmentgrade.rounded(.down))-1])
                                        }
                                        else
                                        {
                                            Text("Grade: " + otherclassgradesae[Int(assignmentgrade.rounded(.down))-1])
                                        }
                                    }
                                   Spacer()
                                }.frame(height: 30)
                                Slider(value: $assignmentgrade, in: self.getgrademinbyclass()...self.getgrademaxbyclass())
                            }
                            else
                            {
                                HStack {
                                    Text("Grade: \(assignmentgrade.rounded(.down), specifier: "%.0f")")
                                    Spacer()
                                }.frame(height: 30)
                                Slider(value: $assignmentgrade, in: 1...100)

                            }


                        }

                    }

                    Section {
                        Picker(selection: $selectedclass, label: Text("Class")) {
                            ForEach(0 ..< getnontrashclasslist().count) {
                                if ($0 < self.getnontrashclasslist().count)
                                {
                                    Text(self.classeslist[self.getnontrashclasslist()[$0]].name)
                                }

                            }
                        }
    //                    ForEach(0 ..< getgradableassignments().count) {
    //                        if ($0 < self.getgradableassignments().count)
    //                        {
    //                            Text(self.assignmentlist[self.getgradableassignments()[$0]].name)
    //                        }
    //                    }
                    }
                    Section {
                        Picker(selection: $assignmenttype, label: Text("Type")) {
                            ForEach(0 ..< assignmenttypes.count) {
                                Text(self.assignmenttypes[$0])
                            }
                        }
                    }
//
                    Section {
                        Text("Assignment Length")
                        HStack {
                            VStack {
                                Picker(selection: $hours, label: Text("Hour")) {
                                    ForEach(hourlist.indices) { hourindex in
                                        Text(String(self.hourlist[hourindex]) + (self.hourlist[hourindex] == 1 ? " hour" : " hours"))
                                     }
                                 }.pickerStyle(WheelPickerStyle())
                            }.frame(minWidth: 100, maxWidth: .infinity)
                            .clipped()

                            VStack {
                                if hours == 0 {
                                    Picker(selection: $minutes, label: Text("Minutes")) {
                                        ForEach(minutelist[6...].indices) { minuteindex in
                                            Text(String(self.minutelist[minuteindex]) + " mins")
                                        }
                                    }.pickerStyle(WheelPickerStyle())
                                }

                                else {
                                    Picker(selection: $minutes, label: Text("Minutes")) {
                                        ForEach(minutelist.indices) { minuteindex in
                                            Text(String(self.minutelist[minuteindex]) + " mins")
                                        }
                                    }.pickerStyle(WheelPickerStyle())
                                }
                            }.frame(minWidth: 100, maxWidth: .infinity)
                            .clipped()
                        }
                    }
//
                    Section {


                        if #available(iOS 14.0, *) {
                            Button(action: {
                                    self.expandedduedate.toggle()

                            }) {
                                HStack {
                                    Text("Due Date").foregroundColor(colorScheme == .light ? Color.black : Color.white)
                                    Spacer()
                                    Text(formatter.string(from: selectedDate)).foregroundColor(expandedduedate ? Color.blue: Color.gray)
                                }

                            }
                            if (expandedduedate)
                            {
                                VStack {
                                    DatePicker("", selection: $selectedDate, in:  Date(timeIntervalSince1970: 0)... , displayedComponents: [.date, .hourAndMinute]).animation(.spring()).datePickerStyle(WheelDatePickerStyle())
                                }.animation(.spring())
                            }

                        }

                        else {
                            Button(action: {
                                    self.expandedduedate.toggle()

                            }) {
                                HStack {
                                    Text("Due Date").foregroundColor(Color.black)
                                    Spacer()
                                    Text(formatter.string(from: selectedDate)).foregroundColor(expandedduedate ? Color.blue: Color.gray)
                                }

                            }
                            if (expandedduedate)
                            {
                                VStack { //change startDate thing to the time-adjusted one (look at iOS 14 implementation
                                    MyDatePicker(selection: $selectedDate, starttime: $startDate, dateandtimedisplayed: true).frame(width: UIScreen.main.bounds.size.width-40, height: 200, alignment: .center).animation(nil)
                                }.animation(nil)
                            }

                        }
                    }

                    Section {
                        Button(action: {
                            self.createassignmentallowed = true

                            for assignment in self.assignmentlist {
                                if assignment.name == self.assignmentname {
                                    self.createassignmentallowed = false
                                }
                            }

                            if (self.assignmentname == "")
                            {
                                self.createassignmentallowed = false
                            }

                            if self.createassignmentallowed {

                                let newAssignment = Assignment(context: self.managedObjectContext)
                                newAssignment.completed = true
                                newAssignment.grade = Int64(self.assignmentgrade)
                                newAssignment.subject = self.classeslist[self.getnontrashclasslist()[self.selectedclass]].originalname
                                newAssignment.name = self.assignmentname
                                newAssignment.type = self.assignmenttypes[self.assignmenttype]
                                newAssignment.progress = 100
                                newAssignment.duedate = self.selectedDate

                                if (self.hours == 0)
                                {
                                    newAssignment.totaltime = Int64(self.minutelist[self.minutes+6])
                                }
                                else
                                {
                                    newAssignment.totaltime = Int64(60*self.hourlist[self.hours] + self.minutelist[self.minutes])
                                }
                                newAssignment.timeleft = 0

                                for classity in self.classeslist {
                                    if (classity.originalname == newAssignment.subject) {
                                        newAssignment.color = classity.color
//                                        classity.assignmentnumber += 1
                                    }
                                }

                                //assignment specific
                                

                                do {
                                    try self.managedObjectContext.save()
                                } catch {
                                    print(error.localizedDescription)
                                }
//                                masterRunning.uniqueAssignmentName = self.assignmentname
//                                print("G")
                                //master function shouldn't be run
//                                masterRunning.masterRunningNow = true
//                                masterRunning.displayText = true
                                
                                self.NewGradePresenting = false
                            }

                            else {
                                self.showingAlert = true
                            }
                        }) {
                            Text("Add Completed Assignment")
                        }
                    }
                    
                }
                else
                {
                    if (self.getgradableassignments().count != 0) {
                        Section {
                            Picker(selection: $selectedassignment, label: Text("Assignment")) {
                                ForEach(0 ..< getgradableassignments().count) {
                                    if ($0 < self.getgradableassignments().count)
                                    {
                                        Text(self.assignmentlist[self.getgradableassignments()[$0]].name)
                                    }
                                }

                            }
                        }
                    
                        Section {
                            VStack {
                                //Text("Hello")
                                if (self.getgradableassignments().count > 0)
                                {
                                    if (self.getgradingscheme(assignment: self.assignmentlist[self.getgradableassignments()[selectedassignment]])[0..<1] == "N" || self.getgradingscheme(assignment: self.assignmentlist[self.getgradableassignments()[selectedassignment]])[0..<1] == "L")
                                    {
                                        HStack {
                                            if (self.getgradingscheme(assignment: self.assignmentlist[self.getgradableassignments()[selectedassignment]])[0..<1] == "N")
                                            {
                                                Text("Grade: \(assignmentgrade.rounded(.down), specifier: "%.0f")")
                                            }
                                            else
                                            {
                                                if (self.getgradingscheme(assignment: self.assignmentlist[self.getgradableassignments()[selectedassignment]])[3..<4] == "F")
                                                {
                                                    Text("Grade: " + otherclassgradesaf[Int(assignmentgrade.rounded(.down))-1])
                                                }
                                                else
                                                {
                                                    Text("Grade: " + otherclassgradesae[Int(assignmentgrade.rounded(.down))-1])
                                                }
                                            }
                                           Spacer()
                                        }.frame(height: 30)
                                        Slider(value: $assignmentgrade, in: self.getgrademin(assignment: self.assignmentlist[self.getgradableassignments()[selectedassignment]])...self.getgrademax(assignment: self.assignmentlist[self.getgradableassignments()[selectedassignment]]))
                                    }
                                    else
                                    {
                                        HStack {
                                            Text("Grade: \(assignmentgrade.rounded(.down), specifier: "%.0f")")
                                            Spacer()
                                        }.frame(height: 30)
                                        Slider(value: $assignmentgrade, in: 1...100)

                                    }
                                }

                            }

                        }
                        
                        Section {
                            Button(action: {
                  
                              //  print(self.getgradableassignments()[4])
                                let value = self.getgradableassignments()[self.selectedassignment]
                                for assignment in self.assignmentlist {
                                    if (assignment.name == self.assignmentlist[value].name)
                                    {
                                        assignment.grade =  Int64(self.assignmentgrade.rounded(.down))
                                    }
                                }
                             
                                do {
                                    try self.managedObjectContext.save()
                                } catch {
                                    print(error.localizedDescription)
                                }
                                
                                self.NewGradePresenting = false
                            }) {
                                Text("Add Grade")
                            }
                        }
                    }
                }
                
                if !self.classeslist.isEmpty {
                    Section {
                        VStack {
                            HStack {
                                Text("To add a grade to a completed assignment from the past, toggle the switch below.").fontWeight(.light).minimumScaleFactor(0.9).lineLimit(3)
                                Spacer()
                            }
                            
                            Toggle(isOn: $newassignment)
                            {
                                Text("Create New Completed Assignment")
                            }
                        }
                    }
                }
            }.gesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onChanged { _ in
                UIApplication.shared.endEditing()
            }.onEnded { _ in
                UIApplication.shared.endEditing()
            }).navigationBarItems(leading: Button(action: {self.NewGradePresenting = false}, label: {Text("Cancel")}), trailing: Button(action:
            {
                if (newassignment)
                {
                    self.createassignmentallowed = true

                    for assignment in self.assignmentlist {
                        if assignment.name == self.assignmentname {
                            self.createassignmentallowed = false
                        }
                    }

                    if (self.assignmentname == "")
                    {
                        self.createassignmentallowed = false
                    }

                    if self.createassignmentallowed {

                        let newAssignment = Assignment(context: self.managedObjectContext)
                        newAssignment.completed = true
                        newAssignment.grade = Int64(self.assignmentgrade)
                        newAssignment.subject = self.classeslist[self.getnontrashclasslist()[self.selectedclass]].originalname
                        newAssignment.name = self.assignmentname
                        newAssignment.type = self.assignmenttypes[self.assignmenttype]
                        newAssignment.progress = 100
                        newAssignment.duedate = self.selectedDate

                        if (self.hours == 0)
                        {
                            newAssignment.totaltime = Int64(self.minutelist[self.minutes+6])
                        }
                        else
                        {
                            newAssignment.totaltime = Int64(60*self.hourlist[self.hours] + self.minutelist[self.minutes])
                        }
                        newAssignment.timeleft = 0

                        for classity in self.classeslist {
                            if (classity.originalname == newAssignment.subject) {
                                newAssignment.color = classity.color
//                                        classity.assignmentnumber += 1
                            }
                        }

                        //assignment specific
                        

                        do {
                            try self.managedObjectContext.save()
                        } catch {
                            print(error.localizedDescription)
                        }
//                                masterRunning.uniqueAssignmentName = self.assignmentname
//                                print("G")
                        //master function shouldn't be run
//                                masterRunning.masterRunningNow = true
//                                masterRunning.displayText = true
                        
                        self.NewGradePresenting = false
                    }

                    else {
                        self.showingAlert = true
                    }
                }
                else
                {
                    if (self.getgradableassignments().count > 0)
                    {
                        let value = self.getgradableassignments()[self.selectedassignment]
                        for assignment in self.assignmentlist {
                            if (assignment.name == self.assignmentlist[value].name)
                            {
                                assignment.grade =  Int64(self.assignmentgrade.rounded(.down))
                            }
                        }
                     
                        do {
                            try self.managedObjectContext.save()
                        } catch {
                            print(error.localizedDescription)
                        }
                        
                        self.NewGradePresenting = false
                    }
                }
            })
            {
                Text("Add")
            }).navigationTitle("Add Grade").navigationBarTitleDisplayMode(.inline).alert(isPresented: $showingAlert) {
                Alert(title: self.assignmentname == "" ? Text("No Assignment Name Provided") : Text("Assignment Already Exists"), message: self.assignmentname == "" ? Text("Add an Assignment Name") : Text("Change Assignment Name"), dismissButton: .default(Text("Continue")))
            }
        }
    }
}




struct EditAssignmentModalView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var changingDate: DisplayedDate
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    @Binding var NewAssignmentPresenting: Bool
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.completed, ascending: true), NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    var assignmentslist: FetchedResults<Assignment>
    
    @FetchRequest(entity: Subassignmentnew.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Subassignmentnew.startdatetime, ascending: true)])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    let assignmenttypes2 = ["Homework", "Study", "Test", "Essay", "Presentation/Oral", "Exam", "Report/Paper"]
    @State var nameofassignment: String
    @State private var hours: Int
    @State private var minutes: Int
    @State private var selectedassignment: Int
    @State var selectedDate: Date
    @State var iscompleted: Bool
    @State var gradeval: Double
    @State var assignmentsubject: String
    @State var assignmenttypeval: Int
    @State var deleteassignmentallowed: Bool = true

    @EnvironmentObject var masterRunning: MasterRunning
    let hourlist = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60]
    let minutelist = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    //@State var textfieldmanager: TextFieldManager = TextFieldManager()
    @State private var createassignmentallowed = true
    @State private var showingAlert = false
    @State private var expandedduedate = false
    @State private var startDate = Date()
    @State var originalname: String
    var formatter: DateFormatter
    
    let otherclassgradesae = ["E", "D", "C", "B", "A"]
    let otherclassgradesaf = ["F", "E", "D", "C", "B", "A"]
    init(NewAssignmentPresenting: Binding<Bool>, selectedassignment: Int, assignmentname: String, timeleft: Int, duedate: Date, iscompleted: Bool, gradeval: Int, assignmentsubject: String, assignmenttype: Int) {
       // print(selectedassignment)
        self._NewAssignmentPresenting = NewAssignmentPresenting
       // selectedDate = changingDate.displayedDate
        formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
       // formatter.timeZone = TimeZone(secondsFromGMT: 0)
        self._selectedassignment = State(initialValue: selectedassignment)
        self._nameofassignment = State(initialValue: assignmentname)
        
        //self.textfieldmanager.userInput = assignmentname
        self._hours = State(initialValue: timeleft/60)
        self._minutes = State(initialValue: (timeleft%60)/5)
        self._selectedDate = State(initialValue: duedate)
        self._iscompleted = State(initialValue: iscompleted)
        self._gradeval = State(initialValue: Double(gradeval))
        self._assignmentsubject = State(initialValue: assignmentsubject)
        self._originalname = State(initialValue: assignmentname)
        self._assignmenttypeval = State(initialValue: assignmenttype) // State(initialValue: assignmenttype)
       // print(type(of: assignmenttypeval))
        print(gradeval)
        
    }
    func getminhourindex() -> Int
    {
        var minutecount = 0
        for subassignment in subassignmentlist
        {
            if (subassignment.assignmentname == self.originalname)
            {
                if (subassignment.startdatetime < Date())
                {
                    minutecount += Calendar.current.dateComponents([.minute], from: subassignment.startdatetime, to: subassignment.enddatetime).minute!
                }
            }
        }
        return minutecount/60
    }
    func getminminuteindex() -> Int
    {
        var minutecount = 0
        for subassignment in subassignmentlist
        {
            if (subassignment.assignmentname == self.originalname)
            {
                if (subassignment.startdatetime < Date())
                {
                    minutecount += Calendar.current.dateComponents([.minute], from: subassignment.startdatetime, to: subassignment.enddatetime).minute!
                }
            }
        }
        minutecount %= 60
        return minutecount/5
    }
    
    func getgradingscheme() -> String
    {
        for classity in classlist
        {
            if (assignmentsubject == classity.originalname)
            {
                return classity.gradingscheme
            }
        }
        return "P"
    }
    func getgrademin() -> Double
    {
        let gradeschemeval = self.getgradingscheme()
        if (gradeschemeval[0..<1] == "L")
        {
            return 1
        }
        else if (gradeschemeval[0..<1] == "N")
        {
            return 1
        }
        else
        {
            return 1
        }
    }
    func getgrademax() -> Double
    {
        let gradeschemeval = self.getgradingscheme()
        if (gradeschemeval[0..<1] == "L")
        {
            if (gradeschemeval[3..<4] == "F")
            {
                return 6
            }
            return 5
        }
        else if (gradeschemeval[0..<1] == "N")
        {
            return Double(gradeschemeval[3..<gradeschemeval.count]) ?? 7
        }
        else
        {
            return 100
        }
        
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Assignment Name", text: self.$nameofassignment).keyboardType(.default).onTapGesture {
                        UIApplication.shared.endEditing()
                    }//.disabled(nameofassignment.count > (20 - 1))
                }

                //Text(String(assignmenttype))
                if (self.iscompleted)
                {
                    Section {
                        VStack {
                            //Text("Hello")

                            if (self.getgradingscheme()[0..<1] == "N" || self.getgradingscheme()[0..<1] == "L")
                            {
                                HStack {
                                    if (self.getgradingscheme()[0..<1] == "N")
                                    {
                                        Text("Grade: \(gradeval.rounded(.down), specifier: "%.0f")")
                                    }
                                    else
                                    {
                                        if (Int(gradeval.rounded(.down)) == 0)
                                        {
                                            Text("Grade: NA")
                                        }
                                        else if (self.getgradingscheme()[3..<4] == "F")
                                        {
                                            Text("Grade: " + otherclassgradesaf[Int(gradeval.rounded(.down))-1])
                                        }
                                        else
                                        {
                                            Text("Grade: " + otherclassgradesae[Int(gradeval.rounded(.down))-1])
                                        }
                                    }
                                   Spacer()
                                }.frame(height: 30)
                                Slider(value: $gradeval, in: self.getgrademin()...self.getgrademax())
                            }
                            else
                            {
                                HStack {
                                    Text("Grade: \(gradeval.rounded(.down), specifier: "%.0f")")
                                    Spacer()
                                }.frame(height: 30)
                                Slider(value: $gradeval, in: 1...100)

                            }
                            

                        }

                    }
                }
                if (!self.iscompleted)
                {
                   // Text("asdofijasfsod")
                    Section {

                            Picker(selection: $assignmenttypeval, label: Text("Type")) {
                                ForEach(assignmenttypes2.indices) {
                                    indexval in
                                    Text(self.assignmenttypes2[indexval])
                                }
                            }

                    }


                    Section {
                        Text("Work left")
                        HStack {
                            VStack {
                                Picker(selection: $hours, label: Text("Hour")) {
                                    ForEach(hourlist[getminhourindex()...].indices) { index in
                                        Text(String(self.hourlist[index]) + (self.hourlist[index] == 1 ? " hour" : " hours"))
                                        
                                        
                                     }
                                 }.pickerStyle(WheelPickerStyle())
                            }.frame(minWidth: 100, maxWidth: .infinity)
                            .clipped()
                            


                            VStack {
                                if (hours > 0)
                                {
                                    Picker(selection: $minutes, label: Text("Minutes")) {
                                        ForEach(minutelist.indices) { index in
                                            if (index < minutelist.count)
                                            {
                                                Text(String(self.minutelist[index]) + " mins")
                                            }
                                        }
                                    }.pickerStyle(WheelPickerStyle())
                                }
                                else if (getminhourindex() == 0 && getminminuteindex() == 0)
                                {
                                    Picker(selection: $minutes, label: Text("Minutes")) {
                                        ForEach(minutelist[6...].indices) { index in
                                            if (index < minutelist.count)
                                            {
                                                Text(String(self.minutelist[index]) + " mins")
                                            }
                                        }
                                    }.pickerStyle(WheelPickerStyle())
                                }
                                else
                                {
                                    Picker(selection: $minutes, label: Text("Minutes")) {
                                        ForEach(minutelist[getminminuteindex()...].indices) { index in
                                            if (index < minutelist.count)
                                            {
                                                Text(String(self.minutelist[index]) + " mins")
                                            }
                                        }
                                    }.pickerStyle(WheelPickerStyle())
                                    
                                }


                            }.frame(minWidth: 100, maxWidth: .infinity)
                            .clipped()
                        }
                    }
                    
                    Section {
                        if #available(iOS 14.0, *) {
                            Button(action: {
                                    self.expandedduedate.toggle()

                            }) {
                                HStack {
                                    Text("Due Date").foregroundColor(colorScheme == .light ? Color.black : Color.white)
                                    Spacer()
                                    Text(formatter.string(from: selectedDate)).foregroundColor(expandedduedate ? Color.blue: Color.gray)
                                }

                            }
                            if (expandedduedate)
                            {
                                VStack {
                                    DatePicker("", selection: $selectedDate, in: startDate..., displayedComponents: [.date, .hourAndMinute]).animation(.spring()).datePickerStyle(WheelDatePickerStyle())
                                }.animation(.spring())
                            }

                        } else {
                            Button(action: {
                                    self.expandedduedate.toggle()

                            }) {
                                HStack {
                                    Text("Due Date").foregroundColor(colorScheme == .light ? Color.black : Color.white)
                                    Spacer()
                                    Text(formatter.string(from: selectedDate)).foregroundColor(expandedduedate ? Color.blue: Color.gray)
                                }

                            }
                            if (expandedduedate)
                            {
                                VStack {
                                    MyDatePicker(selection: $selectedDate, starttime: $startDate, dateandtimedisplayed: true).frame(width: UIScreen.main.bounds.size.width-40, height: 200, alignment: .center).animation(nil)
                                }.animation(nil)
                            }

                        }

                    }
                }
                
                Section {
                    Toggle(isOn: $iscompleted) {
                        Text("Mark as Completed")
                    }.onTapGesture {
                        if (!self.iscompleted)
                         {
                            self.hours = 1
                            self.minutes = 0
                          //  print(!self.iscompleted)
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        self.createassignmentallowed = true
                        

                        if (self.nameofassignment != self.originalname)
                        {
                            for assignment in self.assignmentslist {
                                if assignment.name == self.nameofassignment {
                                    self.createassignmentallowed = false
                                }
                            }
                        }
                        if (self.nameofassignment == "")
                        {
                            createassignmentallowed = false
                        }

                        if self.createassignmentallowed {
                            for subassignment in subassignmentlist {
                                if (subassignment.assignmentname == self.assignmentslist[self.selectedassignment].name)
                                {
                                    subassignment.assignmentname = self.nameofassignment
                                }
                            }
                            self.assignmentslist[self.selectedassignment].name = self.nameofassignment
                            self.assignmentslist[self.selectedassignment].duedate = self.selectedDate
                            self.assignmentslist[self.selectedassignment].type = self.assignmenttypes2[self.assignmenttypeval]
                            var change: Int64 = 0
                            if (hours > 0)
                            {
                                change = Int64(60*self.hourlist[self.hours+getminhourindex()] + self.minutelist[self.minutes]) - self.assignmentslist[self.selectedassignment].timeleft
                            }
                            else if (getminhourindex() == 0 && getminminuteindex() == 0)
                            {
                                change = Int64(60*self.hourlist[self.hours] + self.minutelist[self.minutes+6]) - self.assignmentslist[self.selectedassignment].timeleft
                            }
                            else
                            {
                                change = Int64(60*self.hourlist[self.hours+getminhourindex()] + self.minutelist[self.minutes+getminminuteindex()]) - self.assignmentslist[self.selectedassignment].timeleft

                            }
                            self.assignmentslist[self.selectedassignment].timeleft += change
                            self.assignmentslist[self.selectedassignment].totaltime += change
                            
                            
                            if (self.assignmentslist[self.selectedassignment].timeleft == 0 || self.iscompleted)
                            {
                                print("a")
                                if ( !self.assignmentslist[self.selectedassignment].completed )
                                {
                                    print("b")
                                    for classity in self.classlist {
                                        if (self.assignmentslist[self.selectedassignment].subject == classity.originalname)
                                        {
                                            classity.assignmentnumber -= 1
                                        }
                                    }
                                }
                                for (index, subassignment) in subassignmentlist.enumerated() {
                                    if (subassignment.assignmentname == self.nameofassignment)
                                    {
                                        self.managedObjectContext.delete(self.subassignmentlist[index])
                                    }
                                }
                                self.assignmentslist[self.selectedassignment].grade = Int64(self.gradeval)
                                self.assignmentslist[self.selectedassignment].progress = 100
                                self.assignmentslist[self.selectedassignment].completed = true
                                
                            }

                            else
                            {
                                print("c")
                                if (self.assignmentslist[self.selectedassignment].completed)
                                {
                                    print("d")
                                    for classity in self.classlist {
                                        if (self.assignmentslist[self.selectedassignment].subject == classity.originalname)
                                        {
                                            classity.assignmentnumber += 1
                                        }
                                    }
                                    
                                }
                                if (self.assignmentslist[self.selectedassignment].subject == "Theory of Knowledge" || self.assignmentslist[self.selectedassignment].subject == "Extended Essay")
                                {
                                    self.assignmentslist[self.selectedassignment].grade = 2
                                }
                                else
                                {
                                    self.assignmentslist[self.selectedassignment].grade = 0
                                }
                                self.assignmentslist[self.selectedassignment].completed = false
                                self.assignmentslist[self.selectedassignment].progress =    Int64((Double(self.assignmentslist[self.selectedassignment].totaltime - self.assignmentslist[self.selectedassignment].timeleft)/Double(self.assignmentslist[self.selectedassignment].totaltime )) * 100)
                                
                                masterRunning.uniqueAssignmentName = self.nameofassignment
                                //assignment specific
                                print("H")
                                masterRunning.masterRunningNow = true
                                print("variable changed in editassignmentmodalview")
                                
                            }
                            
                            
                            do {
                                try self.managedObjectContext.save()
                            } catch {
                                print(error.localizedDescription)
                            }

                            
                            self.NewAssignmentPresenting = false
                        }
                     
                        else {
                            self.showingAlert = true
                        }
                    }) {
                        Text("Save Changes")
                    }
                }
                Section
                {
                    Button(action:{
                        
                        if (self.deleteassignmentallowed)
                        {
                            for (index, assignmentval) in assignmentslist.enumerated()
                            {
                                print("A")
                                if (assignmentval.name == self.originalname)
                                {
                                    print("B")
                                    for (index2, subassignment) in subassignmentlist.enumerated()
                                    {
                                        print("C")
                                        if (subassignment.assignmentname == assignmentval.name)
                                        {
                                            self.managedObjectContext.delete(self.subassignmentlist[index2])

                                        }
                                    }
                                    self.managedObjectContext.delete(self.assignmentslist[index])
                                    for (_, classcool) in classlist.enumerated()
                                    {
                                        if (classcool.originalname == assignmentval.subject) && (!assignmentval.completed)
                                        {
                                            classcool.assignmentnumber -= 1
                                        }
                                        do {
                                            try self.managedObjectContext.save()
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                    }
            
                                }
                                
                         

                             do {
                                 try self.managedObjectContext.save()
                             } catch {
                                 print(error.localizedDescription)
                             }
                                
                            }
                            WidgetCenter.shared.reloadTimelines(ofKind: "Today's Tasks")
                          //  masterRunning.masterRunningNow = true
                            
                            self.deleteassignmentallowed = false
                        }
                        self.NewAssignmentPresenting = false
                    })
                    {
                        Text("Delete Assignment")
                    }.foregroundColor(Color.red)
                }
            }.gesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onChanged { _ in
                UIApplication.shared.endEditing()
            }.onEnded { _ in
                UIApplication.shared.endEditing()
            }).navigationBarItems(leading: Button(action: {self.NewAssignmentPresenting = false}, label: {Text("Cancel")}), trailing: Button(action: {
                self.createassignmentallowed = true
                

                if (self.nameofassignment != self.originalname)
                {
                    for assignment in self.assignmentslist {
                        if assignment.name == self.nameofassignment {
                            self.createassignmentallowed = false
                        }
                    }
                }
                if (self.nameofassignment == "")
                {
                    createassignmentallowed = false
                }

                if self.createassignmentallowed {
                    for subassignment in subassignmentlist {
                        if (subassignment.assignmentname == self.assignmentslist[self.selectedassignment].name)
                        {
                            subassignment.assignmentname = self.nameofassignment
                        }
                    }
                    self.assignmentslist[self.selectedassignment].name = self.nameofassignment
                    self.assignmentslist[self.selectedassignment].duedate = self.selectedDate
                    self.assignmentslist[self.selectedassignment].type = self.assignmenttypes2[self.assignmenttypeval]
                    var change: Int64 = 0
                    if (hours > 0)
                    {
                        change = Int64(60*self.hourlist[self.hours+getminhourindex()] + self.minutelist[self.minutes]) - self.assignmentslist[self.selectedassignment].timeleft
                    }
                    else if (getminhourindex() == 0 && getminminuteindex() == 0)
                    {
                        change = Int64(60*self.hourlist[self.hours] + self.minutelist[self.minutes+6]) - self.assignmentslist[self.selectedassignment].timeleft
                    }
                    else
                    {
                        change = Int64(60*self.hourlist[self.hours+getminhourindex()] + self.minutelist[self.minutes+getminminuteindex()]) - self.assignmentslist[self.selectedassignment].timeleft

                    }
                    self.assignmentslist[self.selectedassignment].timeleft += change
                    self.assignmentslist[self.selectedassignment].totaltime += change
                    
                    
                    if (self.assignmentslist[self.selectedassignment].timeleft == 0 || self.iscompleted)
                    {
                        print("a")
                        if ( !self.assignmentslist[self.selectedassignment].completed )
                        {
                            print("b")
                            for classity in self.classlist {
                                if (self.assignmentslist[self.selectedassignment].subject == classity.originalname)
                                {
                                    classity.assignmentnumber -= 1
                                }
                            }
                        }
                        for (index, subassignment) in subassignmentlist.enumerated() {
                            if (subassignment.assignmentname == self.nameofassignment)
                            {
                                self.managedObjectContext.delete(self.subassignmentlist[index])
                            }
                        }
                        self.assignmentslist[self.selectedassignment].grade = Int64(self.gradeval)
                        self.assignmentslist[self.selectedassignment].progress = 100
                        self.assignmentslist[self.selectedassignment].completed = true
                        
                    }

                    else
                    {
                        print("c")
                        if (self.assignmentslist[self.selectedassignment].completed)
                        {
                            print("d")
                            for classity in self.classlist {
                                if (self.assignmentslist[self.selectedassignment].subject == classity.originalname)
                                {
                                    classity.assignmentnumber += 1
                                }
                            }
                            
                        }
                        if (self.assignmentslist[self.selectedassignment].subject == "Theory of Knowledge" || self.assignmentslist[self.selectedassignment].subject == "Extended Essay")
                        {
                            self.assignmentslist[self.selectedassignment].grade = 2
                        }
                        else
                        {
                            self.assignmentslist[self.selectedassignment].grade = 0
                        }
                        self.assignmentslist[self.selectedassignment].completed = false
                        self.assignmentslist[self.selectedassignment].progress =    Int64((Double(self.assignmentslist[self.selectedassignment].totaltime - self.assignmentslist[self.selectedassignment].timeleft)/Double(self.assignmentslist[self.selectedassignment].totaltime )) * 100)
                        
                        masterRunning.uniqueAssignmentName = self.nameofassignment
                        //assignment specific
                        print("H")
                        masterRunning.masterRunningNow = true
                        print("variable changed in editassignmentmodalview")
                        
                    }
                    
                    
                    do {
                        try self.managedObjectContext.save()
                    } catch {
                        print(error.localizedDescription)
                    }

                    
                    self.NewAssignmentPresenting = false
                }
             
                else {
                    self.showingAlert = true
                }
            }) {
                Text("Save")
            }).navigationTitle("Edit Assignment").navigationBarTitleDisplayMode(.inline).alert(isPresented: $showingAlert) {
                Alert(title: self.nameofassignment == "" ? Text("No Assignment Name Provided") : Text("Assignment Already Exists"), message: self.nameofassignment == "" ? Text("Add an Assignment Name") : Text("Change Assignment Name"), dismissButton: .default(Text("Continue")))
            }
            .onAppear
            {
                if (hours > 0)
                {
                    if (hours == getminhourindex())
                    {
                        minutes -= getminminuteindex()
                    }
                    else
                    {
                        
                    }
                }
                else
                {
                    if (getminminuteindex() <= 6)
                    {
                        minutes = 0
                    }
                    else
                    {
                        minutes -= getminminuteindex()
                    }
                }
                
            }
        }
//        if masterRunning.masterRunningNow {
//            MasterClass().environment(\.managedObjectContext, self.managedObjectContext)
//        }
    }
}
