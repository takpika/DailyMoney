//
//  LastDays.swift
//  DailyMoney
//
//  Created by takumi saito on 2021/04/04.
//

import SwiftUI

struct LastDays: View {
    let today = Date()
    @State var date : Array<Date> = []
    @State var showAll : Bool = false
    var body: some View {
        GeometryReader { geometry in
            HStack{
                ForEach(date, id: \.self) { i in
                    DayView(date: i, showAll: $showAll)
                        .frame(width: geometry.size.width / 8)
                }
            }
        }
        .onAppear(){
            let calendar = Calendar.current
            for i in 0..<7{
                date.append(calendar.date(byAdding: .day, value: -i, to: calendar.startOfDay(for: today))!)
            }
            date.reverse()
        }
    }
}

struct DayView: View{
    let date : Date
    @State var daystr = ""
    @State var weekday = ""
    @State var year : Int = 0
    @State var month : Int = 0
    @State var day : Int = 0
    @State var money : Int? = nil
    @State var limit : Int? = nil
    @Binding var showAll : Bool
    var body: some View{
        VStack{
            HStack{
                Text(daystr)
            }
            Divider()
            Spacer()
            VStack{
                if (money != nil) {
                    if (money! < 0){
                        Text(String(money!))
                            .foregroundColor(.red)
                    }else{
                        Text(String(money!))
                    }
                    if (limit != nil && showAll){
                        Text(String(limit!))
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 1.0)
                    }
                }else{
                    Text("-")
                        .foregroundColor(.gray)
                }
            }
            .onTapGesture{
                showAll.toggle()
            }
            Spacer()
        }
        .onAppear {
            let formatter = DateFormatter()
            formatter.locale = NSLocale.current
            let calendar = Calendar.current
            let dayc = calendar.component(.day, from: date)
            let week = calendar.component(.weekday, from: date)
            year = calendar.component(.year, from: date)
            month = calendar.component(.month, from: date)
            day = dayc
            daystr = String(dayc)
            weekday = formatter.shortWeekdaySymbols[week-1]
            let data = load_day_data(year: year, month: month, day: day)
            money = data?[0]
            limit = data?[1]
        }
    }
}
