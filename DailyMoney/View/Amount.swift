//
//  Amount.swift
//  DailyMoney
//
//  Created by takumi saito on 2021/04/02.
//

import SwiftUI

struct AmountView: View {
    @State var showall : Bool
    @Binding var money : Int
    @Binding var allmoney : Int
    @Binding var daily : Int
    @Binding var days : Int
    @State var unit : String
    @State var formatter = DateFormatter()
    @State var datestr = "0"
    @State var weekstr = ""
    @State var showDay = false
    @State var showMoney = 0
    let date = Date()
    var body: some View {
        VStack{
            HStack{
                HStack{
                    if showDay{
                        Text("\(days)")
                            .font(.title)
                        Text("days")
                    }else{
                        Text(datestr)
                            .font(.title)
                        Text(weekstr)
                            .font(.body)
                    }
                }
                .gesture(
                    TapGesture()
                        .onEnded {
                            showDay.toggle()
                        }
                )
                Spacer()
                    .foregroundColor(.gray)
            }
            
            HStack{
                if (money >= 0){
                    Text(unit).font(.title)
                    Text(String.localizedStringWithFormat("%d", money))
                        .font(.largeTitle)
                }else{
                    Text("-"+unit).font(.title)
                        .foregroundColor(.red)
                    Text(String.localizedStringWithFormat("%d", money*(-1)))
                        .font(.largeTitle)
                        .foregroundColor(.red)
                }
            }
            HStack{
                HStack{
                    if (showMoney == 0){
                        Text("本日")
                        Text(unit)
                        Text(String.localizedStringWithFormat("%d", daily))
                    }else if (showMoney == 1){
                        Text(unit)
                        Text(String.localizedStringWithFormat("%d", allmoney/days))
                        Text("/日")
                    }else{
                        if (days > 1){
                            Text("明日")
                            Text(unit)
                            Text(String.localizedStringWithFormat("%d", allmoney/(days-1)))
                        }
                    }
                }
                .gesture(
                    TapGesture()
                        .onEnded {
                            showMoney += 1
                            if (showMoney > 2 || days <= 1){
                                showMoney = 0
                            }
                        }
                )
                Spacer()
                Text(unit)
                Text(String.localizedStringWithFormat("%d", allmoney))
            }
        }
        .onAppear() {
            formatter.locale = NSLocale.current
            let calendar = Calendar.current
            let day = calendar.component(.day, from: date)
            let week = calendar.component(.weekday, from: date)
            datestr = String(day)
            weekstr = formatter.shortWeekdaySymbols[week-1]
        }
    }
}

