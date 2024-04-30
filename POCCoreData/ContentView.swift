//
//  ContentView.swift
//  POCCoreData
//
//  Created by Saket Raje on 25/04/2024.
//

import SwiftUI
import CoreData

// Task: Show the relation between entities
// EmployeeEntity --BELONGS TO--> Department Entity --BELONGS TO--> Buissness Entity

class CoreDataManagerLearning {
    // Making it a singleton by adding static
    static let instance = CoreDataManagerLearning()
    
    let container : NSPersistentContainer
    let context : NSManagedObjectContext
    
    init() {
        self.container = NSPersistentContainer(name: "POCCoreData")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error found while loading the Persistend Data. Here is the Error: \(error.localizedDescription)")
            }
            
        }
        
        context = container.viewContext
    }
    
    func save() {
        do {
            try context.save()
            print("Saved Successfully")
        } catch let error{
            print("\(error.localizedDescription)")
        }
        
        
    }
}

class CoreDataRelationshipViewModel : ObservableObject {
    
    let manager = CoreDataManagerLearning.instance
    
    @Published var buissness : [BuissnessEntity] = []
    
    @Published var departments : [DepartmentEntity] = []
    
    @Published var employees : [EmployeeEntity] = []
    
    init() {
        getBuissness()
        getDepartments()
        getEmployees()
    }
    
    func getBuissness() {
                                // Specify the data type (Generics)
        let request = NSFetchRequest<BuissnessEntity>(entityName: "BuissnessEntity")
        let sort = NSSortDescriptor(key: "name", ascending: false)
        request.sortDescriptors = [sort]
        
//        let filter = NSPredicate(format: "name == %@", "Facebook")
//        request.predicate = filter
        
        do {
            buissness = try manager.context.fetch(request)
        } catch let error{
            print("Erorr Fetching: \(error.localizedDescription)")
        }
        
        
    }
    
    func getDepartments() {
                                // Specify the data type (Generics)
        let request = NSFetchRequest<DepartmentEntity>(entityName: "DepartmentEntity")
        
        
//        request.sortDescriptors
        
        do {
            departments = try manager.context.fetch(request)
        } catch let error{
            print("Erorr Fetching: \(error.localizedDescription)")
        }
        
    }
    
    func getEmployees() {
                                // Specify the data type (Generics)
        let request = NSFetchRequest<EmployeeEntity>(entityName: "EmployeeEntity")
        
//        let filter = NSPredicate(format: "buissness == %@", buissness)
//        request.predicate = filter
        
        do {
            employees = try manager.context.fetch(request)
        } catch let error{
            print("Erorr Fetching: \(error.localizedDescription)")
        }
        
    }
    
    func getEmployeesForBuissness(forBuisiness buisness : BuissnessEntity) {
                                // Specify the data type (Generics)
        let request = NSFetchRequest<EmployeeEntity>(entityName: "EmployeeEntity")
        
        let filter = NSPredicate(format: "buissness == %@", buisness)
        request.predicate = filter
        
        do {
            employees = try manager.context.fetch(request)
        } catch let error{
            print("Erorr Fetching: \(error.localizedDescription)")
        }
        
    }
    
    func updateBuissness() {
        let existingBuissness = buissness[buissness.count - 1]
        existingBuissness.addToDepartments(departments[1])
        save()
    }
    
    func addBuissness(name : String) {
        let newBuissness = BuissnessEntity(context: manager.context)
        newBuissness.name = name
        
//        newBuissness.departments = [departments[0], departments[1]]
//        newBuissness.addToEmployee(employees[1])
        save()
    }
    
    func addDepartment(name : String) {
        let newDepartment = DepartmentEntity(context: manager.context)
        newDepartment.name = name
        
        newDepartment.addToEmployee(employees[1])
        newDepartment.buisnesses = [buissness[0], buissness[buissness.count - 2], buissness[buissness.count - 1]]
        save()
    }
    
    func addEmployee(name : String, dateJoined : Date, age : Int64 ) {
        let newEmployee = EmployeeEntity(context: manager.context)
        newEmployee.name = name
        newEmployee.dateJoined = dateJoined
        newEmployee.age = age
        
        newEmployee.buissness = buissness[buissness.count - 1]
        newEmployee.department = departments[1]
        
        save()
    }
    
    func deleteDepartment() {
        let department = departments[2]
        manager.context.delete(department)
        save()
    }
    
    func save() {
        buissness.removeAll()
        departments.removeAll()
        employees.removeAll()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.manager.save()
            self.getBuissness()
            self.getDepartments()
            self.getEmployees()
        }

    }
}


struct ContentView: View {
    
    @StateObject var vm = CoreDataRelationshipViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Button (action: {
                        vm.deleteDepartment()
                    }, label: {
                        Text("Perform Action")
                            .frame(height: 75)
                            .frame(maxWidth: .infinity)
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(Capsule(style: .continuous))
                    })
                }
                .padding()
                
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack (alignment: .top, spacing: 10, content: {
                        
                        ForEach (vm.buissness) { buissness in
                            BuissnessView(entity: buissness)
                        }
                        
                    })
                }
                
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack (alignment: .top, spacing: 10, content: {
                        
                        ForEach (vm.departments) { department in
                            DepartmentView(entity: department)
                        }
                        
                    })
                }
                
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack (alignment: .top, spacing: 10, content: {
                        
                        ForEach (vm.employees) { employee in
                            EmployeeView(entity: employee)
                        }
                        
                    })
                }
                
            }
            
            .navigationTitle("Core Data Relation")
        }
        
        
        
        
        
        
    }
    
    //    private func addItem() {
    //        withAnimation {
    //            let newItem = Item(context: viewContext)
    //            newItem.timestamp = Date()
    //
    //            do {
    //                try viewContext.save()
    //            } catch {
    //                // Replace this implementation with code to handle the error appropriately.
    //                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    //                let nsError = error as NSError
    //                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    //            }
    //        }
    //    }
    //
    //    private func deleteItems(offsets: IndexSet) {
    //        withAnimation {
    //            offsets.map { items[$0] }.forEach(viewContext.delete)
    //
    //            do {
    //                try viewContext.save()
    //            } catch {
    //                // Replace this implementation with code to handle the error appropriately.
    //                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    //                let nsError = error as NSError
    //                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    //            }
    //        }
    //    }
    
}

//private let itemFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .short
//    formatter.timeStyle = .medium
//    return formatter
//}()



// Create a seperate view for BuissnessEntity
struct BuissnessView : View {
    
    let entity : BuissnessEntity
    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 20, content: {
            Text("Name: \(entity.name ?? "")")
                .bold()
            
            if let departments = entity.departments?.allObjects as? [DepartmentEntity] {
                Text("Departments: ").bold()
                
                ForEach(departments) { department in
                    Text(department.name ?? "")
                    
                }
            }
            
            if let employees = entity.employee?.allObjects as? [EmployeeEntity] {
                Text("Employee: ").bold()
                
                ForEach(employees) { employee in
                    Text(employee.name ?? "")
//                    Text(employee.age ?? "")
//                    Text(employee.dateJoined ?? "")
                    
                }
            }
        })
        .padding()
        .frame(maxWidth: 300, maxHeight: .infinity, alignment: .leading)
        .background(.gray.opacity(0.25))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 10)
        
    }
}

struct DepartmentView : View {
    
    let entity : DepartmentEntity
    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 20, content: {
            Text("Name: \(entity.name ?? "")")
                .bold()
            
            if let buissnesses = entity.buisnesses?.allObjects as? [BuissnessEntity] {
                Text("Buissness: ").bold()
                
                ForEach(buissnesses) { buissness in
                    Text(buissness.name ?? "")
                    
                }
            }
            
            if let employees = entity.employee?.allObjects as? [EmployeeEntity] {
                Text("Employee: ").bold()
                
                ForEach(employees) { employee in
                    Text(employee.name ?? "")
//                    Text(employee.age ?? "")
//                    Text(employee.dateJoined ?? "")
                    
                }
            }
        })
        .padding()
        .frame(maxWidth: 300, maxHeight: .infinity, alignment: .leading)
        .background(.orange.opacity(0.25))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 10)
        
    }
}


struct EmployeeView : View {
    
    let entity : EmployeeEntity
    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 20, content: {
            Text("Name: \(entity.name ?? "")")
                .bold()
            
            Text("Age: \(entity.age)")
                .bold()
            
            Text("Date Joined: \(entity.dateJoined ?? Date.now)")
                .bold()
            
            Text("Buissness: ").bold()
            Text(entity.buissness?.name ?? "")
            
            
            Text("Department: ").bold()
            Text(entity.department?.name ?? "")

        })
        .padding()
        .frame(maxWidth: 300, maxHeight: .infinity, alignment: .leading)
        .background(.mint.opacity(0.25))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 10)
        
    }
}


#Preview {
    ContentView()
}
