//
//  ContentView.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 6/30/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//
import Foundation
import SwiftUI
import UserNotifications
import GoogleSignIn
import GoogleAPIClientForREST

class DisplayedDate: ObservableObject {
    @Published var score: Int = 0
}

class AddTimeSubassignment: ObservableObject {
    @Published var subassignmentname = "SubAssignmentNameBlank"
    @Published var subassignmentlength = 0
    @Published var subassignmentcolor = "one"
    @Published var subassignmentstarttimetext = "aa:bb"
    @Published var subassignmentendtimetext = "cc:dd"
    @Published var subassignmentdatetext = "dd/mm/yy"
    @Published var subassignmentindex = 0
    @Published var subassignmentcompletionpercentage: Double = 0
}

class ActionViewPresets: ObservableObject {
    @Published var actionViewOffset: CGFloat = UIScreen.main.bounds.size.width
    @Published var actionViewType: String = ""
    @Published var actionViewHeight: CGFloat = 0
    
//    @Published var setupLaunchClass: Bool = false
//    @Published var setupLaunchFreetime: Bool = false
}

class AddTimeSubassignmentBacklog: ObservableObject {
    @Published var backlogList: [[String: String]] = []
}

class MasterRunning: ObservableObject {
    @Published var masterRunningNow: Bool = false
    @Published var masterDisplay: Bool = false
    @Published var onlyNotifications: Bool = false
    @Published var displayText: Bool = false
    @Published var uniqueAssignmentName: String = ""
    @Published var extratimealertmessage: String = ""
    @Published var showingalert: Bool = false
}

struct MasterRunningDisplay: View {
    @EnvironmentObject var masterRunning: MasterRunning
  //  @Environment(\.colorScheme) var colorScheme: ColorScheme

    var body: some View {
        VStack {
            Text("Optimizing Schedule").foregroundColor(Color.black)
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2.5, style: .continuous).foregroundColor(.gray).opacity(0.6).frame(width: 163, height: 5)
                RoundedRectangle(cornerRadius: 2.5, style: .continuous).foregroundColor(.blue).frame(width: masterRunning.masterDisplay ? 163 : 0, height: 5).animation(Animation.easeInOut(duration: 1.2).delay(0.4))
            }.cornerRadius(3)
        }.padding(.all, 15).frame(maxHeight: 70).background(Color.white).cornerRadius(10).padding(.all, 15).shadow(radius: 3)
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
   // @EnvironmentObject var googleDelegate: GoogleDelegate
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @FetchRequest(entity: Freetime.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Freetime.startdatetime, ascending: true)])
    var freetimelist: FetchedResults<Freetime>
    @FetchRequest(entity: AssignmentTypes.entity(), sortDescriptors: [])
    var assignmenttypeslist: FetchedResults<AssignmentTypes>
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    
    @EnvironmentObject var masterRunning: MasterRunning
    
    @State var firstLaunchTutorial: Bool = false
    
    init() {
        if #available(iOS 14.0, *) {
            // iOS 14 doesn't have extra separators below the list by default.
        } else {
            // To remove only extra separators below the list:
            UITableView.appearance().tableFooterView = UIView()
        }
        GIDSignIn.sharedInstance().restorePreviousSignIn()
        

       // UITableView.appearance().tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
        // To remove all separators including the actual ones:
        UITableView.appearance().separatorStyle = .none
//        UITableView.appearance().backgroundColor = .clear
//        changingDate.score = 1
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    @State var newclasspresenting = false
    //every time new update, create new userdefaultsvar for that update. If false, recreate userdefaultsvars and core data safely (with whatever updated properties)
    func initialize() {
        let defaults = UserDefaults.standard

        if !(defaults.object(forKey: "LaunchedBefore") as? Bool ?? false) {
            defaults.set(true, forKey: "LaunchedBefore")
         //   print("kewl")
            let gradingschemes: [String] = ["P", "N1-7", "LA-F", "N1-8", "N1-4"]
            defaults.set(0, forKey: "weeklyminutesworked")
            let lastmondaydate =  Calendar.current.date(byAdding: .day, value: 1, to: Date().startOfWeek!)! > Date() ? Calendar.current.date(byAdding: .day, value: -6, to: Date().startOfWeek!)! : Calendar.current.date(byAdding: .day, value: 1, to: Date().startOfWeek!)!
            let nextmondaydate = Date(timeInterval: 604800, since: lastmondaydate)
            
            defaults.set(nextmondaydate, forKey: "weeklyzeroday")
            
            defaults.set(gradingschemes, forKey: "savedgradingschemes")
            let assignmenttypes = ["Homework", "Study", "Test", "Essay", "Presentation/Oral", "Exam", "Report/Paper"]
            
            for assignmenttype in assignmenttypes {
                let newType = AssignmentTypes(context: self.managedObjectContext)
                
                newType.type = assignmenttype
                newType.rangemin = 60
                newType.rangemax = 180
                
                do {
                    try self.managedObjectContext.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            defaults.set(true, forKey: "firstLaunchTutorialDefaults")
        }
        
        if defaults.object(forKey: "firstLaunchTutorialDefaults") as? Bool ?? true {
            self.firstLaunchTutorial = true
        }
        
        var val = defaults.object(forKey: "weeklyzeroday") as? Date
        if (val == nil)
        {
            val = Date()
        }
        if (Date() > val!)
        {
            defaults.set(0, forKey: "weeklyminutesworked")
            let lastmondaydate =  Calendar.current.date(byAdding: .day, value: 1, to: Date().startOfWeek!)! > Date() ? Calendar.current.date(byAdding: .day, value: -6, to: Date().startOfWeek!)! : Calendar.current.date(byAdding: .day, value: 1, to: Date().startOfWeek!)!
            let nextmondaydate = Date(timeInterval: 604800, since: lastmondaydate)
            defaults.set(nextmondaydate, forKey: "weeklyzeroday")
            
        }
        for (index, element) in classlist.enumerated()
        {
            if (element.isTrash)
            {
                self.managedObjectContext.delete(self.classlist[index])
            }

        }
        print("width", UIScreen.main.bounds.size.width, "height", UIScreen.main.bounds.size.height)
        print("hasnotch", UIDevice.current.hasNotch)
        
    }
    @State var showingtutorialview = false
    @State var selectedtab = 0
    @State var worktype1selected: Bool = true
    @State var currentworkhoursview = 0
    
    @State var selectedWorkHours: Int = 0
    
    var body: some View {
        ZStack {
            if (self.firstLaunchTutorial)
            {
//                NavigationView
//                {
                VStack
                {
                  //  ZStack
                   // {
                     //   TabView(selection: $selectedtab)
            //            {
                    
                    VStack
                    {
                        if (selectedtab == 0)
                        {
                            NavigationView
                            {
                                VStack
                                {
                                    //Spacer().frame(height: UIDevice.current.hasNotch ? 150 : 0)
                                   // Spacer()

                                    Text("Welcome To TRACR").font(.system(size: 38)).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-40, alignment: .leading).padding(.horizontal, 20).padding(.top, 40).lineLimit(1).minimumScaleFactor(0.5)//.padding(.top, -30)//.frame(alignment: .leading)
    //                                Image("TracrIcon").resizable().aspectRatio(contentMode: .fit).frame(width: 300)//.padding(.top, -50)
                                    
    //                                Image(self.colorScheme == .light ? "Tracr" : "TracrDark").resizable().aspectRatio(contentMode: .fit).frame(width: 200)
                                    
                                    Spacer().frame(height: 10)
                                    
                                    Text("An app designed to help you stay on top of your schoolwork.").fontWeight(.light).padding(.horizontal, 20).lineLimit(2).minimumScaleFactor(0.95).frame(width: UIScreen.main.bounds.size.width, height: 50)
                                                                        
                                    Spacer().frame(height: 16)
                                    
                                    ScrollView(.vertical, showsIndicators: false) {
                                        VStack(spacing: 25) {
                                            HStack {
                                                Image(systemName: "calendar").resizable().aspectRatio(contentMode: .fit).foregroundColor(Color("freetimeblue")).frame(width: 45)
                                                Spacer().frame(width: 20)
                                                VStack {
                                                    HStack {
                                                        Text("Work Hours").fontWeight(.bold)
                                                        Spacer()
                                                    }
                                                    HStack {
                                                        Text("Schedule your tasks according to your preferred work hours").fontWeight(.light).lineLimit(2).minimumScaleFactor(0.95)
                                                        Spacer()
                                                    }.frame(height: 50)
                                                }.frame(width: UIScreen.main.bounds.size.width - 136)
                                            }.padding(.horizontal, 40)
                                            
                                            HStack {
                                                Image(systemName: "folder").resizable().aspectRatio(contentMode: .fit).foregroundColor(Color.red).frame(width: 45)
                                                Spacer().frame(width: 20)
                                                VStack {
                                                    HStack {
                                                    Text("Classes").fontWeight(.bold)
                                                        Spacer()
                                                    }
                                                    HStack {
                                                        Text("Keep track of work from all your classes").fontWeight(.light).lineLimit(2).minimumScaleFactor(0.95)
                                                        Spacer()
                                                    }.frame(height: 50)
                                                }.frame(width: UIScreen.main.bounds.size.width - 136)
                                            }.padding(.horizontal, 40)
                                            
                                            HStack {
                                                Image(systemName: "doc.plaintext").resizable().aspectRatio(contentMode: .fit).foregroundColor(Color.blue).frame(width: 45)
                                                Spacer().frame(width: 20)
                                                VStack {
                                                    HStack {
                                                        Text("Assignments").fontWeight(.bold)
                                                        Spacer()
                                                    }
                                                    HStack {
                                                        Text("Complete or reschedule assignments for a later time").fontWeight(.light).lineLimit(2).minimumScaleFactor(0.95)
                                                        Spacer()
                                                    }.frame(height: 50)
                                                }.frame(width: UIScreen.main.bounds.size.width - 136)
                                            }.padding(.horizontal, 40)
                                            
                                            HStack {
                                                Image(systemName: "chart.bar").resizable().aspectRatio(contentMode: .fit).foregroundColor(Color.green).frame(width: 45)
                                                Spacer().frame(width: 20)
                                                VStack {
                                                    HStack {
                                                        Text("Progress").fontWeight(.bold)
                                                        Spacer()
                                                    }
                                                    HStack {
                                                        Text("Keep track of your achievements and progress").fontWeight(.light).lineLimit(2).minimumScaleFactor(0.95)
                                                        Spacer()
                                                    }.frame(height: 50)
                                                }.frame(width: UIScreen.main.bounds.size.width - 136)
                                            }.padding(.horizontal, 40)
                                            
                                            HStack {
                                                Image(systemName: "tray.full.fill").resizable().aspectRatio(contentMode: .fit).foregroundColor(Color.orange).frame(width: 45)
                                                Spacer().frame(width: 20)
                                                VStack {
                                                    HStack {
                                                        Text("Tasks Backlog").fontWeight(.bold)
                                                        Spacer()
                                                    }
                                                    HStack {
                                                        Text("Never fall behind on tasks").fontWeight(.light).lineLimit(2).minimumScaleFactor(0.95)
                                                        Spacer()
                                                    }.frame(height: 25)
                                                }.frame(width: UIScreen.main.bounds.size.width - 136)
                                            }.padding(.horizontal, 40)
                                        }
                                    }.frame(height: UIScreen.main.bounds.size.height - 300)

                                    
    //                                Spacer()
    //                                Spacer()
                                }.tag(0).navigationTitle("Welcome!").navigationBarTitleDisplayMode(.inline)
                            }
                        }
                        if (selectedtab == 1)
                        {
                            
//                                NavigationLink(destination: GoogleView())
//                                {
//                                    Text("Click me")
//                                }.gesture(DragGesture()).tag(1)
                            NavigationView
                            {
                                GoogleUnsignedinView().tag(1)

                            }.navigationTitle("Google Classroom").navigationBarTitleDisplayMode(.inline)
                        }
                        if (selectedtab == 2)
                        {
                            NavigationView
                            {
                                SyllabusView(showinginfo: true).tag(2)
                               // Text("This is the syllabus stuff")

                            }.navigationTitle("Syllabus").navigationBarTitleDisplayMode(.large)
                        }
                        if (selectedtab == 3)
                        {
                            NavigationView
                            {
                                if (currentworkhoursview == 0)
                                {
                                    Form
                                    {
                                        HStack {
                                            Text("Scheduling Options").font(.largeTitle).bold()
                                            Spacer()
                                        }.frame(height:40).padding(.bottom, 10).listRowInsets(EdgeInsets()).background(Color(UIColor.systemGroupedBackground))

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
                                        Section(header: Text("Options")) {
                                            HStack
                                            {
                                                VStack
                                                {
                                                    Image("Home View 1").resizable().scaledToFit().frame(width: UIScreen.main.bounds.size.width/2-50)
//                                                    Divider().frame(height: 1)
//                                                    Text("Specific Times").fontWeight(.semibold).frame(width: UIScreen.main.bounds.size.width/2-50, height: 50)
                                                }
                                                Spacer()
                                                VStack
                                                {
                                                    Image("Home view 2").resizable().scaledToFit().frame(width: UIScreen.main.bounds.size.width/2-50)
//                                                    Divider().frame(height: 1)
//                                                    Text("Daily Checklist").fontWeight(.semibold).frame(width: UIScreen.main.bounds.size.width/2-50, height: 50)
                                                }
                                            }
//                                        }
//                                        Section(header: Text("Options"))
//                                        {
                                            Picker(selection: self.$selectedWorkHours, label: Text("Scheduling Options")) {
                                                Text("Specific Times").tag(0)
                                                Text("Daily Checklist").tag(1)
                                            }.pickerStyle(SegmentedPickerStyle()).onChange(of: self.selectedWorkHours)
                                            {
                                                _ in
                                                worktype1selected = self.selectedWorkHours == 0 ? false : true
                                                let defaults = UserDefaults.standard
                                                let defaultsWidget = UserDefaults(suiteName: "group.com.schedulingapp.tracrwidget")
                                                
                                                defaults.set(!worktype1selected, forKey: "specificworktimes")
                                                defaultsWidget?.set(!worktype1selected, forKey: "specificworktimes")
                                            }
                                            
                                        }
//                                        }
                                        
                                        VStack {
                                            HStack {
                                                Text("Click Continue to add your Work Hours.").fontWeight(.light).foregroundColor(Color("darkgray"))

                                                Spacer()
                                            }
                                            Spacer()
                                        }
                                        .listRowInsets(EdgeInsets())
                                        .background(Color(UIColor.systemGroupedBackground))

                                    }.navigationTitle("Scheduling Options").navigationBarTitleDisplayMode(.inline).onDisappear {
                                        print("selection disappeared")
                                        worktype1selected = self.selectedWorkHours == 0 ? false : true
                                        let defaults = UserDefaults.standard
                                        let defaultsWidget = UserDefaults(suiteName: "group.com.schedulingapp.tracrwidget")
                                        
                                        defaults.set(!worktype1selected, forKey: "specificworktimes")
                                        defaultsWidget?.set(!worktype1selected, forKey: "specificworktimes")
                                    }
                                }
                                else
                                {
                                    AnimatedWorkHoursTutorialView()
                                }
//                            ScrollView
//                            {
                                
                                

                            }
                        }
                        if (selectedtab == 4)
                        {
                            NavigationView
                            {
                                
                                WorkHours().tag(4)
                            }
                        }

                        if (selectedtab == 5)
                        {
                            NavigationView {
                                VStack {
                                    Spacer()
                                    
                                    Text("Setup Completed!").font(.largeTitle).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-40, alignment: .leading).padding(.horizontal, 20).padding(.top, 5).lineLimit(1).minimumScaleFactor(0.5)
                                    
                                    Text("TRACR has been setup to schedule your tasks! To learn more about TRACR's features, head to the tutorial, or start using TRACR by clicking Continue and adding a Class with the + button.").font(.title3).fontWeight(.semibold).lineLimit(6).padding(.horizontal, 15).padding(.top, 5)

                                    Spacer()

                                    HStack {
                                        NavigationLink(destination: TutorialView().navigationTitle("Tutorial").navigationBarTitleDisplayMode(.inline))
                                        {
                                            ZStack {
                                                Rectangle().fill(Color.clear).frame(width: (UIScreen.main.bounds.size.width-50)/2, height: 70)
                                                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.orange).frame(width: (UIScreen.main.bounds.size.width-50)/2, height: 50)
                                                Text("Head to Tutorial").foregroundColor(Color.white).fontWeight(.bold)
                                            }.frame(width: (UIScreen.main.bounds.size.width-50)/2, height: 70)
                                        }

                                        Spacer().frame(width: 10)

                                        Button(action: {
                                            let defaults = UserDefaults.standard
                                            defaults.set(false, forKey: "firstLaunchTutorialDefaults")
                                            self.firstLaunchTutorial.toggle()
                                        }){
                                            ZStack {
                                                Rectangle().fill(Color.clear).frame(width: (UIScreen.main.bounds.size.width-50)/2, height: 70)
                                                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.blue).frame(width: (UIScreen.main.bounds.size.width-50)/2, height: 50)
                                                Text("Continue to App").foregroundColor(Color.white).fontWeight(.bold)
                                            }.frame(width: (UIScreen.main.bounds.size.width-50)/2, height: 70)
                                        }
                                    }.frame(width: UIScreen.main.bounds.size.width-40)
                                    
                                   //Spacer().frame(height: 20)
                                }.navigationTitle("Finalizing Setup").navigationBarTitleDisplayMode(.inline)
                            }
                        }
                    }.frame(height: (selectedtab != 5) ? UIScreen.main.bounds.size.height-90 : (UIDevice.current.hasNotch ? UIScreen.main.bounds.size.height-20 : UIScreen.main.bounds.size.height - 20))
                    //Spacer()
                //        }.indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always)).tabViewStyle(PageTabViewStyle()).navigationBarTitle("Setup", displayMode: .inline)
                    VStack
                    {
                        Spacer()
                        if (selectedtab != 5)

                        {
                            Button(action:
                                    {
                                        if (selectedtab == 3 && currentworkhoursview == 0)
                                        {
                                            if (selectedWorkHours == 0)
                                            {
                                                withAnimation(.spring())
                                                {
                                                    currentworkhoursview = 1
                                                }
                                            }
                                            else
                                            {
                                                withAnimation(.spring())
                                                {
                                                    selectedtab += 1
                                                }
                                            }

                                        }
                                        else if ((selectedtab == 4 && freetimelist.count != 0) || selectedtab != 4)
                                        {
                                            if (selectedtab < 5)
                                            {
                                                withAnimation(.spring()) {
                                                    selectedtab += 1
                                                }
                                            }
                                            else
                                            {
                                                let defaults = UserDefaults.standard
                                                defaults.set(false, forKey: "firstLaunchTutorialDefaults")
                                            }
                                        }
                                     //   selectedtab += 1
                                    })
                            {
                                ZStack
                                {
                                    
                                    
                                    if ((selectedtab == 4 && freetimelist.count != 0) || selectedtab != 4)
                                    {
                                        Rectangle().fill(Color.clear).frame(width: UIScreen.main.bounds.size.width-40, height: 70)
                                        RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.blue).frame(width: UIScreen.main.bounds.size.width-40, height: 50)
                                        Text("Continue").foregroundColor(Color.white).fontWeight(.bold)
                                    }
                                    
                                    else {
                                        Rectangle().fill(Color.clear).frame(width: UIScreen.main.bounds.size.width-40, height: 70)
                                        RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.gray).frame(width: UIScreen.main.bounds.size.width-40, height: 50)
                                        Text("Continue").foregroundColor(Color.white).fontWeight(.bold)

                                    }
                                    
                                }
                            }
                            Spacer().frame(height: 20)
                        }
                    }//.frame(height: 50)//.offset(y: UIScreen.main.bounds.size.height-70)

             //   }
 
              //  Spacer()
                        
                    

                }
            }
            else
            {
                if masterRunning.masterRunningNow || masterRunning.onlyNotifications {
                    MasterClass()
                    let _ = print("asfasdfasdf")
                }
                
                TabView {
                    HomeView().tabItem {
                        Image(systemName: "house").resizable().scaledToFill()
                        Text("Home").font(.body)
                    }
                    
                    FilterView().tabItem {
                        Image(systemName:"doc.plaintext").resizable().scaledToFill()
                        Text("Assignments")
                    }
                    
                    ClassesView().tabItem {
                        Image(systemName: "folder").resizable().scaledToFill()
                        Text("Classes")
                    }
                    
                    ProgressView().tabItem {
                        Image(systemName: "chart.bar").resizable().scaledToFit()
                        Text("Progress")
                    }
                    
    //                GoogleView().tabItem {
    //                    Image(systemName: "person.circle.fill").resizable().scaledToFit()
    //                    Text("Hello")
    //                }
            
                
                    

                }.onAppear
                {
                    initialize()
                    let defaults = UserDefaults.standard

                    defaults.set(false, forKey:"accessedclassroom")
                    
                }.onDisappear
                {
                    let defaults = UserDefaults.standard
                    defaults.set(Date(timeIntervalSinceNow: 0), forKey: "lastaccessdate")
                    
                }
//                .alert(isPresented: $masterRunning.showingalert) {
//                    Alert(title: Text("Scheduling Error"),
//                          message: Text(masterRunning.extratimealertmessage),
//                          dismissButton: .default(Text("OK")) {
//                            masterRunning.extratimealertmessage = ""
//                            masterRunning.showingalert = false
//                          })
//                }
                
                VStack {
                    MasterRunningDisplay().offset(y: masterRunning.masterDisplay ? 0 : -200 ).animation(.spring())
                    Spacer()
                }.frame(width: UIScreen.main.bounds.size.width).background((masterRunning.masterDisplay ? Color(UIColor.label).opacity(self.colorScheme == .light ? 0.15 : 0.04) : Color.clear).edgesIgnoringSafeArea(.all))
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        ContentView()
    }
}

struct CoolView1: View
{
    
    var body: some View
    {
        NavigationLink(destination: Text("kewl2"))
        {
            Text("kewl")
        }
    }
}

