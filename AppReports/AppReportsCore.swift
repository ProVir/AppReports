//
//  AppReportsCore.swift
//  AppReports
//
//  Created by Короткий Виталий (ViR) on 16.11.17.
//  Copyright © 2017 ProVir. All rights reserved.
//

import Foundation

///Helper for events logs and changed additional values.
public protocol AppReportsCoreHelper: class {
    func logAdded(_ newStr:String, currentLog:String)
    func additionalValuesChanged(key:String, newValue:Any?, currentDict:[String:Any])
}

///Core functional - Logs and Store Additional Values (use as global dictionary for events and error handlers)
open class AppReportsCore: NSObject {
    
    //MARK: Shared
    
    ///Shared Instance for AppReports.
    public static var coreShared:AppReportsCore?
    
    ///Setup AppReports for use in app - Create and save AppReports.
    public static func setup(_ appReports:AppReportsCore) {
        coreShared = appReports
    }
    
    
    //MARK: Data
    private var mutex = pthread_mutex_t()
    
    
    public let coreHelper:AppReportsCoreHelper?
    
    public let logMaxSize:Int
    public let logBlockSize:Int
    private let logDateFormatter:DateFormatter
    
    private var logData = NSMutableString()
    private var logSizes = [Int]()
    
    private var additionalValues = [String:Any]()
    
    
    
    //MARK: Create
    
    ///Settings logs
    public struct SettingsCore {
        public var logMaxSize:Int
        public var logBlockSize:Int
        public var logTimeFormat:String
        
        public init(logMaxSize:Int = 24576, logBlockSize:Int = 512, logTimeFormat:String = "yyyy-MM-dd HH:mm:ss.SSS") {
            self.logMaxSize = logMaxSize
            self.logBlockSize = logBlockSize
            self.logTimeFormat = logTimeFormat
        }
    }
    
    ///Core constructor
    public init(settings:SettingsCore = SettingsCore(), helper:AppReportsCoreHelper? = nil) {
        self.coreHelper = helper
        
        self.logMaxSize = settings.logMaxSize
        self.logBlockSize = settings.logBlockSize
        
        logDateFormatter = DateFormatter()
        logDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        logDateFormatter.dateFormat = settings.logTimeFormat
        
        pthread_mutex_init(&mutex, nil)
        
        super.init()
    }
    
    deinit {
        pthread_mutex_destroy(&mutex)
    }
    
    
    //MARK: - Logs
    
    ///Write new entry in log
    @objc(logString:)
    public func log(_ str:String) {
        if str.isEmpty {
            return
        }
        
        //@synchronized (self)
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }
        
        
        //New log
        let date = Date()
        let logStr = "\(logDateFormatter.string(from: date)): \(str)\n"
        let size = (logStr as NSString).length
        
        
        //Clear size log
        let lengthCurrent = logData.length + size
        if lengthCurrent > logMaxSize {
            var removeLength = 0
            var removeCount = 0
            
            let logMaxSizeClear = logMaxSize - logBlockSize

            for size in logSizes {
                removeCount += 1
                removeLength += size
                
                //Если необходимое кол-во найдено - удаляем
                if lengthCurrent - removeLength <= logMaxSizeClear {
                    break
                }
            }
            
            if removeLength < logData.length && removeCount < logSizes.count {
                logData.deleteCharacters(in: NSRange(location: 0, length: removeLength))
                logSizes.removeSubrange(Range<Int>(uncheckedBounds: (lower: 0, upper: removeCount-1)))
            } else {
                logData = NSMutableString()
                logSizes = []
            }
        }
        
        //Add log
        logData.append(logStr)
        logSizes.append(size)
        
        
        coreHelper?.logAdded(str, currentLog: logData as String)
    }
    
    ///Read all logs (with time marks and split lines (use \\n))
    @objc
    public func allLogs() -> String {
        //@synchronized (self)
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }
        
        return logData as String
    }
    
    
    ///Remove all logs
    @objc
    public func clearLogs() {
        //@synchronized (self)
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }
        
        logData = NSMutableString()
        logSizes = []
    }
    
    
    
    //MARK: - Variables additional
    
    ///Add value for key. Use `value = nil` for remove value.
    @objc(setAdditionalValue:forKey:)
    public func setAdditional(value:Any?, forKey key:String) {
        //@synchronized (self)
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }
        
        additionalValues[key] = value
        
        coreHelper?.additionalValuesChanged(key: key, newValue: value, currentDict: additionalValues)
    }
    
    ///Remove value for key.
    @objc(removeAdditionalValueForKey:)
    public func removeAdditionalValue(forKey key:String) {
        setAdditional(value: nil, forKey: key)
    }
    
    
    ///Remove all values.
    @objc
    public func clearAllAdditionalValues() {
        //@synchronized (self)
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }
        
        additionalValues = [:]
        
        coreHelper?.additionalValuesChanged(key: "", newValue: nil, currentDict: additionalValues)
    }
    
    
    ///Read value from key.
    @objc(additionalValueForKey:)
    public func additionalValue(forKey key:String) -> Any? {
        //@synchronized (self)
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }
        
        return additionalValues[key]
    }
    
    ///Read all values.
    @objc
    public func allAdditionalValues() -> [String:Any] {
        //@synchronized (self)
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }
        
        return additionalValues
    }
    
}

//MARK: - Logs helper
public extension AppReportsCore {
    
    ///Add event viewDidAppear in log.
    @objc(logScreenDidAppear:)
    func logScreenDidAppear(viewController:AnyObject) {
        log("Screen Appear: \(NSStringFromClass(type(of: viewController)))")
    }
    
    ///Add event viewDidDisappear in log.
    @objc(logScreenDidDisappear:)
    func logScreenDidDisappear(viewController:AnyObject) {
        log("Screen Disappear: \(NSStringFromClass(type(of: viewController)))")
    }
}

///Static functions (use `coreShared`, need perform `AppReportsCore.setup()`).
public extension AppReportsCore {
    
    ///Write new entry in log
    static func log(_ str:String) {
        coreShared?.log(str)
    }
    
    ///Add event viewDidAppear in log.
    static func logScreenDidAppear(viewController:AnyObject) {
        coreShared?.logScreenDidAppear(viewController: viewController)
    }
    
    ///Add event viewDidDisappear in log.
    static func logScreenDidDisappear(viewController:AnyObject) {
        coreShared?.logScreenDidDisappear(viewController: viewController)
    }
}

