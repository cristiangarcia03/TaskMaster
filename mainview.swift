//
////  todo
////
////  Created by Cristian Garcia on 6/23/23.
////
//
import SwiftUI

struct Front: View {
    @State private var size = 0.6
    @State private var opacity = 0.2
    @State private var status = false
    @State var pushNewView: Bool = false
    var body: some View {
        NavigationView {
            HStack {
                Text("Cristian's Studio")
                    .bold()
                    .font(.system(size:27))
                NavigationLink("", isActive: $pushNewView) {
                    Page()
                }
            }
            
            .scaleEffect(size)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 2.4)) {
                    self.size = 1.0
                    self.opacity = 1.0
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false) { _ in
                pushNewView = true
            }
        }
    }
} //End Front View




struct Page: View {
    @State private var userinput: String = ""
    
    @State private var task_list: [String] = ["Hello, Welcome", "Task will be added here", "like these" ,"Try the Star and Minus up above"] {
        didSet {
            saveTask()
        }
    }
    @State private var fav_list: [String] = ["Here", "Is where saved task would be stored for quick adding"] {
        didSet {
            saveFav()
        }
    }
    
    @State var index = 0
    @State private var currentDrag: String?
    @State private var remove_mode: Bool = false
    @State private var fav_mode: Bool = false
    @State private var add_mode: Bool = false
    
    let task_key: String = "t"
    let fav_key: String = "f"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if self.index == 0 {
                    VStack(spacing: 0){
                        task_title(remove_mode: $remove_mode, fav_mode: $fav_mode)
                        Task_ScrollView()
                        Input_Row(remove_mode: $remove_mode, userinput: $userinput, task_list: $task_list)
                    }
                
                } else if self.index == 1 {
                    VStack(spacing: 0) {
                        fav_title(remove_mode: $remove_mode, fav_mode: $fav_mode, add_mode: $add_mode)
                        Deleted_ScrollView()
                    }
                    
                } else if self.index == 2 {
                    Color.green.edgesIgnoringSafeArea(.top)
                }
                
                
                Tabs(remove_mode: $remove_mode, fav_mode: $fav_mode, add_mode: $add_mode, index: $index)
            }
            .background(Color(UIColor(red: 0.96, green: 0.95, blue: 0.89, alpha: 1.00)
            ))
            
            
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear{
            self.getTask()
            self.getFav()
        }
    } //body view
    
    func getTask() {
        guard
            let data = UserDefaults.standard.data(forKey: task_key),
            let savedTask = try? JSONDecoder().decode([String].self, from: data)
        else {return}
        self.task_list = savedTask
    }
    func getFav() {
        
        guard
            let data2 = UserDefaults.standard.data(forKey: fav_key),
            let savedfav = try? JSONDecoder().decode([String].self, from: data2)
        else {return}
        self.fav_list = savedfav
    }
    
    
    
    @ViewBuilder
    func Task_ScrollView() -> some View {
        ScrollView(.vertical) {
            Task_Rows(task_list)
        }
        .frame(maxWidth: .infinity)
    }
    
    
    @ViewBuilder
    func Task_Rows(_ listofTask: [String]) -> some View {
        VStack(alignment: .leading, content: {
            ForEach(listofTask, id: \.self) { task in
                Taskrow(task)
            }
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 5))
        })
        .padding(EdgeInsets(top:25, leading: 25, bottom: 10, trailing: 25))
        .frame(maxWidth: .infinity)
    }
    
    
    @ViewBuilder
    func Taskrow(_ task: String) -> some View {
        HStack {
            Text(task)
                .font((.custom("Ping Fang", size: 17)))
                .padding(EdgeInsets(top: 18, leading: 20, bottom: 18, trailing: 10))
                .frame(maxWidth: .infinity, alignment: .leading)
                //.frame(minHeight: 45)
                .background(Color(UIColor(red: 0.47, green: 0.67, blue: 0.58, alpha: 1.00)
                ))
                .cornerRadius(10)
                .draggable(task) {
                    Text(task)
                        .padding(EdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 10))
                        .frame(minWidth: 200, maxWidth: .infinity)
                        .frame(minHeight: 45)
                        .background(Color(UIColor(red: 0.47, green: 0.67, blue: 0.58, alpha: 1.00)
                        ))
                        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .onAppear(perform: {
                            currentDrag = task
                        })
                }
                .dropDestination(for: String.self) { items, location in
                    currentDrag = nil
                    return false
                } isTargeted: { status in
                    if let currentDrag, currentDrag != task {
                        withAnimation(.easeOut) {
                            replace(tasks: &task_list, droppingTask: task)
                        }
                    }
                }
            HStack {
                Task_multiButton(task)
            }.frame(minWidth: 40, maxHeight: 40)
        }
        .background(Color(UIColor(red: 0.47, green: 0.67, blue: 0.58, alpha: 1.00)
        ))
        .cornerRadius(10)
        .shadow(radius: 7, x: 7, y: 10)
    }
    
    
    @ViewBuilder
    func Task_multiButton(_ task: String) -> some View {
        if remove_mode == true {
            Button {
                let impactMed = UIImpactFeedbackGenerator(style: .rigid)
                impactMed.impactOccurred()
                task_list = task_list.filter(){ $0 != task}
                saveTask()
                saveFav()
            } label: {
                Label("", systemImage: "checkmark")
                    .labelStyle(.iconOnly)
                    .font(.subheadline)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
            }
            .tint(.black)
        }
        if fav_mode == true {
            Button {
                if !(fav_list.contains(task)) {
                    fav_list.append(task)
                } else {
                    fav_list = fav_list.filter(){ $0 != task}
                }
                saveTask()
                saveFav()
            } label: {
                if (fav_list.contains(task)) {
                    Label("", systemImage: "star.fill")
                        .tint(.yellow)
                        .labelStyle(.iconOnly)
                        .font(.subheadline)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                } else {
                    Label("", systemImage: "star.fill")
                        .tint(.black)
                        .labelStyle(.iconOnly)
                        .font(.subheadline)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                }
            }
        }
    }
    
    
    @ViewBuilder
    func fav_multiButton(_ task: String) -> some View {
        if remove_mode == true {
            Button {
                if remove_mode == true {
                    fav_list = fav_list.filter(){ $0 != task}
                    saveTask()
                    saveFav()
                }
            } label: {
                Label("", systemImage: "trash") // note.text.badge.plus
                    .labelStyle(.iconOnly)
                    .font(.subheadline)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
            }
            .tint(.black)
        }
        if add_mode {
            Button {
                if add_mode == true {
                    if !(task_list.contains(task)) {
                        task_list.append(task)
                    }
                }
                saveTask()
                saveFav()
            } label: {
                Label("", systemImage: "note.text.badge.plus")
                    .labelStyle(.iconOnly)
                    .font(.subheadline)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
            }
            .tint(.black)
        }
    }
    
    
    @ViewBuilder
    func Deleted_ScrollView() -> some View {
        ScrollView(.vertical) {
            Fav_Rows(fav_list)
        }
        .frame(maxWidth: .infinity)
    }
    
    
    @ViewBuilder
    func Fav_Rows(_ listofTask: [String]) -> some View {
        VStack(alignment: .leading, content: {
            ForEach(listofTask, id: \.self) { task in
                Favrow(task)
            }
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 15, trailing: 5))
        })
        .padding(EdgeInsets(top:25, leading: 25, bottom: 10, trailing: 25))
        .frame(maxWidth: .infinity)
        
    }
    
    
    @ViewBuilder
    func Favrow(_ task: String) -> some View {
        HStack {
            Text(task)
                .font((.custom("Ping Fang", size: 17)))
                .padding(EdgeInsets(top: 18, leading: 20, bottom: 18, trailing: 10))
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: 45)
                .background(Color(UIColor(red: 0.40, green: 0.41, blue: 0.40, alpha: 1.00)
                ))
                .cornerRadius(10)
                .draggable(task) {
                    Text(task)
                        .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 10))
                        .frame(minWidth: 200, maxWidth: .infinity)
                        .frame(minHeight: 45)
                        .background(Color(UIColor(red: 0.40, green: 0.41, blue: 0.40, alpha: 1.00)
                        ))
                        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .onAppear(perform: {
                            currentDrag = task
                        })
                }
                .dropDestination(for: String.self) { items, location in
                    currentDrag = nil
                    return false
                } isTargeted: { status in
                    if let currentDrag, currentDrag != task {
                        withAnimation(.easeOut) {
                            replace(tasks: &fav_list, droppingTask: task)
                        }
                    }
                }
            HStack {
                fav_multiButton(task)
            }.frame(minWidth: 40, maxHeight: 40)
            
        }
        .background(Color(UIColor(red: 0.40, green: 0.41, blue: 0.40, alpha: 1.00)))
        .cornerRadius(10)
        .shadow(radius: 7, x: 7, y: 10)
    }
    
    
    func replace(tasks: inout [String], droppingTask: String) { //updates listing orders for drag placement
        if let currentDrag {
            if let sourceIndex = tasks.firstIndex(where: {$0 == currentDrag}),
               let destinationIndex = tasks.firstIndex(where: {$0 == droppingTask}) {
                
                let sourceItem = tasks.remove(at:sourceIndex)
                tasks.insert(sourceItem, at: destinationIndex)
            }
        }
    }
    
    func saveTask() {
        if let encodedData = try? JSONEncoder().encode(task_list) {
            UserDefaults.standard.set(encodedData, forKey: task_key)
        }
    }
    func saveFav() {
        if let encodedData2 = try? JSONEncoder().encode(fav_list) {
            UserDefaults.standard.set(encodedData2, forKey: fav_key)
        }
    }

} // page view




struct Previews: PreviewProvider {
    static var previews: some View {
        ContentView().preferredColorScheme(.light)
    }
}




struct Tabs : View {
    @Binding var remove_mode: Bool
    @Binding var fav_mode: Bool
    @Binding var add_mode: Bool
    @Binding var index: Int
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                index = 0;
                remove_mode = false;
                fav_mode = false;
                add_mode = false
                
            }) {
                Image("task_icon")
                    .resizable()
                    .scaledToFill()
                    .frame(width:40, height:40)

            }.foregroundColor(Color.blue.opacity(index == 0 ? 1 : 0.1))
            Spacer()
            Spacer()
            Button(action: {index = 1; remove_mode = false; fav_mode = false}){
                Image("fav_icon")
                    .resizable()
                    .scaledToFill()
                    .frame(width:40, height:40)

            }.foregroundColor(Color.green.opacity(index == 1 ? 1 : 0.1))
            Spacer()

        }
        
        .padding(EdgeInsets(top: 20, leading: 50, bottom: 0, trailing: 50))
        .frame(maxHeight:50)
        .background(Color(UIColor(red: 0.20, green: 0.19, blue: 0.17, alpha: 1.00)))
    }
}



struct fav_title : View {
    @Binding var remove_mode: Bool
    @Binding var fav_mode: Bool
    @Binding var add_mode: Bool
    var body: some View {
        HStack{
            Image("logo2").padding(EdgeInsets(top: 20,leading: 20,bottom: 10,trailing: 0))
            Spacer()
            Button {
                if (remove_mode == true) {
                    remove_mode = false
                } else {
                    add_mode = false
                    remove_mode = true
                }
            } label: {
                Label("", systemImage: "minus")
                    .tint(.white)
                    .labelStyle(.iconOnly)
                    .font(.title2)
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8))
            
            Button {
                if (add_mode == true) {
                    add_mode = false
                } else {
                    remove_mode = false
                    add_mode = true
                }
            } label: {
                Label("", systemImage: "plus")
                    .tint(.white)
                    .labelStyle(.iconOnly)
                    .font(.title2)
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 18))
        }
        .frame(height: 70)
        .background(Color(UIColor(red: 0.20, green: 0.19, blue: 0.17, alpha: 1.00)
        ))
    }
}



struct task_title : View {
    @Binding var remove_mode: Bool
    @Binding var fav_mode: Bool
    
    var body: some View {
        HStack{
            Image("logo2")
                .padding(EdgeInsets(top: 20,leading: 20,bottom: 10,trailing: 0))
            Spacer()
            
            Button {
                if (remove_mode == true) {
                    remove_mode = false
                } else {
                    fav_mode = false
                    remove_mode = true
                }
            } label: {
                Label("", systemImage: "minus")
                    .tint(.white)
                    .labelStyle(.iconOnly)
                    .font(.title2)
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8))
            
            Button {
                if (fav_mode == true) {
                    fav_mode = false
                } else {
                    remove_mode = false
                    fav_mode = true
                }
            } label: {
                Label("", systemImage: "star.fill")
                    .tint(.white)
                    .labelStyle(.iconOnly)
                    .font(.title3)
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 18))
            
            
        }
        .frame(height: 70)
        .background(Color(UIColor(red: 0.20, green: 0.19, blue: 0.17, alpha: 1.00)
        ))
    }
}



struct Input_Row : View {
    @Binding var remove_mode: Bool
    @Binding var userinput: String
    @Binding var task_list: [String]
    
    var body: some View {
        HStack {
            TextField("Enter...", text: $userinput)
                .foregroundColor(.black)
                .padding(.all)
                .frame(height: 50.0)
                .background(Color(UIColor(red: 0.96, green: 0.95, blue: 0.89, alpha: 1.00)
                ))
                .cornerRadius(25)
                .onSubmit {
                    task_list.append(userinput)
                    userinput = ""
                }.padding(10)
            
        }
        .background(Color(UIColor(red: 0.20, green: 0.19, blue: 0.17, alpha: 1.00)
        ))
    }
}


