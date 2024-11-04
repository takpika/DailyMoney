//
//  SettingView.swift
//  DailyMoney
//
//  Created by takumi saito on 2021/05/02.
//

import SwiftUI
import UIKit

struct SettingView: View {
    @State var showShareView = false
    @State var showBackupAlert = false
    @State var showRestoreView = false
    @State var data : [Any] = []
    @State var formatter = DateFormatter()
    @Binding var backup : Bool
    let date = Date()
    var body: some View {
        VStack{
            Text("設定")
                .font(.title)
            List {
                Button("データを出力する"){
                    let url = backupData()
                    data.append(url)
                    showShareView.toggle()
                }
                Button("データをバックアップ"){
                    _ = backupData()
                    showBackupAlert.toggle()
                }
                
                BackupCell(backup: $backup)
                
                Button("データを復元"){
                    showRestoreView.toggle()
                }
            }
        }
        .padding(.vertical)
        .sheet(isPresented: self.$showShareView, content: {
            ActivityView(
                activityItems: self.$data,
                applicationActivities: nil
            )
        })
        .alert(isPresented: self.$showBackupAlert, content: {
            Alert(title: Text("バックアップが完了しました"))
        })
        .sheet(isPresented: self.$showRestoreView, content: {
            Restore_YearView(showRestoreView: self.$showRestoreView)
        })
    }
}

struct ActivityView: UIViewControllerRepresentable {

    @Binding var activityItems: [Any]
    let applicationActivities: [UIActivity]?
    
    func makeUIViewController(
        context: UIViewControllerRepresentableContext<ActivityView>
    ) -> UIActivityViewController {
        return UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: UIViewControllerRepresentableContext<ActivityView>
    ) {
        // Nothing to do
    }
}

struct Restore_YearView: View{
    @State var years : [String] = []
    @Binding var showRestoreView : Bool
    var body: some View{
        NavigationView{
            List{
                ForEach(years, id: \.self){ y in
                    NavigationLink(destination: Restore_MonthView(year: y, showRestoreView: $showRestoreView)) {
                        Text("\(y)年")
                    }
                }
            }
            .navigationTitle("復元")
            .navigationBarItems(trailing: Button("キャンセル"){
                showRestoreView.toggle()
            })
        }
        .onAppear(){
            years = backup_year_list()
        }
    }
}

struct Restore_MonthView: View{
    let year: String
    @State var months : [String] = []
    @Binding var showRestoreView : Bool
    var body: some View{
        List{
            ForEach(months, id: \.self){ m in
                NavigationLink(destination: Restore_DayView(year: year, month: m, showRestoreView: $showRestoreView)) {
                    Text("\(m)月")
                }
            }
        }
        .onAppear(){
            months = backup_month_list(year: year)
        }
        .navigationTitle("復元 - \(year)年")
        .navigationBarItems(trailing: Button("キャンセル"){
            showRestoreView.toggle()
        })
    }
}

struct Restore_DayView: View{
    let year: String
    let month: String
    let formatter = DateFormatter()
    @State var days : [Date] = []
    @Binding var showRestoreView : Bool
    var body: some View{
        List{
            ForEach(days, id: \.self){ d in
                NavigationLink(destination: RestoreView(date: d, showRestoreView: $showRestoreView)) {
                    Text(formatter.string(from: d))
                }
            }
        }
        .onAppear(){
            days = backup_day_list(year: year, month: month)
            days = sort_date(dates: days, i: 0, count: days.count)
            formatter.dateStyle = .long
            formatter.timeStyle = .none
        }
        .navigationTitle("復元 - \(year)年\(month)月")
        .navigationBarItems(trailing: Button("キャンセル"){
            showRestoreView.toggle()
        })
    }
}

struct RestoreView: View{
    let date : Date
    @State var unit:String = "NTD"
    @State var money: Int = load_data()[1] as! Int
    @State var monthly: Int = load_data()[0] as! Int
    @State var daily : Int = load_data()[2] as! Int
    @State var days : Int = load_data()[3] as! Int
    @State var backup : Bool = load_data()[4] as! Bool
    
    @State var bmoney: Int = 0
    @State var bmonthly: Int = 0
    @State var bdaily : Int = 0
    @State var bdays : Int = 0
    @State var bbackup : Bool = false
    
    @State var pushed : Bool = false
    @State var showingAlert : Bool = false
    @Binding var showRestoreView : Bool
    var body: some View{
        GeometryReader{ geo in
            VStack{
                HStack{
                    Text("バックアップからデータを復元しますか？")
                    Spacer()
                }
                Divider()
                HStack{
                    Text("現在")
                    Spacer()
                }
                AmountView(showall: false, money: $money, allmoney: $monthly, daily: $daily, days: $days, unit: unit)
                    .frame(height: 100)
                Divider()
                Text("↓")
                    .font(.title3)
                HStack{
                    Text("復元後")
                    Spacer()
                }
                AmountView(showall: false, money: $bmoney, allmoney: $bmonthly, daily: $bdaily, days: $days, unit: unit)
                    .frame(height: 100)
                Spacer()
                if pushed{
                    HStack{
                        Text("データは戻りませんよ？それでも実行しますか？")
                    }
                    .padding(.bottom)
                    Button(action: {
                        restore_data(date: date)
                        showingAlert.toggle()
                    }, label: {
                        Text("復元する")
                            .fontWeight(.bold)
                            .frame(width: geo.size.width, height: 50)
                            .accentColor(.white)
                            .background(Color.red)
                            .cornerRadius(10.0)
                    })
                }else{
                    Button(action: {
                        pushed = true
                    }, label: {
                        Text("復元する")
                            .frame(width: geo.size.width, height: 50)
                            .accentColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10.0)
                    })
                }
            }
            .onAppear(){
                bmoney = load_backup(date: date)[1] as! Int
                bmonthly = load_backup(date: date)[0] as! Int
                bdaily = load_backup(date: date)[2] as! Int
                bbackup = load_backup(date: date)[4] as! Bool
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("復元完了"),
                      message: Text("指定されたバックアップデータから復元が完了しました。\nデータを反映するため、アプリを終了します。"),
                      dismissButton: .default(Text("了解"),
                                              action: {exit(0)})) // ボタンがタップされた時の処理
            }
        }
        .padding([.leading, .bottom, .trailing])
        .navigationBarItems(trailing: Button("キャンセル"){
            showRestoreView.toggle()
        })
    }
}
