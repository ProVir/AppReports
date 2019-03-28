//
//  AppReportsTypes.swift
//  AppReports
//
//  Created by Короткий Виталий (ViR) on 16.11.17.
//  Copyright © 2017 ProVir. All rights reserved.
//

import Foundation


///Standard type for sending errors
public struct AppReportsErrorData {
    
    ///Options for report errors.
    public struct Options: OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }
        
        public static let includeLogs = Options(rawValue: 1 << 1)
        public static let titleIsPrefix = Options(rawValue: 1 << 2)
        public static let titleFull = Options(rawValue: 1 << 3)
    }
    
    public var error:Error?
    public var title:String?
    public var options:Options = []
    
    public var userInfo:[String:Any]?
    public var bigData:Any?
    
    
    public init() { }
    
    ///Base constructor.
    public init(error:Error?, title:String?, options:Options, userInfo:[String:Any]? = nil, bigData:Any? = nil) {
        self.error = error
        self.title = title
        self.options = options
        self.userInfo = userInfo
        self.bigData = bigData
    }
    
    ///Constructor for report Error object with custom additional data.
    public init(error:Error?, userInfo:[String:Any]? = nil) {
        self.error = error
        self.userInfo = userInfo
    }
    
    ///Constructor for report error as string with custom additional data.
    public init(title:String?, userInfo:[String:Any]? = nil) {
        self.title = title
        self.userInfo = userInfo
    }
}


///Report errors functions if use AppReportsErrorData.
public extension AppReportsGenericError where TypeErrorData == AppReportsErrorData {
    
    ///Base function for report errors.
    func report(error:Error?, title:String?, options:AppReportsErrorData.Options, userInfo:[String:Any]? = nil, bigData:Any? = nil) {
        reportError(AppReportsErrorData(error: error, title: title, options: options, userInfo: userInfo, bigData: bigData))
    }
    
    ///Report Error object with custom additional data.
    func reportError(_ error:Error, userInfo:[String:Any]? = nil) {
        reportError(AppReportsErrorData(error: error, userInfo: userInfo))
    }
    
    ///Report error as string with custom additional data.
    func reportTitleError(_ title:String, userInfo:[String:Any]? = nil) {
        reportError(AppReportsErrorData(title: title, userInfo: userInfo))
    }
}



