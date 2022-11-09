import SwiftUI
import WidgetKit

struct IndividualAssignmentFilterView: View {
    @ObservedObject var assignment: Assignment
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var dragoffset = CGSize.zero
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    
    @State var isDragged: Bool = false
    @State var isDraggedleft: Bool = false
    @State var deleted: Bool = false
    @State var deleteonce: Bool = true
    @State var incompleted: Bool = false
    @State var incompletedonce: Bool = true
    @State var showingexacttimes: Bool = true
    @Binding var selectededitassignment: String
    @Binding var showeditassignment: Bool
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [])
    
    var classlist: FetchedResults<Classcool>
    var formatter: DateFormatter
    
    let isExpanded: Bool
    
    let isCompleted: Bool
    
    @FetchRequest(entity: Subassignmentnew.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Subassignmentnew.startdatetime, ascending: true)])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    
    var assignmentduedate: String
    var assignmentactualduedate: Date
    
    @EnvironmentObject var masterRunning: MasterRunning
    
    var timeformatter: DateFormatter
    
    init(isExpanded2: Bool, isCompleted2: Bool, assignment2: Assignment, selectededit: Binding<String>, showedit: Binding<Bool>)
    {
        isExpanded = isExpanded2
        isCompleted = isCompleted2
        formatter = DateFormatter()
        formatter.dateFormat = "HH:mm E, d MMM y"
       // formatter.timeZone = TimeZone(secondsFromGMT: 0)
        assignment = assignment2
        assignmentduedate = formatter.string(from: assignment2.duedate)
        self.assignmentactualduedate = assignment2.duedate
        self._selectededitassignment = selectededit
        self._showeditassignment = showedit
        
        timeformatter = DateFormatter()
        timeformatter.dateFormat = "HH:mm"
        
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
        if (existinggradients.contains(currentColor)) {
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
    
    func TASKStext() -> String {
        var counter = 0
        
        for subassignment in subassignmentlist {
            if subassignment.assignmentname == assignment.name {
                counter += 1
            }
        }
        
        return "TASKS (\(counter))"
        
    }
    func getunscheduledtime() -> Int
    {
        var totalsubtime: Int = 0
        for subassignment in subassignmentlist
        {
            if (subassignment.assignmentname == assignment.name)
            {
                totalsubtime += Calendar.current.dateComponents([.minute], from: subassignment.startdatetime, to: subassignment.enddatetime).minute!
            }
        }
        return Int(assignment.timeleft) - totalsubtime
    }

    func atLeastOneTask() -> Bool {
        for subassignment in subassignmentlist {
            if subassignment.assignmentname == assignment.name {
                return true
            }
        }
        
        return false
    }
    var body: some View {
        ZStack {
            VStack {
                if (isDragged && !self.isCompleted) {
                    ZStack {
                        HStack {
                            Rectangle().fill(Color("fourteen")) .frame(width: UIScreen.main.bounds.size.width-20).offset(x: UIScreen.main.bounds.size.width-10+self.dragoffset.width)
                        }
                        HStack {
                            Spacer()
//                            if (self.dragoffset.width < -110) {
//                                Text("Complete").foregroundColor(Color.white).frame(width:100)
//                            }
//                            else {
                                Text("Complete").foregroundColor(Color.white).frame(width:100).offset(x: self.dragoffset.width < -110 ? 0: self.dragoffset.width + 110)
                                //Text("Complete").foregroundColor(Color.white).frame(width:100).offset(x: self.dragoffset.width + 110)
                         //   }
                        }
                    }
                }

            }
            
            VStack {
                if (!isExpanded) {
                    HStack {
                        let datedifference = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: assignmentactualduedate )).day

                        let previewduedatetext: String = datedifference == 1 ? "Tomorrow" : (datedifference == 0 ? "Today" : "\(assignmentduedate.components(separatedBy: " ")[assignmentduedate.components(separatedBy: " ").count - 3]) \(assignmentduedate.components(separatedBy: " ")[assignmentduedate.components(separatedBy: " ").count - 2])")
                        
                        let previewduedateweight: Font.Weight = datedifference ?? 0 < 2 ? (Date() > assignmentactualduedate ? .bold : .semibold) : .light
                        
                        let previewduedatecolor: Color = Date() > assignmentactualduedate ? Color("ohnored") : ((colorScheme == .light) ? Color.black : Color.white)
                        
                        let previewduedatewidth: CGFloat = previewduedatetext == "Tomorrow" ? UIScreen.main.bounds.size.width/2 - 95 : UIScreen.main.bounds.size.width/2 - 140
                        
                        let assignmentnamewidth: CGFloat = previewduedatetext == "Tomorrow" ? UIScreen.main.bounds.size.width/2 + 10 : UIScreen.main.bounds.size.width/2 + 55
                        
                        Text(assignment.name).font(.system(size: 20)).fontWeight(.bold).frame(width: assignmentnamewidth, height: 30, alignment: .topLeading).padding(.leading, 5)
                        
                        Spacer()
                        
                        Text(previewduedatetext).fontWeight(previewduedateweight).foregroundColor(previewduedatecolor).frame(width: previewduedatewidth, height: 20, alignment: .topTrailing).minimumScaleFactor(0.92).padding(.trailing, 5)
                        if (getunscheduledtime() != 0)
                        {
                            Image(systemName: "exclamationmark.circle.fill").resizable().frame(width: 15, height: 15)
                            Spacer().frame(width: 4)
                        }
                    }.padding(.bottom, -3)
                }
                    
                else {
                    ZStack {
                        VStack {
                            HStack {
                                Text(assignment.name).font(.system(size: 20)).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-100, height: 30, alignment: .topLeading).padding(.leading, 5)
                                Spacer()

                            }
                            
                            Text(assignmentduedate).frame(width: UIScreen.main.bounds.size.width-50,height: 20, alignment: .topLeading).padding(.horizontal, 5).padding(.bottom, 3).padding(.top, 1)
                           
                            HStack {
                              //  Text("Length: " + String(gethourminutestext(minutenumber: Int(assignment.totaltime)))).frame( height: 20, alignment: .topLeading).padding(5)
                                Text(assignment.type).frame(height: 20, alignment: .topLeading)
                                Spacer()
                                Text(gethourminutestext(minutenumber: Int(assignment.timeleft)) + " left").fontWeight(.bold).frame( height: 20, alignment: .topTrailing)
                            }.padding(.horizontal, 5).padding(.bottom, 2)
                            
                            if (getunscheduledtime() != 0)
                            {
                                Text("There " + (gethourminutestext(minutenumber: getunscheduledtime()).last! == "s" ? "are " : "is ") + gethourminutestext(minutenumber: getunscheduledtime()) + " that could not be scheduled. Please adjust your Work Hours in Settings or shorten the Assignment.").fontWeight(.light).frame(width: UIScreen.main.bounds.size.width-50, height: 75, alignment: .topLeading)
                            }
                        }
                        VStack {
                            HStack {
                                Spacer()
                                Button(action:{
                                    self.selectededitassignment = self.assignment.name
                                    self.showeditassignment = true
                                }) {
                                    Image(systemName: "pencil.circle").resizable().frame(width: 30, height: 30).padding(.top, 10).padding(.trailing, 10).foregroundColor(colorScheme == .light ? Color.black : Color.white)//.foregroundColor(Color.black)
                                }
                            }
                            Spacer()
                        }
                    }
                }
                
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.white).frame(width:  UIScreen.main.bounds.size.width-50, height: 20)
                    HStack {
                        if (assignment.progress == 100) {
                            RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.blue).frame(width:  CGFloat(CGFloat(assignment.progress)/100*(UIScreen.main.bounds.size.width-50)),height: 20, alignment: .leading)
                        }
                        else {
                            RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.blue).frame(width:  CGFloat(CGFloat(assignment.progress)/100*(UIScreen.main.bounds.size.width-50)),height: 20, alignment: .leading)
                            Spacer()
                        }
                    }
                }
                
                if isExpanded && self.atLeastOneTask() {
                    HStack {
                        Text(TASKStext()).font(.footnote).fontWeight(.light).rotationEffect(Angle(degrees: 270.0), anchor: .center).fixedSize().frame(width: 25, height: 90)
                        
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(subassignmentlist) { subassignment in
                                    if subassignment.assignmentname == assignment.name {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 3, style: .continuous).fill(subassignment.color.contains("rgbcode") ? GetColorFromRGBCode(rgbcode: subassignment.color, number: 2) : getNextColor(currentColor: subassignment.color)).frame(width: 130, height: 90)
                                            
                                            VStack {
                                                let datedifference = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: subassignment.startdatetime)).day
                                                
                                                let subassignmentstartdatetimeformatted = formatter.string(from: subassignment.startdatetime)
                                                
                                                let previewduedatetext: String = datedifference == 1 ? "Tomorrow" : (datedifference == 0 ? "Today" : "\(subassignmentstartdatetimeformatted.components(separatedBy: " ")[subassignmentstartdatetimeformatted.components(separatedBy: " ").count - 3]) \(subassignmentstartdatetimeformatted.components(separatedBy: " ")[subassignmentstartdatetimeformatted.components(separatedBy: " ").count - 2])")
                                                                                                
                                                let subassignmentlength = Calendar.current.dateComponents([.minute], from: subassignment.startdatetime, to: subassignment.enddatetime).minute!

//                                                let starttoendtime = timeformatter.string(from: subassignment.startdatetime) + " - " + timeformatter.string(from: subassignment.enddatetime

                                                Text(previewduedatetext).foregroundColor(subassignment.enddatetime < Date() ? Color.red : (subassignment.startdatetime < Date() ? Color.blue : (colorScheme == .light ? Color.black : Color.white) )).font(.headline).fontWeight(.bold)
                                                if (showingexacttimes)
                                                {
                                                    Text(timeformatter.string(from: subassignment.startdatetime) + " - " + timeformatter.string(from: subassignment.enddatetime)).font(.footnote).fontWeight(.light)
                                                }
                                                else
                                                {
                                                    Text((subassignmentlength / 60 == 0 ? "" : (subassignmentlength / 60 == 1 ? "1 hour " : String(subassignmentlength / 60) + " hours ")) + (subassignmentlength % 60 == 0 ? "" : String(subassignmentlength % 60) + " minutes")).font(.footnote).fontWeight(.light)
                                                }
                                                
                                            }.padding(.vertical, 5)
                                            //maybe on tap, goes to homeview of relevant date (maybe not, since only next 4 weeks displayed)
                                            //might not account for group stuff in the other homeview (multiple subassignments on same day)
                                        }.padding(.trailing, 4)
                                    }
                                }
                            }
                        }.padding(.all, 4)
                    }.frame(height: 100).animation(.spring())
                }
            }.padding(10).background(assignment.color.contains("rgbcode") ? GetColorFromRGBCode(rgbcode: assignment.color) : Color(assignment.color)).cornerRadius(14).offset(x: self.dragoffset.width).opacity(isCompleted ? 0.7 : 1.0).gesture(DragGesture(minimumDistance: isExpanded ? 70 : 20, coordinateSpace: .local)
                .onChanged { value in
                    //self.dragoffset = value.translation
                    if (!self.isCompleted) {
                        self.dragoffset = value.translation
                        if (self.dragoffset.width < 0) {
                            self.isDraggedleft = false
                            self.isDragged = true
                        }
                        else if (self.dragoffset.width > 0) {
                            self.dragoffset = .zero
                        }
                                            
                        if (self.dragoffset.width < -UIScreen.main.bounds.size.width * 1/2) {
                            self.deleted = true
                        }
                        else if (self.dragoffset.width > UIScreen.main.bounds.size.width * 1/2) {
                            self.incompleted = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1000)) {
                            self.dragoffset = .zero
                        }
                    }



                }
                .onEnded { value in
                    if (!self.isCompleted)
                    {
                        self.dragoffset = .zero
                        // self.isDragged = false
                        if (self.incompleted == true) {
                            if (self.incompletedonce == true) {
                                self.incompletedonce = false;
                            }
                        }
                         if (self.deleted == true) {
                             if (self.deleteonce == true) {
                                 self.deleteonce = false
                                 self.assignment.completed = true
                                self.assignment.totaltime -= self.assignment.timeleft
                                 self.assignment.timeleft = 0
                                 self.assignment.progress = 100
                                 

                                 for classity in self.classlist {
                                     if (classity.originalname == self.assignment.subject) {
                                         classity.assignmentnumber -= 1
                                     }
                                 }
                                 for (index, element) in self.subassignmentlist.enumerated() {
                                     if (element.assignmentname == self.assignment.name)
                                     {
                                         self.managedObjectContext.delete(self.subassignmentlist[index])
                                     }
                                 }
                                 do {
                                     try self.managedObjectContext.save()
                                 } catch {
                                     print(error.localizedDescription)
                                 }
                                
                                simpleSuccess()
                                
                                WidgetCenter.shared.reloadTimelines(ofKind: "Today's Tasks")
                              //  masterRunning.masterRunningNow = true
                             }
                         }
                    }
                    else
                    {
                        self.dragoffset = .zero
                        if (self.incompleted == true)
                        {
                            if (self.incompletedonce == true)
                            {
                                self.incompletedonce = false;
                            }
                        }
                    }
 
                }).animation(.spring())
        }.frame(width: UIScreen.main.bounds.size.width-20).padding(.horizontal, 10).onAppear
        {
            let defaults = UserDefaults.standard
            showingexacttimes = defaults.object(forKey: "specificworktimes") as? Bool ?? true
        }
    }
    func gethourminutestext(minutenumber: Int) -> String {
        if (minutenumber < 60)
        {
            return String(minutenumber) + " minutes"
        }
        else if (minutenumber % 60 == 0)
        {
            return (minutenumber/60 == 1 ? String(minutenumber/60) + " hour" : String(minutenumber/60) + " hours")
        }
        else
        {
            return String(minutenumber/60) + " h " + String(minutenumber%60) + " min"
        }
    }
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}


struct GradedAssignmentsView: View {
    @ObservedObject var assignment: Assignment
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var dragoffset = CGSize.zero
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    
    @State var isDragged: Bool = false
    @State var isDraggedleft: Bool = false
    @State var deleted: Bool = false
    @State var deleteonce: Bool = true
    @State var incompleted: Bool = false
    @State var incompletedonce: Bool = true
    @Binding var selectededitassignment: String
    @Binding var showeditassignment: Bool
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [])
    
    var classlist: FetchedResults<Classcool>
    var formatter: DateFormatter
    
    let isExpanded: Bool
    
    let isCompleted: Bool
    
    @FetchRequest(entity: Subassignmentnew.entity(), sortDescriptors: [])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    
    var assignmentduedate: String
    let lettergrades = ["E", "D", "C", "B", "A"]
    
    init(isExpanded2: Bool, isCompleted2: Bool, assignment2: Assignment, selectededit: Binding<String>, showedit: Binding<Bool>)
    {
        isExpanded = isExpanded2
        isCompleted = isCompleted2
        formatter = DateFormatter()
        formatter.dateFormat = "HH:mm E, d MMM y"
    //    formatter.timeZone = TimeZone(secondsFromGMT: 0)
        assignment = assignment2
        assignmentduedate = formatter.string(from: assignment2.duedate)
        self._selectededitassignment = selectededit
        self._showeditassignment = showedit
        
    }
    
    func GetColorFromRGBCode(rgbcode: String, number: Int = 1) -> Color {
        if number == 1 {
            return Color(.sRGB, red: Double(rgbcode[9..<14])!, green: Double(rgbcode[15..<20])!, blue: Double(rgbcode[21..<26])!, opacity: 1)
        }
        
        return Color(.sRGB, red: Double(rgbcode[36..<41])!, green: Double(rgbcode[42..<47])!, blue: Double(rgbcode[48..<53])!, opacity: 1)
    }
    func getdisplaygrade() -> String
    {
        let aflist = ["F", "E", "D", "C", "B", "A"]
        let aelist = ["E", "D", "C", "B", "A"]
        
        for classity in classlist
        {
            if (assignment.subject == classity.originalname)
            {
                if (classity.gradingscheme[0..<1] != "L")
                {
                    return String(assignment.grade)
                }
                else
                {
                    if (classity.gradingscheme[3..<4] == "F")
                    {
                        return aflist[Int(assignment.grade)-1]
                    }
                    else
                    {
                        return aelist[Int(assignment.grade)-1]
                    }
                }
            }
        }
        return "NA";
    }
    
    var body: some View {
        ZStack {
            VStack {
                if (isDragged && !self.isCompleted) {
                    ZStack {
                        HStack {
                            Rectangle().fill(Color("fourteen")) .frame(width: UIScreen.main.bounds.size.width-20).offset(x: UIScreen.main.bounds.size.width-10+self.dragoffset.width)
                        }
                        HStack {
                            Spacer()
//                            if (self.dragoffset.width < -110) {
//                                Text("Complete").foregroundColor(Color.white).frame(width:100)
//                            }
//                            else {
                                Text("Complete").foregroundColor(Color.white).frame(width:100).offset(x: self.dragoffset.width < -110 ? 0: self.dragoffset.width + 110)
                                //Text("Complete").foregroundColor(Color.white).frame(width:100).offset(x: self.dragoffset.width + 110)
                         //   }
                        }
                    }
                }

            }
            
            VStack {
                if (!isExpanded) {
                    HStack {
                        Text(assignment.name).font(.system(size: 20)).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-100, height: 30, alignment: .topLeading).padding(.leading, 5)
                        Spacer()
                    }
       

                    if (assignment.grade == 0)
                    {
                        Text("Grade: NA").frame(width: UIScreen.main.bounds.size.width-50,height: 20, alignment: .topLeading).padding(.horizontal, 5).padding(.vertical, 0)
                        
                    }
                    else
                    {
                        Text("Grade: " + getdisplaygrade()).frame(width: UIScreen.main.bounds.size.width-50,height: 20, alignment: .topLeading).padding(.horizontal, 5).padding(.bottom, 1)
                    }
                    
                }
                    
                else {
                    ZStack {
                        VStack {
                            HStack {
                                Text(assignment.name).font(.system(size: 20)).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-100, height: 30, alignment: .topLeading).padding(.leading, 5)
                                Spacer()

                            }


                            if (assignment.grade == 0)
                            {
                                Text("Grade: NA").frame(width: UIScreen.main.bounds.size.width-50,height: 20, alignment: .topLeading).padding(.horizontal, 5).padding(.vertical, 0)
                                
                            }
                            else
                            {
                                Text("Grade: " + getdisplaygrade()).frame(width: UIScreen.main.bounds.size.width-50,height: 20, alignment: .topLeading).padding(.horizontal, 5).padding(.bottom, 1)
                            }
                            
                            

                            Text(assignmentduedate).frame(width: UIScreen.main.bounds.size.width-50,height: 20, alignment: .topLeading).padding(.horizontal, 5).padding(.vertical, 3)
                            HStack
                            {
                                Text(assignment.type).frame(height: 20, alignment: .topLeading)//.padding(.horizontal, 5).padding(.vertical, 0)
                                Spacer()
                                Text( String(gethourminutestext(minutenumber: Int(assignment.totaltime)))).fontWeight(.bold).frame(height: 20, alignment: .topLeading)//.padding(.horizontal, 5).padding(.vertical, 0)
                            }.padding(.horizontal, 5).padding(.vertical, 0)
                        }
                        VStack {
                            HStack {
                                Spacer()
                                Button(action:{
                                    self.selectededitassignment = self.assignment.name
                                    self.showeditassignment = true
                                }) {
                                    Image(systemName: "pencil.circle").resizable().frame(width: 30, height: 30).padding(.top, 10).padding(.trailing, 10).foregroundColor(colorScheme == .light ? Color.black : Color.white)//.foregroundColor(Color.black)
                                }
                            }
                            Spacer()
                        }
                    }
                }
            }.padding(10).background(assignment.color.contains("rgbcode") ? GetColorFromRGBCode(rgbcode: assignment.color) : Color(assignment.color)).cornerRadius(14).offset(x: self.dragoffset.width).opacity(isCompleted ? 0.7 : 1.0).gesture(DragGesture(minimumDistance: 40, coordinateSpace: .local)
                .onChanged { value in
                    //self.dragoffset = value.translation

                    if (!self.isCompleted)
                    {
                        self.dragoffset = value.translation
                        if (self.dragoffset.width < 0) {
                            self.isDraggedleft = false
                            self.isDragged = true
                        }
                        else if (self.dragoffset.width > 0) {
                            self.dragoffset = .zero
                        }
                                            
                        if (self.dragoffset.width < -UIScreen.main.bounds.size.width * 1/2) {
                            self.deleted = true
                        }
                        else if (self.dragoffset.width > UIScreen.main.bounds.size.width * 1/2) {
                            self.incompleted = true
                        }
                    }



                }
                .onEnded { value in
                    if (!self.isCompleted)
                    {
                        self.dragoffset = .zero
                        // self.isDragged = false
                        if (self.incompleted == true)
                        {
                            if (self.incompletedonce == true)
                            {
                                self.incompletedonce = false;
                            }
                        }
                         if (self.deleted == true) {
                             if (self.deleteonce == true) {
                                 self.deleteonce = false
                                 self.assignment.completed = true
                                self.assignment.totaltime -= self.assignment.timeleft
                                 self.assignment.timeleft = 0
                                 self.assignment.progress = 100
                                 
                                 for classity in self.classlist {
                                     if (classity.originalname == self.assignment.subject) {
                                         classity.assignmentnumber -= 1
                                     }
                                 }
                                 for (index, element) in self.subassignmentlist.enumerated() {
                                     if (element.assignmentname == self.assignment.name)
                                     {
                                         self.managedObjectContext.delete(self.subassignmentlist[index])
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
                    else {
                        self.dragoffset = .zero
                        if (self.incompleted == true) {
                            if (self.incompletedonce == true) {
                                self.incompletedonce = false;
                            }
                        }
                    }
 
                }).animation(.spring())
        }.frame(width: UIScreen.main.bounds.size.width-20).padding(.horizontal, 10)
    }
    func gethourminutestext(minutenumber: Int) -> String {
        if (minutenumber < 60)
        {
            return String(minutenumber) + " minutes"
        }
        else if (minutenumber % 60 == 0)
        {
            return (minutenumber/60 == 1 ? String(minutenumber/60) + " hour" : String(minutenumber/60) + " hours")
        }
        else
        {
            return String(minutenumber/60) + " h " + String(minutenumber%60) + " min"
        }
    }
}
