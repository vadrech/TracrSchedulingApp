//
//  ClassesView.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 6/30/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import SwiftUI
import WidgetKit

struct ClassView: View {
    @ObservedObject var classcool: Classcool
    @Binding var startedToDelete: Bool
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [])
    var classlist: FetchedResults<Classcool>
    
    var body: some View {
        ZStack {
            if (classcool.color != "") {
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .fill(LinearGradient(gradient: Gradient(colors: classcool.color.contains("rgbcode") ? [GetColorFromRGBCode(rgbcode: classcool.color, number: 1), GetColorFromRGBCode(rgbcode: classcool.color, number: 2)] : [getcurrentolor(currentColor: classcool.color), getNextColor(currentColor: classcool.color)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: UIScreen.main.bounds.size.width - 20, height: (120)).shadow(radius: 5)
            }

            HStack {
                Text(classcool.name).font(.system(size: 24)).fontWeight(.bold).frame(width: classcool.assignmentnumber == 0 ? UIScreen.main.bounds.size.width/2 - 20 : UIScreen.main.bounds.size.width/2 + 40, height: 120, alignment: .leading)
                Spacer()
                if classcool.assignmentnumber == 0 && !self.startedToDelete {
                    Text("No Assignments").font(.system(size: 17)).fontWeight(.light)
                }
                else {
                    Text(String(classcool.assignmentnumber)).font(.title).fontWeight(.bold)
                }
            }.padding(.horizontal, 40)
        }
    }
    func getcurrentolor(currentColor: String) -> Color {
        return Color(currentColor)
    }
    
    func GetColorFromRGBCode(rgbcode: String, number: Int = 1) -> Color {
        if number == 1 {
            return Color(.sRGB, red: Double(rgbcode[9..<14])!, green: Double(rgbcode[15..<20])!, blue: Double(rgbcode[21..<26])!, opacity: 1)
        }
        
        return Color(.sRGB, red: Double(rgbcode[36..<41])!, green: Double(rgbcode[42..<47])!, blue: Double(rgbcode[48..<53])!, opacity: 1)
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

struct EditClassModalView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [])
    var classlist: FetchedResults<Classcool>
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [])
    var assignmentlist: FetchedResults<Assignment>
    
    @FetchRequest(entity: Subassignmentnew.entity(), sortDescriptors: [])
    var subassignmentlist: FetchedResults<Subassignmentnew>
    
    @Binding var showeditclass: Bool
    @State var currentclassname: String
    @State var classnamechanged: String
    @Binding var EditClassPresenting: Bool
    @State var classtolerancedouble: Double
    @State var classassignmentnumber: Int
    
    @EnvironmentObject var masterRunning: MasterRunning
    @ObservedObject var textfieldmanager: TextFieldManager

    let colorsa = ["one", "two", "three", "four", "five"]
    let colorsb = ["six", "seven", "eight", "nine", "ten"]
    let colorsc = ["eleven", "twelve", "thirteen", "fourteen", "fifteen"]
    
    @State private var coloraselectedindex: Int
    @State private var colorbselectedindex: Int
    @State private var colorcselectedindex: Int
    
    @State private var createclassallowed = true
    @State private var showingAlert = false
    
    @State var customcolor1: Color
    @State var customcolor2: Color
    @State var customcolorchosen: Bool

    init(showeditclass: Binding<Bool>, currentclassname: String, classnamechanged: String, EditClassPresenting: Binding<Bool>, classtolerancedouble: Double, classassignmentnumber: Int, classcolor: String)
    {
        self._showeditclass = showeditclass
        self._currentclassname = State(initialValue: currentclassname)
        self._classnamechanged = State(initialValue: classnamechanged)
        self._EditClassPresenting = EditClassPresenting
        self._classtolerancedouble = State(initialValue: classtolerancedouble)
        self._classassignmentnumber = State(initialValue: classassignmentnumber)
        textfieldmanager = TextFieldManager(blah: classnamechanged)
        self._coloraselectedindex = State(initialValue: -1)
        self._colorbselectedindex = State(initialValue: -1)
        self._colorcselectedindex = State(initialValue: -1)
        if (colorsa.contains(classcolor))
        {
            self._coloraselectedindex = State(initialValue: colorsa.firstIndex(of: classcolor)!)
            self._customcolor1 = State(initialValue: Color("one"))
            self._customcolor2 = State(initialValue: Color("one-b"))
            self._customcolorchosen = State(initialValue: false)

            //print(1)
        }
        else if (colorsb.contains(classcolor))
        {
            self._colorbselectedindex = State(initialValue: colorsb.firstIndex(of: classcolor)!)
            self._customcolor1 = State(initialValue: Color("one"))
            self._customcolor2 = State(initialValue: Color("one-b"))
            self._customcolorchosen = State(initialValue: false)

           // print(colorsb.firstIndex(of: classcolor)!)
            //print(2)
        }
        else if (colorsc.contains(classcolor))
        {
            self._colorcselectedindex = State(initialValue: colorsc.firstIndex(of: classcolor)!)
            self._customcolor1 = State(initialValue: Color("one"))
            self._customcolor2 = State(initialValue: Color("one-b"))
            self._customcolorchosen = State(initialValue: false)

           // print(3)
        }
        
        else { //custom color
            self._customcolor1 = State(initialValue: Color(.sRGB, red: Double(classcolor[9..<14])!, green: Double(classcolor[15..<20])!, blue: Double(classcolor[21..<26])!, opacity: 1))
            self._customcolor2 = State(initialValue: Color(.sRGB, red: Double(classcolor[36..<41])!, green: Double(classcolor[42..<47])!, blue: Double(classcolor[48..<53])!, opacity: 1))
            self._customcolorchosen = State(initialValue: true)
        }
        //print(coloraselectedindex!, colorbselectedindex!, colorcselectedindex!)
        print(classcolor)
        
    }
    
    func GetColorFromRGBCode(rgbcode: String, number: Int = 1) -> Color {
        if number == 1 {
            return Color(.sRGB, red: Double(rgbcode[9..<14])!, green: Double(rgbcode[15..<20])!, blue: Double(rgbcode[21..<26])!, opacity: 1)
        }
        
        return Color(.sRGB, red: Double(rgbcode[36..<41])!, green: Double(rgbcode[42..<47])!, blue: Double(rgbcode[48..<53])!, opacity: 1)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Class Name", text: $textfieldmanager.userInput).onTapGesture {
                        UIApplication.shared.endEditing()
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
//                                    path.addQuadCurve(to: CGPoint(x: (geometry.size.width / 2) + 9, y: (geometry.size.height / 2) + 7), control: CGPoint(x: (geometry.size.width / 2), y: ((geometry.size.height / 2) + 7) + CGFloat(4 * (self.classtolerancedouble - 3))))
//                                }.stroke((colorScheme == .light ? Color.black : Color.white), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
//                            }
//                        }
//                    }.padding(.bottom, 8)
//                }
                
                
                
                Section {
                    HStack {
                        Text("Color Presets").fontWeight(self.customcolorchosen ? .regular : .semibold)
                        
                        Spacer()
                        
                        VStack(spacing: 10) {
                            HStack(spacing: 10) {
                                ForEach(0 ..< 5) { colorindexa in
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color(self.colorsa[colorindexa])).frame(width: 25, height: 25)
                                        RoundedRectangle(cornerRadius: 5, style: .continuous).stroke(Color.black
                                            , lineWidth: (self.coloraselectedindex == colorindexa ? 3 : 1)).frame(width: 25, height: 25)
                                    }.onTapGesture {
                                        self.coloraselectedindex = colorindexa
                                        self.colorbselectedindex = -1
                                        self.colorcselectedindex = -1
                                        self.customcolorchosen = false
                                    }
                                }
                            }
                            HStack(spacing: 10) {
                                ForEach(0 ..< 5) { colorindexb in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color(self.colorsb[colorindexb])).frame(width: 25, height: 25)
                                        RoundedRectangle(cornerRadius: 5, style: .continuous).stroke(Color.black
                                        , lineWidth: (self.colorbselectedindex == colorindexb ? 3 : 1)).frame(width: 25, height: 25)
                                    }.onTapGesture {
                                        self.coloraselectedindex = -1
                                        self.colorbselectedindex = colorindexb
                                        self.colorcselectedindex = -1
                                        self.customcolorchosen = false
                                    }
                                }
                            }
                            HStack(spacing: 10) {
                                ForEach(0 ..< 5) { colorindexc in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color(self.colorsc[colorindexc])).frame(width: 25, height: 25)
                                        RoundedRectangle(cornerRadius: 5, style: .continuous).stroke(Color.black
                                    , lineWidth: (self.colorcselectedindex == colorindexc ? 3 : 1)).frame(width: 25, height: 25)
                                    }.onTapGesture {
                                        self.coloraselectedindex = -1
                                        self.colorbselectedindex = -1
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
                                if self.coloraselectedindex != -1 {
                                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                                        .fill(LinearGradient(gradient: Gradient(colors: [Color(self.colorsa[self.coloraselectedindex]), getNextColor(currentColor: self.colorsa[self.coloraselectedindex])]), startPoint: .leading, endPoint: .trailing))
                                        .frame(width: UIScreen.main.bounds.size.width - 80, height: (120 ))
                                    
                                }
                                else if self.colorbselectedindex != -1 {
                                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                                        .fill(LinearGradient(gradient: Gradient(colors: [Color(self.colorsb[self.colorbselectedindex]), getNextColor(currentColor: self.colorsb[self.colorbselectedindex])]), startPoint: .leading, endPoint: .trailing))
                                        .frame(width: UIScreen.main.bounds.size.width - 80, height: (120 ))
                                    
                                }
                                else if self.colorcselectedindex != -1 {
                                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                                        .fill(LinearGradient(gradient: Gradient(colors: [Color(self.colorsc[self.colorcselectedindex]), getNextColor(currentColor: self.colorsc[self.colorcselectedindex])]), startPoint: .leading, endPoint: .trailing))
                                        .frame(width: UIScreen.main.bounds.size.width - 80, height: (120 ))
                                    
                                }
                            }

                            VStack {
                                HStack {
                                    Text(self.textfieldmanager.userInput).font(.system(size: 22)).fontWeight(.bold)
                                    
                                    Spacer()
                                    
                                    if classassignmentnumber == 0 {
                                        Text("No Assignments").font(.body).fontWeight(.light)
                                    }
                                        
                                    else {
                                        Text(String(classassignmentnumber)).font(.title).fontWeight(.bold)
                                    }
                                }
                            }.padding(.horizontal, 25)
                        }
                    }.padding(.top, 8)
                }
                
                Section {
                    Button(action: {
                        let testname = self.textfieldmanager.userInput
                        
                        self.createclassallowed = true
                        
                        for classity in self.classlist {
                            if classity.name == testname && classity.name != self.currentclassname {
                                print("sdfds")
                                self.createclassallowed = false
                            }
                        }
                        
                        if testname == "" {
                            self.createclassallowed = false
                        }

                        if self.createclassallowed {
                            for classity in self.classlist {
                                if (classity.name == self.currentclassname) {
                                    classity.name = testname
                                    classity.tolerance  = Int64(self.classtolerancedouble.rounded(.down))
                                    
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
                                        
                                        classity.color = "rgbcode1-\(r1)-\(g1)-\(b1)-rgbcode2-\(r2)-\(g2)-\(b2)"
                                        print(classity.color)
                                    }
                                    
                                    else {
                                        if self.coloraselectedindex != -1 {
                                            classity.color = self.colorsa[self.coloraselectedindex]
                                        }
                                        else if self.colorbselectedindex != -1 {
                                            classity.color = self.colorsb[self.colorbselectedindex]
                                        }
                                        else if self.colorcselectedindex != -1 {
                                            classity.color = self.colorsc[self.colorcselectedindex]
                                        }
                                    }
                                    
                                    for assignment in self.assignmentlist {
                                        if (assignment.subject == classity.originalname) {
                                            assignment.color = classity.color
                                            for subassignment in self.subassignmentlist {
                                                if (subassignment.assignmentname == assignment.name) {
                                                    subassignment.color = classity.color
                                                }
                                            }
                                        }
                                    }
                                    do {
                                        try self.managedObjectContext.save()
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                    //run on all assignments of class (maybe special property in masterrunning)
                                    //get rid of tolerance and then comment this out!
                                    masterRunning.masterRunningNow = true
                                    print("I")
                                }
                            }
                            self.showeditclass = false
                            self.EditClassPresenting = false
                        }
                            
                        else {
                            print("Class with Same Name Exists; Change Name")
                            self.showingAlert = true
                        }
                    }) {
                        Text("Save Changes")
                    }.alert(isPresented: $showingAlert) {
                        Alert(title: Text("Class Already Exists"), message: Text("Change Class"), dismissButton: .default(Text("Continue")))
                    }
                }
            }.gesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onChanged { _ in
                UIApplication.shared.endEditing()
            }.onEnded { _ in
                UIApplication.shared.endEditing()
            }).navigationBarItems(trailing: Button(action: {
                self.showeditclass = false
                self.EditClassPresenting = false
            }, label: {Text("Cancel")})).navigationTitle("Edit Class").navigationBarTitleDisplayMode(.inline)
        }

//        if masterRunning.masterRunningNow {
//            MasterClass()
//        }
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
class SheetNavigatorEditClass: ObservableObject {
    @Published var showeditclass: Bool = false
    @Published var selectededitassignment: String = ""
}
struct DetailView: View {
    @State var EditClassPresenting = false
    @ObservedObject var classcool: Classcool
    @State private var selection: Set<Assignment> = []
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.completed, ascending: true), NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    
    @State var NewAssignmentPresenting: Bool = false
    @State var noClassesAlert: Bool = false
    @State var scalevalue: CGFloat = 1
    @State private var ocolor = Color.blue
    @State var showeditassignment: Bool = false
    @State var selectededitassignment: String = ""
    @State var NewSheetPresenting: Bool = false
    @ObservedObject var sheetnavigator: SheetNavigatorEditClass = SheetNavigatorEditClass()
    let assignmenttypes = ["Homework", "Study", "Test", "Essay", "Presentation/Oral", "Exam", "Report/Paper"]
    private func selectDeselect(_ singularassignment: Assignment) {
        if selection.contains(singularassignment) {
            selection.remove(singularassignment)
        } else {
            selection.insert(singularassignment)
        }
    }
    
    func getclassindex(classcool: Classcool) -> Int {
        for (index, element) in classlist.enumerated()
        {
            if (element == classcool)
            {
                return index
            }
        }
        return 0
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
    
    @EnvironmentObject var masterRunning: MasterRunning
    
    @ViewBuilder
    private func sheetContent() -> some View {
        
        if (!self.sheetnavigator.showeditclass)
        {
            EditAssignmentModalView(NewAssignmentPresenting: self.$NewSheetPresenting, selectedassignment: self.getassignmentindex(), assignmentname: self.assignmentlist[self.getassignmentindex()].name, timeleft: Int(self.assignmentlist[self.getassignmentindex()].timeleft), duedate: self.assignmentlist[self.getassignmentindex()].duedate, iscompleted: self.assignmentlist[self.getassignmentindex()].completed, gradeval: Int(self.assignmentlist[self.getassignmentindex()].grade), assignmentsubject: self.assignmentlist[self.getassignmentindex()].subject, assignmenttype: self.assignmenttypes.firstIndex(of: self.assignmentlist[self.getassignmentindex()].type)!).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning)
            
        }
        else
        {
            EditClassModalView(showeditclass: self.$sheetnavigator.showeditclass , currentclassname: self.classcool.name, classnamechanged: self.classcool.name, EditClassPresenting: self.$NewSheetPresenting, classtolerancedouble: Double(self.classcool.tolerance) + 0.5, classassignmentnumber: Int(self.classcool.assignmentnumber), classcolor: self.classcool.color).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning)
        }
    }
    var body: some View {
        ZStack {
            VStack {
                Text(classcool.name).font(.system(size: 24)).fontWeight(.bold) .frame(maxWidth: UIScreen.main.bounds.size.width-50, alignment: .center).multilineTextAlignment(.center)
                Spacer()
//                Text("Tolerance: " + String(classcool.tolerance)).padding(2)
                Spacer()
                
                ScrollView {
                    ForEach(assignmentlist) { assignment in
                        if (self.classcool.assignmentnumber != 0 && assignment.subject == self.classcool.originalname && assignment.completed == false) {
                            IndividualAssignmentFilterView(isExpanded2: self.selection.contains(assignment), isCompleted2: false, assignment2: assignment, selectededit: self.$sheetnavigator.selectededitassignment, showedit: self.$NewSheetPresenting).shadow(radius: 10).onTapGesture {
                                self.selectDeselect(assignment)
                            }
                        }
                    }.sheet(isPresented: $showeditassignment, content: {
                        EditAssignmentModalView(NewAssignmentPresenting: self.$showeditassignment, selectedassignment: self.getassignmentindex(), assignmentname: self.assignmentlist[self.getassignmentindex()].name, timeleft: Int(self.assignmentlist[self.getassignmentindex()].timeleft), duedate: self.assignmentlist[self.getassignmentindex()].duedate, iscompleted: self.assignmentlist[self.getassignmentindex()].completed, gradeval: Int(self.assignmentlist[self.getassignmentindex()].grade), assignmentsubject: self.assignmentlist[self.getassignmentindex()].subject, assignmenttype: self.assignmenttypes.firstIndex(of: self.assignmentlist[self.getassignmentindex()].type)!).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning)}).animation(.spring())
                    if (!getexistingassignments())
                    {
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
                            }
                            Spacer()
                        }.frame(height: UIScreen.main.bounds.size.height/2)
//                        Spacer().frame(height: 100)
//                        Image(colorScheme == .light ? "emptyassignment" : "emptyassignmentdark").resizable().aspectRatio(contentMode: .fit).frame(width: UIScreen.main.bounds.size.width-100)//.frame(width: UIScreen.main.bounds.size.width, alignment: .center)//.offset(x: -20)
//                        Text("No Assignments!").font(.system(size: 40)).frame(width: UIScreen.main.bounds.size.width - 40, height: 100, alignment: .center).multilineTextAlignment(.center)
                        
                    }
                    if (getCompletedAssignmentNumber() > 0)
                    {
                        HStack {
                            VStack {
                                Divider()
                            }
                            Text("Completed Assignments").frame(width: 200)
                            VStack {
                                Divider()
                            }
                        }.animation(.spring())
                        ForEach(assignmentlist) {
                            assignment in
                            if (self.classcool.assignmentnumber != -1 && assignment.subject == self.classcool.originalname && assignment.completed == true) {
                                GradedAssignmentsView(isExpanded2: self.selection.contains(assignment), isCompleted2: true, assignment2: assignment, selectededit: self.$sheetnavigator.selectededitassignment, showedit: self.$NewSheetPresenting).shadow(radius: 10).onTapGesture {
                                    self.selectDeselect(assignment)
                                }
                            }
                        }
//                        .sheet(isPresented: $showeditassignment, content: {
//                            EditAssignmentModalView(NewAssignmentPresenting: self.$showeditassignment, selectedassignment: self.getassignmentindex(), assignmentname: self.assignmentlist[self.getassignmentindex()].name, timeleft: Int(self.assignmentlist[self.getassignmentindex()].timeleft), duedate: self.assignmentlist[self.getassignmentindex()].duedate, iscompleted: self.assignmentlist[self.getassignmentindex()].completed, gradeval: Int(self.assignmentlist[self.getassignmentindex()].grade), assignmentsubject: self.assignmentlist[self.getassignmentindex()].subject).environment(\.managedObjectContext, self.managedObjectContext)}).animation(.spring())
                    }
                    
//                    if masterRunning.masterRunningNow {
//                        MasterClass()
//                    }
                }
            }.navigationBarItems(trailing: Button(action: {
                self.NewSheetPresenting = true
                sheetnavigator.showeditclass.toggle()
                
            })
            { Text("Edit Class").frame(height: 100, alignment: .trailing) }
            ).sheet(isPresented: $NewSheetPresenting, content: sheetContent)
            VStack {
                Spacer()
                HStack {
                    Spacer()

                    Button(action: {
                        self.classlist.count > 0 ? self.NewAssignmentPresenting.toggle() : self.noClassesAlert.toggle()
//                        self.scalevalue = self.scalevalue == 1.5 ? 1 : 1.5
//                        self.ocolor = self.ocolor == Color.blue ? Color.green : Color.blue
                        
                    }) {
                        RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.blue).frame(width: 70, height: 70).scaleEffect(self.scalevalue).padding(20).overlay(
                            ZStack {
                                //Circle().strokeBorder(Color.black, lineWidth: 0.5).frame(width: 50, height: 50)
                                Image(systemName: "plus").resizable().font(Font.title.weight(.bold)).foregroundColor(Color.white).frame(width: 12, height: 12).offset(x: -12, y: 12).scaleEffect(self.scalevalue)
                                Image(systemName: "doc.plaintext").resizable().foregroundColor(Color.white).scaledToFit().frame(width: 21).offset(x: 5, y: -5).scaleEffect(self.scalevalue)
                            }
                        ).shadow(radius: 50)
                    }.buttonStyle(PlainButtonStyle()).animation(.spring()).sheet(isPresented: $NewAssignmentPresenting, content: { NewGoogleAssignmentModalView(NewAssignmentPresenting: self.$NewAssignmentPresenting, selectedClass: self.getclassindex(classcool: self.classcool), preselecteddate: -1).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning)}).alert(isPresented: $noClassesAlert) {
                        Alert(title: Text("No Classes Added"), message: Text("Add a Class First"))
                    }
                }
            }
        }
    }
    
    func getexistingassignments() -> Bool {
        for assignment in assignmentlist {
            if (assignment.subject == classcool.originalname)
            {
                return true
            }
        }
        return false
    }
    func getCompletedAssignmentNumber() -> Int {
        
        
        var ans: Int = 0
        for assignment in assignmentlist {
            if (assignment.subject == self.classcool.originalname && assignment.completed == true)
            {
                ans += 1
            }
        }
        return ans
    }
}

enum MasterErrors: Error {
    case ImpossibleDueDate
}

struct MasterClass: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    var assignmentlistrequest: FetchRequest<Assignment> = FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    var assignmentlist: FetchedResults<Assignment>{assignmentlistrequest.wrappedValue}

    //@FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
   // var assignmentlist: FetchedResults<Assignment>
    
    @FetchRequest(entity: Freetime.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Freetime.startdatetime, ascending: true)])
    var freetimelist: FetchedResults<Freetime>
    @FetchRequest(entity: Subassignmentnew.entity(), sortDescriptors: [])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
//    var subassignmentlistrequest: FetchRequest<Subassignmentnew> = FetchRequest(entity: Subassignmentnew.entity(),
//                                                                       sortDescriptors: [])
//    var subassignmentlist: FetchedResults<Subassignmentnew>{subassignmentlistrequest.wrappedValue}
        @FetchRequest(entity: AssignmentTypes.entity(), sortDescriptors: [])
    
    var assignmenttypeslist: FetchedResults<AssignmentTypes>
    var startOfDay: Date {
//        let timezoneOffset =  TimeZone.current.secondsFromGMT()
        
        return Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: 0)))
        //may need to be changed to timeintervalsincenow: 0 because startOfDay automatically adds 2 hours to input date before calculating start of day
    }
    
    @EnvironmentObject var masterRunning: MasterRunning
    
    func theBigMaster() {
        WidgetCenter.shared.reloadTimelines(ofKind: "Today's Tasks")
      //  print("Signal Received.")
        
        if masterRunning.displayText {
            masterRunning.masterDisplay = true
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1700)) {
                masterRunning.masterDisplay = false
            }
            masterRunning.displayText = false
        }
        
        if masterRunning.onlyNotifications {
            print("notifications thing being run 1")
            schedulenotifications()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(200)) {
                masterRunning.onlyNotifications = false
                print("notifications thing being run 2 - set false")
            }
        }
        
        else if masterRunning.masterRunningNow {
            print("SUPPOSED TO BE RUN")
            if (masterRunning.uniqueAssignmentName != "")
            {
                assignmentspecificmaster()
            }
            else
            {
               

                    master()
                    
                
            }
            masterRunning.masterRunningNow = false
            masterRunning.uniqueAssignmentName = ""
            schedulenotifications()
        }
        
       // print("Terminating Signal.")
    }
    
    func schedulenotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
       
        let calendar = Calendar.current
        
        let times = [0, 5, 10, 15, 30]

        // show this notification five seconds from now
     //   print(subassignmentlist.count)
        let defaults = UserDefaults.standard
        let array = defaults.object(forKey: "savedassignmentnotifications") as? [String] ?? ["At Start"]
        let array2 = defaults.object(forKey: "savedbreaknotifications") as? [String] ?? ["None"]
        //let array2 = defaults.object(forKey: "savedbreaknotifications") as? [String] ?? ["None"]
        let beforeassignmenttimes = ["At Start", "5 minutes", "10 minutes", "15 minutes", "30 minutes"]

        var listofnotifications: [DateComponents] = []
        for subassignment in subassignmentlist {
            for (index, val) in beforeassignmenttimes.enumerated() {
                if (array.contains(val))
                {
                    let content = UNMutableNotificationContent()
                    if (index == 0)
                    {
                        content.title = "Task starting now: "
                    }
                    else{
                        
                        content.title = "Upcoming Task " + "in " + String(times[index]) + " minutes: "
                    }
                    
                       content.body = subassignment.assignmentname
                       content.sound = UNNotificationSound.default

                    let datevalue = Date(timeInterval: TimeInterval(-1*times[index]*60), since: subassignment.startdatetime)
                        let components = calendar.dateComponents([Calendar.Component.minute,Calendar.Component.hour,Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: datevalue)
                        listofnotifications.append(components)
                        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

                        // choose a random identifier
                        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                        // add our notification request
                        UNUserNotificationCenter.current().add(request)

                }
                    if (array2.contains(val))
                    {
                        let content = UNMutableNotificationContent()
                           content.title = "Task Ending " + "in " + String(times[index]) + " minutes: "
                              content.body = subassignment.assignmentname
                           content.sound = UNNotificationSound.default

                        let datevalue = Date(timeInterval: TimeInterval(-1*times[index]*60), since: subassignment.enddatetime)
                            let components = calendar.dateComponents([Calendar.Component.minute,Calendar.Component.hour,Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: datevalue)
                        listofnotifications.append(components)
                            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

                            // choose a random identifier
                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                            // add our notification request
                            UNUserNotificationCenter.current().add(request)
                    }
            }
        }
    }
    
    func bulk(assignment: Assignment, daystilldue: Int, totaltime: Int, bulk: Bool, dateFreeTimeDict: [Date: Int])  -> ([(Int, Int)], Int, Bool)
    {
        let safetyfraction:Double = daystilldue > 20 ? (daystilldue > 100 ? 0.95 : 0.9) : (daystilldue > 7 ? 0.75 : 1)
        var tempsubassignmentlist: [(Int, Int)] = []
        var newd = Int(ceil(Double(daystilldue)*Double(safetyfraction)))
        let defaults = UserDefaults.standard
        _ = defaults.object(forKey: "savedbreakvalue") as? Int ?? 10
//        guard newd > 0 else {
//            throw MasterErrors.ImpossibleDueDate
//        }
        let totaltime = totaltime
        var possible: Bool = true

        var approxlength = 0
        if (bulk) {
            for classity in classlist {
                if (classity.originalname == assignment.subject)
                {
                    for assignmenttype in assignmenttypeslist {
                        if (assignmenttype.type == assignment.type)
                        {
                            //we're removing tolerance; yayyyyyy
                            approxlength = Int(assignmenttype.rangemin + ((assignmenttype.rangemax - assignmenttype.rangemin)/5) * classity.tolerance)
                        }
                    }
                }
            }
            approxlength = Int(ceil(CGFloat(approxlength)/CGFloat(5))*5)

        }
        newd = max(newd, 1)
        
        if (Int(ceil(CGFloat(CGFloat(totaltime)/CGFloat(newd))/CGFloat(5))*5) > approxlength)
        {
            approxlength = Int(ceil(CGFloat(CGFloat(totaltime)/CGFloat(newd))/CGFloat(5))*5)
        }
        

        var possibledays = 0
        var possibledayslist: [Int] = []
        var notpossibledayslist: [Int] = []
        var ntotal = Int(ceil(CGFloat(totaltime)/CGFloat(approxlength)))
        var extratime: Int = 0
        if (ntotal == 1)
        {
            approxlength = totaltime
        }
        if (totaltime <= 60)
        {
            approxlength = totaltime
            ntotal = 1
        }
        print("approxlength", approxlength, ntotal)
        print(dateFreeTimeDict[startOfDay]!)
        for i in 0..<newd {
            if ( dateFreeTimeDict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!]! >= approxlength) {
                possibledays += 1
                possibledayslist.append(i)
            }
        }
    
        if (ntotal <= possibledays)
        {
            
            if (ntotal == possibledays)
            {
                var sumsy = 0
                for i in 0..<ntotal-1 {
                    tempsubassignmentlist.append((possibledayslist[i], approxlength))
                    sumsy += approxlength
                }
                tempsubassignmentlist.append((possibledayslist[ntotal-1], totaltime-sumsy))
            }
            else
            {
                // needs to be fixed :)))))))))))))))))))))
                let breaks = possibledays-ntotal
                let breakworkratio = Int(floor(Double(breaks)/Double(ntotal)))
                let x = ntotal*(breakworkratio+1)-breaks
                
                var breaklist: [Int] = []
                if (x-1 >= 0)
                {
                    for _ in 0...(x-1)
                    {
                        breaklist.append(breakworkratio)
                    }
                }
                if (ntotal-x-1 >= 0)
                {
                    for _ in 0...(ntotal-x-1)
                    {
                        breaklist.append(breakworkratio+1)
                    }
                }

                var counter = 0
                var sumsy = 0
                print(breaklist, possibledayslist, ntotal, x, breakworkratio, possibledays)
                for i in 0...(ntotal-1)
                {
                    tempsubassignmentlist.append((possibledayslist[counter], approxlength))
                    sumsy += approxlength
                    counter += 1
                    counter += breaklist[i]
                }
   
//                if (tempsubassignmentlist.count > 0)
//                {
//                    tempsubassignmentlist[tempsubassignmentlist.count-1].1 -= (sumsy-totaltime)
//                }
                while (sumsy != totaltime)
                {
                    var possible: Bool = false
                    for (index, _) in tempsubassignmentlist.enumerated()
                    {
                        if (tempsubassignmentlist[index].1 >= 45)
                        {
                            possible = true
                            let stuff = min(15, sumsy-totaltime);
                            sumsy -= stuff
                            tempsubassignmentlist[index].1 -= stuff
                            
                        }
                    }
                    if (!possible)
                    {
                        
                        print("Charan thought...")
                        break
                    }
                }
            }
        }
        else {
            extratime = totaltime - approxlength*possibledays
            for i in 0..<newd {
                if ( dateFreeTimeDict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!]! < approxlength) {
                    notpossibledayslist.append(i)
                }
            }
            print(notpossibledayslist)

            for value in notpossibledayslist {

                
                if (dateFreeTimeDict[Calendar.current.date(byAdding: .day, value: value, to: startOfDay)!]! >= 30) // could be a different more dynamic bound
                {

                    if (extratime > dateFreeTimeDict[Calendar.current.date(byAdding: .day, value: value, to: startOfDay)!]!)
                    {
                        tempsubassignmentlist.append((value,dateFreeTimeDict[Calendar.current.date(byAdding: .day, value: value, to: startOfDay)!]! ))
                        extratime -= dateFreeTimeDict[Calendar.current.date(byAdding: .day, value: value, to: startOfDay)!]!
                    }
                    else
                    {

                        tempsubassignmentlist.append((value, extratime))
                        extratime = 0
                    }
                    if (extratime == 0) {
                        break;
                    }
                }
            }
            if (extratime == 0)
            {
                for day in possibledayslist {
                    tempsubassignmentlist.append((day, approxlength))
                }
            }
            else
            {
                for day in possibledayslist {
                    tempsubassignmentlist.append((day, approxlength))
                }
                if (extratime <= 15)
                {
                    for i in 0..<tempsubassignmentlist.count {
                        if (dateFreeTimeDict[Calendar.current.date(byAdding: .day, value: tempsubassignmentlist[i].0, to: startOfDay)!]! >= tempsubassignmentlist[i].1 + extratime)
                        {
                            tempsubassignmentlist[i].1 += extratime
                            extratime = 0;
                        }
                    }
                }
                else
                {
                    for i in 0..<possibledayslist.count {
                        for j in 0..<tempsubassignmentlist.count {
                            if (tempsubassignmentlist[j].0 == possibledayslist[i])
                            {
                                //set the last value to something dynamic or reasonable
                                let value = min(extratime, dateFreeTimeDict[Calendar.current.date(byAdding: .day, value: tempsubassignmentlist[j].0, to: startOfDay)!]! - tempsubassignmentlist[j].1, 1000 )
                                tempsubassignmentlist[j].1 += value
                                extratime -= value
                                if (extratime == 0)
                                {
                                    break
                                }
                            }
                            
                        }
                        if (extratime == 0)
                        {
                            break
                        }
                    }
                }
                if (extratime != 0)
                {
                    print("EPIC FAIL")
                    possible = false
                }

            }
        }
        print(tempsubassignmentlist, extratime, possible)
        return (tempsubassignmentlist, extratime, possible)
    }
    func assignmentspecificmaster()
    {
        let namey: String = masterRunning.uniqueAssignmentName
        print("assignmentspecific master on " + masterRunning.uniqueAssignmentName)
       masterRunning.uniqueAssignmentName = ""
        var pastassignmenttime = 0

        for (index, val) in subassignmentlist.enumerated() {
            if (val.assignmentname == namey)
            {
                if (val.startdatetime > Date())
                {
                    print(val.assignmentname)
                    self.managedObjectContext.delete(self.subassignmentlist[index])
                }
                else
                {
                    pastassignmenttime += Calendar.current.dateComponents([.minute], from: val.startdatetime, to: val.enddatetime).minute!
                }
            }
        }

        do {
            try self.managedObjectContext.save()
        } catch {
            print("error fail 1")
            print(error.localizedDescription)
        }
        var counterb: Int = 0
        for classitye in classlist {
            counterb = 0
            for assignmentye in assignmentlist {
                if (assignmentye.subject == classitye.originalname) && (assignmentye.completed == false) {
                    counterb = counterb + 1
                }
            }
            classitye.assignmentnumber = Int64(counterb)
        }

        do {
            try self.managedObjectContext.save()
        } catch {
            print("error fail 2")
            print(error.localizedDescription)
        }
       


        

        var timemonday = 0
        var timetuesday = 0
        var timewednesday = 0
        var timethursday = 0
        var timefriday = 0
        var timesaturday = 0
        var timesunday = 0
        _ = Date(timeInterval: 86300, since: startOfDay)
        _ = Date(timeInterval: 86300, since: startOfDay)
        _ = Date(timeInterval: 86300, since: startOfDay)
        _ = Date(timeInterval: 86300, since: startOfDay)
        _ = Date(timeInterval: 86300, since: startOfDay)
        _ = Date(timeInterval: 86300, since: startOfDay)
        _ = Date(timeInterval: 86300, since: startOfDay)

        var monfreetimelist:[(Date, Date)] = [], tuefreetimelist:[(Date, Date)] = [], wedfreetimelist:[(Date, Date)] = [], thufreetimelist:[(Date, Date)] = [], frifreetimelist:[(Date, Date)] = [], satfreetimelist:[(Date, Date)] = [], sunfreetimelist:[(Date, Date)] = []


        var latestDate = Date(timeIntervalSinceNow: TimeInterval(0))
        var dateFreeTimeDict = [Date: Int]()
        var specificdatefreetimedict = [Date: [(Date,Date)]]()
        //initial subassignment objects are added just as (assignmentname, length of subassignment)
        var subassignmentdict = [Int: [(String, Int)]]()

        for freetime in freetimelist {
            if (freetime.monday) {
                timemonday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
                monfreetimelist.append((freetime.startdatetime, freetime.enddatetime))

            }
            if (freetime.tuesday) {
                timetuesday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
                tuefreetimelist.append((freetime.startdatetime, freetime.enddatetime))

            }
            if (freetime.wednesday) {
                timewednesday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
                wedfreetimelist.append((freetime.startdatetime, freetime.enddatetime))
            }
            if (freetime.thursday) {
                timethursday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
                thufreetimelist.append((freetime.startdatetime, freetime.enddatetime))
            }
            if (freetime.friday) {
                timefriday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
                frifreetimelist.append((freetime.startdatetime, freetime.enddatetime))
            }

            if (freetime.saturday) {
                timesaturday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
                satfreetimelist.append((freetime.startdatetime, freetime.enddatetime))
            }
            if (freetime.sunday) {
                timesunday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
                sunfreetimelist.append((freetime.startdatetime, freetime.enddatetime))
            }
        }
        var generalfreetimelist = [timesunday, timemonday, timetuesday, timewednesday, timethursday, timefriday, timesaturday]

        let actualfreetimeslist = [sunfreetimelist, monfreetimelist, tuefreetimelist, wedfreetimelist, thufreetimelist, frifreetimelist, satfreetimelist, sunfreetimelist]
        for (index, _) in generalfreetimelist.enumerated() {
                generalfreetimelist[index] = Int(Double(generalfreetimelist[index])/Double(5) * 5)

        }

        for assignment in assignmentlist {
            latestDate = max(latestDate, assignment.duedate)
        }

        let daystilllatestdate = Calendar.current.dateComponents([.day], from: Date(timeIntervalSinceNow: TimeInterval(0)), to: latestDate).day!

        for i in 0...daystilllatestdate {
            subassignmentdict[i] = []

            dateFreeTimeDict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!] = generalfreetimelist[(Calendar.current.component(.weekday, from: Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!) - 1)]

            specificdatefreetimedict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!] = actualfreetimeslist[(Calendar.current.component(.weekday, from: Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!) - 1)]

        }
        print("time to schedule today" ,dateFreeTimeDict[startOfDay]!)
        //not necessary because no one-off free times for now
//        for freetime in freetimelist {
//            if (!freetime.monday && !freetime.tuesday && !freetime.wednesday && !freetime.thursday && !freetime.friday && !freetime.saturday && !freetime.sunday) {
//
//                if (freetime.enddatetime > Date())
//                {
//                    dateFreeTimeDict[Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: freetime.startdatetime))]! += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
//                    specificdatefreetimedict[Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: freetime.startdatetime))]!.append((freetime.startdatetime, freetime.enddatetime))
//                }
//
//            }
//        }

        // look at free times objects that have passed today
//        print(specificdatefreetimedict[startOfDay]![0].0, specificdatefreetimedict[startOfDay]![0].1)
        var deletelist: [Int] = []
        var changelist: [Int] = []
        for (index,(start, end)) in specificdatefreetimedict[startOfDay]!.enumerated()
        {
            if ((Calendar.current.dateComponents([.minute], from: Date(timeIntervalSince1970: 0), to: end).minute!) <  Calendar.current.dateComponents([.minute], from: startOfDay, to: Date(timeIntervalSinceNow: 0)).minute!)
            {
                print("fail1")
                print(end.description, Date().description, startOfDay.description)
                dateFreeTimeDict[startOfDay]! -= Calendar.current.dateComponents([.minute], from: start, to: end).minute!
                deletelist.append(index)
            }
            else if (Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for: start), to: start).minute! < Calendar.current.dateComponents([.minute], from: startOfDay, to: Date(timeIntervalSinceNow: 0)).minute! && Calendar.current.dateComponents([.minute], from: Date(timeIntervalSince1970: 0), to: end).minute! > Calendar.current.dateComponents([.minute], from: startOfDay, to: Date(timeIntervalSinceNow: 0)).minute!)
            {
                print("fail2")
                dateFreeTimeDict[startOfDay]! -= (Calendar.current.dateComponents([.minute], from: startOfDay, to: Date(timeIntervalSinceNow: 0)).minute! - Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for: start), to: start).minute! )
                dateFreeTimeDict[startOfDay]! -= (dateFreeTimeDict[startOfDay]! % 5)
                changelist.append(index)
            }
        }
        for index in changelist
        {
            var minutesfromstart = Calendar.current.dateComponents([.minute], from: startOfDay, to: Date()).minute!
            minutesfromstart += 5 - (minutesfromstart % 5)
            print(minutesfromstart)
            //something is wrong here with the -3600
            specificdatefreetimedict[startOfDay]![index].0 = Date(timeInterval: TimeInterval(minutesfromstart*60-3600), since: Date(timeIntervalSince1970: 0))
        }
        var counter = 0

        let deletelistsize = deletelist.count
        for index in 0..<deletelistsize
        {
            specificdatefreetimedict[startOfDay]!.remove(at: index-counter)
            counter += 1
        }
        print("datefreetimedict today" ,dateFreeTimeDict[startOfDay]!)
//        print(specificdatefreetimedict[startOfDay]![0].0, specificdatefreetimedict[startOfDay]![0].1)
        
        for subassignment in subassignmentlist
        {
            if (subassignment.enddatetime < Date())
            {
                continue
            }
            if (Calendar.current.startOfDay(for: subassignment.startdatetime) != startOfDay)
            {
             //   let subassignmentdaysfromnow =  Calendar.current.dateComponents([.day], from: startOfDay, to: Calendar.current.startOfDay(for: subassignment.startdatetime)).day!
                dateFreeTimeDict[Calendar.current.startOfDay(for: subassignment.startdatetime)]! -= Calendar.current.dateComponents([.minute], from: subassignment.startdatetime, to: subassignment.enddatetime).minute!
              //  subassignmentdict[subassignmentdaysfromnow]!.append((subassignment.assignmentname,  Calendar.current.dateComponents([.minute], from: subassignment.startdatetime, to: subassignment.enddatetime).minute!))

            }
            else
            {
                
                if (subassignment.enddatetime > Date() && subassignment.startdatetime < Date())
                {
                    //add logic not to move the position of this subassignment
                    dateFreeTimeDict[Calendar.current.startOfDay(for: subassignment.startdatetime)]! -= Calendar.current.dateComponents([.minute], from: Date(), to: subassignment.enddatetime).minute!
                    dateFreeTimeDict[Calendar.current.startOfDay(for: subassignment.startdatetime)]! -= dateFreeTimeDict[Calendar.current.startOfDay(for: subassignment.startdatetime)]! % 5
                    print(dateFreeTimeDict[startOfDay]!, dateFreeTimeDict[Calendar.current.startOfDay(for: subassignment.startdatetime)]!)
                    for (index, (start, _)) in specificdatefreetimedict[startOfDay]!.enumerated()
                    {
                       if (Calendar.current.dateComponents([.minute], from: start, to: Date()).minute! <= 1)
                       {
                        specificdatefreetimedict[startOfDay]![index].0 = Date(timeIntervalSince1970: TimeInterval(Calendar.current.dateComponents([.second], from: startOfDay, to: subassignment.enddatetime).second!))
                            if (Calendar.current.dateComponents([.minute], from: specificdatefreetimedict[startOfDay]![index].0, to: specificdatefreetimedict[startOfDay]![index].1).minute! < 30)
                            {
                                print("kewlio")
                                dateFreeTimeDict[startOfDay]! -= Calendar.current.dateComponents([.minute], from: specificdatefreetimedict[startOfDay]![index].0, to: specificdatefreetimedict[startOfDay]![index].1).minute!
                                print(dateFreeTimeDict[startOfDay]!)
                                specificdatefreetimedict[startOfDay]!.remove(at: index)
                            }
                            break
                       }
                    }

                }
                else if (subassignment.startdatetime > Date())
                {
                   // let subassignmentdaysfromnow =  Calendar.current.dateComponents([.day], from: startOfDay, to: Calendar.current.startOfDay(for: subassignment.startdatetime)).day!
                    dateFreeTimeDict[Calendar.current.startOfDay(for: subassignment.startdatetime)]! -= Calendar.current.dateComponents([.minute], from: subassignment.startdatetime, to: subassignment.enddatetime).minute!
                  //  subassignmentdict[0]!.append((subassignment.assignmentname,  Calendar.current.dateComponents([.minute], from: subassignment.startdatetime, to: subassignment.enddatetime).minute!))

                }
            }
        }
        print("datefreetimedict today after subassignment adjustment", dateFreeTimeDict[startOfDay]!)
//        print(specificdatefreetimedict[startOfDay]![0].0, specificdatefreetimedict[startOfDay]![0].1)
        //may cause mass destruction
        var assignmentindex: Int = 0
        var lastincompleteassignmentindex: Int = -1
        var found: Bool = false
        for (index, assignment) in assignmentlist.enumerated()
        {
            if (namey == assignment.name)
            {
                assignmentindex = index
                found = true
                break
            }
            if (!assignment.completed)
            {
                lastincompleteassignmentindex = index
            }
        }
        if (!found)
        {
            print("No assignment with this name was found " + namey)
            return
        }
  //      let assignmentobject: Assignment = assignmentobjec
        

        let daystilldue = Calendar.current.dateComponents([.day], from: Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: 0))), to:  Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: Date(timeInterval: 0, since: assignmentlist[assignmentindex].duedate)))).day!
        var nextbest: Int = 1
        var extratime: Int = 0
        var subassignments = [(Int, Int)]()
        var possible:Bool = false
        var tempsubassignmentdict = [Int: [(String, Int)]]()
        for i in 0...daystilllatestdate
        {
            tempsubassignmentdict[i] = []
        }
 
       (subassignments, extratime, possible) = bulk(assignment: assignmentlist[assignmentindex], daystilldue: daystilldue, totaltime: Int(assignmentlist[assignmentindex].timeleft)-pastassignmenttime, bulk: true, dateFreeTimeDict: dateFreeTimeDict)
        for (daysfromnow, lengthofwork) in subassignments {
            //dateFreeTimeDict[Calendar.current.date(byAdding: .day, value: daysfromnow, to: startOfDay)!]! -= lengthofwork
            tempsubassignmentdict[daysfromnow]!.append((assignmentlist[assignmentindex].name, lengthofwork))
        }
     //   let (subassignments, _, _) = try bulk(assignment: assignment, daystilldue: daystilldue, totaltime: Int(assignment.timeleft), bulk: true, dateFreeTimeDict: dateFreeTimeDict)



        if (possible)
        {
            print(subassignments)
            for (daysfromnow, lengthofwork) in subassignments {
                dateFreeTimeDict[Calendar.current.date(byAdding: .day, value: daysfromnow, to: startOfDay)!]! -= lengthofwork
                subassignmentdict[daysfromnow]!.append((assignmentlist[assignmentindex].name, lengthofwork))
            }
            for i in 0...daystilllatestdate
            {
                print(i, subassignmentdict[i]!.count)
            }
            for subassignment in subassignmentlist
            {
                if (subassignment.enddatetime < Date())
                {
                    continue
                }
                if (Calendar.current.startOfDay(for: subassignment.startdatetime) != startOfDay)
                {
                   let subassignmentdaysfromnow =  Calendar.current.dateComponents([.day], from: startOfDay, to: Calendar.current.startOfDay(for: subassignment.startdatetime)).day!
                   subassignmentdict[subassignmentdaysfromnow]!.append((subassignment.assignmentname,  Calendar.current.dateComponents([.minute], from: subassignment.startdatetime, to: subassignment.enddatetime).minute!))

                }
                else
                {
                    // this may cause problems because it assumes there are no existing subassignments today that have been passed but not completed
                    
                    if (subassignment.enddatetime > Date() && subassignment.startdatetime < Date())
                    {
                        //add logic not to move the position of this subassignment
                        //could change the from: Date() to from: subassignment.startdatetime assuming this isn't referenced anywhere else
                       // subassignmentdict[0]!.append((subassignment.assignmentname,  Calendar.current.dateComponents([.minute], from: Date(), to: subassignment.enddatetime).minute!))

                    }
                    else if (subassignment.startdatetime > Date())
                    {
                        subassignmentdict[0]!.append((subassignment.assignmentname,  Calendar.current.dateComponents([.minute], from: subassignment.startdatetime, to: subassignment.enddatetime).minute!))

                    }
                }
            }
            print("possible")
        }
        else
        {
            
            var overalloverallpossible: Bool = false
            var dateFreeTimeDictCopy: [Date: Int] = dateFreeTimeDict
            var overallpossible: Bool = true

            print(assignmentindex, assignmentlist.count)
            while (assignmentindex+nextbest < assignmentlist.count)
            {
                if (assignmentlist[assignmentindex+nextbest].completed)
                {
                    nextbest += 1
                    continue
                }
                print(nextbest)
                dateFreeTimeDict = dateFreeTimeDictCopy
                for i in 0...daystilllatestdate
                {
                    tempsubassignmentdict[i] = []
                }
                for (index, val) in subassignmentlist.enumerated() {
                    if (val.assignmentname == assignmentlist[assignmentindex+nextbest].name && val.startdatetime > Date())
                    {
                        dateFreeTimeDict[Calendar.current.startOfDay(for: val.startdatetime)]! += Calendar.current.dateComponents([.minute], from: val.startdatetime, to: val.enddatetime).minute!
                        self.managedObjectContext.delete(self.subassignmentlist[index])
                    }
                    
                }
                print("kewl")

                dateFreeTimeDictCopy = dateFreeTimeDict
                overallpossible = true
                for i in 0...(nextbest+1)
                {
                     (subassignments, extratime, possible) = bulk(assignment: assignmentlist[assignmentindex+i], daystilldue: Calendar.current.dateComponents([.day], from: Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: 0))), to:  Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: Date(timeInterval: 0, since: assignmentlist[assignmentindex+i].duedate)))).day!, totaltime: Int(assignmentlist[assignmentindex+i].timeleft)-pastassignmenttime, bulk: true, dateFreeTimeDict: dateFreeTimeDict)
                    if (!possible && assignmentindex+nextbest < lastincompleteassignmentindex)
                    {
                        overallpossible = false
                        break
                    }
                    if (!possible && assignmentindex+nextbest == lastincompleteassignmentindex)
                    {
                        overallpossible = false
                    }
                    for (daysfromnow, lengthofwork) in subassignments {
                        dateFreeTimeDict[Calendar.current.date(byAdding: .day, value: daysfromnow, to: startOfDay)!]! -= lengthofwork
                        tempsubassignmentdict[daysfromnow]!.append((assignmentlist[assignmentindex+i].name, lengthofwork))
                    }
                }
                if (!overallpossible && assignmentindex+nextbest == lastincompleteassignmentindex)
                {
                    print("Being Scheduled but assignment needs to be shortened or work hours incresed")
                    overallpossible = true
                }
                if (overallpossible)
                {
                    break
                }
                

                nextbest += 1
            }

            for (index, assignment) in assignmentlist.enumerated()
            {
                for subassignment in subassignmentlist
                {
                    if ((index < assignmentindex || index > assignmentindex+nextbest) && subassignment.assignmentname == assignment.name)
                    {
                        if (subassignment.enddatetime < Date())
                        {
                            continue
                        }
                        if (Calendar.current.startOfDay(for: subassignment.startdatetime) != startOfDay)
                        {
                            let subassignmentdaysfromnow =  Calendar.current.dateComponents([.day], from: startOfDay, to: Calendar.current.startOfDay(for: subassignment.startdatetime)).day!
                            subassignmentdict[subassignmentdaysfromnow]!.append((subassignment.assignmentname,  Calendar.current.dateComponents([.minute], from: subassignment.startdatetime, to: subassignment.enddatetime).minute!))

                        }
                        else
                        {
                            // this may cause problems because it assumes there are no existing subassignments today that have been passed but not completed
                            if (subassignment.enddatetime > Date() && subassignment.startdatetime < Date())
                            {
                                //add logic not to move the position of this subassignment
                                //could change the from: Date() to from: subassignment.startdatetime assuming this isn't referenced anywhere else
                               // subassignmentdict[0]!.append((subassignment.assignmentname,  Calendar.current.dateComponents([.minute], from: Date(), to: subassignment.enddatetime).minute!))

                            }
                            else if (subassignment.startdatetime > Date())
                            {
                                subassignmentdict[0]!.append((subassignment.assignmentname,  Calendar.current.dateComponents([.minute], from: subassignment.startdatetime, to: subassignment.enddatetime).minute!))

                            }
                        }
                        
                    }
                }
            }
            for i in 0...daystilllatestdate
            {
                for tup in tempsubassignmentdict[i]!
                {
                    print(tup.0, tup.1, i)
                    //need to reinitialize subassignmentdict using current subassiegnmentlist
                    subassignmentdict[i]!.append((tup.0, tup.1))
                }
            }
            overalloverallpossible = true
            
            
            if (overalloverallpossible)
            {
                print("You're a BEAST")
            }
            else
            {
                print("Massive Fail")
              //  return
            }
            
        }
        
        //creating subassignments according to freetimes - may need to be checked because of revised SAM
        for (index, val) in subassignmentlist.enumerated() {
            if (val.startdatetime > Date())
            {
                self.managedObjectContext.delete(self.subassignmentlist[index])
            }
            
        }
        for i in 0...daystilllatestdate {
            if (subassignmentdict[i]!.count > 0 &&  specificdatefreetimedict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!]!.count > 0 )
            {
                
                if (specificdatefreetimedict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!]!.count == 1)
                {
                    let startime = Date(timeInterval: TimeInterval(Calendar.current.dateComponents([.minute], from: Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: specificdatefreetimedict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!]![0].0)), to: specificdatefreetimedict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!]![0].0).minute!*60), since: Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!)

                    var timeoffset = 0
                    
                    for (name, lengthofwork) in subassignmentdict[i]! {
                        if (lengthofwork < 5)
                        {
                            continue
                        }
                        
                        let newSubassignment4 = Subassignmentnew(context: self.managedObjectContext)
                           newSubassignment4.assignmentname = name
                        for assignment in assignmentlist {
                            if (assignment.name == name)
                            {
                                newSubassignment4.color = assignment.color
                                newSubassignment4.assignmentduedate = assignment.duedate
                            }
                        }
                        
                        newSubassignment4.startdatetime = Date(timeInterval:     TimeInterval(timeoffset), since: startime)
                        newSubassignment4.enddatetime = Date(timeInterval: TimeInterval(timeoffset+lengthofwork*60), since: startime)
                        timeoffset += lengthofwork*60
                        do {
                            try self.managedObjectContext.save()
                        } catch {
                        }
                    }
                }
                else
                {
                    print(i,specificdatefreetimedict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!]!.count)
                    var startime = Date(timeInterval: TimeInterval(Calendar.current.dateComponents([.minute], from: Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: specificdatefreetimedict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!]![0].0)), to:  specificdatefreetimedict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!]![0].0).minute!*60), since: Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!)
                    var endtime = Date(timeInterval: TimeInterval(Calendar.current.dateComponents([.minute], from: Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: specificdatefreetimedict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!]![0].1)), to:  specificdatefreetimedict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!]![0].1).minute!*60), since: Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!)
                    var counter = 1
                    var timeoffset = 0
                    for (name, lengthofwork) in subassignmentdict[i]! {
                        if (lengthofwork < 5)
                        {
                            continue
                        }
                        var lengthofwork2 = lengthofwork
                        while (lengthofwork2 > 0)
                        {
                            let newSubassignment4 = Subassignmentnew(context: self.managedObjectContext)
                               newSubassignment4.assignmentname = name
                            for assignment in assignmentlist {
                                if (assignment.name == name)
                                {
                                    newSubassignment4.color = assignment.color
                                    newSubassignment4.assignmentduedate = assignment.duedate
                                }
                            }

                            newSubassignment4.startdatetime = Date(timeInterval: TimeInterval(timeoffset), since: startime)
                            if (Date(timeInterval: TimeInterval(timeoffset+lengthofwork2*60), since: startime) > endtime)
                            {
                                newSubassignment4.enddatetime = endtime
                                var subtractionval = Calendar.current.dateComponents([.minute], from:Date(timeInterval: TimeInterval(timeoffset), since: startime), to:  endtime).minute!
                                if (subtractionval % 5 == 4)
                                {
                                    subtractionval += 1
                                }
                                if (subtractionval % 5 == 1)
                                {
                                    subtractionval -= 1
                                }
                                
                                lengthofwork2 -= subtractionval
                                timeoffset = 0
                                startime = Date(timeInterval: TimeInterval(Calendar.current.dateComponents([.minute], from: Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: specificdatefreetimedict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!]![counter].0)), to:  specificdatefreetimedict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!]![counter].0).minute!*60), since: Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!)
                                endtime = Date(timeInterval: TimeInterval(Calendar.current.dateComponents([.minute], from: Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: specificdatefreetimedict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!]![counter].1)), to:  specificdatefreetimedict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!]![counter].1).minute!*60), since: Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!)
                                counter += 1
                            }
                            else
                            {
                                newSubassignment4.enddatetime = Date(timeInterval: TimeInterval(timeoffset+lengthofwork2*60), since: startime)
                                timeoffset += lengthofwork2*60
                                lengthofwork2 = 0
                            }
                           
                            do {
                                try self.managedObjectContext.save()
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            }
        }
        //needs to be changed because it's possible extratime is not for the correct assignment
        if (extratime != 0)
        {
            masterRunning.extratimealertmessage = "There are " + String(extratime) + " minutes for assignment " + namey + " that cannot be scheduled. Please adjust your work hours or edit the assignment."
            masterRunning.showingalert = true
            print(masterRunning.extratimealertmessage)
        }
            
        

    }

    
    func master() {
        // delete all subassignments RECONSIDER
    
        print("full master being run")
        for assignment in assignmentlist
        {
            if (!assignment.completed)
            {
                masterRunning.uniqueAssignmentName = assignment.name
                assignmentspecificmaster()
            }
        }
//        for (index, _) in subassignmentlist.enumerated() {
//             self.managedObjectContext.delete(self.subassignmentlist[index])
//        }
//
//        do {
//            try self.managedObjectContext.save()
//        } catch {
//            print(error.localizedDescription)
//        }
//
//        var counterb: Int = 0
//        // update assignmentnumber property
//        for classitye in classlist {
//            counterb = 0
//            for assignmentye in assignmentlist {
//                if (assignmentye.subject == classitye.originalname) && (assignmentye.completed == false) {
//                    counterb = counterb + 1
//                }
//            }
//            classitye.assignmentnumber = Int64(counterb)
//        }
//
//        do {
//            try self.managedObjectContext.save()
//        } catch {
//            print(error.localizedDescription)
//        }
//
//        // calculating free time on each day
//
//        var timemonday = 0
//        var timetuesday = 0
//        var timewednesday = 0
//        var timethursday = 0
//        var timefriday = 0
//        var timesaturday = 0
//        var timesunday = 0
//        _ = Date(timeInterval: 86300, since: startOfDay)
//        _ = Date(timeInterval: 86300, since: startOfDay)
//        _ = Date(timeInterval: 86300, since: startOfDay)
//        _ = Date(timeInterval: 86300, since: startOfDay)
//        _ = Date(timeInterval: 86300, since: startOfDay)
//        _ = Date(timeInterval: 86300, since: startOfDay)
//        _ = Date(timeInterval: 86300, since: startOfDay)
//
//        var monfreetimelist:[(Date, Date)] = [], tuefreetimelist:[(Date, Date)] = [], wedfreetimelist:[(Date, Date)] = [], thufreetimelist:[(Date, Date)] = [], frifreetimelist:[(Date, Date)] = [], satfreetimelist:[(Date, Date)] = [], sunfreetimelist:[(Date, Date)] = []
//
//
//        var latestDate = Date(timeIntervalSinceNow: TimeInterval(0))
//        var dateFreeTimeDict = [Date: Int]()
//        var specificdatefreetimedict = [Date: [(Date,Date)]]()
//        //initial subassignment objects are added just as (assignmentname, length of subassignment)
//        var subassignmentdict = [Int: [(String, Int)]]()
//
//        for freetime in freetimelist {
//            if (freetime.monday) {
//                timemonday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
//                monfreetimelist.append((freetime.startdatetime, freetime.enddatetime))
//
//            }
//            if (freetime.tuesday) {
//                timetuesday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
//                tuefreetimelist.append((freetime.startdatetime, freetime.enddatetime))
//
//            }
//            if (freetime.wednesday) {
//                timewednesday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
//                wedfreetimelist.append((freetime.startdatetime, freetime.enddatetime))
//            }
//            if (freetime.thursday) {
//                timethursday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
//                thufreetimelist.append((freetime.startdatetime, freetime.enddatetime))
//            }
//            if (freetime.friday) {
//                timefriday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
//                frifreetimelist.append((freetime.startdatetime, freetime.enddatetime))
//            }
//
//            if (freetime.saturday) {
//                timesaturday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
//                satfreetimelist.append((freetime.startdatetime, freetime.enddatetime))
//            }
//            if (freetime.sunday) {
//                timesunday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
//                sunfreetimelist.append((freetime.startdatetime, freetime.enddatetime))
//            }
//        }
//        var generalfreetimelist = [timesunday, timemonday, timetuesday, timewednesday, timethursday, timefriday, timesaturday]
//
//        let actualfreetimeslist = [sunfreetimelist, monfreetimelist, tuefreetimelist, wedfreetimelist, thufreetimelist, frifreetimelist, satfreetimelist, sunfreetimelist]
//        for (index, _) in generalfreetimelist.enumerated() {
//                generalfreetimelist[index] = Int(Double(generalfreetimelist[index])/Double(5) * 5)
//
//        }
//
//
//
//
//        // latest duedate among all assignments
//        for assignment in assignmentlist {
//            latestDate = max(latestDate, assignment.duedate)
//        }
//
//        let daystilllatestdate = Calendar.current.dateComponents([.day], from: Date(timeIntervalSinceNow: TimeInterval(0)), to: latestDate).day!
//
//        for i in 0...daystilllatestdate {
//            subassignmentdict[i] = []
//
//            dateFreeTimeDict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!] = generalfreetimelist[(Calendar.current.component(.weekday, from: Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!) - 1)]
//
//            specificdatefreetimedict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!] = actualfreetimeslist[(Calendar.current.component(.weekday, from: Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!) - 1)]
//
//        }
//
//        for freetime in freetimelist {
//            if (!freetime.monday && !freetime.tuesday && !freetime.wednesday && !freetime.thursday && !freetime.friday && !freetime.saturday && !freetime.sunday) {
//
//                if (freetime.enddatetime > Date())
//                {
//                    dateFreeTimeDict[Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: freetime.startdatetime))]! += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
//                    specificdatefreetimedict[Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: freetime.startdatetime))]!.append((freetime.startdatetime, freetime.enddatetime))
//                }
//
//            }
//        }
//
//        // look at free times objects that have passed today
//        var deletelist: [Int] = []
//        var changelist: [Int] = []
//        for (index,(start, end)) in specificdatefreetimedict[startOfDay]!.enumerated()
//        {
//            if (Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for: end), to: end).minute! <  Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for: Date()), to: Date()).minute!)
//            {
//                dateFreeTimeDict[startOfDay]! -= Calendar.current.dateComponents([.minute], from: start, to: end).minute!
//                deletelist.append(index)
//            }
//            else if (Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for: start), to: start).minute! < Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for: Date()), to: Date()).minute! && Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for: end), to: end).minute! > Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for: Date()), to: Date()).minute!)
//            {
//                dateFreeTimeDict[startOfDay]! -= (Calendar.current.dateComponents([.minute], from: startOfDay, to: Date()).minute! - Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for: start), to: start).minute! )
//                dateFreeTimeDict[startOfDay]! -= (dateFreeTimeDict[startOfDay]! % 5)
//                changelist.append(index)
//            }
//        }
//        for index in changelist
//        {
//            var minutesfromstart = Calendar.current.dateComponents([.minute], from: startOfDay, to: Date()).minute!
//            minutesfromstart += 5 - (minutesfromstart % 5)
//            specificdatefreetimedict[startOfDay]![index].0 = Date(timeInterval: TimeInterval(minutesfromstart*60), since: startOfDay)
//        }
//        var counter = 0
//
//        let deletelistsize = deletelist.count
//        for index in 0..<deletelistsize
//        {
//            specificdatefreetimedict[startOfDay]!.remove(at: index-counter)
//            counter += 1
//        }
//
//
//        //bulk function for each assignment
//
//        for assignment in assignmentlist {
//            let daystilldue = Calendar.current.dateComponents([.day], from: Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: 0))), to:  Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: Date(timeInterval: 0, since: assignment.duedate)))).day!
//
//            if (!assignment.completed)
//            {
//                let (subassignments, _, _) = bulk(assignment: assignment, daystilldue: daystilldue, totaltime: Int(assignment.timeleft), bulk: true, dateFreeTimeDict: dateFreeTimeDict)
//
//
//
//                for (daysfromnow, lengthofwork) in subassignments {
//                    dateFreeTimeDict[Calendar.current.date(byAdding: .day, value: daysfromnow, to: startOfDay)!]! -= lengthofwork
//                    subassignmentdict[daysfromnow]!.append((assignment.name, lengthofwork))
//                }
//            }
//        }
//        //creating subassignments according to freetimes
//        for i in 0...daystilllatestdate {
//            if (subassignmentdict[i]!.count > 0)
//            {
//                if (specificdatefreetimedict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!]!.count == 1)
//                {
//                    let startime = Date(timeInterval: TimeInterval(Calendar.current.dateComponents([.minute], from: Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: specificdatefreetimedict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!]![0].0)), to: specificdatefreetimedict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!]![0].0).minute!*60), since: Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!)
//
//                    var timeoffset = 0
//
//                    for (name, lengthofwork) in subassignmentdict[i]! {
//
//                        let newSubassignment4 = Subassignmentnew(context: self.managedObjectContext)
//                           newSubassignment4.assignmentname = name
//                        for assignment in assignmentlist {
//                            if (assignment.name == name)
//                            {
//                                newSubassignment4.color = assignment.color
//                                newSubassignment4.assignmentduedate = assignment.duedate
//                            }
//                        }
//
//                        newSubassignment4.startdatetime = Date(timeInterval:     TimeInterval(timeoffset), since: startime)
//                        newSubassignment4.enddatetime = Date(timeInterval: TimeInterval(timeoffset+lengthofwork*60), since: startime)
//                        timeoffset += lengthofwork*60
//                        do {
//                            try self.managedObjectContext.save()
//                        } catch {
//                        }
//                    }
//                }
//                else
//                {
//                    var startime = Date(timeInterval: TimeInterval(Calendar.current.dateComponents([.minute], from: Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: specificdatefreetimedict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!]![0].0)), to:  specificdatefreetimedict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!]![0].0).minute!*60), since: Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!)
//                    var endtime = Date(timeInterval: TimeInterval(Calendar.current.dateComponents([.minute], from: Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: specificdatefreetimedict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!]![0].1)), to:  specificdatefreetimedict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!]![0].1).minute!*60), since: Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!)
//                    var counter = 1
//                    var timeoffset = 0
//                    for (name, lengthofwork) in subassignmentdict[i]! {
//                        var lengthofwork2 = lengthofwork
//                        while (lengthofwork2 > 0)
//                        {
//                            let newSubassignment4 = Subassignmentnew(context: self.managedObjectContext)
//                               newSubassignment4.assignmentname = name
//                            for assignment in assignmentlist {
//                                if (assignment.name == name)
//                                {
//                                    newSubassignment4.color = assignment.color
//                                    newSubassignment4.assignmentduedate = assignment.duedate
//                                }
//                            }
//
//                            newSubassignment4.startdatetime = Date(timeInterval: TimeInterval(timeoffset), since: startime)
//                            if (Date(timeInterval: TimeInterval(timeoffset+lengthofwork2*60), since: startime) > endtime)
//                            {
//                                newSubassignment4.enddatetime = endtime
//                                var subtractionval = Calendar.current.dateComponents([.minute], from:Date(timeInterval: TimeInterval(timeoffset), since: startime), to:  endtime).minute!
//                                if (subtractionval % 5 == 4)
//                                {
//                                    subtractionval += 1
//                                }
//                                if (subtractionval % 5 == 1)
//                                {
//                                    subtractionval -= 1
//                                }
//
//                                lengthofwork2 -= subtractionval
//                                timeoffset = 0
//                                startime = Date(timeInterval: TimeInterval(Calendar.current.dateComponents([.minute], from: Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: specificdatefreetimedict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!]![counter].0)), to:  specificdatefreetimedict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!]![counter].0).minute!*60), since: Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!)
//                                endtime = Date(timeInterval: TimeInterval(Calendar.current.dateComponents([.minute], from: Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: specificdatefreetimedict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!]![counter].1)), to:  specificdatefreetimedict[Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!]![counter].1).minute!*60), since: Calendar.current.date(byAdding: .day, value: i, to: startOfDay)!)
//                                counter += 1
//                            }
//                            else
//                            {
//                                newSubassignment4.enddatetime = Date(timeInterval: TimeInterval(timeoffset+lengthofwork2*60), since: startime)
//                                timeoffset += lengthofwork2*60
//                                lengthofwork2 = 0
//                            }
//
//                            do {
//                                try self.managedObjectContext.save()
//                            } catch {
//                                print(error.localizedDescription)
//                            }
//                        }
//                    }
//                }
//            }
//        }
    }
    
    var body: some View {
        Text("").frame(width: 1, height: 1).background(Color.clear).onAppear(perform: theBigMaster).opacity(0)
        //.offset(y: UIScreen.main.bounds.size.height)
    }
}

struct ClassesView: View {
    @EnvironmentObject var googleDelegate: GoogleDelegate

    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colorScheme: ColorScheme
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
    @State var NewAssignmentPresenting = false
    @State var NewClassPresenting = false
    @State var NewOccupiedtimePresenting = false
    @State var NewFreetimePresenting = false
    @State var NewGradePresenting = false
    @State var noClassesAlert = false
    @State var NewAssignmentPresenting2 = false
    @State var stored: Double = 0
    @State var noAssignmentsAlert = false
    @State var startedToDelete = false
    @State var showingSettingsView = false
    
    let types = ["Test", "Homework", "Presentation/Oral", "Essay", "Study", "Exam", "Report/Paper", "Essay", "Presentation/Oral", "Essay"]
    let duedays = [7, 2, 3, 8, 180, 14, 1, 4 , 300, 150]
    let duetimes = ["day", "day", "day", "night", "day", "day", "day", "day", "day", "day"]
    let totaltimes = [600, 90, 240, 210, 4620, 840, 120, 300, 720, 240]
    let names = ["Trigonometry Test", "Trigonometry Packet", "German Oral 2", "Othello Essay", "Physics Studying", "Final Exam", "Chemistry IA Final", "McDonalds Macroeconomics Essay", "ToK Final Presentation", "Extended Essay Final Essay"]
    let classnames = ["Math", "Math", "German", "English", "Physics" , "Physics", "Chemistry", "Economics", "Theory of Knowledge", "Extended Essay"]
    let colors = ["one", "one", "two", "three" , "four", "four", "five", "six", "seven", "eight"]
    let assignmentoriginalclassnames = ["Mathematics: Analysis and Approaches SL","Mathematics: Analysis and Approaches SL","German B: SL", "English A: Language and Literature SL","Physics: HL","Physics: HL","Chemistry: HL", "Economics: HL","Theory of Knowledge",  "Extended Essay"]
    
    let bulks = [true, true, true, false, false, false, false, false]
    let classnameactual = ["Math", "German", "English", "Physics", "Chemistry", "Economics", "Theory of Knowledge", "Extended Essay"]
    let originalclassnames = ["Mathematics: Analysis and Approaches SL", "German B: SL","English A: Language and Literature SL",  "Physics: HL","Chemistry: HL", "Economics: HL", "Theory of Knowledge",  "Extended Essay"]
    let tolerances = [4, 1, 2, 4, 3, 4, 1, 5]
    let assignmentnumbers = [2, 1, 1, 2, 1, 1, 1, 1]
    let classcolors = ["one", "two", "three", "four", "five", "six", "seven", "eight"]
    @State var modalView: ModalView = .none
    @State var alertView: AlertView = .noclass
    @State var NewSheetPresenting = false
    @State var NewAlertPresenting = false
    @ObservedObject var sheetNavigator = SheetNavigator()
    @State var widthAndHeight: CGFloat = 50
    var startOfDay: Date {
        
        return Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: 0)))
        //may need to be changed to timeintervalsincenow: 0 because startOfDay automatically adds 2 hours to input date before calculating start of day
    }
    
    
    func getclassindex(classcool: Classcool) -> Int {
        for (index, element) in classlist.enumerated()
        {
            if (element == classcool)
            {
                return index
            }
        }
        return 0
    }
    func getnumofclasses() -> Bool {
        var count = 0
        for _ in classlist {
            count += 1
        }
        if (count > 0)
        {
            return true
        }
        return false
    }
    func getactualclassnumber(classcool: Classcool) -> Int
    {
        var counter = 0
        for (index, element) in classlist.enumerated() {
            if (!element.isTrash)
            {
                if (element.name == classcool.name)
                {
                    return index-counter
                }
            }
            else
            {
                counter += 1
            }
        }
        return 0
    }
    func getclassnumber(classcool: Classcool) -> Int
    {
        for (index, element) in classlist.enumerated() {
            if (element.name == classcool.name)
            {
                return index+1
            }
        }
        return 0
    }
    
    @EnvironmentObject var masterRunning: MasterRunning
    
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
    @State var selectedClass: Int? = 0
    @State var storedindex = 0
    @State var opacityvalue = 1.0
    @State var deletedclassindex = -1
    @ObservedObject var sheetnavigator: SheetNavigatorClassesView = SheetNavigatorClassesView()
    @ObservedObject var classdeleter: ClassDeleter = ClassDeleter()
    @State var showpopup: Bool = false
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    var body: some View {
        NavigationView {
            VStack {
            HStack {
                Text("Classes").font(.largeTitle).bold().frame(height:40)
                Spacer()
            }.padding(.all, 10).padding(.top, -60).padding(.leading, 10)
            ZStack {
//                NavigationLink(destination: EmptyView()) {
//                    EmptyView()
//                }
                NavigationLink(destination: SettingsView(), isActive: self.$showingSettingsView)
                 { EmptyView() }
                ScrollView {
                    if (getnumofclasses())
                    {
                        ForEach(self.classlist, id: \.self) { classcool in
                            if (!classcool.isTrash)
                            {
                                
                                
                                NavigationLink(destination: DetailView(classcool: classcool), tag: self.getclassnumber(classcool: classcool), selection: self.$selectedClass) {
                                    EmptyView()
                                }
                                Button(action: {
                                    self.selectedClass = self.getclassnumber(classcool: classcool)
                                }) {
                                    ClassView(classcool: classcool, startedToDelete: self.$startedToDelete).padding(.vertical, 5)

                                }.buttonStyle(PlainButtonStyle()).contextMenu {
                                    Button (action: {

                                        self.sheetnavigator.storedindex = self.getactualclassnumber(classcool: classcool)
                                        NewAssignmentPresenting2.toggle()
                                    }) {
                                        HStack {
                                            Text("Add Assignment")
                                            Spacer()
                                            Image(systemName: "doc.plaintext")
                                        }
                                    }
                                    Divider()
                                    Button(action: {
                                        classcool.isTrash = true
                                        classcool.googleclassroomid = ""
                                        for (index2, element) in self.assignmentlist.enumerated() {
                                            if (element.subject == classcool.originalname) {
                                                for (index3, element2) in self.subassignmentlist.enumerated() {
                                                    if (element2.assignmentname == element.name) {
                                                        self.managedObjectContext.delete(self.subassignmentlist[index3])
                                                    }
                                                }
                                                self.managedObjectContext.delete(self.assignmentlist[index2])

                                            }
                                        }
                                        do {
                                            try self.managedObjectContext.save()
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                    })
                                    {
                                        HStack {
                                            Text("Delete Class")
                                            Spacer()
                                            Image(systemName: "trash")
                                        }
                                    }
                                }
                            }
                        }.frame(width: UIScreen.main.bounds.size.width).animation(.spring())
                        
                    }
                    else
                    {
                        
                        VStack {
                            Spacer()
                            Text("No Classes").font(.title2).fontWeight(.bold)
                            HStack {
                                Text("Add a Class using the").foregroundColor(.gray).fontWeight(.semibold)
                                RoundedRectangle(cornerRadius: 3, style: .continuous).fill(Color.blue).frame(width: 15, height: 15).overlay(
                                    ZStack {
                                        Image(systemName: "plus").resizable().font(Font.title.weight(.bold)).foregroundColor(Color.white).frame(width: 9, height: 9)
                                    }
                                )
                                Text("button").foregroundColor(.gray).fontWeight(.semibold)
                            }
                            Spacer()
                        }.frame(height: UIScreen.main.bounds.size.height/2)
//                        VStack {
//                            Spacer().frame(height: 100)
//                            ZStack {
//
//                                Image(systemName: "moon.zzz").resizable().frame(width: 200, height: 250)
//                                Text("No classes created").font(.title).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-40, height: 30, alignment: .center).offset(y: 175)
//                            }
//                        }
                    }

                }.frame(width: UIScreen.main.bounds.size.width).sheet(isPresented: self.$NewAssignmentPresenting2, content: { NewAssignmentModalView(NewAssignmentPresenting: self.$NewAssignmentPresenting2, selectedClass: self.sheetnavigator.storedindex, preselecteddate: -1).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning)}).alert(isPresented: self.$noClassesAlert) {
                    Alert(title: Text("No Classes Added"), message: Text("Add a Class First"))
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
                            //            countnewassignments = 0
                                        
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
            }.navigationBarItems(
                leading:
                HStack(spacing: UIScreen.main.bounds.size.width / 4.5) {
                        Button(action: {
                            self.showingSettingsView = true
                        })
                        {
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
            })//.navigationTitle("Classes")
        }.navigationViewStyle(StackNavigationViewStyle())
        .onDisappear() {
            self.showingSettingsView = false
            self.showpopup = false
            self.selectedClass = 0
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
}

class SheetNavigatorClassesView: ObservableObject {
    @Published var storedindex: Int = 0
}

class ClassDeleter: ObservableObject {
    @Published var isdeleting: Bool = false
}

struct ClassesView_Previews: PreviewProvider {
    static var previews: some View {
      let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        return ClassesView().environment(\.managedObjectContext, context)
    }
}
