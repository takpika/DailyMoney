//
//  CalcView.swift
//  DailyMoney
//
//  Created by takumi saito on 2021/04/02.
//

import SwiftUI

struct CalcView: View {
    @State var num : String = "0"
    @Binding var today : Int
    @Binding var month : Int
    @Binding var backup : Bool
    @Binding var limit : Int
    var body: some View {
        VStack{
            TextField("", text: $num)
                .keyboardType(.numberPad)
                .font(.largeTitle)
                .lineLimit(1)
                .disableAutocorrection(true)
                .multilineTextAlignment(.trailing)
            HStack{
                NumButton(num: 7, str: $num)
                NumButton(num: 8, str: $num)
                NumButton(num: 9, str: $num)
                DeleteButton(str: $num)
            }
            .padding(.bottom)
            HStack{
                NumButton(num: 4, str: $num)
                NumButton(num: 5, str: $num)
                NumButton(num: 6, str: $num)
                VoidButton()
            }
            .padding(.bottom)
            HStack{
                NumButton(num: 1, str: $num)
                NumButton(num: 2, str: $num)
                NumButton(num: 3, str: $num)
                VoidButton()
            }
            .padding(.bottom)
            HStack{
                PlusMinusButton(str: $num)
                NumButton(num: 0, str: $num)
                VoidButton()
                ReturnButton(str: $num, today: $today, month: $month, backup: $backup, limit: $limit)
            }
        }
    }
}

