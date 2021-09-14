//
//  TimeFormatter.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 12/09/2021.
//

import UIKit

public enum FormatDate {
    case fullDate
    case date
}

public protocol TimeFormatter {
    func timeAndFullDate(interval: Int) -> String
    func fullDateAndTime(interval: Int) -> String
    func fullDate(interval: Int) -> String
    func date(interval: Int) -> String
    func time(interval: Int) -> String
    func toCurrencyFrom(number: Double) -> String
    func getTimeStringFrom(interval: Int) -> String
    func weekAndFullDate(interval: Int) -> String
    func week(interval: Int) -> String
    func timeAgo(from interval: TimeInterval, format: FormatDate) -> String
    func onlineStatusTimeAgo(from interval: TimeInterval) -> String
    func getTime(interval: Int) -> String
}

public class TimeFormaterImpl: TimeFormatter {
    public func timeAndFullDate(interval: Int) -> String {
        let formater = DateFormatter()
        formater.dateFormat = "HH:mm - dd/MM/yyyy"
        return formater.string(from: Date.init(timeIntervalSince1970: TimeInterval(interval)))
    }
    
    public func fullDateAndTime(interval: Int) -> String {
        let formater = DateFormatter()
        formater.dateFormat = "dd/MM/yyyy HH:mm"
        return formater.string(from: Date.init(timeIntervalSince1970: TimeInterval(interval)))
    }
    
    public func fullDate(interval: Int) -> String {
        let formater = DateFormatter()
        formater.dateFormat = "dd/MM/yyyy"
        return formater.string(from: Date.init(timeIntervalSince1970: TimeInterval(interval)))
    }
    
    public func date(interval: Int) -> String {
        let formater = DateFormatter()
        formater.dateFormat = "dd/MM"
        return formater.string(from: Date.init(timeIntervalSince1970: TimeInterval(interval)))
    }
    
    public func time(interval: Int) -> String {
        // Check if time passed return FT
//        let currentInterval = Date().timeIntervalSince1970
//        if TimeInterval(interval) + 120 * 60 < currentInterval {
//            return "FT"
//        }
        
        let formater = DateFormatter()
        formater.dateFormat = "HH:mm"
        return formater.string(from: Date.init(timeIntervalSince1970: TimeInterval(interval)))
    }
    
    public func toCurrencyFrom(number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(floatLiteral: number)) ?? ""
    }
    
    public func getTimeStringFrom(interval: Int) -> String {
        let hours = interval / 3600; let hoursStr = hours < 9 ? "0\(hours)" : "\(hours)"
        let minutes = interval % 3600 / 60; let minutesStr = minutes < 9 ? "0\(minutes)" : "\(minutes)"
        return "\(hoursStr) giờ \(minutesStr) phút"
    }
    
    public func getTime(interval: Int) -> String {
        let hours = interval / 3600; let hoursStr = hours < 9 ? "0\(hours)" : "\(hours)"
        let minutes = interval % 3600 / 60; let minutesStr = minutes < 9 ? "0\(minutes)" : "\(minutes)"
        let seconds = interval % 60; let secondsStr = seconds < 10 ? "0\(seconds)" : "\(seconds)"
        return hours > 0 ? "\(hoursStr):\(minutesStr):\(secondsStr)" : "\(minutesStr):\(secondsStr)"
    }
    
    public func weekAndFullDate(interval: Int) -> String {
        let formater = DateFormatter()
        formater.dateFormat = "EEEE, dd/MM/yyyy"
        formater.locale = Locale.current
        return formater.string(from: Date.init(timeIntervalSince1970: TimeInterval(interval)))
    }
    public func week(interval: Int) -> String {
        let formater = DateFormatter()
        formater.dateFormat = "EEEE"
        formater.locale = Locale(identifier: "vi_VN")
        return formater.string(from: Date.init(timeIntervalSince1970: TimeInterval(interval)))
    }
    
    // dd - hh - mm - ss
    public func distanceTime(from interval: TimeInterval) -> [Int] {
        var results = [0, 0, 0, 0]
        let currentInterval = Date().timeIntervalSince1970
        let distanceTime = currentInterval - interval
        if  distanceTime < 0 { return results }
        
        let dictanceTimeInt = Int(distanceTime)
        results[0] = dictanceTimeInt / 86400
        results[1] = (dictanceTimeInt % 86400) / 3600
        results[2] = (dictanceTimeInt % 3600) / 60
        results[3] = dictanceTimeInt % 60
        
        return results
    }
    
    public func timeAgo(from interval: TimeInterval, format: FormatDate = .fullDate) -> String {
        let labels = ["days", "hours", "minutes", "seconds"]
        let times = distanceTime(from: interval)
        let index = times.firstIndex { $0 != 0 } ?? 3
        
        var result = ""
        if index == 0 && times[index] > 7 {
            result = format == .fullDate ? self.fullDate(interval: Int(interval)) : self.date(interval: Int(interval))
        } else if index == 3 {
            result = "just now".localized
        } else {
//            result = "\(times[index]) \(labels[index].localized)"
            result = "%d \(labels[index])".localizedPlural(times[index])
        }
        
        return result
    }
    
    public func onlineStatusTimeAgo(from interval: TimeInterval) -> String {
        let labels = ["days", "hours", "minutes", "seconds"]
        let times = distanceTime(from: interval)
        let index = times.firstIndex { $0 != 0 } ?? 3
        var result = ""
        if index == 3 {
            result = "Just now".localized
        } else {
            result = "Last seen %d \(labels[index]) ago".localizedPlural(times[index])
        }
        
        return result
    }
}
