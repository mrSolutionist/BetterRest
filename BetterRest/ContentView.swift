//
//  ContentView.swift
//  BetterRest
//
//  Created by  Robin George  on 29/01/22.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeUpTime
    @State private var sleepAmount = 8.0
    @State private var coffeAmount = 1
    
    //for alert
    
    @State private var alertTitle = ""
    @State private var alertMsg = ""
    @State private var isAlert = false
    
    
    static var defaultWakeUpTime : Date {
        var component = DateComponents()
        component.hour = 7
        component.minute = 0
        return Calendar.current.date(from: component) ?? Date.now
        
    }
    var body: some View {
        
        NavigationView {
            
            //main content
                Form{
                    
                    // wake up time picker
                    Section{
                        HStack(spacing: 100) {
                            
                            DatePicker("Please enter a time", selection: $wakeUp,displayedComponents: .hourAndMinute)
                                .labelsHidden()
                          
                        }
                    } header: {
                        Text("when do you want to wake up?")
                            .font(.headline)
                    }
                    
                    
                    
                    // amount of sleep time picker
                    Section{
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    } header: {
                        Text("Desired amount of sleep")
                            .font(.headline)
                    }
                    
                    
                    
                    
                    // coffee cup picker
                    Section {
                        Picker(selection: $coffeAmount) {
                            ForEach(1..<21) {
                                num in
                                Text(num == 1 ? "1 cup" : "\(num) cups")
                            }
                        } label: {
                            Text("Number of cups of coffe")
                        }
                        .pickerStyle(.wheel)
                    } header: {
                        Text("Daily coffe intake")
                            .font(.headline)
                    }
                    
                    
                    
                } //form ends here
                
                .navigationTitle("Better Rest")
                .toolbar{
                    
                    Button("Calculate", action: calculateBedTime)
                }
                
                .alert(alertTitle, isPresented: $isAlert){
                    Button("OK"){}
                }
            message:{
                Text(alertMsg)
            }
            
            
        }
    }
    
    
    
    //calculate Function
    func calculateBedTime(){
        do {
            
            let config = MLModelConfiguration()
            //SleepCalulator is a class created by default from Trained ML model
            let model = try SleepCalulator(configuration: config)
            //getting values from wakeup date using calender
            let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
            //converting to seconds
            let hour = (components.hour ?? 0) * 60 * 60
            let min = (components.minute ?? 0)  * 60
            // adding data to prediction
            let prediction = try model.prediction(wake: Double(hour + min), estimatedSleep: Double(sleepAmount), coffee: Double(coffeAmount))
            // prediction value is in double so using apple frame work gets in a date Type
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your estimated bed time is "
            alertMsg = sleepTime.formatted(date: .omitted, time: .shortened)
            
        }
        catch{
            alertTitle = "Someting went wromg "
            alertMsg = "could not present"
        }
        isAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
