//
//  Function.swift
//  DailyMoney
//
//  Created by takumi saito on 2021/04/03.
//

import Foundation
import SwiftUI

var plist:NSMutableDictionary = [:]
var max_month = [31,28,31,30,31,30,31,31,30,31,30,31]
let date = Date()
let calendar = Calendar.current
let year = calendar.component(.year, from: date)
let month = calendar.component(.month, from: date)
let day = calendar.component(.day, from: date)
func load_data() -> Array<Any>{
    if (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)){
        max_month[1] = 29
    }
    let manager = FileManager.default
    let documentDir = manager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let url = documentDir.appendingPathComponent("data.plist")
    plist = NSMutableDictionary(contentsOfFile: url.path) ?? NSMutableDictionary(dictionary: ["Monthly":6000, "Daily": 200, "Remain": 6000, "Day": NSMutableDictionary(dictionary: ["2021": NSMutableDictionary(dictionary: ["4": NSMutableDictionary(dictionary: ["2": -27])])])])
    return load_custom_data(data: plist)
}

func load_backup(date: Date) -> Array<Any> {
    let calendar = Calendar.current
    let year = calendar.component(.year, from: date)
    let month = calendar.component(.month, from: date)
    let day = calendar.component(.day, from: date)
    let manager = FileManager.default
    let documentDir = manager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    var url = documentDir.appendingPathComponent("Backup", isDirectory: true)
    url = url.appendingPathComponent(NSString(format: "%04d", year) as String, isDirectory: true)
    url = url.appendingPathComponent(NSString(format: "%02d", month) as String, isDirectory: true)
    url = url.appendingPathComponent("DailyMoney_\(NSString(format: "%04d", year))\(NSString(format: "%02d", month))\(NSString(format: "%02d", day)).plist")
    let data = NSMutableDictionary(contentsOf: url) ?? NSMutableDictionary(dictionary: [:])
    return load_custom_data(data: data)
}

func restore_data(date: Date){
    let calendar = Calendar.current
    let year = calendar.component(.year, from: date)
    let month = calendar.component(.month, from: date)
    let day = calendar.component(.day, from: date)
    let manager = FileManager.default
    let documentDir = manager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    var url = documentDir.appendingPathComponent("Backup", isDirectory: true)
    url = url.appendingPathComponent(NSString(format: "%04d", year) as String, isDirectory: true)
    url = url.appendingPathComponent(NSString(format: "%02d", month) as String, isDirectory: true)
    url = url.appendingPathComponent("DailyMoney_\(NSString(format: "%04d", year))\(NSString(format: "%02d", month))\(NSString(format: "%02d", day)).plist")
    let data = NSMutableDictionary(contentsOf: url) ?? NSMutableDictionary(dictionary: [:])
    plist = data
    url = documentDir.appendingPathComponent("data.plist")
    plist.write(to:url, atomically: true)
}

func load_custom_data(data: NSMutableDictionary) -> Array<Any>{
    var maindata = data
    var month_m = 0
    var today = 0
    var daily = maindata["Daily"] as! Int
    let backup = maindata["Backup"] as? Bool ?? false
    let version = maindata["Version"] as? Int ?? 1
    if version == 1{
        maindata = Conv_1to2(data: maindata)
    }
    //Correct_2()
    if backup{
        backupDailyData()
    }
    if let y = (maindata["Day"] as! NSDictionary)[String(year)] as? NSDictionary{
        if let m = y[String(month)] as? NSDictionary{
            if let d = m[String(day)]{
                today = (d as! NSDictionary)["Remain"] as! Int
                month_m = maindata["Remain"] as! Int
                daily = (d as! NSDictionary)["Limit"] as! Int
            }
        }
    }
    if (today == 0 && month_m == 0){
        let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: date))!
        let year_yes = calendar.component(.year, from: yesterday)
        let month_yes = calendar.component(.month, from: yesterday)
        let day_yes = calendar.component(.day, from: yesterday)
        if year == year_yes{
            if let y = (maindata["Day"] as! NSDictionary)[String(year_yes)] as? NSDictionary{
                if month == month_yes{
                    if let m = y[String(month_yes)] as? NSDictionary{
                        if let d = m[String(day_yes)]{
                            month_m = maindata["Remain"] as! Int
                            if (month_m/(max_month[month-1]-day+1)<daily){
                                daily = month_m/(max_month[month-1]-day+1)
                                today = daily
                            }else{
                                if ((d as! NSDictionary)["Remain"] as! Int) < 0{
                                    if ((daily)+((d as! NSDictionary)["Remain"] as! Int) < 0){
                                        today = daily
                                    }else{
                                        today = (daily)+((d as! NSDictionary)["Remain"] as! Int)
                                    }
                                }else{
                                    today = (daily)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    if(today == 0 && month_m == 0){
        if let y = (maindata["Day"] as! NSDictionary)[String(year)] as? NSDictionary{
            if (y[String(month)] as? NSDictionary) != nil{
                month_m = maindata["Remain"] as! Int
            }
        }
        month_m = maindata["Monthly"] as! Int
        if (month_m/(max_month[month-1]-day+1)<daily){
            daily = month_m/(max_month[month-1]-day+1)
        }
        today = daily
    }
    return [month_m,today,daily,max_month[month-1]-day+1, backup]
}

func Conv_1to2(data: NSMutableDictionary) -> NSMutableDictionary{
    let version = data["Version"] as? Int ?? 1
    if version == 1{
        let day_data = data["Day"] as! NSMutableDictionary
        let year_keys = Array(day_data.allKeys)
        for y in year_keys{
            let year_data = day_data[y as! String] as! NSMutableDictionary
            let month_keys = Array(year_data.allKeys)
            for m in month_keys{
                let month_data = year_data[m as! String] as! NSMutableDictionary
                let day_keys = month_data.allKeys as! Array<String>
                let days = max_month[Int(m as! String)!-1]
                var remain = data["Monthly"] as! Int
                let daily = data["Daily"] as! Int
                let new_month_data : NSMutableDictionary = [:]
                for d in 1...days{
                    var day = Int(remain/(days-d+1))
                    if day > daily{
                        day = daily
                    }
                    if let _ = day_keys.firstIndex(of: String(d)){
                        let used_money = daily - (month_data[String(d)] as! Int)
                        remain -= used_money
                        new_month_data[String(d)] = ["Remain": (month_data[String(d)] as! Int), "Limit": day]
                    }
                }
                year_data[m as! String] = new_month_data
            }
            day_data[y as! String] = year_data
        }
        data["Day"] = day_data
        data["Version"] = 2
    }else{
        print("Error: This data is not Version 1.")
    }
    return data
}

//func Correct_2(){
//    let version = plist["Version"] as? Int ?? 1
//    if version == 2{
//        let day_data = plist["Day"] as! NSMutableDictionary
//        let year_keys = Array(day_data.allKeys)
//        for y in year_keys{
//            let year_data = day_data[y as! String] as! NSMutableDictionary
//            let month_keys = Array(year_data.allKeys)
//            for m in month_keys{
//                let month_data = year_data[m as! String] as! NSMutableDictionary
//                let day_keys = month_data.allKeys as! Array<String>
//                let days = max_month[Int(m as! String)!-1]
//                var remain = plist["Monthly"] as! Int
//                let daily = plist["Daily"] as! Int
//                let new_month_data : NSMutableDictionary = [:]
//                for d in 1...days{
//                    var day = Int(remain/(days-d+1))
//                    if day > daily{
//                        day = daily
//                    }
//                    if let _ = day_keys.firstIndex(of: String(d)){
//                        let used_money = daily - ((month_data[String(d)] as! NSDictionary)["Remain"] as! Int)
//                        remain -= used_money
//                        new_month_data[String(d)] = ["Remain": ((month_data[String(d)] as! NSDictionary)["Remain"] as! Int), "Limit": day]
//                    }
//                }
//                year_data[m as! String] = new_month_data
//            }
//            day_data[y as! String] = year_data
//        }
//        plist["Day"] = day_data
//        plist["Version"] = 2
//    }else{
//        print("Error: This data is not Version 2.")
//        return
//    }
//}

func load_day_data(year: Int, month: Int, day: Int) -> Array<Int>?{
    let manager = FileManager.default
    let documentDir = manager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let url = documentDir.appendingPathComponent("data.plist")
    plist = NSMutableDictionary(contentsOfFile: url.path) ?? NSMutableDictionary(dictionary: ["Monthly":6000, "Daily": 200, "Remain": 6000, "Day": NSMutableDictionary(dictionary: ["2021": NSMutableDictionary(dictionary: ["4": NSMutableDictionary(dictionary: ["2": -27])])])])
    if let d = (((plist["Day"] as! NSDictionary)["\(year)"] as? NSDictionary)?["\(month)"] as? NSDictionary)?["\(day)"] as? NSDictionary{
        return [d["Remain"] as? Int, d["Limit"] as? Int] as? Array<Int>
    }else{
        return nil
    }
}

func save_data(month_m: Int, today: Int, backup: Bool, limit: Int){
    let date = Date()
    let calendar = Calendar.current
    let year = calendar.component(.year, from: date)
    let month = calendar.component(.month, from: date)
    let day = calendar.component(.day, from: date)
    plist["Remain"] = month_m
    plist["Backup"] = backup
    plist["Version"] = 2
    let monthly_data = (((plist["Day"] as? NSMutableDictionary ?? [:])[String(year)] as? NSMutableDictionary ?? [:])[String(month)] as? NSMutableDictionary ?? [:])
    let year_data = ((plist["Day"] as? NSMutableDictionary ?? [:])[String(year)] as? NSMutableDictionary ?? [:])
    let all_data = (plist["Day"] as? NSMutableDictionary ?? [:])
    monthly_data[String(day)] = ["Remain": today, "Limit": limit]
    year_data[String(month)] = monthly_data
    all_data[String(year)] = year_data
    plist["Day"] = all_data
    let manager = FileManager.default
    let documentDir = manager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let url = documentDir.appendingPathComponent("data.plist")
    plist.write(to:url, atomically: true)
}

func time_money(from: Binding<Int>, fromAll: Binding<Int>, amount: Int, backup: Bool, limit: Int){
    let moto = from.wrappedValue - amount
    let moto2 = fromAll.wrappedValue - amount
    withAnimation {
                // Decide on the number of animation steps
        let animationDuration = 1000 // milliseconds
        let steps = min(abs(amount), 100)
        let stepDuration = (animationDuration / steps)
        from.wrappedValue -= amount % steps
        fromAll.wrappedValue -= amount % steps
        (0..<steps).forEach { step in
            // create the period of time when we want to update the number
            // I chose to run the animation over a second
            let updateTimeInterval = DispatchTimeInterval.milliseconds(step * stepDuration)
            let deadline = DispatchTime.now() + updateTimeInterval
            
            // tell dispatch queue to run task after the deadline
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                // Add piece of the entire entered number to our total
                from.wrappedValue -= Int(amount / steps)
                fromAll.wrappedValue -= Int(amount / steps)
            }
        }
    }
    save_data(month_m: moto2, today: moto, backup: backup, limit: limit)
}

func backupData() -> URL {
    let manager = FileManager.default
    let documentDir = manager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let calendar = Calendar.current
    let day = calendar.component(.day, from: date)
    let month = calendar.component(.month, from: date)
    let year = calendar.component(.year, from: date)
    let backupdir = documentDir.appendingPathComponent("Backup", isDirectory: true).appendingPathComponent("\(year)", isDirectory: true).appendingPathComponent("\(NSString(format: "%02d", month))", isDirectory: true)
    do{
        try manager.createDirectory(at: backupdir, withIntermediateDirectories: true, attributes: nil)
    }catch{
        fatalError("Create Directory Error")
    }
    let filePath = "DailyMoney_\(NSString(format: "%04d", year))\(NSString(format: "%02d", month))\(NSString(format: "%02d", day)).plist"
    let url = backupdir.appendingPathComponent(filePath)
    plist.write(to: url, atomically: true)
    return url
}

func backupDailyData() {
    let manager = FileManager.default
    let documentDir = manager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let url = documentDir.appendingPathComponent("last_backup")
    let calendar = Calendar.current
    let day = calendar.component(.day, from: date)
    let month = calendar.component(.month, from: date)
    let year = calendar.component(.year, from: date)
    var last_backup = ""
    do{
        last_backup = try String(contentsOf: url)
    }catch{
        print("Load Error")
    }
    let d = "\(year)/\(NSString(format: "%02d", month))/\(NSString(format: "%02d", day))"
    if last_backup != d{
        let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: date))!
        let year_yes = calendar.component(.year, from: yesterday)
        let month_yes = calendar.component(.month, from: yesterday)
        let day_yes = calendar.component(.day, from: yesterday)
        let backupdir = documentDir.appendingPathComponent("Backup", isDirectory: true).appendingPathComponent("\(year_yes)", isDirectory: true).appendingPathComponent("\(NSString(format: "%02d", month_yes))", isDirectory: true)
        do{
            try manager.createDirectory(at: backupdir, withIntermediateDirectories: true, attributes: nil)
        }catch{
            fatalError("Create Directory Error")
        }
        let filePath = "DailyMoney_\(NSString(format: "%04d", year_yes))\(NSString(format: "%02d", month_yes))\(NSString(format: "%02d", day_yes)).plist"
        let url_data = backupdir.appendingPathComponent(filePath)
        plist.write(to: url_data, atomically: true)
        do{
            try d.write(to: url, atomically: false, encoding: .utf8)
        }catch{
            print("Backup Date Error")
        }
    }
}

//func list_backups(){
//    let manager = FileManager.default
//    let documentDir = manager.urls(for: .documentDirectory, in: .userDomainMask)[0]
//    let url = documentDir.appendingPathComponent("Backup", isDirectory: true)
//    do{
//        let year_folders = try manager.contentsOfDirectory(atPath: url.path)
//        for y in year_folders{
//            let year = url.appendingPathComponent(y, isDirectory: true)
//            let month_folders = try manager.contentsOfDirectory(atPath: year.path)
//            for m in month_folders{
//                let month = year.appendingPathComponent(m, isDirectory: true)
//                let files = try manager.contentsOfDirectory(atPath: month.path)
//                for file in files{
//                    if let _ = file.range(of: "DailyMoney"){
//                        let startindex = file.index(file.startIndex, offsetBy: 11)
//                        let endindex = file.index(startindex, offsetBy: 8)
//                        let datestr = file[startindex..<endindex]
//                        let formatter = DateFormatter()
//                        formatter.dateFormat = "yyyyMMdd"
//                        let date = formatter.date(from: String(datestr))
//                        print(date)
//                    }
//                }
//            }
//        }
//    }catch{
//        print("Error")
//    }
//}

func backup_year_list() -> [String]{
    let manager = FileManager.default
    let documentDir = manager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let url = documentDir.appendingPathComponent("Backup", isDirectory: true)
    do{
        return try manager.contentsOfDirectory(atPath: url.path)
    }catch{
        return []
    }
}

func backup_month_list(year: String) -> [String]{
    let manager = FileManager.default
    let documentDir = manager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    var url = documentDir.appendingPathComponent("Backup", isDirectory: true)
    url = url.appendingPathComponent(year, isDirectory: true)
    do{
        return try manager.contentsOfDirectory(atPath: url.path)
    }catch{
        return []
    }
}

func backup_day_list(year: String, month: String) -> [Date]{
    let manager = FileManager.default
    let documentDir = manager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    var url = documentDir.appendingPathComponent("Backup", isDirectory: true)
    url = url.appendingPathComponent(year, isDirectory: true)
    url = url.appendingPathComponent(month, isDirectory: true)
    var dates : [Date] = []
    do{
        let files = try manager.contentsOfDirectory(atPath: url.path)
        for file in files{
            if let _ = file.range(of: "DailyMoney"){
                let startindex = file.index(file.startIndex, offsetBy: 11)
                let endindex = file.index(startindex, offsetBy: 8)
                let datestr = file[startindex..<endindex]
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMdd"
                let date = formatter.date(from: String(datestr))!
                dates.append(date)
            }
        }
        return dates
    }catch{
        return []
    }
}

func sort_date(dates: [Date], i: Int, count: Int) -> [Date]{
    var tmp = dates
    if count == 1{
        return dates
    }else if i+1 == count{
        return sort_date(dates: dates, i: 0, count: count-1)
    }else{
        if tmp[i] < tmp[i+1]{
            let before = tmp[i+1]
            tmp[i+1] = tmp[i]
            tmp[i] = before
        }
        return sort_date(dates: tmp, i: i+1, count: count)
    }
}
