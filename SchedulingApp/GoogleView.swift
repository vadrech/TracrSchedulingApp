import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher
import UIKit
import SwiftUI
import GoogleAPIClientForREST



class GoogleDelegate: NSObject, GIDSignInDelegate, ObservableObject
{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }

        // If the previous `error` is null, then the sign-in was succesful
        print("Successful sign-in!")
        signedIn = true
        
    }
    
    @Published var signedIn: Bool = false
}

struct DetailGoogleView: View
{
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    var classlist: FetchedResults<Classcool>

    @State var classid: String
    @State var googleclassname: String
    @State var classselection: Int = 0
    
    func getlinked() -> String
    {
        for classity in classlist
        {
            if (classity.googleclassroomid == classid)
            {
                return classity.name
            }
        }
        return "none"
    }
    
    func getunlinkedclasses() -> [String]
    {
        var classities: [String] = []
        for classity in classlist
        {
            if (classity.googleclassroomid == "")
            {
                classities.append(classity.name)
            }
        }
        return classities
    }
    var body: some View {
        ScrollView {
            VStack {
                Spacer().frame(height: 5)
                Text(googleclassname).font(.title).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-40, alignment:    .leading).padding(.top, 12)
                
                Spacer()
            
                if (getlinked() != "none") {
                    VStack {
                        Text("Linked with \(getlinked())").font(.title2).fontWeight(.semibold).frame(width: UIScreen.main.bounds.size.width-40, alignment: .leading).padding(.top, 2)
                        
                        Spacer().frame(height: 12)
                        Divider().padding(.horizontal, 12)
                        Spacer().frame(height: 12)

                        Spacer()
                        
                        Button(action: {
                            for classity in classlist {
                                if (classity.googleclassroomid == classid) {
                                    classity.googleclassroomid = ""
                                    do {
                                        try self.managedObjectContext.save()
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                    break
                                }
                            }
                            
                        })
                        {
                            Text("Unlink Class")
                        }
                        Spacer()
                    }
                }
                
                else if (self.getunlinkedclasses().count > 0) {
                    VStack {
                        Text("\(googleclassname) is not linked with any TRACR classes").font(.title2).fontWeight(.semibold).frame(width: UIScreen.main.bounds.size.width-40, alignment: .leading).padding(.top, 2)
                        
                        Spacer().frame(height: 12)
                        Divider().padding(.horizontal, 12)
                        Spacer().frame(height: 12)
                        
                        Text("Choose from the following TRACR classes to link with \(googleclassname):").font(.title3).fontWeight(.regular).frame(width: UIScreen.main.bounds.size.width-40, alignment: .leading).padding(.top, 2)

                        Spacer()
                        
                        Picker(selection: $classselection, label: Text("Link Classes")) {
                            ForEach(0 ..< getunlinkedclasses().count) {
                                if ($0 < self.getunlinkedclasses().count)
                                {
                                    Text(self.getunlinkedclasses()[$0])
                                }
                            }
                        }
                        
                        Button(action:{
                            if (self.getunlinkedclasses().count > 0) {
                                for classity in classlist {
                                    if (classity.name == self.getunlinkedclasses()[classselection]) {
                                        classity.googleclassroomid = self.classid
                                        do {
                                            try self.managedObjectContext.save()
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                        break
                                    }
                                }
                            }
                            
                        })
                        {
                            Text("Link Classes")
                        }
                        
                        Spacer()
                    }
                }
                
                else {
                    VStack {
                        Text("Add more classes on TRACR to link them with link with \(googleclassname)").font(.title3).fontWeight(.semibold).frame(width: UIScreen.main.bounds.size.width-40, alignment: .leading).padding(.top, 2)
                        
                        Spacer().frame(height: 12)
                        Divider().padding(.horizontal, 12)
                        Spacer().frame(height: 12)
                        
                        Spacer()
                    }
                }
            }.frame(height: UIScreen.main.bounds.size.height - 200)
        }
    }
}

struct GCLoadingView: View {
    @State var dummytogglevar: Bool = true

    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color("CharansOCD"), Color("CharansOCD twin")]), startPoint: .leading, endPoint: .trailing))
                    .shadow(color: (colorScheme == .light ? .gray : .black), radius: 3, x: 2, y: 2).frame(height: 80)
                
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color("CharansOCD twin"), Color("CharansOCD")]), startPoint: .leading, endPoint: .trailing))
                    .opacity(self.dummytogglevar ? 0.0 : 1.0)
                    .animation(Animation.easeInOut(duration: 0.78).repeatForever(autoreverses: true))
                
                //text thing
                VStack(alignment: .leading, spacing: 6) {
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(LinearGradient(gradient: Gradient(colors: [Color("CharansOCD text twin"), Color("CharansOCD text")]), startPoint: .leading, endPoint: .trailing))
                        
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(LinearGradient(gradient: Gradient(colors: [Color("CharansOCD text"), Color("CharansOCD text twin")]), startPoint: .leading, endPoint: .trailing))
                            .opacity(self.dummytogglevar ? 0.0 : 1.0)
                            .animation(Animation.easeInOut(duration: 0.78).repeatForever(autoreverses: true))
                    }
                    .frame(width: (UIScreen.main.bounds.size.width-140)/2, height: 19)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(LinearGradient(gradient: Gradient(colors: [Color("CharansOCD text twin"), Color("CharansOCD text")]), startPoint: .leading, endPoint: .trailing))
                        
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(LinearGradient(gradient: Gradient(colors: [Color("CharansOCD text"), Color("CharansOCD text twin")]), startPoint: .leading, endPoint: .trailing))
                            .opacity(self.dummytogglevar ? 0.0 : 1.0)
                            .animation(Animation.easeInOut(duration: 0.78).repeatForever(autoreverses: true))
                    }
                    .frame(width: (UIScreen.main.bounds.size.width-80)/2, height: 19)
                    .padding(.bottom, 6).padding(.leading, 0)
                }
            }
         
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color("CharansOCD"), Color("CharansOCD twin")]), startPoint: .leading, endPoint: .trailing))
                    .shadow(color: (colorScheme == .light ? .gray : .black), radius: 3, x: 2, y: 2).frame(height: 80)
                
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color("CharansOCD twin"), Color("CharansOCD")]), startPoint: .leading, endPoint: .trailing))
                    .opacity(self.dummytogglevar ? 0.0 : 1.0)
                    .animation(Animation.easeInOut(duration: 0.78).repeatForever(autoreverses: true))
                
                //text thing
                VStack(alignment: .leading, spacing: 6) {
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(LinearGradient(gradient: Gradient(colors: [Color("CharansOCD text twin"), Color("CharansOCD text")]), startPoint: .leading, endPoint: .trailing))
                        
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(LinearGradient(gradient: Gradient(colors: [Color("CharansOCD text"), Color("CharansOCD text twin")]), startPoint: .leading, endPoint: .trailing))
                            .opacity(self.dummytogglevar ? 0.0 : 1.0)
                            .animation(Animation.easeInOut(duration: 0.78).repeatForever(autoreverses: true))
                    }
                    .frame(width: (UIScreen.main.bounds.size.width-140)/2, height: 19)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(LinearGradient(gradient: Gradient(colors: [Color("CharansOCD text twin"), Color("CharansOCD text")]), startPoint: .leading, endPoint: .trailing))
                        
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(LinearGradient(gradient: Gradient(colors: [Color("CharansOCD text"), Color("CharansOCD text twin")]), startPoint: .leading, endPoint: .trailing))
                            .opacity(self.dummytogglevar ? 0.0 : 1.0)
                            .animation(Animation.easeInOut(duration: 0.78).repeatForever(autoreverses: true))
                    }
                    .frame(width: (UIScreen.main.bounds.size.width-80)/2, height: 19)
                    .padding(.bottom, 6).padding(.leading, 0)
                }
            }
        }.onAppear {
            self.dummytogglevar = false
        }
    }
}
struct GoogleUnsignedinView: View
{
    @EnvironmentObject var googleDelegate: GoogleDelegate

    @State var currentPageGCPreview = 0
    let GCtimer = Timer.publish(every: 6, on: .main, in: .common).autoconnect()
    var body: some View
    {
        VStack
        {
            ScrollView {

                
                Text("Google Classroom").font(.largeTitle).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-40, alignment: .leading).padding(.top, 12)
                Text("Sign in with your Google Account to link your Google Classroom classes and assignments with TRACR.").font(.title2).fontWeight(.semibold).frame(width: UIScreen.main.bounds.size.width-40, alignment: .leading).padding(.vertical, 8).lineLimit(4).minimumScaleFactor(0.9)

                
                TabView(selection: self.$currentPageGCPreview) {
                    Image("GCPreview1").resizable().aspectRatio(contentMode: .fit).tag(0)
                    Image("GCPreview2").resizable().aspectRatio(contentMode: .fit).tag(1)
                }.tabViewStyle(PageTabViewStyle()).frame(width: UIScreen.main.bounds.size.width-40, height: 400, alignment: .leading)
                .onReceive(self.GCtimer, perform: { _ in
                    withAnimation {
                        print(self.currentPageGCPreview)
                        self.currentPageGCPreview = self.currentPageGCPreview < 1 ? self.currentPageGCPreview + 1 : 0
                    }
                }).padding(.vertical, 8)

                Spacer()

    //                        Button(action: {
    //                            GIDSignIn.sharedInstance().signIn()
    //                        }) {
    //                            HStack {
    //                                Image("Google Sign In Button").resizable().frame(width: 70, height: 48)//.padding(.all, 0)
    //                                Text("Sign in with Google").font(.custom("Roboto-Medium", size: 21)).foregroundColor(.black)
    //                                Spacer()
    //                            }.padding(.all, 0).overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.black, lineWidth: 1)).background(Color.white).frame(width: UIScreen.main.bounds.size.width-120, height: 48).padding(.horizontal, 60)
    //                        }
                if (googleDelegate.signedIn)
                {
                    Text("You're succesfully signed in!").font(.title3).fontWeight(.light).padding(.vertical, 6)
                }
                else
                {
                    Button(action: {
                        GIDSignIn.sharedInstance().signIn()
                    }) {
                        Image("Google Sign In Button with Text").resizable().frame(width: 382/1.5, height: 90/1.5).padding(.horizontal, 60).shadow(radius: 3, x: -2, y: 2)
                    }.buttonStyle(PlainButtonStyle())
                    Text("Or Continue with the Setup").font(.title3).fontWeight(.light).padding(.vertical, 6)
                }
                
                

            Spacer()
            }.frame(width: UIScreen.main.bounds.size.width)
        }.frame(width: UIScreen.main.bounds.size.width).navigationTitle("Google Classroom").navigationBarTitleDisplayMode(.inline)
    }
}
struct OverallGoogleView: View {
    @EnvironmentObject var googleDelegate: GoogleDelegate
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    
    @State var currentPageGCPreview = 0
    let GCtimer = Timer.publish(every: 6, on: .main, in: .common).autoconnect()
    var body: some View
    {
        if (googleDelegate.signedIn)
        {
            GoogleView()
        }
        else
        {
            VStack
            {
                ScrollView {
                    Text("Google Classroom").font(.largeTitle).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-40, alignment: .leading).padding(.top, 12)
                    Text("Sign in with your Google Account to link your Google Classroom classes and assignments with TRACR.").font(.title2).fontWeight(.semibold).frame(width: UIScreen.main.bounds.size.width-40, alignment: .leading).padding(.vertical, 8).lineLimit(4).minimumScaleFactor(0.9)

                    
                    TabView(selection: self.$currentPageGCPreview) {
                        Image("GCPreview1").resizable().aspectRatio(contentMode: .fit).tag(0)
                        Image("GCPreview2").resizable().aspectRatio(contentMode: .fit).tag(1)
                    }.tabViewStyle(PageTabViewStyle()).frame(width: UIScreen.main.bounds.size.width-40, height: 400, alignment: .leading)
                    .onReceive(self.GCtimer, perform: { _ in
                        withAnimation {
                            //print(self.currentPageGCPreview)
                            self.currentPageGCPreview = self.currentPageGCPreview < 1 ? self.currentPageGCPreview + 1 : 0
                        }
                    })

                    Spacer()

//                        Button(action: {
//                            GIDSignIn.sharedInstance().signIn()
//                        }) {
//                            HStack {
//                                Image("Google Sign In Button").resizable().frame(width: 70, height: 48)//.padding(.all, 0)
//                                Text("Sign in with Google").font(.custom("Roboto-Medium", size: 21)).foregroundColor(.black)
//                                Spacer()
//                            }.padding(.all, 0).overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.black, lineWidth: 1)).background(Color.white).frame(width: UIScreen.main.bounds.size.width-120, height: 48).padding(.horizontal, 60)
//                        }

                    Button(action: {
                        GIDSignIn.sharedInstance().signIn()
                    }) {
                        Image("Google Sign In Button with Text").resizable().frame(width: 382/1.5, height: 90/1.5).padding(.horizontal, 60).shadow(radius: 3, x: -2, y: 2)
                    }.buttonStyle(PlainButtonStyle())

                    Spacer()
                }
            }
        }
    }
}

struct GoogleView: View {
    @EnvironmentObject var googleDelegate: GoogleDelegate
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    @State var classeslist: [String] = []
    @State var classesselected: [Bool] = []
    @State var classesidlist: [String] = []
    @State var assignmentsforclass = [String: [String]]()
    @State private var refreshID = UUID()
    @State private var selection: Set<String> = []
    @State var selectedClass: Int? = 100000
    @State var noclassesavailable: Bool = false
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    init()
    {
        let defaults = UserDefaults.standard
      //  print(defaults.object(forKey: "accessedclassroom") ?? false)
        let valstuffity = defaults.object(forKey: "accessedclassroom") as? Bool ?? false
        if (valstuffity)
        {
            let defaults = UserDefaults.standard
        //    print(defaults.object(forKey: "savedgoogleclasses") as! [String])
            classeslist = defaults.object(forKey: "savedgoogleclasses") as? [String] ?? []
            classesidlist = defaults.object(forKey: "savedgoogleclassesids") as? [String] ?? []
        }
        
    }
    private func selectDeselect(_ singularassignment: String) {
        if selection.contains(singularassignment) {
            selection.remove(singularassignment)
        } else {
            selection.insert(singularassignment)
        }
    }
 
    
    func getassignments(index: Int, id: String, service: GTLRClassroomService) -> Void {
        let idiii = id
        let assignmentsquery = GTLRClassroomQuery_CoursesCourseWorkList.query(withCourseId: idiii)

        assignmentsquery.pageSize = 1000

        service.executeQuery(assignmentsquery, completionHandler: {(ticket, stuff, error) in
            let assignmentsforid = stuff as! GTLRClassroom_ListCourseWorkResponse
            
            if assignmentsforid.courseWork != nil {
                for assignment in assignmentsforid.courseWork! {
                    print(assignment.title!)
                }
            }
        })
    }
    
    func getclasses(service: GTLRClassroomService) -> [(String, String)] {
        let coursesquery = GTLRClassroomQuery_CoursesList.query()

        coursesquery.pageSize = 1000
        var partiallist: [(String, String)] = []
        service.executeQuery(coursesquery, completionHandler: {(ticket, stuff, error) in
            let stuff1 = stuff as! GTLRClassroom_ListCoursesResponse

            for course in stuff1.courses! {
                if course.courseState == kGTLRClassroom_Course_CourseState_Active {
                    partiallist.append((course.identifier!, course.name!))
                    print(course.name!)
                }
            }
            
        })
        
        return partiallist
    }
    func getiterationcounter() -> Int
    {
        if (noclassesavailable)
        {
            return 1
        }
        if (classeslist.count == 0)
        {
            return 10
        }
        if (classeslist.count % 2 == 0)
        {
            return classeslist.count/2
        }
        else
        {
            return (classeslist.count+1)/2
        }
    }
    func checklinkedclass(classval: Int) -> Bool
    {
        for classity in classlist
        {
            if (classity.googleclassroomid == classesidlist[classval])
            {
                return true
            }
        }
        return false
    }
    func GetColorFromRGBCode(rgbcode: String, number: Int = 1) -> Color {
        if number == 1 {
            return Color(.sRGB, red: Double(rgbcode[9..<14])!, green: Double(rgbcode[15..<20])!, blue: Double(rgbcode[21..<26])!, opacity: 1)
        }
        
        return Color(.sRGB, red: Double(rgbcode[36..<41])!, green: Double(rgbcode[42..<47])!, blue: Double(rgbcode[48..<53])!, opacity: 1)
    }
    func getclasscolor(classval: Int) -> Color
    {
        if (!checklinkedclass(classval: classval))
        {
            return Color("CharansOCD")
        }
        for classity in classlist
        {
            if (classity.googleclassroomid == classesidlist[classval])
            {
                return classity.color.contains("rgbcode") ? GetColorFromRGBCode(rgbcode: classity.color) : Color(classity.color)
            }
        }
        
        return Color("CharansOCD")
    }
    func reloadlist()
    {
        classeslist = []
        classesidlist = []
        GIDSignIn.sharedInstance().restorePreviousSignIn()
        if (googleDelegate.signedIn)
        {
            var partiallist: [(String, String)] = []

            let service = GTLRClassroomService()
            service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()

            let coursesquery = GTLRClassroomQuery_CoursesList.query()

            coursesquery.pageSize = 1000
            service.executeQuery(coursesquery, completionHandler: {(ticket, stuff, error) in
                let stuff1 = stuff as! GTLRClassroom_ListCoursesResponse
                if (stuff1.courses != nil)
                {
                    for course in stuff1.courses! {
                        if course.courseState == kGTLRClassroom_Course_CourseState_Active {
                            partiallist.append((course.identifier!, course.name!))
                        }
                    }
                }
            })

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(2000)) {
                for val in partiallist
                {
                    classeslist.append(val.1)
                }
                var islinked: [Bool] = []
                classeslist = Array(Set(classeslist))
                classeslist.sort()


            for val in classeslist
            {
                for pairity in partiallist
                {
                    if (pairity.1 == val)
                    {
                        classesidlist.append(pairity.0)
                    }
                }
            }

            for val in classesidlist
            {
                var found = false
                for numpty in classlist
                {
                    if (numpty.googleclassroomid == val)
                    {
                        found = true
                        break
                    }
                }
                islinked.append(found)
            }
            var newclasseslist: [String] = []
            var newclassesidlist: [String] = []

            for (index, val) in classeslist.enumerated()
            {
                if (islinked[index])
                {
                    newclasseslist.append(val)
                    newclassesidlist.append(classesidlist[index])
                }
            }
            for (index, val) in classeslist.enumerated()
            {
                if (!islinked[index])
                {
                    newclasseslist.append(val)
                    newclassesidlist.append(classesidlist[index])
                }
            }

            classeslist = newclasseslist
            classesidlist = newclassesidlist
                if (classeslist.count==0)
                {
                    noclassesavailable = true
                }
                print(classeslist, classesidlist)
                
            }
        }
    }

    
    @State var currentPageGCPreview = 0
    let GCtimer = Timer.publish(every: 6, on: .main, in: .common).autoconnect()
        
    var body: some View {
        VStack {
                Spacer().frame(height: 5)
                ScrollView {
                    Spacer().frame(height: 5)
                    Text(GIDSignIn.sharedInstance().currentUser == nil ? "" : GIDSignIn.sharedInstance().currentUser!.profile.name).font(.title).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-40, alignment: .leading).padding(.top, 12)
                    Text(GIDSignIn.sharedInstance().currentUser == nil ? "" : GIDSignIn.sharedInstance().currentUser!.profile.email).font(.title2).fontWeight(.semibold).frame(width: UIScreen.main.bounds.size.width-40, alignment: .leading).padding(.top, 2)
                    
                    Spacer().frame(height: 12)
                    Divider().padding(.horizontal, 12)
                    Spacer().frame(height: 12)
                    
                    ForEach(0..<classeslist.count, id: \.self) {
                        classityval in
                        NavigationLink(destination: DetailGoogleView(classid: classesidlist[classityval], googleclassname: classeslist[classityval]), tag: classityval, selection: self.$selectedClass) {
                            EmptyView()
                        }
                    }//.id(refreshID)

                    ForEach(0..<getiterationcounter(), id: \.self) { classityval in
                        if (noclassesavailable)
                        {
                            Text("No Classes Available")
                        }
                        else if (classeslist.count == 0)
                        {
                            GCLoadingView()
                                .onAppear
                                {
                                    //sometimes not being called when log out, log into other account, log out, log back into original account but no crash just infinite loading time
                                    reloadlist()
                                }
//                            .onDisappear
//                            {
//                                reloadlist()
//                            }
                        }
                        else
                        {
                            HStack {
                                Button(action:{
                                    print("hello")
                                    self.selectedClass = 2*classityval
                                    print(self.selectedClass!)
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 7, style: .continuous).fill(self.getclasscolor(classval: 2*classityval)).shadow(color: (colorScheme == .light ? .gray : .black), radius: 3, x: 2, y: 2).frame(width: UIScreen.main.bounds.size.width/2-20)
                                            
                                        Text(classeslist[2*classityval]).font(.system(size: 18)).fontWeight(.semibold).frame(width: (UIScreen.main.bounds.size.width-70)/2, height: 80, alignment: .bottomLeading).lineLimit(2)
                                                .allowsTightening(true).padding(.bottom, 6)
                                    }
                                }.buttonStyle(PlainButtonStyle())
                                //need to add check if odd number of google classes without type-check error
                                Spacer()
                        
                                Button(action:{
                                    print("hello")
                                    self.selectedClass = 2*classityval+1
                                    print(self.selectedClass!)

                                })
                                {
                                    ZStack {
                                        let n = 2*classityval+1
                                        if (n < classesidlist.count) {
                                            if n < classeslist.count {
                                                RoundedRectangle(cornerRadius: 7, style: .continuous).fill(self.getclasscolor(classval: n)).shadow(color: (colorScheme == .light ? .gray : .black), radius: 3, x: 2, y: 2)
                                                
                                                Text(classeslist[n]).font(.system(size: 18)).fontWeight(.semibold).frame(width: (UIScreen.main.bounds.size.width-70)/2, height: 80, alignment: .bottomLeading).lineLimit(2)
                                                        .allowsTightening(true).padding(.bottom, 6)
                                            }
                                            
                                            else {
                                                RoundedRectangle(cornerRadius: 7, style: .continuous).fill(Color.gray)
                                            }
    //                                        }.frame(height: 86)
                                        }
                                    }//.opacity(2*classityval+1 < classeslist.count ? 1 : 0)

                                }.buttonStyle(PlainButtonStyle())
                            }
//                            .onAppear
//                            {
//                                reloadlist()
//                            }
                        }
                    }.padding(.horizontal, 10)//.id(refreshID)
                
//                    NavigationLink(destination: GoogleAssignmentsView())
//                    {
//                        Text("See Assignments???")
//                    }
                    Spacer().frame(height: 10)
                }.frame(width: UIScreen.main.bounds.size.width)
            
        }.navigationTitle("Google Classroom").navigationBarTitleDisplayMode(.inline).frame(width: UIScreen.main.bounds.size.width).toolbar
        {
            ToolbarItem(placement: .navigationBarLeading)
            {
                Text("")
            }
            ToolbarItem(placement: .navigation)
            {
                Button(action:{
                    GIDSignIn.sharedInstance().signOut()
                    googleDelegate.signedIn = false
                    noclassesavailable = false
                    for classity in classlist
                    {
                        classity.googleclassroomid = ""
                    }
                    do {
                        try self.managedObjectContext.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                    let defaults = UserDefaults.standard
                    classeslist = []
                    classesidlist = []
                    defaults.set([], forKey: "savedgoogleclasses")
                    defaults.set([], forKey: "savedgoogleclassesids")

                })
                {
                    if googleDelegate.signedIn {
                        Text("Sign Out")
                    } else {
                        Text("")
                    }
                }.padding(.top, -40)
            }//.padding(.top, -40)
        }
        .onAppear
        {
          //  print("success")
//            let defaults = UserDefaults.standard
//          //  print(defaults.object(forKey: "accessedclassroom") ?? false)
//            classeslist = defaults.object(forKey: "savedgoogleclasses") as? [String] ?? []
//            classesidlist = defaults.object(forKey: "savedgoogleclassesids") as? [String] ?? []
//            let valstuffity = defaults.object(forKey: "accessedclassroom") as? Bool ?? false
//            //let bobbity = defaults.object(forKey: "lastaccessdate")
//            if (!valstuffity || classeslist.count == 0)
//            {
//                classeslist = []
//                classesidlist = []
//                GIDSignIn.sharedInstance().restorePreviousSignIn()
//                if (googleDelegate.signedIn)
//                {
//                defaults.set(true, forKey: "accessedclassroom")
//                var partiallist: [(String, String)] = []
//
//                let service = GTLRClassroomService()
//                service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
//
//                let coursesquery = GTLRClassroomQuery_CoursesList.query()
//
//                coursesquery.pageSize = 1000
//                service.executeQuery(coursesquery, completionHandler: {(ticket, stuff, error) in
//                    let stuff1 = stuff as! GTLRClassroom_ListCoursesResponse
//                    if (stuff1.courses != nil)
//                    {
//                        for course in stuff1.courses! {
//                            if course.courseState == kGTLRClassroom_Course_CourseState_Active {
//                                partiallist.append((course.identifier!, course.name!))
//                            }
//                        }
//                    }
//                })
//
//                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(2000)) {
//                        for val in partiallist
//                        {
//                            classeslist.append(val.1)
//                        }
//                        var islinked: [Bool] = []
//                        classeslist = Array(Set(classeslist))
//                        classeslist.sort()
//
//
//                    for val in classeslist
//                    {
//                        for pairity in partiallist
//                        {
//                            if (pairity.1 == val)
//                            {
//                                classesidlist.append(pairity.0)
//                            }
//                        }
//                    }
//
//                    for val in classesidlist
//                    {
//                        var found = false
//                        for numpty in classlist
//                        {
//                            if (numpty.googleclassroomid == val)
//                            {
//                                found = true
//                                break
//                            }
//                        }
//                        islinked.append(found)
//                    }
//                    var newclasseslist: [String] = []
//                    var newclassesidlist: [String] = []
//
//                    for (index, val) in classeslist.enumerated()
//                    {
//                        if (islinked[index])
//                        {
//                            newclasseslist.append(val)
//                            newclassesidlist.append(classesidlist[index])
//                        }
//                    }
//                    for (index, val) in classeslist.enumerated()
//                    {
//                        if (!islinked[index])
//                        {
//                            newclasseslist.append(val)
//                            newclassesidlist.append(classesidlist[index])
//                        }
//                    }
//
//                    classeslist = newclasseslist
//                    classesidlist = newclassesidlist
//
////                    for _ in classeslist
////                    {
////                        classesselected.append(false)
////                    }
//
////                    let arraykewl = defaults.object(forKey: "savedgoogleclasses") as? [String] ?? []
////                    for (index, classval) in classeslist.enumerated()
////                    {
////                        if (arraykewl.contains(classval))
////                        {
////                            classesselected[index] = true
////                        }
////                    }
//
//
//                }
//
//                }
//            }
//            else
//            {
//                let defaults = UserDefaults.standard
//                print("yay")
//                classeslist = defaults.object(forKey: "savedgoogleclasses") as? [String] ?? []
//                classesidlist = defaults.object(forKey: "savedgoogleclassesids") as? [String] ?? []
//
//               // self.refreshID = UUID()
//
//            }
        
        }.onDisappear
        {
            let defaults = UserDefaults.standard

            defaults.set(classeslist, forKey: "savedgoogleclasses")
            defaults.set(classesidlist, forKey: "savedgoogleclassesids")

        }
    }
}

struct GoogleAssignmentsView: View
{   @State var classeslist: [String] = []
    @State var refreshID = UUID()
    @State var assignmentsforclass = [String:[String]]()
    var body: some View
    {
        VStack
        {

                ForEach(classeslist,id: \.self)
                {
                    classity in
                    Text(classity).fontWeight(.bold)
                    ForEach(assignmentsforclass[classity] ?? [], id: \.self)
                    {
                        assignmenty in
                        Text(assignmenty)
                    }.id(refreshID)
                    
                }.id(refreshID)

            
        }.onAppear
        {
            let defaults = UserDefaults.standard
            let googleclasses = defaults.object(forKey: "savedgoogleclasses") as? [String] ?? []
            classeslist = googleclasses
            let googleclassesids = defaults.object(forKey: "savedgoogleclassesids") as? [String] ?? []
            
            let service = GTLRClassroomService()
            service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
            for (index, idiii) in googleclassesids.enumerated() {
                let assignmentsquery = GTLRClassroomQuery_CoursesCourseWorkList.query(withCourseId: idiii)
                let workingdate = Date(timeIntervalSinceNow: -3600*24*7)
                let dayformatter = DateFormatter()
                let monthformatter = DateFormatter()
                let yearformatter = DateFormatter()
                yearformatter.dateFormat = "yyyy"
                monthformatter.dateFormat = "MM"
                dayformatter.dateFormat = "dd"
                assignmentsquery.pageSize = 1000
                var vallist: [String] = []
                service.executeQuery(assignmentsquery, completionHandler: {(ticket, stuff, error) in
                    let assignmentsforid = stuff as! GTLRClassroom_ListCourseWorkResponse

                    if assignmentsforid.courseWork != nil {
                        for assignment in assignmentsforid.courseWork! {
                            //print(assignment.title!)
                            if (assignment.dueDate != nil)
                            {
                                if (assignment.dueDate!.day! as! Int >= Int(dayformatter.string(from: workingdate)) ?? 0 && assignment.dueDate!.month as! Int >= Int(monthformatter.string(from: workingdate)) ?? 0 && assignment.dueDate!.year as! Int >= Int(yearformatter.string(from: workingdate)) ?? 0 )
                                {
                                 //   print(assignment.title!)
//                                    var newComponents = DateComponents()
//                                    newComponents.timeZone = .current
//                                    newComponents.day = Int(assignment.dueDate!.day!)
//                                    newComponents.month = Int(assignment.dueDate!.month!)
//                                    newComponents.year = Int(assignment.dueDate!.year!)
//                                    newComponents.hour = assignment.dueTime!.hours as! Int
//                                    newComponents.minute = assignment.dueTime!.minutes as! Int
//                                    newComponents.second = 0
                              //      newComponents.second = assignment.dueTime!.seconds as! Int
                                    vallist.append(assignment.title!)
                                }
                            }
                        }
                    }
                    assignmentsforclass[classeslist[index]] = vallist
                    self.refreshID = UUID()
                })

                
            }
                
        }
    }
}

