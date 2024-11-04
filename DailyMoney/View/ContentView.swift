//
//  ContentView.swift
//  DailyMoney
//
//  Created by takumi saito on 2021/04/02.
//

import SwiftUI

extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ContentView: View {
    @State var unit:String = "NTD"
    @State var money: Int = load_data()[1] as! Int
    @State var monthly: Int = load_data()[0] as! Int
    @State var daily : Int = load_data()[2] as! Int
    @State var days : Int = load_data()[3] as! Int
    @State var backup : Bool = load_data()[4] as! Bool
    @State var showSettingView : Bool = false
    var body: some View {
        VStack{
            TabView {
                ZStack{
                    AmountView(showall: false, money: $money, allmoney: $monthly, daily: $daily, days: $days, unit: unit)
                    HStack{
                        Spacer()
                        VStack{
                            Button(action: {
                                showSettingView.toggle()
                            }, label: {
                                Image(systemName: "gear")
                            })
                            .accentColor(.primary)
                            Spacer()
                        }
                    }
                }
                LastDays()
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 100)
            Divider()
            Spacer()
            CalcView(today: $money, month: $monthly, backup: $backup, limit: $daily)
                .padding([.leading, .bottom, .trailing])
        }
        .padding()
        .gesture(
            TapGesture()
                .onEnded { _ in
                    UIApplication.shared.closeKeyboard()
                }
        )
        .sheet(isPresented: self.$showSettingView, content: {
            SettingView(backup: $backup)
        })
        .onChange(of: backup, perform: { value in
            save_data(month_m: monthly, today: money, backup: backup, limit: daily)
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
