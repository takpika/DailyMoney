//
//  Parts.swift
//  DailyMoney
//
//  Created by takumi saito on 2021/04/02.
//

import SwiftUI

struct NumButton: View {
    @State var num : Int
    @Binding var str : String
    var body: some View {
        Button(action: {
            let x = Int(str.replacingOccurrences(of: ",", with: "")) ?? 0
            str = String.localizedStringWithFormat("%d", x*10+num)
        }, label: {
            Text(String(num))
                .accentColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
                .font(.system(size: 40, weight: .light, design: .default))
        })
        .frame(width: 75.0, height: 75.0)
        .background(Color(.brown))
        .cornerRadius(75)
    }
}

struct DeleteButton: View{
    @Binding var str : String
    var body: some View {
        Button(action: {
            let x = Int(str.replacingOccurrences(of: ",", with: "")) ?? 0
            str = String.localizedStringWithFormat("%d", x/10)
        }, label: {
            Image(systemName: "delete.left")
                .accentColor(.white)
                .font(.system(size: 40))
        })
        .frame(width: 75.0, height: 75.0)
        .background(Color(.red))
        .cornerRadius(75)
    }
}

struct VoidButton: View{
    var body: some View{
        VStack{
            Text("")
        }.frame(width: 75, height: 75)
    }
}

struct PlusMinusButton: View{
    @Binding var str : String
    var body: some View{
        Button(action: {
            let x = Int(str.replacingOccurrences(of: ",", with: "")) ?? 0
            str = String.localizedStringWithFormat("%d", x*(-1))
        }, label: {
            Image(systemName: "plus.slash.minus")
                .accentColor(.white)
                .font(.system(size: 40))
        })
        .frame(width: 75.0, height: 75.0)
        .background(Color(.orange))
        .cornerRadius(75)
    }
}

struct ReturnButton: View{
    @Binding var str: String
    @Binding var today : Int
    @Binding var month : Int
    @Binding var backup : Bool
    @Binding var limit : Int
    var body: some View{
        Button(action: {
            let x = Int(str.replacingOccurrences(of: ",", with: "")) ?? 0
            if x != 0{
                time_money(from: $today, fromAll: $month, amount: x, backup: backup, limit: limit)
            }
            str = "0"
        }, label: {
            Image(systemName: "return")
                .accentColor(.white)
                .font(.system(size: 40))
        })
        .frame(width: 75.0, height: 75.0)
        .background(Color(.orange))
        .cornerRadius(75)
        
    }
}

struct BackupCell: View{
    @Binding var backup: Bool
    var body: some View{
        HStack{
            Text("毎日バックアップする")
            Spacer()
            Toggle(isOn: $backup) {
                Text("")
            }
        }
    }
}
