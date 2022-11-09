//
//  FilterView.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 6/30/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import SwiftUI

struct DropDown: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var showCompleted: Bool
    @State private var selectedFilter = 0
    //@State private var showCompleted = false

    init(showCompleted2: Binding<Bool>) {
        UITableView.appearance().tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
        self._showCompleted = showCompleted2
    }
    @State var selectedbutton = "Due Date"
    let filters: [String] = ["Due Date", "Class", "Length", "Work Left", "Name", "Type"]
    @State var filterspresented: Bool = false
    var body: some View {
        VStack {
            NavigationLink(destination: EmptyView()) {
                EmptyView()
            }
            NavigationLink(destination:


                    List
                    {
                        ForEach(0..<filters.count) {
                            filter in
                            Button(action:{
                                selectedbutton = filters[filter]
                               // self.presentationMode.wrappedValue.dismiss()
                                filterspresented = false
                            })
                            {
                                HStack {
                                    Text(filters[filter])
                                    Spacer()
                                    if (selectedbutton == filters[filter])
                                    {
                                        Image(systemName: "checkmark").resizable().scaledToFit().foregroundColor(Color.blue)
                                    }
                                }.frame(height: 20)
                            }
                        }
                    },
                           isActive: $filterspresented )
            {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color("graphbackgroundtop")).frame(width: UIScreen.main.bounds.size.width-20, height: 50)
                    HStack {
                        Text("Sort Assignments By: ").foregroundColor(Color.black)
                        Spacer()
                        Text(selectedbutton).foregroundColor(Color.gray)
                        Image(systemName: "chevron.right").resizable().scaledToFit().foregroundColor(Color.gray)
                    }.frame(width: UIScreen.main.bounds.size.width-60, height: 15).onTapGesture {
                        filterspresented = true
                    }
                   // Image("chevron.right")
                }
            }
//                    Toggle(isOn: $showCompleted) {
//                        Text("Show Completed Assignments")
//                    }
//                    Text(showCompleted ? "Completed Assignments" : "To-Do Assignments").frame(width: 500, alignment: .leading)
                //}
          //  }.frame(height: 100)
            
            AssignmentsView(selectedFilter: selectedbutton, value: showCompleted)
        }
    }
}

class SheetNavigatorFilterView: ObservableObject {
    @Published var showassignmentedit: Bool = false
    @Published var selectedassignmentedit: String = ""
}

struct AssignmentsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var selection: Set<Assignment> = []
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.completed, ascending: true), NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
    var assignmentlist2: FetchedResults<Assignment>
    var assignmentlistrequest: FetchRequest<Assignment>
    var assignmentlist: FetchedResults<Assignment>{assignmentlistrequest.wrappedValue}
    var showCompleted: Bool
    @FetchRequest(entity: Classcool.entity(),
                  sortDescriptors: [])

    var classlist: FetchedResults<Classcool>
    @State var showassignmentedit: Bool = false
    @State var selectedassignmentedit: String = ""
    @ObservedObject var sheetnavigator: SheetNavigatorFilterView = SheetNavigatorFilterView()
    let assignmenttypes = ["Homework", "Study", "Test", "Essay", "Presentation/Oral", "Exam", "Report/Paper"]
    
    @EnvironmentObject var masterRunning: MasterRunning
    
    init(selectedFilter:String, value: Bool){
        if (selectedFilter == "Due Date") {
            self.assignmentlistrequest = FetchRequest(entity: Assignment.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
        }
            
        else if (selectedFilter == "Length") {
           self.assignmentlistrequest = FetchRequest(entity: Assignment.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.totaltime, ascending: true)])
        }
            
        else if (selectedFilter == "Class") {
            self.assignmentlistrequest = FetchRequest(entity: Assignment.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.subject, ascending: true)])
        }
            
        else if (selectedFilter == "Name") {
            self.assignmentlistrequest = FetchRequest(entity: Assignment.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.name, ascending: true)])
        }
            
        else if (selectedFilter == "Work Left") {
            self.assignmentlistrequest = FetchRequest(entity: Assignment.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.timeleft, ascending: true)])
        }
            
        else {
            self.assignmentlistrequest = FetchRequest(entity: Assignment.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.type, ascending: true)])
        }
        self.showCompleted = value
    }
    
    private func selectDeselect(_ singularassignment: Assignment) {
        if selection.contains(singularassignment) {
            selection.remove(singularassignment)
        } else {
            selection.insert(singularassignment)
        }
    }
    
    @State var incompleteAssignmentsThereBool: Bool = false
    
    func incompleteAssignmentsThereFunc() {
        incompleteAssignmentsThereBool = true
    }
    
    func noIncompleteAssignmentsThereFunc() -> Bool {
        for assignment in assignmentlist {
            if !assignment.completed {
                return false
            }
        }
        
        return true
    }
    
    var body: some View {
        VStack {
            Text(self.showCompleted ? "Completed Assignments" : "Incomplete Assignments").animation(.none).padding(.all, 2)
            
            if self.noIncompleteAssignmentsThereFunc() && !self.showCompleted {
                VStack {
                    Spacer()
                    Text("No Assignments").font(.title2).fontWeight(.bold)
                    HStack {
                        Text("Add an Assignment using the").foregroundColor(.gray).fontWeight(.semibold)
                        RoundedRectangle(cornerRadius: 3, style: .continuous).fill(Color.blue).frame(width: 15, height: 15).overlay(
                            ZStack {
                                Image(systemName: "plus").resizable().font(Font.title.weight(.bold)).foregroundColor(Color.white).frame(width: 9, height: 9)
                            }
                        )
                        Text("button").foregroundColor(.gray).fontWeight(.semibold)
                    }
                    Spacer()
                }.frame(height: UIScreen.main.bounds.size.height/2)
//                Spacer().frame(height: 100)
//                Image(systemName: "zzz").resizable().aspectRatio(contentMode: .fit).frame(width: UIScreen.main.bounds.size.width-100)
//                Image(systemName: "bed.double").resizable().aspectRatio(contentMode: .fit).frame(width: UIScreen.main.bounds.size.width-100)
//               // Image(colorScheme == .light ? "emptyassignment" : "emptyassignmentdark").resizable().aspectRatio(contentMode: .fit).frame(width: UIScreen.main.bounds.size.width-100)//.frame(width: UIScreen.main.bounds.size.width, alignment: .center)//.offset(x: -20)
//                Text("No Assignments!").font(.system(size: 40)).frame(width: UIScreen.main.bounds.size.width - 40, height: 100, alignment: .center).multilineTextAlignment(.center)
            }
            
            ScrollView {
                Spacer().frame(height:10)
                ForEach(assignmentlist) { assignment in
                  if (assignment.completed == self.showCompleted) {
                        VStack {
                            if (assignment.completed == true) {
                                GradedAssignmentsView(isExpanded2: self.selection.contains(assignment), isCompleted2: self.showCompleted, assignment2: assignment, selectededit: self.$sheetnavigator.selectedassignmentedit, showedit: self.$showassignmentedit).environment(\.managedObjectContext, self.managedObjectContext).onTapGesture {
                                        self.selectDeselect(assignment)
                                }.animation(.spring()).shadow(radius: 5)
                            }
                            
                            else {
                                IndividualAssignmentFilterView(isExpanded2: self.selection.contains(assignment), isCompleted2: self.showCompleted, assignment2: assignment, selectededit: self.$sheetnavigator.selectedassignmentedit, showedit: self.$showassignmentedit).environment(\.managedObjectContext, self.managedObjectContext).onTapGesture {
                                        self.selectDeselect(assignment)
                                }.animation(.spring()).shadow(radius: 5).onAppear(perform: incompleteAssignmentsThereFunc)
                            }
                        }
                    }
                }.animation(.spring())
                
//                if masterRunning.masterRunningNow {
//                    MasterClass()
//                }
            }
            
        }.sheet(isPresented: self.$showassignmentedit, content: {
                    EditAssignmentModalView(NewAssignmentPresenting: self.$showassignmentedit, selectedassignment: self.getassignmentindex(), assignmentname: self.assignmentlist2[self.getassignmentindex()].name, timeleft: Int(self.assignmentlist2[self.getassignmentindex()].timeleft), duedate: self.assignmentlist2[self.getassignmentindex()].duedate, iscompleted: self.assignmentlist2[self.getassignmentindex()].completed, gradeval: Int(self.assignmentlist2[self.getassignmentindex()].grade), assignmentsubject: self.assignmentlist2[self.getassignmentindex()].subject, assignmenttype: getassignmenttype()).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning)})//.animation(.spring())
    }
    func getassignmenttype() -> Int {
        for (index, assignmenttype) in assignmenttypes.enumerated() {
            if (assignmenttype ==  self.assignmentlist2[self.getassignmentindex()].type )
            {
                return index
            }
        }
        return 0
       // return Int(self.assignmenttypes.firstIndex(of: self.assignmentlist2[self.getassignmentindex()].type)!)
    }
    func getassignmentindex() -> Int {
        for (index, assignment) in assignmentlist2.enumerated() {
            if (assignment.name == sheetnavigator.selectedassignmentedit)
            {
                return index
            }
        }
        return 0
    }
}



struct FilterView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject var googleDelegate: GoogleDelegate


    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.subject, ascending: true)])

    var assignmentlist: FetchedResults<Assignment>
    
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [])
    
    var classlist: FetchedResults<Classcool>
    @State var NewAssignmentPresenting = false
    @State var NewClassPresenting = false
    @State var NewOccupiedtimePresenting = false
    @State var NewFreetimePresenting = false
    @State var NewGradePresenting = false
    @State var noClassesAlert = false
    @State var noAssignmentsAlert = false
    @State var completedvalue = false
    @State var showingSettingsView = false
    @State var modalView: ModalView = .none
    @State var alertView: AlertView = .noclass
    @State var NewSheetPresenting = false
    @State var NewAlertPresenting = false
    @ObservedObject var sheetNavigator = SheetNavigator()
    @State var showpopup = false
    @EnvironmentObject var masterRunning: MasterRunning
    @State var widthAndHeight: CGFloat = 50
    @FetchRequest(entity: Freetime.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Freetime.startdatetime, ascending: true)])
    var freetimelist: FetchedResults<Freetime>
    
    @ViewBuilder
    private func sheetContent() -> some View {
        
        if (self.sheetNavigator.modalView == .freetime)
        {
            
            NewFreetimeModalView(NewFreetimePresenting: self.$NewSheetPresenting).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning)
        }
        else if (self.sheetNavigator.modalView == .assignment)
        {
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
            ZStack {
//                NavigationLink(destination: EmptyView()) {
//                    EmptyView()
//                }
                NavigationLink(destination: SettingsView(), isActive: self.$showingSettingsView)
                 { EmptyView() }
                VStack {
                    DropDown(showCompleted2: $completedvalue).environment(\.managedObjectContext, self.managedObjectContext)
                }
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
                                     //   countnewassignments = 0
                                        
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
//                                            if (countnewassignments > 0)
//                                            {
//                                                VStack
//                                                {
//                                                    HStack
//                                                    {
//                                                        Spacer()
//                                                        ZStack
//                                                        {
//                                                            Circle().fill(Color.red).frame(width: 15, height: 15)
//                                                            Text(String(countnewassignments)).foregroundColor(Color.white).font(.system(size: 10)).frame(width: 15, height: 15)
//                                                        }.offset(x: 5, y: -5)
//                                                    }
//                                                    Spacer()
//                                                }
//                                            }
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
//                                        if (self.getcompletedAssignments())
//                                        {
                                            self.sheetNavigator.modalView = .grade
                                            self.NewSheetPresenting = true
//                                        }
//                                        else
//                                        {
//                                            self.sheetNavigator.alertView = .noassignment
//                                            self.NewAlertPresenting = true
//                                        }
                                        
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
                                    }.offset(x: -190, y: 10).shadow(radius: 5).opacity(classlist.count == 0 ? 0.5 : 1)//.opacity(!self.getcompletedAssignments() ? 0.5: 1)
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
            }
            .navigationBarItems(
                leading:
                HStack(spacing: UIScreen.main.bounds.size.width / 4.5) {
                    Button(action: {self.showingSettingsView = true}) {
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
                        Button(action: {
                          //  withAnimation(.spring())
                          //  {
                                self.completedvalue.toggle()
                          //  }
                            
                        }) {
                            Image(systemName: self.completedvalue ? "checkmark.circle.fill" : "checkmark.circle").resizable().scaledToFit().foregroundColor(colorScheme == .light ? Color.black : Color.white).font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
                        }
                }.padding(.top, 0)).navigationTitle("Assignments")
        }.navigationViewStyle(StackNavigationViewStyle())
        .onDisappear() {
            self.showingSettingsView = false
            self.showpopup = false
        }
    }
    func getcompletedAssignments() -> Bool {
        for assignment in assignmentlist {
            if (assignment.completed == true && assignment.grade == 0)
            {
                return true;
            }
        }
        return false
    }
    //hello
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
          
          return FilterView().environment(\.managedObjectContext, context)
    }
}


