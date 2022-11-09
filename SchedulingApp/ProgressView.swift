//
//  ProgressView.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 6/30/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//
 
import SwiftUI
 
struct ClassProgressView: View {
    var classcool: Classcool
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Assignment.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
 
    func GetColorFromRGBCode(rgbcode: String, number: Int = 1) -> Color {
        if number == 1 {
            return Color(.sRGB, red: Double(rgbcode[9..<14])!, green: Double(rgbcode[15..<20])!, blue: Double(rgbcode[21..<26])!, opacity: 1)
        }
        
        return Color(.sRGB, red: Double(rgbcode[36..<41])!, green: Double(rgbcode[42..<47])!, blue: Double(rgbcode[48..<53])!, opacity: 1)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
               // .fill(LinearGradient(gradient: Gradient(colors: [Color(classcool.color), getNextColor(currentColor: classcool.color)]), startPoint: .leading, endPoint: .trailing))
                .fill(classcool.color.contains("rgbcode") ? GetColorFromRGBCode(rgbcode: classcool.color) : Color(classcool.color))
                .frame(width: (UIScreen.main.bounds.size.width - 40)/2, height: (100 ))
               // .shadow(radius: 10)
            VStack {
               // HStack {
                Text(classcool.name).font(.system(size: 20)).fontWeight(.bold).multilineTextAlignment(.center).frame(width: (UIScreen.main.bounds.size.width-60)/2)

            }.frame(height: 100).padding(.horizontal, 10).padding(.vertical, 5)
        }.frame(width: (UIScreen.main.bounds.size.width-20)/2).shadow(radius: 5)
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
    func getAverageGrade() -> Double
    {
        var gradesum: Double = 0
        var gradenum: Double = 0
        for assignment in assignmentlist {
            if (assignment.subject == classcool.originalname && assignment.completed == true && assignment.grade != 0)
            {
                gradesum += Double(assignment.grade)
                gradenum += 1
            }
        }
        if (gradesum == 0)
        {
            return 0;
        }
        return (gradesum/gradenum)
    }
}
 
struct DetailProgressView: View {
    var classcool: Classcool
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.completed, ascending: true), NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    
    @FetchRequest(entity: Classcool.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    var classlist: FetchedResults<Classcool>
    @State var selectedtimeframe = 0
    let screensize = UIScreen.main.bounds.size.width-20
    var formatter: DateFormatter
    @ObservedObject var sheetnavigator: SheetNavigatorFilterView = SheetNavigatorFilterView()
   // let gradedict:[String:[Double]]
    init(classcool2: Classcool) {
        classcool = classcool2
        formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        
    }
    //fix this stuff
    let subjectgroups = ["Group 1: Language and Literature", "Group 2: Language Acquisition", "Group 3: Individuals and Societies", "Group 4: Sciences", "Group 5: Mathematics", "Group 6: The Arts", "Extended Essay", "Theory of Knowledge"]
 
    let groups = [["English A: Literature", "English A: Language and Literatue"], ["German B", "French B", "German A: Literature", "German A: Language and Literatue", "French A: Literature", "French A: Language and Literatue"], ["Geography", "History", "Economics", "Psychology", "Global Politics"], ["Biology", "Chemistry", "Physics", "Computer Science", "Design Technology", "Environmental Systems and Societies", "Sport Science"], ["Mathematics: Analysis and Approaches", "Mathematics: Applications and Interpretation"], ["Music", "Visual Arts", "Theatre" ], ["Extended Essay"], ["Theory of Knowledge"]]
    var group1_averages = ["English A: Literature SL" : 5.02, "English A: Literature HL" : 4.68, "English A: Language and Literature SL" :5.10, "English A: Language and Literature HL" :4.98, "English B SL" :5.76, "English B HL" :5.73]
 
    var group2_averages = ["French B SL" :5.04, "French B HL" :5.15, "German B SL" :5.10, "German B HL" :5.68, "Spanish B SL" :5.03, "German Ab Initio" :5.00, "Spanish Ab Initio":4.97, "French Ab Initio" :4.90, "French A: Literature SL" :5.10, "French A: Literature HL" :5.21, "French A: Language and Literature SL" :5.33, "French A: Language and Literature HL" :5.11, "German A: Literature SL" :4.96, "German A: Literature HL" : 5.07, "German A: Language and Literature SL" :5.25, "German A: Language and Literature HL" :5.34, "Spanish A: Language and Literature SL" :4.76, "Spanish A: Language and Literature HL" :4.87]
 
    var group3_averages = ["Economics: SL" :4.67, "Economics HL" :5.10, "Geography: SL" :4.80, "Geography: HL" :5.19, "Global Politics: SL" :4.77, "Global Politics: HL" :5.09, "History: SL" :4.46, "History: HL" :4.29, "Psychology: SL" :4.39, "Psychology: HL" :4.71, "Environmental Systems and Societies SL" :4.17]
 
    var group4_averages = ["Biology: SL" :4.18, "Biology: HL" :4.34, "Chemistry: SL" :4.02, "Chemistry: HL" :4.51, "Computer Science: SL" :3.85, "Computer Science: HL" :4.22, "Design Technology: SL" :3.97, "Design Technology: HL" :4.47, "Physics: SL" :4.04, "Physics: HL" :4.65, "Sport, Exercise and Health Science: SL" :3.95, "Sport, Exercise and Health Science: HL" :4.90, "Environmental Systems and Societies SL" :4.17]
 
    var group5_averages = ["Mathematics: Analysis and Approaches SL" :4.19, "Mathematics: Analysis and Approaches HL" :4.69, "Mathematics: Applications and Interpretation SL" :4.19, "Mathematics: Applications and Interpretation HL" :4.69]
 
    var group6_averages = ["Music SL" :4.66, "Music HL" :4.71, "Theatre SL" :4.46, "Theatre HL" :4.88, "Visual Art SL" :3.77, "Visual Art HL" :4.27, "Economics SL" :4.67, "Economics HL" :5.10, "Psychology SL" :4.39, "Psychology HL" :4.71, "Biology SL" :4.18, "Biology HL" :4.34, "Chemistry SL" :4.02, "Chemistry HL" :4.51, "Physics SL" :4.04, "Physics HL" :4.65]
    
    var group1_percentages = ["English A: Literature SL" : [0.00, 0.80, 5.80, 22.80, 38.10, 26.40, 6.20], "English A: Literature HL" : [0.00, 1.50, 8.90, 31.40, 39.40, 16.20, 2.60], "English A: Language and Literature SL" : [0.00, 0.30, 4.00, 20.90, 39.10, 31.50, 4.10], "English A: Language and Literature HL" : [0.00, 0.50, 5.80, 25.50, 37.50, 25.40, 5.30], "English B: SL" : [0.00, 0.20, 1.90, 7.60, 21.80, 48.80, 19.70], "English B: HL" : [0.00, 0.00, 0.60, 5.70, 25.50, 56.10, 12.10]]
    var group2_percentages = ["French B: SL" : [0.10, 1.80, 8.20, 22.90, 27.40, 30.50, 9.10], "French B: HL" : [0.10, 2.3, 10.7, 17.7, 23.5, 29.5, 16.20], "German B: SL" : [0.00, 0.90, 9.30, 21.40, 27.30, 28.80, 12.20], "German B: HL" : [0.00, 0.00, 2.20, 10.00, 24.60, 43.80, 19.40], "Spanish B: SL" : [0.00, 0.70, 9.20, 23.50, 28.50, 28.90, 9.20], "German Ab Initio: SL": [0.00, 1.00, 11.10, 23.10, 25.70, 29.40, 9.60], "Spanish Ab Initio: SL": [0.10, 2.80, 9.40, 24.10, 25.60, 27.30, 10.70], "French Ab Initio: SL" : [0.20, 3.30, 11.30, 23.30, 26.10, 24.50, 11.20], "French A: Literature SL" : [0.00, 0.40, 4.50, 22.70, 37.90, 26.80, 7.80], "French A: Literature HL" : [0.00, 0.00, 4.20, 19.60, 37.40, 28.80, 10.00], "French A: Language and Literature SL" : [0.00, 0.00, 1.00, 17.50, 36.50, 37.60, 7.50], "French A: Language and Literature HL" : [0.00, 0.00, 2.00, 23.30, 41.70, 27.10, 5.80], "German A: Literature SL" : [0.00, 2.30, 6.50, 26.00, 33.10, 22.40, 9.70], "German A: Literature HL" : [0.00, 0.00, 3.0, 23.30, 42.70, 25.90, 5.20], "German A: Language and Literature SL" : [0.00, 0.00, 2.30, 21.10, 32.90, 36.10, 7.40], "German A: Language and Literature HL" : [0.00, 0.00, 3.10, 19.10, 29.40, 37.50, 10.80], "Spanish A: Language and Literature SL" : [0.00, 2.80, 12.90, 24.50, 30.60, 23.50, 5.70], "Spanish A: Language and Literature HL" : [0.00, 1.10, 7.50, 24.10, 42.90, 20.10, 4.40]]
    var group3_percentages = ["Economics: SL" : [1.00, 5.50, 16.30, 20.80, 24.80, 21.80, 9.80], "Economics HL" : [0.40, 2.50, 8.00, 18.00, 30.50, 27.90, 13.10], "Geography: SL" : [0.20, 2.90, 13.90, 22.00, 30.80, 20.90, 9.20], "Geography: HL" : [0.00, 0.60, 6.60, 17.70, 36.20, 25.40, 13.40], "Global Politics: SL" : [0.10, 2.90, 10.80, 24.90, 35.50, 18.80, 7.10], "Global Politics: HL" : [0.10, 1.00, 5.40, 20.80, 37.10, 27.60, 8.00], "History: SL" : [0.10, 4.00, 10.90, 35.90, 34.80, 11.90, 2.20], "History: HL" : [0.20, 4.60, 15.50, 38.50, 29.10, 10.00, 2.00], "Psychology: SL" : [0.80, 8.60, 14.30, 27.60, 27.90, 17.20, 3.50], "Psychology: HL" : [0.20, 3.20, 12.20, 25.70, 31.10, 23.70, 3.90], "Environmental Systems and Societies: SL" : [1.80, 8.00, 24.20, 25.50, 23.60, 11.90, 5.00]]
    var group4_percentages = ["Biology: SL" : [0.90, 10.80, 21.80, 26.60, 20.50, 14.40, 5.0], "Biology: HL" : [1.20, 8.30, 18.50, 26.90, 23.00, 16.10, 5.90], "Chemistry: SL" : [2.90, 15.60, 22.50, 21.30, 17.00, 15.10, 5.50], "Chemistry: HL" : [1.10, 8.80, 17.90, 20.10, 23.00, 20.20, 8.80], "Computer Science: SL" : [2.30, 17.10, 24.70, 24.10, 16.40, 11.50, 3.90], "Computer Science: HL" : [2.00, 11.60, 17.90, 24.20, 25.30, 13.30, 5.70], "Design Technology: SL" : [0.00, 8.50, 28.10, 32.40, 21.80, 7.50, 1.70], "Design Technology: HL" : [0.30, 4.90, 15.70, 30.70, 27.50, 17.20, 3.80], "Physics: SL" : [1.70, 13.10, 26.70, 23.10, 17.20, 10.00, 8.10], "Physics: HL" : [0.70, 6.40, 18.60, 20.80, 22.20, 17.40, 14.00], "Sport, Exercise and Health Science: SL" : [0.90, 13.90, 27.10, 23.40, 20.80, 10.20, 3.70], "Sport, Exercise and Health Science: HL" : [0.00, 3.90, 12.70, 21.00, 26.70, 23.60, 12.20], "Environmental Systems and Societies: SL" : [1.80, 8.00, 24.20, 25.50, 23.60, 11.90, 5.00]]
    var group5_percentages = ["Mathematics: Analysis and Approaches SL" : [2.00, 12.40, 19.90, 23.30, 21.20, 14.90, 6.20], "Mathematics: Analysis and Approaches HL" : [1.10, 7.20, 13.50, 21.90, 24.80, 18.60, 12.80], "Mathematics: Applications and Interpretation SL" : [2.00, 12.40, 19.90, 23.30, 21.20, 14.90, 6.20], "Mathematics: Applications and Interpretation HL" : [1.10, 7.20, 13.50, 21.90, 24.80, 18.60, 12.80]]
    var group6_percentages = ["Music: SL" : [0.30, 1.60, 13.80, 30.90, 27.50, 21.90, 4.10], "Music: HL" : [0.10, 3.20, 17.30, 22.20, 28.50, 19.90, 8.70], "Theatre: SL" : [0.80, 7.40, 14.50, 29.30, 25.80, 14.50, 7.70], "Theatre: HL" : [0.30, 3.00, 10.60, 24.30, 27.60, 24.60, 9.40], "Visual Art: SL" : [0.30, 10.50, 35.20, 28.30, 19.20, 5.60, 1.10], "Visual Art: HL" : [0.10, 4.80, 23.80, 29.50, 26.20, 12.90, 2.70], "Economics: SL" : [1.00, 5.50, 16.30, 20.80, 24.80, 21.80, 9.80], "Economics HL" : [0.40, 2.50, 8.00, 18.00, 30.50, 27.90, 13.10], "Psychology: SL" : [0.80, 8.60, 14.30, 27.60, 27.90, 17.20, 3.50], "Psychology: HL" : [0.20, 3.20, 12.20, 25.70, 31.10, 23.70, 3.90], "Biology: SL" : [0.90, 10.80, 21.80, 26.60, 20.50, 14.40, 5.0], "Biology: HL" : [1.20, 8.30, 18.50, 26.90, 23.00, 16.10, 5.90], "Chemistry: SL" : [2.90, 15.60, 22.50, 21.30, 17.00, 15.10, 5.50], "Chemistry: HL" : [1.10, 8.80, 17.90, 20.10, 23.00, 20.20, 8.80], "Physics: SL" : [1.70, 13.10, 26.70, 23.10, 17.20, 10.00, 8.10], "Physics: HL" : [0.70, 6.40, 18.60, 20.80, 22.20, 17.40, 14.00]]
    var group7_percentages = ["Extended Essay": [10.90, 23.54, 37.99, 25.06, 1.53, 0.99], "Theory of Knowledge": [5.57, 25.54, 48.36, 18.94, 0.68, 0.91]]
    @State var showassignmentedit: Bool = false
    @State var selectedassignmentedit: String = ""
    let minussize: CGFloat = 45
    let squarecolor: String = "statsbg"
    @State var NewGradePresenting = false
    @State var storedindex = -1
    @State var noAssignmentsAlert = false
    @State private var selection: Set<Assignment> = []
    func getgradingscheme() -> String
    {
        return classcool.gradingscheme
    }
    func getnumberoflines() -> Int
    {
        if (getgradingscheme()[0..<1] == "P")
        {
            return 10
        }
        else if (getgradingscheme()[0..<1] == "N")
        {
            return Int(getgradingscheme()[3..<getgradingscheme().count]) ?? 10
        }
        else
        {
            if (getgradingscheme()[3..<4] == "F")
            {
                return 6
            }
            return 5
        }
    //    return 10
    }
    func getlinepadding(value: Int) -> CGFloat
    {
        return 270/CGFloat(getnumberoflines())*CGFloat(value+1)
       // return 0
    }
    func gettextvalue(value: Int) -> String
    {
        let aflist = ["F", "E" , "D", "C", "B", "A"]
        let aelist = ["E" , "D", "C", "B", "A"]
        if (getgradingscheme()[0..<1] == "N")
        {
            return String(value+1)
        }
        else if (getgradingscheme()[0..<1] == "P")
        {
            return String((value+1)*10)
        }
        else
        {
            if (getgradingscheme()[3..<4] == "F")
            {
                return aflist[value]
            }
            return aelist[value]
        }
    }

    @EnvironmentObject var masterRunning: MasterRunning
    let assignmenttypes = ["Homework", "Study", "Test", "Essay", "Presentation/Oral", "Exam", "Report/Paper"]
    var body: some View {
        ZStack {
            VStack {
                Text(classcool.name).font(.system(size: 24)).fontWeight(.bold) .frame(maxWidth: UIScreen.main.bounds.size.width-50, alignment: .center).multilineTextAlignment(.center)
                Spacer()
                Text("Average Grade: \(getAverageGrade(), specifier: "%.1f")")
                Spacer().frame(height: 20)
                Divider().frame(width: UIScreen.main.bounds.size.width-40, height: 4).background(Color("graphbackground"))
                ScrollView(showsIndicators: false) {
                    if (getAverageGrade() != 0) {
                        VStack {

                            if (getgradenum()) {
                                
                                Text(getFirstAssignmentDate() + " - " + getLastAssignmentDate()).font(.system(size: 20)).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-20, height: 40, alignment: .topLeading).offset(y: 30)
                            }
                            ZStack {
                                VStack {
                                    Rectangle().fill(Color("graphbackground")).frame(width:UIScreen.main.bounds.size.width, height: 300)
                                }.offset(y: 20)
                                HStack
                                {
                                    Spacer()
                                    VStack(alignment: .leading,spacing: 0) {
                                        
                                        Spacer()
                                        ZStack(alignment: .bottom)
                                        {
                                            ForEach(0..<getnumberoflines())
                                            {
                                                value in
                                                HStack
                                                {
                                                    Spacer()
                                                    Rectangle().fill(Color.black).frame(width: screensize, height: 0.5)
                                                    Text(gettextvalue(value: value)).frame(width: 20).font(.system(size: 10))
                                                    Spacer().frame(width: 20)
                                                }.frame(height: 5).padding(.bottom, getlinepadding(value: value)-3)
                                            }
                                            HStack
                                            {
                                                Spacer()
                                                VStack
                                                {
                                                    Spacer()
                                                
                                                    Rectangle().fill(Color.black).frame(width: screensize, height: 1.5).padding(.bottom, 2)
                                                }
                                                Text("0").frame(width: 20).font(.system(size: 10))
                                                Spacer().frame(width: 20)
                                            }.frame(height: 5).padding(.bottom, 0)
                                            
                                            HStack
                                            {
                                                Spacer()
                                                Rectangle().fill(Color.black).frame(width: 1.5, height: 271)
                                                Text("").frame(width: 20).font(.system(size: 10))
                                                Spacer().frame(width: 20)
                                            }.padding(.bottom, 0)
                                        }
                                        
                                        
                                        
                                    }//.offset(x: -10, y: -15)
                                 //   Spacer()
                                    
                                
                                }
                                HStack {
                                    Spacer()
                                    ScrollView(.horizontal, showsIndicators: false)
                                    {
                                        HStack {
                                            Spacer()
                                            ForEach(assignmentlist) {
                                                assignment in
                                                
                                                if (self.graphableAssignment(assignment: assignment))
                                                {
 
                                                    VStack {
                                                        Spacer()

                                                            Rectangle()
                                                            .fill(Color.blue)
                                                                .frame(width: self.getCompletedNumber(), height: getgradingscheme()[0..<1] == "P" ? CGFloat(assignment.grade)*270/100 : CGFloat(assignment.grade)*getlinepadding(value: 0))

                                                    }
 
                                                }
                                            }
                                        }
                                        
                                    }.frame(width: UIScreen.main.bounds.size.width-30)
                                    Spacer().frame(width: 50)


                                }

                            }
                            
                        }
                        VStack
                        {
                            if (getgradenum())
                            {
                                Spacer().frame(height: 40)
                                HStack {
                                    Text("Additional Insights").font(.headline)
                                    Spacer()
                                }.padding(.leading, 15)
                                Spacer().frame(height: 20)

                                HStack {
                                    VStack {
                                        Text("Average Grade").font(.system(size: 20)).fontWeight(.bold).padding(10).background(Color(squarecolor)).frame(width: UIScreen.main.bounds.size.width/2-minussize ,height: (UIScreen.main.bounds.size.width/2-minussize)/2)
                                        Text("\(getAverageGrade(), specifier: "%.2f")").font(.system(size: 25)).fontWeight(.light).frame(width: UIScreen.main.bounds.size.width/2-minussize , height: (UIScreen.main.bounds.size.width/2-minussize)/4)
                                        if (getChangeInAverageGrade() >= 0)
                                        {
                                            Text("+ \(getChangeInAverageGrade(), specifier: "%.2f")").foregroundColor(Color.green).font(.system(size: 25)).fontWeight(.light).frame(width: UIScreen.main.bounds.size.width/2-minussize , height: (UIScreen.main.bounds.size.width/2-minussize)/4)
                                        }
                                        else
                                        {
                                            Text("\(getChangeInAverageGrade(), specifier: "%.2f")").foregroundColor(Color.red).font(.system(size: 25)).fontWeight(.light).frame(width: UIScreen.main.bounds.size.width/2-minussize , height: (UIScreen.main.bounds.size.width/2-minussize)/4)
                                        }
                                    }.padding(10).background(Color(squarecolor)).cornerRadius(25)//.shadow(radius: 10)
                                    Spacer().frame(width: 20)
                                    VStack {
                                        Text("Last Assignment").font(.system(size: 20)).fontWeight(.bold).multilineTextAlignment(.center).padding(10).background(Color(squarecolor)).frame(width: UIScreen.main.bounds.size.width/2-minussize ,height: (UIScreen.main.bounds.size.width/2-minussize)/2)
                                        Text(String(getLastAssignmentGrade())).font(.system(size: 25)).fontWeight(.light).frame(width: UIScreen.main.bounds.size.width/2-minussize , height: (UIScreen.main.bounds.size.width/2-minussize)/4)
                                        if (Double(getLastAssignmentGrade()) - getAverageGrade() >= 0.0)
                                        {
                                            Text("+ \(Double(getLastAssignmentGrade()) - getAverageGrade(), specifier: "%.2f")").foregroundColor(Color.green).font(.system(size: 25)).fontWeight(.light).frame(width: UIScreen.main.bounds.size.width/2-minussize , height: (UIScreen.main.bounds.size.width/2-minussize)/4)
                                        }
                                        else
                                        {
                                            Text("\(Double(getLastAssignmentGrade()) - getAverageGrade(), specifier: "%.2f")").foregroundColor(Color.red).font(.system(size: 25)).fontWeight(.light).frame(width: UIScreen.main.bounds.size.width/2-minussize , height: (UIScreen.main.bounds.size.width/2-minussize)/4)
                                        }
                                    }.padding(10).background(Color(squarecolor)).cornerRadius(25)//.shadow(radius: 10)
                                }
                                if (getgradingscheme() == "N1-7")
                                {
                                    
                                    Spacer().frame(height: 20)
                                    HStack {
                                        VStack {
                                            Text("IB Class Average").font(.system(size: 20)).fontWeight(.bold).padding(10).background(Color(squarecolor)).frame(width: UIScreen.main.bounds.size.width/2-minussize ,height: (UIScreen.main.bounds.size.width/2-minussize)/2)
                                            Text(getGlobalAverageI() == 0 ? "No Data": String(getGlobalAverageI())).font(.system(size: 25)).fontWeight(.light).frame(width: UIScreen.main.bounds.size.width/2-minussize , height: (UIScreen.main.bounds.size.width/2-minussize)/4)
                                            Text("").font(.system(size: 20)).frame(width: UIScreen.main.bounds.size.width/2-minussize , height: (UIScreen.main.bounds.size.width/2-minussize)/4)

                                        }.padding(10).background(Color(squarecolor)).cornerRadius(25)//.shadow(radius: 10)
                                        Spacer().frame(width: 20)
                                        VStack {
                                            Text("IB Percentile").font(.system(size: 20)).fontWeight(.bold).padding(10).background(Color(squarecolor)).frame(width: UIScreen.main.bounds.size.width/2-minussize ,height: (UIScreen.main.bounds.size.width/2-minussize)/2)
                                            Text(getPercentile() == 0 ? "No Data": String(getPercentile()) + "%").font(.system(size:  25)).fontWeight(.light).frame(width: UIScreen.main.bounds.size.width/2-minussize , height: (UIScreen.main.bounds.size.width/2-minussize)/4)
                                            Text("").font(.system(size: 20)).frame(width: UIScreen.main.bounds.size.width/2-minussize , height: (UIScreen.main.bounds.size.width/2-minussize)/4)
                                        }.padding(10).background(Color(squarecolor)).cornerRadius(25)//.shadow(radius: 10)
                                    }
                                }
 
                            }
                            
                        }.frame(width: UIScreen.main.bounds.size.width)
 
                    }
                                        
                    Spacer().frame(height: 20)
//                    HStack {
//                        Text("Completed Assignments").font(.headline)
//                        Spacer()
//                    }.padding(.leading, 15)
                    
                    Text("Completed Assignments").font(.headline).frame(width: UIScreen.main.bounds.size.width-20, height: 40, alignment: .topLeading)//.offset(y: 30)

//                    Spacer().frame(height: 20)
                    
                    ForEach(assignmentlist)
                    {
                        assignment in
                        if (assignment.subject == self.classcool.originalname && assignment.completed == true && assignment.grade != 0)
                        {
                            GradedAssignmentsView(isExpanded2: self.selection.contains(assignment), isCompleted2: true, assignment2: assignment, selectededit: self.$sheetnavigator.selectedassignmentedit, showedit: self.$showassignmentedit).environment(\.managedObjectContext, self.managedObjectContext).onTapGesture {
                                    self.selectDeselect(assignment)
                                }.animation(.spring()).shadow(radius: 10)
                            
                        }
                    }
                    if (getUngradedAssignments() > 0)
                    {
                        Spacer().frame(height:10)
                        HStack {
                            VStack {
                                Divider()
                            }
                            Text("Ungraded Assignments").frame(width: 200)
                            VStack {
                                Divider()
                            }
                        }.animation(.spring())
                        ForEach(assignmentlist) {
                            assignment in
                            if (assignment.subject == self.classcool.originalname && assignment.completed == true && assignment.grade == 0) {
                                GradedAssignmentsView(isExpanded2: self.selection.contains(assignment), isCompleted2: true, assignment2: assignment, selectededit: self.$sheetnavigator.selectedassignmentedit, showedit: self.$showassignmentedit).shadow(radius: 10).onTapGesture {
                                    self.selectDeselect(assignment)
                                }.animation(.spring())
                            }
                        }
                    }
                }.animation(.spring())
                
            }.sheet(isPresented: $showassignmentedit, content: {
                        EditAssignmentModalView(NewAssignmentPresenting: self.$showassignmentedit, selectedassignment: self.getassignmentindex(), assignmentname: self.assignmentlist[self.getassignmentindex()].name, timeleft: Int(self.assignmentlist[self.getassignmentindex()].timeleft), duedate: self.assignmentlist[self.getassignmentindex()].duedate, iscompleted: self.assignmentlist[self.getassignmentindex()].completed, gradeval: Int(self.assignmentlist[self.getassignmentindex()].grade), assignmentsubject: self.assignmentlist[self.getassignmentindex()].subject, assignmenttype: self.assignmenttypes.firstIndex(of: self.assignmentlist[self.getassignmentindex()].type)!).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning)}).animation(.spring())
            VStack {
                Spacer()
                HStack {
                    Spacer()
 
                    Button(action: {
                        self.storedindex = self.getactualclassnumber(classcool: self.classcool)
                        self.getcompletedassignmentsbyclass() ? self.NewGradePresenting.toggle() : self.noAssignmentsAlert.toggle()
//                        self.scalevalue = self.scalevalue == 1.5 ? 1 : 1.5
//                        self.ocolor = self.ocolor == Color.blue ? Color.green : Color.blue
                        
                    }) {
                        RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.blue).frame(width: 70, height: 70).opacity(1).padding(.horizontal, getAverageGrade() == 0 ? 20 : 40).padding(.vertical, 20).overlay(

                            
                            ZStack {
                                //Circle().strokeBorder(Color.black, lineWidth: 0.5).frame(width: 50, height: 50)
                                Image(systemName: "plus").resizable().font(Font.title.weight(.bold)).foregroundColor(Color.white).frame(width: 12, height: 12).offset(x: -12, y: 12)
                                Image(systemName: "percent").resizable().foregroundColor(Color.white).scaledToFit().frame(width: 21).offset(x: 5, y: -5)
                            }
                        )
                    }.buttonStyle(PlainButtonStyle()).shadow(radius: 5)
                }
            }.animation(.spring()).sheet(isPresented: self.$NewGradePresenting, content: { NewGradeModalView(NewGradePresenting: self.$NewGradePresenting, classfilter: self.storedindex).environment(\.managedObjectContext, self.managedObjectContext)}).alert(isPresented: self.$noAssignmentsAlert) {
                Alert(title: Text("No Completed Assignments for this Class"), message: Text("Complete an Assignment First"))
            }
        }
    }
    func getUngradedAssignments() -> Int {
        for assignment in assignmentlist {
            if (assignment.subject == self.classcool.originalname && assignment.completed == true && assignment.grade == 0)
            {
                return 1
            }
        }
        return 0
    }
    private func selectDeselect(_ singularassignment: Assignment) {
        if selection.contains(singularassignment) {
            selection.remove(singularassignment)
        } else {
            selection.insert(singularassignment)
        }
    }
    func getassignmentindex() -> Int {
        for (index, assignment) in assignmentlist.enumerated() {
            if (assignment.name == sheetnavigator.selectedassignmentedit)
            {
                return index
            }
        }
        return 0
    }

    func getactualclassnumber(classcool: Classcool) -> Int
    {
        for (index, element) in classlist.enumerated() {
            if (element.name == classcool.name)
            {
                return index
            }
        }
        return 0
    }
    func getcompletedassignmentsbyclass() -> Bool {
        for assignment in assignmentlist {
            if (assignment.completed == true && assignment.grade == 0 && assignment.subject == self.classlist[self.storedindex].originalname)
            {
                return true;
            }
        }
        return false
    }
    func createDict() -> [Assignment: Int] {
        var assignmentgradetonumberdict = [Assignment: Int]()
        var counter = 1
        for assignment in assignmentlist {
            if (assignment.subject == classcool.originalname && assignment.completed == true && assignment.grade != 0) {
                assignmentgradetonumberdict[assignment] = counter
                counter += 1
            }
        }
        return assignmentgradetonumberdict
    }
    func getGlobalAverageI() -> Double {
        let allaverages = [group1_averages, group2_averages, group3_averages, group4_averages, group5_averages, group6_averages]
        var _: Double = 0
        for group in allaverages {
            for (name, grade) in group {
                if (name == classcool.originalname)
                {
                    return grade
                }
            }
        }
        return 0
    }
    func getPercentile() -> Int {
        let allpercentages = [group1_percentages, group2_percentages, group3_percentages, group4_percentages, group5_percentages, group6_percentages]
        var percentile: Double = 0
        for group in allpercentages {
            for (name, percentilelist) in group {
                if (name == classcool.originalname)
                {
                    for i in 0...(Int(getAverageGrade()+0.99)-1) {
                        percentile += percentilelist[i]
                    }
                    return Int(percentile+0.5)
                }
            }
        }
        return 0
    }
    func getAverageGrade() -> Double {
        var gradesum: Double = 0
        var gradenum: Double = 0
        for assignment in assignmentlist {
            if (assignment.subject == classcool.originalname && assignment.completed == true && assignment.grade != 0) {
                gradesum += Double(assignment.grade)
                gradenum += 1
            }
        }
        if (gradesum == 0) {
            return 0;
        }
        return (gradesum/gradenum)
    }
    func getFirstAssignmentDate() -> String {
        var formattertitle: DateFormatter
        formattertitle = DateFormatter()
        formattertitle.dateFormat = "MMMM yyyy"
        for assignment in assignmentlist {
            if (assignment.subject == classcool.originalname)
            {
                return formattertitle.string(from: assignment.duedate)
            }
        }
        return formattertitle.string(from: assignmentlist[0].duedate)
    }
    func getLastAssignmentDate() -> String {
        var storedDate: Date
        storedDate = Date()
        var formattertitle: DateFormatter
        formattertitle = DateFormatter()
        formattertitle.dateFormat = "MMMM yyyy"
        for assignment in assignmentlist {
            if (assignment.subject == classcool.originalname)
            {
                storedDate = assignment.duedate
            }
            
        }
        return formattertitle.string(from: storedDate)
    }
    
    func getLastAssignmentGrade() -> Int64 {
        var gradeval: Int64 = 0
        for assignment in assignmentlist {
            if (assignment.subject == classcool.originalname && assignment.completed == true && assignment.grade != 0) {
                gradeval = assignment.grade
            }
        }
      //  print(gradeval)
        return gradeval
    }
    
    func getgradenum() -> Bool {
        var gradenum: Int = 0
        for assignment in assignmentlist {
            if (assignment.subject == classcool.originalname && assignment.completed == true && assignment.grade != 0) {
                gradenum += 1
            }
        }
        if (gradenum >= 2) {
            return true
        }
        return false
    }
    
    func getChangeInAverageGrade() -> Double{
        var gradesum: Double = 0
        var gradenum: Double = 0
        var lastgrade: Double = 0
        for assignment in assignmentlist {
            if (assignment.subject == classcool.originalname && assignment.completed == true && assignment.grade != 0)
            {
                gradesum += Double(assignment.grade)
                gradenum += 1
                lastgrade = Double(assignment.grade)
            }
        }
        gradesum -= lastgrade
        gradenum -= 1
        return getAverageGrade() - gradesum/gradenum
    }
    func getCompletedNumber() -> CGFloat {
        var numberofcompleted: Double = 0
        
        for assignment in assignmentlist {
            if (assignment.subject == classcool.originalname && assignment.completed == true && assignment.grade != 0) {
                numberofcompleted += 1
            }
        }
        if (CGFloat(CGFloat((screensize-30)/CGFloat(numberofcompleted)) - 10) < CGFloat((screensize-30)/40)){
            return CGFloat((screensize-30)/40)
        }
        return CGFloat(CGFloat((screensize-30)/CGFloat(numberofcompleted)) - 10)
    }
    
    func graphableAssignment(assignment: Assignment) -> Bool{
        if (assignment.subject == self.classcool.originalname && assignment.completed == true && assignment.grade != 0) {
            return true;
        }
        return false;
    }
}
 
struct Line: View {
    var classcool: Classcool
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    var assignmentlist: FetchedResults<Assignment>
    
 
    var data: [Double] {
        var listofassignments: [Double] = []
        for (_, assignment) in assignmentlist.enumerated() {
            if (assignment.completed == true && assignment.grade != 0 && assignment.subject == classcool.originalname)
            {
                listofassignments.append(Double(assignment.grade))
            }
        }
        //print(listofassignments)
        return listofassignments
        
    }
    var stepWidth: CGFloat {
        if data.count < 2 {
            return 0
        }
     //   print(CGFloat(UIScreen.main.bounds.size.width-80)/CGFloat(data.count-1))
        return CGFloat(UIScreen.main.bounds.size.width-80)/CGFloat(data.count-1)
        
    }
    var stepHeight: CGFloat {

        if (classcool.gradingscheme[0..<1] == "N")
        {
            let value = classcool.gradingscheme[3..<classcool.gradingscheme.count]
            let intvalue = Int(value) ?? 8
            if (intvalue%2==0)
            {
                return 220/CGFloat(intvalue)
            }
            else
            {
                return 220/CGFloat(intvalue+1)
            }
        }
        else if (classcool.gradingscheme[0..<1] == "L")
        {
            if (classcool.gradingscheme[3..<4] == "F")
            {
                return 220/CGFloat(6)
            }
            else
            {
                return 220/CGFloat(5)
            }
        }
        else
        {
            return 220/CGFloat(100)
        }
                
    }
    var path: Path {
        let points = self.data
        return Path.lineChart(points: points, step: CGPoint(x: stepWidth, y: stepHeight))

    }
    
    func GetColorFromRGBCode(rgbcode: String, number: Int = 1) -> Color {
        if number == 1 {
            return Color(.sRGB, red: Double(rgbcode[9..<14])!, green: Double(rgbcode[15..<20])!, blue: Double(rgbcode[21..<26])!, opacity: 1)
        }
        
        return Color(.sRGB, red: Double(rgbcode[36..<41])!, green: Double(rgbcode[42..<47])!, blue: Double(rgbcode[48..<53])!, opacity: 1)
    }
    func getval(val: Int) -> CGFloat
    {
        if (val < self.data.count)
        {
            return CGFloat(self.data[val])
        }
        return CGFloat(0)
    }
    public var body: some View {
        
   //     ZStack {
 
            self.path
                .stroke(classcool.color.contains("rgbcode") ? GetColorFromRGBCode(rgbcode: classcool.color) : Color(classcool.color) ,style: StrokeStyle(lineWidth: 3, lineJoin: .round))
            if (self.data.count >= 2)
            {
                Circle().fill(classcool.color.contains("rgbcode") ? GetColorFromRGBCode(rgbcode: classcool.color) : Color(classcool.color) ).frame(width: 7, height: 7).position(x:20, y: 235-CGFloat(self.data[0]) * CGFloat(stepHeight) )
                ForEach(1..<self.data.count)
                {
                    val in
                    Circle().fill(classcool.color.contains("rgbcode") ? GetColorFromRGBCode(rgbcode: classcool.color) : Color(classcool.color) ).frame(width: 7, height: 7).position(x: 20 + stepWidth * CGFloat(val), y: 235 - stepHeight*getval(val: val))
                }
            }
           
      //  }
    }
}
extension Path {
    
    static func lineChart(points:[Double], step:CGPoint) -> Path {
        var path = Path()
        if (points.count < 2){
            return path
        }
        let p1 = CGPoint(x: 20, y: 235 - CGFloat(points[0]) * step.y)
        path.move(to: p1)
        for pointIndex in 1..<points.count {
            let p2 = CGPoint(x: 20 + step.x * CGFloat(pointIndex), y: 235 - step.y*CGFloat(points[pointIndex]))

            path.addLine(to: p2)
        }
        return path
    }
}

class SheetNavigatorProgressView: ObservableObject {
    @Published var storedindex: Int = -1
}
 
struct AddTimeClockView: View {
    @Binding var clockType: Int
    @Binding var dateRange: Int
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @FetchRequest(entity: AddTimeLog.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \AddTimeLog.starttime, ascending: true)])
    var addtimelog: FetchedResults<AddTimeLog>
    
    func ShouldDisplayAndMinutesFromDate(addTimeStartTime: Date) -> (Bool, Double) {
        let minutesFromStartOfDay = Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for: addTimeStartTime), to: addTimeStartTime).minute!
        
        let minutesTo12HourSystem = minutesFromStartOfDay % (60 * 12)
        
        if minutesFromStartOfDay == minutesTo12HourSystem {
            if clockType == 0 {
                return (true, Double(minutesTo12HourSystem) * 0.5)
            }
        }
        
        else {
            if clockType == 1 {
                return (true, Double(minutesTo12HourSystem) * 0.5)
            }
        }
        
        return (false, Double(minutesTo12HourSystem) * 0.5)
    }
    
    func findOuterBorderAngles() -> ([[Angle]], [Bool]) {
        var originalMinutes: [[Double]] = []
        var originalBools: [Bool] = []
        
//        let DateRanges: [Date] = [Calendar.current.date(byAdding: .day, value: -1, to: Date().startOfWeek!)!, Calendar.current.date(byAdding: .day, value: -7, to: Date().startOfWeek!)!, Calendar.current.date(byAdding: .day, value: -28, to: Date().startOfWeek!)!, Calendar.current.date(byAdding: .day, value: -365, to: Date().startOfWeek!)!]
        
        for addtimeinstance in self.addtimelog {
            if addtimeinstance.starttime != nil && addtimeinstance.endtime != nil && addtimeinstance.date != nil {
//                if addtimeinstance.date! >= DateRanges[self.dateRange] {
                    let (shouldDisplay, startDouble) = ShouldDisplayAndMinutesFromDate(addTimeStartTime: addtimeinstance.starttime!)
                    let (_, endDouble) = ShouldDisplayAndMinutesFromDate(addTimeStartTime: addtimeinstance.endtime!)
                    
                    originalMinutes.append([startDouble, endDouble])
                    originalBools.append(shouldDisplay)
//                }
            }
        }
        
        var originalMinutesDay: [[Double]] = []
        var originalMinutesNight: [[Double]] = []
        
        var finalDoublesDay: [[Double]] = []
        var finalDoublesNight: [[Double]] = []
        
        for (index, originalMinute) in originalMinutes.enumerated() {
            if originalBools[index] {
                originalMinutesDay.append(originalMinute)
            }
            
            else {
                originalMinutesNight.append(originalMinute)
            }
        }
        
        for originalMinute in originalMinutesDay {
            var appended = false
            
            for (finalDoubleIndex, finalDouble) in finalDoublesDay.enumerated() {
                if ((originalMinute[0] >= finalDouble[0] && originalMinute[0] <= finalDouble[1]) || (originalMinute[1] >= finalDouble[0] && originalMinute[1] <= finalDouble[1]) || (originalMinute[0] <= finalDouble[0] && originalMinute[0] >= finalDouble[1]) || (originalMinute[0] <= finalDouble[0] && originalMinute[0] >= finalDouble[1])) {
                    finalDoublesDay[finalDoubleIndex] = [min(originalMinute[0], finalDouble[0]), max(originalMinute[1], finalDouble[1])]
                    appended = true
                }
            }
            
            if !appended {
                finalDoublesDay.append(originalMinute)
            }
        }
        
        for originalMinute in originalMinutesNight {
            var appended = false
            
            for (finalDoubleIndex, finalDouble) in finalDoublesNight.enumerated() {
                if ((originalMinute[0] >= finalDouble[0] && originalMinute[0] <= finalDouble[1]) || (originalMinute[1] >= finalDouble[0] && originalMinute[1] <= finalDouble[1]) || (originalMinute[0] <= finalDouble[0] && originalMinute[0] >= finalDouble[1]) || (originalMinute[0] <= finalDouble[0] && originalMinute[0] >= finalDouble[1])) {
                    finalDoublesNight[finalDoubleIndex] = [min(originalMinute[0], finalDouble[0]), max(originalMinute[1], finalDouble[1])]
                    appended = true
                }
            }
            
            if !appended {
                finalDoublesNight.append(originalMinute)
            }
        }
        
        var finalAngles: [[Angle]] = []
        var finalBools: [Bool] = []
        
        for finalDouble in finalDoublesDay {
            finalAngles.append([Angle(degrees: finalDouble[0] - 90.0), Angle(degrees: finalDouble[1] - 90.0)])
            finalBools.append(true)
        }
        
        for finalDouble in finalDoublesNight {
            finalAngles.append([Angle(degrees: finalDouble[0] - 90.0), Angle(degrees: finalDouble[1] - 90.0)])
            finalBools.append(false)
        }
        
        return (finalAngles, finalBools)
    }
    
    var body: some View {
        VStack {
            ZStack {
                GeometryReader { geometry in
                    HStack(alignment: .center) {
                        Spacer()
                        ZStack {
                            ForEach(0..<60) { minute in
                                VStack {
                                    RoundedRectangle(cornerRadius: 1, style: .continuous).fill(self.colorScheme == .light ? Color.black : Color.white).frame(width: 3, height: 7).opacity(0.6)
                                    Spacer()
                                }.frame(height: geometry.size.width / 2).rotationEffect(Angle(degrees: Double(6 * minute)), anchor: .bottom)
                            }
                            
                            ForEach(0..<12) { semiImportantMinute in
                                VStack {
                                    RoundedRectangle(cornerRadius: 1, style: .continuous).fill(self.colorScheme == .light ? Color.black : Color.white).frame(width: 4, height: 9).opacity(0.9)
                                    Spacer()
                                }.frame(height: geometry.size.width / 2).rotationEffect(Angle(degrees: Double(30 * semiImportantMinute)), anchor: .bottom)
                            }
                            
                            ForEach(0..<4) { importantMinute in
                                VStack {
                                    RoundedRectangle(cornerRadius: 1, style: .continuous).fill(self.colorScheme == .light ? Color.black : Color.white).frame(width: 5, height: 11).opacity(1.0)
                                    Spacer()
                                }.frame(height: geometry.size.width / 2).rotationEffect(Angle(degrees: Double(90 * importantMinute)), anchor: .bottom)
                            }
                        }
                        Spacer()
                    }
                    
                    let centerPoint = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    let radius: CGFloat = (geometry.size.width / 2)
                    
                    let (anglesList, shouldDisplayList) = findOuterBorderAngles()
                    
                    ForEach(Array(zip(anglesList, shouldDisplayList)), id: \.0) { (angles, shouldDisplay) in
                        ZStack {
                            Path { path in
                                path.addArc(center: centerPoint, radius: radius, startAngle: angles[0], endAngle: angles[1], clockwise: false)
                                path.addArc(center: centerPoint, radius: 0, startAngle: angles[1], endAngle: angles[0], clockwise: true)
                                path.closeSubpath()
                            }.strokedPath(StrokeStyle(lineWidth: 2, lineCap: .square, lineJoin: .round, dash: [8, 14])).foregroundColor(Color("clockfg"))
                            
                            Path { path in
                                path.addArc(center: centerPoint, radius: radius, startAngle: angles[0], endAngle: angles[1], clockwise: false)
                                path.addArc(center: centerPoint, radius: 0, startAngle: angles[1], endAngle: angles[1], clockwise: true)
                                path.closeSubpath()
                            }.foregroundColor(Color("clockfg")).opacity(0.50)
                        }.opacity(shouldDisplay ? 1.0 : 0.0).animation(.spring())
                    }
                }
            }.frame(width: 180, height: 180)
            
            Text("6" + (clockType == 0 ? "AM" : "PM")).font(.footnote).fontWeight(.light).animation(.spring())
        }
    }
}


struct LittleRedIndicator: View {
    var body: some View {
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


struct TopBitView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Classcool.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    func allClassesTrash() -> Bool {
        for classity in self.classlist {
            if !classity.isTrash {
                return false
            }
        }
        
        return true
    }
    
    func displayNoneText() -> Bool {
        if classlist.isEmpty {
            return true
        }
        
        else if allClassesTrash() {
            return true
        }
        
        return false
    }
    
    var body: some View {
        HStack {
            Text("Progress").font(.largeTitle).bold().frame(height:40)
            Spacer()
        }.padding(.all, 10).padding(.top, -60).padding(.leading, 10)
            
        if self.displayNoneText() {
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
                }
                Text("button to start making progress!").foregroundColor(.gray).fontWeight(.semibold).multilineTextAlignment(.center)
                Spacer()
            }.frame(height: UIScreen.main.bounds.size.height/2)
        }
    }
}

struct ProgressView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var googleDelegate: GoogleDelegate
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @FetchRequest(entity: Classcool.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    var assignmentlist: FetchedResults<Assignment>
    
    @FetchRequest(entity: AddTimeLog.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \AddTimeLog.starttime, ascending: true)])
    var addtimelog: FetchedResults<AddTimeLog>
    
    @State var NewAssignmentPresenting = false
    @State var NewClassPresenting = false
    @State var NewOccupiedtimePresenting = false
    @State var NewFreetimePresenting = false
    @State var NewGradePresenting = false
    @State var NewGradePresenting2 = false
    @State var NewGradePresenting3 = false
    @State var noClassesAlert = false
    @State var noAssignmentsAlert = false
    @State var noAssignmentsAlert2 = false
    @State var storedindex = 0
    @ObservedObject var sheetnavigator: SheetNavigatorProgressView = SheetNavigatorProgressView()
    @State var showingSettingsView = false
    @State private var selectedClass: Int? = 0
    @State var selectedGraphClass: Int = 0
    @State private var selection: Set<String> = []
    @State var modalView: ModalView = .none
    @State var alertView: AlertView = .noclass
    @State var NewSheetPresenting = false
    @State var NewAlertPresenting = false
    @ObservedObject var sheetNavigator = SheetNavigator()
    @State var showpopup: Bool = false
    @State var widthAndHeight: CGFloat = 50
    @State var displayinggoalsetting: Bool = false
    @State var weeklygoal: Int = 0
    @State var editingweeklygoal: Bool = false
    @State var completedamountofweeklygoalminutes: Int = 90
    
    
    
    private func selectDeselect(_ singularassignment: String) {
        selection.removeAll()
        selection.insert(singularassignment)
        
    }
    
    func getclassnumber(classcool: Classcool) -> Int
    {
        for (index, element) in classlist.enumerated() {
            if (element.name == classcool.name)
            {
                return index+1
            }
        }
        return 1
    }
    func getactualclassnumber(classcool: Classcool) -> Int
    {
        for (index, element) in classlist.enumerated() {
            if (element.name == classcool.name)
            {
                return index
            }
        }
        return 0
    }
    func getdivisiblebytwo(value: Int) -> Bool {
        if (value % 2 == 0)
        {
            return true
        }
        return false
    }
    func getlastclass(value: Int) -> Bool {
        if (self.classlist.count % 2 == 1 && value == self.classlist.count-1)
        {
            return true
        }
        return false
        
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
    
    func GetColorFromRGBCode(rgbcode: String, number: Int = 1) -> Color {
        if number == 1 {
            return Color(.sRGB, red: Double(rgbcode[9..<14])!, green: Double(rgbcode[15..<20])!, blue: Double(rgbcode[21..<26])!, opacity: 1)
        }
        
        return Color(.sRGB, red: Double(rgbcode[36..<41])!, green: Double(rgbcode[42..<47])!, blue: Double(rgbcode[48..<53])!, opacity: 1)
    }
    
    @FetchRequest(entity: Freetime.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Freetime.startdatetime, ascending: true)])
    var freetimelist: FetchedResults<Freetime>
    
    func getloopnumber(classity: Classcool) -> Int
    {

       // print(classity.name, "loop number")
        if (classity.gradingscheme[0..<1] == "N")
        {
            let value = classity.gradingscheme[3..<classity.gradingscheme.count]
            let intvalue = Int(value) ?? 8
            if (intvalue%2==0)
            {
             //   print(intvalue/2)
                return intvalue/2
                
            }
            else
            {
               // print((intvalue+1)/2)
                return (intvalue+1)/2
            }
        }
        else if (classity.gradingscheme[0..<1] == "L")
        {
            if (classity.gradingscheme[3..<4] == "F")
            {
              //  print(6)
                return 6
            }
            else
            {
             //   print(5)
                return 5
            }
        }
        else
        {
        //    print(5)
            return 5
        }
    }
    func gettextval(value2: Int, classity: Classcool) -> String
    {
        let aflist = ["F", "E", "D", "C", "B", "A"]
        let aelist = ["E", "D", "C", "B", "A"]
        
        
        if (classity.gradingscheme[0..<1] == "N")
        {
            let value = classity.gradingscheme[3..<classity.gradingscheme.count]
            let intvalue = Int(value) ?? 8
            if (intvalue%2==0)
            {
                return String(2*(value2+1))
            }
            else
            {
                return String(2*(value2+1))
            }
        }
        else if (classity.gradingscheme[0..<1] == "L")
        {
            if (classity.gradingscheme[3..<4] == "F")
            {
                return aflist[value2]
            }
            else
            {
                return aelist[value2]
            }
        }
        else
        {
            return String(20*(value2+1))
        }

        
    }
    func getrightpadding(classity: Classcool) -> CGFloat
    {

        
        if (classity.gradingscheme[0..<1] == "N")
        {
            return CGFloat(20)
        }
        else if (classity.gradingscheme[0..<1] == "L")
        {
            return CGFloat(20)
        }
        else
        {
           return CGFloat(20)
        }
 
    }
    
    @State private var refreshID = UUID()
    
    func getclassindex(classity: Classcool) -> Int
    {
        for (index, classity2) in classlist.enumerated()
        {
            if (classity2 == classity)
            {
                return index
            }
        }
        return 0
    }
    
    func allClassesTrash() -> Bool {
        for classity in self.classlist {
            if !classity.isTrash {
                return false
            }
        }
        
        return true
    }
    
    //bug! changing tab makes it stuck (temp fix: permanently displayed)
//    @State var bigGraphTitleOpacity: Double = 1.0
    
    @State var isDayClock: Bool = true
    @State var clockType: Int = 0
    @State var dateRange: Int = 2
    
    @State var rescheduledtabselection: Int = 0
    
    var body: some View {
         NavigationView {
            VStack {
            TopBitView()
            
            ZStack {
//                NavigationLink(destination: EmptyView()) {
//                    EmptyView()
//                }
                NavigationLink(destination: SettingsView(), isActive: self.$showingSettingsView)
                { EmptyView() }
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .center )
                    {
                        if (classlist.count > 0 && !self.allClassesTrash())
                        {
                            TabView(selection: $selectedGraphClass)
                            {
                                ForEach(classlist)
                                {
                                    classity in
                                    if (!classity.isTrash)
                                    {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .fill(LinearGradient(gradient: Gradient(colors: [ Color("graphbackgroundtop"), Color("graphbackgroundbottom")]), startPoint: .bottomTrailing, endPoint: .topLeading))
                                                .frame(width: (UIScreen.main.bounds.size.width-20), height: (250 ))
                                                //.padding(5)
                                            
                                            VStack {
                                                HStack {
                                                    Rectangle().frame(width:(UIScreen.main.bounds.size.width-40), height: 1).padding(.top, 15).padding(.leading, 20)
                                                    Spacer()
                                                }
                                                Spacer()
                                                HStack {
                                                    Rectangle().frame(width: (UIScreen.main.bounds.size.width-40), height: 1).padding(.bottom, 15).padding(.leading, 20)
                                                    Spacer()
                                                }
                 
                                            }.frame(height: 250)
                 
                                            HStack {
                                                Spacer()
                                                VStack {
                                                    Spacer()
                                                    Rectangle().frame(width: 1, height: 220).padding(.bottom, 15).padding(.trailing, 40)
                                                }
                                            }.frame(height: 250)
                                            
                                            ForEach(0..<getloopnumber(classity: classity)) {
                                                value in
                                                VStack {
                                                    Spacer()
                                                    HStack {
                                                        Rectangle().fill(Color.black).frame(width: (UIScreen.main.bounds.size.width-40), height: 1).padding(.leading, 20).padding(.bottom, 15 + (220/CGFloat(getloopnumber(classity: classity)))*CGFloat(value+1)).opacity(0.3)
                                                        Spacer()
                                                    }
                                                }
                                                VStack {
                                                    Spacer()
                                                    HStack {
                                                        Spacer()
                                                        Text(gettextval(value2: value, classity: classity)).font(.system(size: 12)).padding(.trailing, getrightpadding(classity: classity) - 5).padding(.bottom, (220/CGFloat(getloopnumber(classity: classity)))*CGFloat(value+1) - 5)
                                                    }
                                                }
                                            }//.id(refreshID)

               
                                            Line(classcool: classity)
                                            
                                            VStack {
                                                HStack {
                                                    Text("Your Grades (by Class)").font(.footnote).fontWeight(.semibold).padding(.all, 5).background(Color("CharansOCD twin")).overlay(
                                                        RoundedRectangle(cornerRadius: 5)
                                                            .stroke(Color("CharansOCD twin"), lineWidth: 4)
                                                    )
                                                    Spacer()
                                                }
                                                Spacer()
                                            }.padding(.all, 12).padding(.horizontal, 3)
//                                            .opacity(self.bigGraphTitleOpacity)
//                                            .onAppear {
//                                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(2800)) {
//                                                    withAnimation(.spring()) {
//                                                        self.bigGraphTitleOpacity = 0.0
//                                                    }
//                                                }
//                                            }
                                        }.tag(getclassindex(classity: classity)).id(refreshID)
                                    }
                                }
                            }.tabViewStyle(PageTabViewStyle()).frame(width: (UIScreen.main.bounds.size.width-20), height: (250))
//                            .onTapGesture {
//                                withAnimation(.spring()) {
//                                    self.bigGraphTitleOpacity = 1.0
//                                }
//                            }
                        }
                        // || self.allClassesTrash()
//                        if !(self.allClassesTrash()) {
//                        else {
                            HStack(alignment: .center) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color("clockbg"))
                                        .frame(width: (UIScreen.main.bounds.size.width-30)*2/3, height: (300 ))
                                    
                                    VStack(spacing: 0) {
                                        Text("Rescheduled Tasks").fontWeight(.semibold).frame(width: (UIScreen.main.bounds.size.width-50)*2/3, height: 30).padding(.top, 5)
                                        
    //                                    Picker("Date Range", selection: $dateRange) {
    //                                        Text("Year").tag(3)
    //                                        Text("Month").tag(2)
    //                                        Text("Week").tag(1)
    //                                        Text("Day").tag(0)
    //                                    }.pickerStyle(SegmentedPickerStyle()).frame(width: (UIScreen.main.bounds.size.width-70)*2/3).padding(.bottom, 4)
                                        TabView(selection: self.$rescheduledtabselection) {
                                            VStack(spacing: 12) {
                                                Text("View all the tasks which you swiped right to reschedule on a clock face, based on when they were originally scheduled.").fontWeight(.light).lineLimit(5).minimumScaleFactor(0.5).frame(width: 2*(UIScreen.main.bounds.size.width-30)/3 - 32, alignment: .leading)
                                                
                                                Text("You can use this chart as a guide to adjust your work hours to maximize productivity.").fontWeight(.light).minimumScaleFactor(0.6).frame(width: 2*(UIScreen.main.bounds.size.width-30)/3 - 32, alignment: .leading)
                                                
                                                Spacer()
                                                
                                                if self.addtimelog.isEmpty {
                                                    HStack {
                                                        Text("You have rescheduled 0 tasks!").fontWeight(.light).multilineTextAlignment(.center)
                                                    }
                                                }

                                                else {
                                                    Button(action: {
                                                        withAnimation(Animation.spring()) {
                                                            self.rescheduledtabselection = 1
                                                        }
                                                    }) {
                                                        Text("View Chart").fontWeight(.light)
                                                    }
                                                }
                                            }.padding(.all, 12).tag(0)
                                            
//                                            if !self.addtimelog.isEmpty {
                                                VStack {
                                                    AddTimeClockView(clockType: self.$clockType, dateRange: self.$dateRange).transition(.opacity).padding(.bottom, 4)
                                                    
                                                    Picker("Clock Type", selection: $clockType) {
                                                        Image(systemName: "sun.max.fill").tag(0)
                                                        Image(systemName: "moon.fill").tag(1)
                                                    }.pickerStyle(SegmentedPickerStyle()).frame(width: (UIScreen.main.bounds.size.width-30)*1/3)
                                                }.tag(1)
//                                            }
                                        }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)).frame(height: 270)
                                    }
                                }
    //                            ZStack {
    //                                RoundedRectangle(cornerRadius: 10, style: .continuous)
    //                                    .fill(Color("thirteen"))
    //                                    .frame(width: (UIScreen.main.bounds.size.width-30)*2/3, height: (200 ))
    //                                VStack {
    //
    //                                    if (editingweeklygoal)
    //                                    {
    //                                        VStack
    //                                        {
    //                                            Text("Set Your Weekly Worload Goal!").font(.system(size: 20)).fontWeight(.bold).foregroundColor(Color.black).padding(10)
    //                                            Button(action:{
    //                                                withAnimation(.spring())
    //                                                {
    //                                                    displayinggoalsetting.toggle()
    //                                                }
    //                                            })
    //                                            {
    //                                                Image(systemName: "chevron.compact.down").resizable().frame(width: 42, height: 10)
    //                                            }.buttonStyle(PlainButtonStyle())
    //                                            if (displayinggoalsetting)
    //                                            {
    //                                                Stepper(String(weeklygoal) + " hours", value: $weeklygoal, in: 0...168).padding(15)
    //                                            }
    //
    //                                        }
    //                                    }
    //                                    else
    //                                    {
    //                                        HStack
    //                                        {
    //                                            VStack
    //                                            {
    //                                                ZStack
    //                                                {
    //                                                    VStack
    //                                                    {
    //                                                        Spacer().frame(height: 20)
    //                                                        Text("\(String(format: "%.0f", Double(completedamountofweeklygoalminutes)/Double(60*weeklygoal)*100))" + "%").fontWeight(.bold).font(.system(size: 25))
    //                                                        Spacer()
    //                                                    }
    //                                                    VStack
    //                                                    {
    //                                                        Spacer().frame(height: 70)
    //                                                        HStack
    //                                                        {
    //                                                            Spacer()
    //                                                            Rectangle().frame(width: 5, height: 80)
    //                                                            Spacer().frame(width: 60)
    //                                                            Rectangle().frame(width: 5, height: 80)
    //                                                            Spacer()
    //                                                        }
    //                                                        Spacer()
    //                                                    }
    //                                                    VStack
    //                                                    {
    //                                                        Spacer().frame(height: 150)
    //                                                        Rectangle().frame(width: 70, height: 5)
    //                                                        Spacer()
    //                                                    }
    //                                                    VStack
    //                                                    {
    //                                                        Spacer().frame(height: 150 -  min(80, CGFloat(Double(completedamountofweeklygoalminutes)/Double(60*weeklygoal))*80 ))
    //                                                        Rectangle().fill(Color.blue).frame(width: 60, height: min(80, CGFloat(Double(completedamountofweeklygoalminutes)/Double(60*weeklygoal))*80 ))
    //                                                        Spacer()
    //                                                    }
    //
    //                                                }
    //                                            }
    ////                                            Spacer()
    ////                                            Rectangle().frame(width: 2, height: 160)
    ////                                            Spacer()
    ////                                            VStack
    ////                                            {
    ////                                                Text(String(completedamountofweeklygoalminutes/60) + " hours").fontWeight(.bold).font(.system(size: 20)).frame(width: 120)
    ////                                                Rectangle().frame(width: 100, height: 2)
    ////                                                Text(String(weeklygoal) + " hours").fontWeight(.bold).font(.system(size: 20)).frame(width: 120)
    ////                                            }
    //                                        }
    //                                    }
    //
    //                                }
    //                                VStack
    //                                {
    //                                    HStack
    //                                    {
    //                                        Spacer()
    //                                        Button(action:
    //                                        {
    //                                            editingweeklygoal.toggle()
    //                                        })
    //                                        {
    //                                            Image(systemName: editingweeklygoal ? "pencil.circle.fill" : "pencil.circle").resizable().frame(width: 20, height:20).padding(10)
    //                                        }.buttonStyle(PlainButtonStyle())
    //
    ////
    //                                    }
    //                                    Spacer()
    //                                }
    //
    //                            }
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(LinearGradient(gradient: Gradient(colors: [ Color("graphbackgroundtop"), Color("graphbackgroundbottom")]), startPoint: .bottomTrailing, endPoint: .topLeading))
    //                                    .fill(LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.purple]), startPoint: .bottomTrailing, endPoint: .topLeading))
                                        .frame(width: (UIScreen.main.bounds.size.width-30)*1/3, height: (300 ))
                                    ScrollView(showsIndicators: false) {
     
     
                                            VStack(alignment: .leading,spacing:10) {
                                                Text("Your Classes:").font(.system(size: 16)).fontWeight(.semibold).padding(.leading, 10)
                                                ForEach(classlist) {
                                                    classcool in
                                                    if (!classcool.isTrash)
                                                    {

                                                        HStack {
                                                            
                                                            Rectangle().fill(classcool.color.contains("rgbcode") ? GetColorFromRGBCode(rgbcode: classcool.color) : Color(classcool.color)).frame(width: 20, height: 4).padding(.leading, 10).opacity(self.selection.contains(classcool.name) ? 1.0 : 0.5)
                                                            Spacer()
                                                            Button(action: {
                                                                withAnimation(.spring())
                                                                {
                                                                    self.selectedGraphClass = getclassindex(classity: classcool)
                                                                }
                                                                //self.refreshID = UUID()
                                                            })
                                                            {
                                                              
                                                                Text(classcool.name).font(.system(size: 15)).fontWeight(self.selectedGraphClass == getclassindex(classity: classcool) ? .semibold : .regular).frame(width:(UIScreen.main.bounds.size.width-30)*1/3-60, alignment: .topLeading).foregroundColor(Color("selectedcolor")).opacity(self.selectedGraphClass == getclassindex(classity: classcool) ? 1.0 : 0.5)
                                                            }
            //                                                Spacer()
            //                                                if (self.selection.contains(classcool.name)) {
            //
            //                                                    Image(systemName: "checkmark").foregroundColor(.blue)
            //                                                }
                                                            Spacer()
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                        }
                                        
                                    }.frame(height: 280)//.padding(10)
                                    //Text("Key").font(.title)
                                }
                            }.opacity((self.allClassesTrash() || self.classlist.isEmpty) ? 0.0 : 1.0).disabled((self.allClassesTrash() || self.classlist.isEmpty) ? true : false).frame(height: (self.allClassesTrash() || self.classlist.isEmpty) ? 1 : 300).padding(.horizontal, 10)
//                        }
                        
                        WorkloadPie()
 
//                        Spacer().frame(height: 8)
                       // Text("Classes").font(.system(size: 35)).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-20, alignment: .leading)

                        ForEach(0..<classlist.count, id: \.self) {
                            value in
//                            if (!self.classlist[value].isTrash) {
                                NavigationLink(destination: DetailProgressView(classcool2: self.classlist[value]), tag: self.getclassnumber(classcool: self.classlist[value]), selection: self.$selectedClass) {
                                    EmptyView()
                                }
                                HStack {
                                    
                                    Button(action: {
                                        self.selectedClass = self.getclassnumber(classcool: self.classlist[value])
                                    }) {
                                        if (self.getlastclass(value: value))
                                        {
                                            ClassProgressView(classcool: self.classlist[value]).frame(alignment: .leading).padding(.leading, 5)
                                        }
                                        else if (self.getdivisiblebytwo(value: value))
                                        {
                                            
                                            ClassProgressView(classcool: self.classlist[value])
                                            
                                        }
 
                                    }.buttonStyle(PlainButtonStyle()).contextMenu {
                                        Button (action: {
 
                                            self.sheetnavigator.storedindex = self.getactualclassnumber(classcool: self.classlist[value])
                                            self.getcompletedassignmentsbyclass() ? self.NewGradePresenting2.toggle() : self.noAssignmentsAlert2.toggle()
                                        }) {
                                            Text("Add Grade")
                                        }
                                        
                                    }.padding(0)
                                    
                                    Button(action: {
                                        self.selectedClass = self.getclassnumber(classcool: self.classlist[value+1])
                                    }) {
                                        if (self.getlastclass(value: value))
                                        {
                                        }
                                        else if (self.getdivisiblebytwo(value: value))
                                        {
                                            ClassProgressView(classcool: self.classlist[value+1])
                                        }
                                    }.buttonStyle(PlainButtonStyle()).contextMenu {
                                        Button (action: {
                                            self.sheetnavigator.storedindex = self.getactualclassnumber(classcool: self.classlist[value+1])
                                            self.getcompletedassignmentsbyclass() ? self.NewGradePresenting2.toggle() : self.noAssignmentsAlert2.toggle()
                                        }) {
                                            Text("Add Grade")
                                        }
                                    }.padding(0)
                                    
//                                }
                                }
                        }.opacity(self.allClassesTrash() ? 0.0 : 1.0).disabled(self.allClassesTrash() ? true : false)
                        .sheet(isPresented: self.$NewGradePresenting2, content: { NewGradeModalView(NewGradePresenting: self.$NewGradePresenting2, classfilter: self.sheetnavigator.storedindex).environment(\.managedObjectContext, self.managedObjectContext)}).alert(isPresented: self.$noAssignmentsAlert2) {
                            Alert(title: Text("No Completed Assignments for this Class"), message: Text("Complete an Assignment First"))
                        }
                    }
                    
                    Spacer().frame(height: 5)
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
                                 //       countnewassignments = 0
                                        
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
            }
            .navigationBarItems(
                leading:
                HStack(spacing: UIScreen.main.bounds.size.width / 4.5) {
                    Button(action: {self.showingSettingsView = true}) {
                        ZStack {
                            Image(systemName: "gear").resizable().scaledToFit().foregroundColor(colorScheme == .light ? Color.black : Color.white).font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
                            
                            if self.freetimelist.isEmpty {
                                LittleRedIndicator()
                            }
                        }
                    }.padding(.leading, 2.0)
                
                    Image(self.colorScheme == .light ? "Tracr" : "TracrDark").resizable().scaledToFit().frame(width: UIScreen.main.bounds.size.width / 3.5).offset(y: 5)
                    Text("").frame(width: UIScreen.main.bounds.size.width/11, height: 20)

                })//.navigationTitle("Progress")//.padding(.top, 0))//.navigationTitle("Progress")
         }.navigationViewStyle(StackNavigationViewStyle())
         .onDisappear {
            let defaults = UserDefaults.standard
            defaults.set(weeklygoal, forKey: "weeklygoal")
            
            self.showingSettingsView = false
            self.selectedClass = 0
            self.showpopup = false
         }.onAppear {
            let defaults = UserDefaults.standard
            weeklygoal = defaults.object(forKey: "weeklygoal") as? Int ?? 0
            if (weeklygoal == 0)
            {
                editingweeklygoal = true
            }
            completedamountofweeklygoalminutes = defaults.object(forKey: "weeklyminutesworked") as! Int
            if (classlist.count > 0)
            {
                self.selectDeselect(classlist[0].name)
            }
            self.refreshID = UUID()
         }
    }
    
    func getcompletedAssignments() -> Bool {
        for assignment in assignmentlist {
            if (assignment.completed == true && assignment.grade == 0)
            {
               // print(assignment.name)
                return true;
            }
        }
        return false
    }
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    func getcompletedassignmentsbyclass() -> Bool {
        for assignment in assignmentlist {
            if (assignment.completed == true && assignment.grade == 0 && assignment.subject == self.classlist[self.sheetnavigator.storedindex].originalname)
            {
                return true;
            }
        }
        return false
    }
}

struct WorkloadSliver: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    let classname: String
    let startingAngle: Angle
    let endingAngle: Angle
    let color: Color
    let largeRadiusPercentage: CGFloat
    
    @Binding var selectedSliver: [String]
    let sliverinfo: [String]
    
    @State var thisSliverClicked: Bool = false
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let centerPoint = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let innerRadius: CGFloat = (geometry.size.width / 7)
//                let largeRadius = (innerRadius + (largeRadiusPercentage * (((geometry.size.width / 2) - 40) - innerRadius))) nope
                
                let largeRadius: CGFloat = (innerRadius + (0.88 * (((geometry.size.width / 2) - 40) - innerRadius)))
                if self.selectedSliver == self.sliverinfo && self.thisSliverClicked {
                    Path { path in
                        path.addArc(center: centerPoint, radius: innerRadius, startAngle: startingAngle, endAngle: endingAngle, clockwise: false)
                        path.addArc(center: centerPoint, radius: largeRadius, startAngle: endingAngle, endAngle: startingAngle, clockwise: true)
                        path.closeSubpath()
                    }.stroke(self.colorScheme == .light ? Color.black : Color.white, lineWidth: self.colorScheme == .light ? 1 : 2)
                }
                Path { path in
                    path.addArc(center: centerPoint, radius: innerRadius, startAngle: startingAngle, endAngle: endingAngle, clockwise: false)
                    path.addArc(center: centerPoint, radius: largeRadius, startAngle: endingAngle, endAngle: startingAngle, clockwise: true)
                    path.closeSubpath()
                }.foregroundColor(self.color)
            }
        }.zIndex((self.selectedSliver == self.sliverinfo && self.thisSliverClicked) ? 1 : 0).animation(.easeInOut(duration: 0.14)).onTapGesture {
            if self.selectedSliver == self.sliverinfo {
                self.selectedSliver = []
                self.thisSliverClicked = false
            }

            else {
                self.selectedSliver = self.sliverinfo
                withAnimation(.spring())
                {
                self.thisSliverClicked = true
                }
            }
        }
    }
}

struct WorkloadPie: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Classcool.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    var classlist: FetchedResults<Classcool>
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    var assignmentlist: FetchedResults<Assignment>

    @State var selectedSliver: [String] = []
    
    @State var slivers: [[String]] = []
    // classname, startingAngle, endingAngle, colorstring, largeRadiusPercentage
        
    func DataPrep() -> Void {
        var ClassToWorkDone: [String: Int64] = [:] // (sum of totaltime) - (sum of timeleft)
        var ClassToWorkTotal: [String: Int64] = [:] // sum of totaltime
        var ClassToProgress: [String: Double] = [:] // (WorkDone / WorkTotal)
        var ClassToAngleDegrees: [String: Double] = [:] // (WorkDone / sum(WorkDone)) * 360
        var ClassToFirstAngle: [String: Double] = [:]
        var ClassToSecondAngle: [String: Double] = [:]
        var ClassToColor: [String: String] = [:]
        
        self.slivers.removeAll()
        self.selectedSliver.removeAll()
        
        var totalWorkDone: Int64 = 0
        
        // Creating the WorkDone and WorkTotal Dictionaries
        for assignment in assignmentlist {
            if let WorkDone = ClassToWorkDone[assignment.subject] {
                ClassToWorkDone[assignment.subject] = WorkDone + (assignment.totaltime - assignment.timeleft)
                if let WorkTotal = ClassToWorkTotal[assignment.subject] {
                    ClassToWorkTotal[assignment.subject] = WorkTotal + assignment.totaltime
                }
            }
            
            else {
                ClassToWorkDone[assignment.subject] = assignment.totaltime - assignment.timeleft
                ClassToWorkTotal[assignment.subject] = assignment.totaltime
            }
            
            totalWorkDone = totalWorkDone + (assignment.totaltime - assignment.timeleft)
        }
        
        // Creating the Progress Dictionary
        for (classname, workdone) in ClassToWorkDone {
            if let worktotal = ClassToWorkTotal[classname] {
                ClassToProgress[classname] = worktotal == 0 ? nil : Double(workdone) / Double(worktotal)
            }
        }
        
        // Creating the TotalAngleDegrees Dictionary
        for (classname, _) in ClassToProgress {
            if let WorkDoneforClass = ClassToWorkDone[classname] {
                ClassToAngleDegrees[classname] = Double(WorkDoneforClass) / Double(totalWorkDone) * 360.0
            }
        }
        
        // Creating the FirstAndSecondAngle Dictionaries
        var firstAngle = 0.0
        var secondAngle = 0.0
        
        for (classname, totalangle) in ClassToAngleDegrees {
            firstAngle = secondAngle
            secondAngle = firstAngle + totalangle
            
            ClassToFirstAngle[classname] = firstAngle
            ClassToSecondAngle[classname] = secondAngle
        }
        
        // Creating the ClassColors Dictionary
        for classity in classlist {
            ClassToColor[classity.originalname] = classity.color
        }
        
        // Appending to Slivers
        for (classname, progress) in ClassToProgress {
            self.slivers.append([classname, String(ClassToFirstAngle[classname, default: 0.0]), String(ClassToSecondAngle[classname, default: 0.0]), ClassToColor[classname, default: "datenumberred"], String(progress), String(ClassToAngleDegrees[classname, default: 0.0] / 360.0)])
        }
        
//        self.slivers.append(["Biology HL", "0.0", "90.0", "three", "0.8"])
//        self.slivers.append(["Mathematics HL", "90.0", "110.0", "two", "0.3"])
//        self.slivers.append(["Design SL", "110.0", "360.0", "one", "1.0"])
    }
    
    func getColor(colorstring: String) -> Color {
        if colorstring.contains("rgbcode") {
            return Color(.sRGB, red: Double(colorstring[9..<14])!, green: Double(colorstring[15..<20])!, blue: Double(colorstring[21..<26])!, opacity: 1)
        }
    
        else {
            return Color(colorstring)
        }
    }
    
    var body: some View {
        VStack {
            Spacer().frame(height: 10).onAppear(perform: self.DataPrep)
            
            if self.slivers.count > 1 {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous).fill(LinearGradient(gradient: Gradient(colors: [Color("workloadpiechartbg1"), Color("workloadpiechartbg2")]), startPoint: .top, endPoint: .bottom)).frame(width: UIScreen.main.bounds.size.width - 20, height: UIScreen.main.bounds.size.width).shadow(radius: 1)
                    
                    VStack {
                        HStack {
                            Text("Workload Distribution").font(.system(size: 19)).fontWeight(.semibold).multilineTextAlignment(.leading).frame(width: 200)
                            Spacer()
                        }.padding(.horizontal, 9).padding(.top, 9)

                        ZStack {
                            ForEach(self.slivers, id: \.self) { sliverinfo in
                                WorkloadSliver(classname: sliverinfo[0], startingAngle: Angle(degrees: Double(sliverinfo[1])!), endingAngle: Angle(degrees: Double(sliverinfo[2])!), color: self.getColor(colorstring: sliverinfo[3]), largeRadiusPercentage: CGFloat(Double(sliverinfo[4])!), selectedSliver: self.$selectedSliver, sliverinfo: sliverinfo).shadow(radius: 2)
                            }
                        }
                        
                        if !self.selectedSliver.isEmpty {
                            VStack(spacing: 4) {
                                HStack(spacing: 0) {
                                    Text(selectedSliver[0]).fontWeight(.semibold).animation(.spring())
                                    Spacer()
                                }
                                
                                HStack(spacing: 0) {
                                    Text("% Workload: \(Int(round(100 * Double(selectedSliver[5])!)))%").fontWeight(.light).animation(.spring())
                                    Spacer()
//                                    Text("% Completed: \(Int(round(100 * Double(selectedSliver[4])!)))%").fontWeight(.light).animation(.spring())
                                }
                            }.frame(height: 60).padding(.horizontal, 9).animation(.spring())
                        }
                        
                        else {
                            VStack(alignment: .leading) {
                                Spacer()
                                HStack {
                                    Text("Proportion of the Pie: Proportion of Total Workload of that Class").font(.system(size: 15)).fontWeight(.light).animation(.spring())//.frame(height: 50)
                                    Spacer()
                                }
                            }.frame(height: 60).padding(.horizontal, 9).padding(.bottom, 9)
                        }
                    }.animation(.spring())
                }.frame(width: UIScreen.main.bounds.size.width - 20, height: UIScreen.main.bounds.size.width)
                
                Spacer().frame(height: 9)
            }
        }
    }
}

 
struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
          let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        return ProgressView().environment(\.managedObjectContext, context)
    }
}
