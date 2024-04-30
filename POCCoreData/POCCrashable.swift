//
//  POCCrashable.swift
//  POCCoreData
//
//  Created by Saket Raje on 29/04/2024.
//

/*
 
    TASK: HAve multiple Calls in Main Thread. Add Function one after the other.
            Move it to the back thread.
            And solve the error.
 
 */


import SwiftUI
import CoreData

    
func getRandomLetter(_ length : Int) -> String{
    let letters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
    var string = ""
    
    for i in 0 ..< length {
        string += letters.randomElement()!
    }
    return string
}

func getRandomName() -> String {
    return [
        "Earl", "Pearl", "Saket", "Rohan", "Johan", "Aarush", "Arhan", "Tellimandu", "Aashtapashta Bhum!"
    ].randomElement()!
}


class CoreDataViewModel : ObservableObject {
    let manager = CoreDataManager.instance
    
    @Published var crashable : [CrashableEntity] = []
    
    init () {
        getCrashables()
    }
    
    
    func getCrashables() {
        
        let context = manager.container.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        
        context.performAndWait {
            // Specify the data type (Generics)
            let request = NSFetchRequest<CrashableEntity>(entityName: "CrashableEntity")
            
            do {
                self.crashable = try self.manager.context.fetch(request)
            } catch let error{
                print("Erorr Fetching: \(error.localizedDescription)")
            }
        }
        
    }
    
    func addCrashables(name : String, value : String?) {
        
//        let context = manager.container.newBackgroundContext()
//        context.automaticallyMergesChangesFromParent = true
//        
        manager.context.perform {
            let newCrashable = CrashableEntity(context: self.manager.context)
            newCrashable.name = name
            newCrashable.value = value
            self.save()
        }
        
        
    }
    
    func deleteAll() {
        for item in crashable{
            manager.context.delete(item)
        }
        
        save()
    }
    
    func save() {

        self.crashable.removeAll()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.manager.save()
            self.getCrashables()
        }

    }
}
    
    
struct POCCrashable: View {
    
    @StateObject var vm = CoreDataViewModel()
    
    @State var availableOptions = [0, 10, 20, 30, 40, 50, 100, 1000, 10000, 100000, 1000000]
    
    @State var selectedNumber : Int = 0
    
    
    func repeatAddition(times: Int) {
        for _ in 0 ..< times {
            vm.addCrashables(name: getRandomName(), value: getRandomLetter(Int.random(in: 1 ..< 25)))
        }
    }
                       
    
    var body: some View {
        NavigationStack{
            ScrollView {
                Picker("Times", selection: $selectedNumber) {
                    ForEach (availableOptions, id:\.self) { selectedNumber in
                        Text("\(selectedNumber)")
                        
                    }
                }
                HStack{
                    Button(action: {
                        repeatAddition(times: selectedNumber)
                    } ) {
                        Text("Add Value")
                            .frame(height: 75)
                            .frame(maxWidth: .infinity)
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(Capsule(style: .continuous))
                        
                    } .padding()
                    
                    Button(action: {vm.deleteAll()} ) {
                        Text("Delete All")
                            .frame(height: 75)
                            .frame(maxWidth: .infinity)
                            .background(.red)
                            .foregroundStyle(.white)
                            .clipShape(Capsule(style: .continuous))

                    } .padding()
                }
                
                VStack {
                    ForEach(vm.crashable) { crasher in
                        DisplayCrashable(entity: crasher)
                    }
                }

                
                
            }
        }
        let word = getRandomLetter(4)
        Text("\(word)")
    }
}



struct DisplayCrashable : View {
    var entity : CrashableEntity
    
    var body : some View {
        VStack {
            Text("\(entity.name!) : \(entity.value!)")
            
        }

    }
}
    
#Preview {
    POCCrashable()
}
