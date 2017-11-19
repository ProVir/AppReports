//
//  AppReports.swift
//  AppReports
//
//  Created by Короткий Виталий (ViR) on 16.11.17.
//  Copyright © 2017 ProVir. All rights reserved.
//

import Foundation


///Base class for events destination. Use custom type event data (usually enum or struct)
open class AppReportEventsDestionation<TypeEventData> {
    public init() { }
    
    open func reportEvent(appReport:AppReportsCore, data:TypeEventData, additionalValues:[String:Any]) {
        assertionFailure("Require implementation reportEvent(appReport:data:additionalValues:) without perform super function")
    }
}

///Base class for errors destination. Usually use AppReportsErrorData as type error data. You can use custom type.
open class AppReportErrorsDestionation<TypeErrorData> {
    public init() { }
    
    open func reportError(appReport:AppReportsCore, data:TypeErrorData, logs:String, additionalValues:[String:Any]) {
        assertionFailure("Require implementation reportError(appReport:data:logs:additionalValues:) without perform super function")
    }
}


//MARK: - AppReports

///Generic AppReports for only errors support. It is convenient to use together with AppReportsErrorData without having information about the TypeEventData, example: `(AppReportsCore.coreShared as? AppReportsGenericError<AppReportErrorData>)?.reportError(...)`
open class AppReportsGenericError<TypeErrorData>: AppReportsCore {
    
    let errorsDests:[AppReportErrorsDestionation<TypeErrorData>]
    
    ///Constructor for support errors.
    public init(settings:SettingsCore,
         helper:AppReportsCoreHelper? = nil,
         errorsDestionations:[AppReportErrorsDestionation<TypeErrorData>]) {
        
        self.errorsDests = errorsDestionations
        
        super.init(settings: settings, helper: helper)
    }
    

    ///General function for report errors.
    public func reportError(_ data:TypeErrorData) {
        let logs = allLogs()
        let values = allAdditionalValues()
        
        errorsDests.forEach { dests in
            dests.reportError(appReport: self, data: data, logs: logs, additionalValues: values)
        }
    }
    
}


///Generic AppReports for use events and errors. Usually used as the main class.
open class AppReportsGeneric<TypeEventData, TypeErrorData>: AppReportsGenericError<TypeErrorData> {
    
    let eventsDests:[AppReportEventsDestionation<TypeEventData>]
    
    
    ///Constructor for support events and errors.
    public init(settings:SettingsCore,
         helper:AppReportsCoreHelper? = nil,
         eventsDestionations:[AppReportEventsDestionation<TypeEventData>],
         errorsDestionations:[AppReportErrorsDestionation<TypeErrorData>]) {
        
        self.eventsDests = eventsDestionations
        
        super.init(settings: settings,
                   helper: helper,
                   errorsDestionations: errorsDestionations)
    }
    
    
    ///General function for report custom events.
    public func reportEvent(_ data:TypeEventData) {
        let values = allAdditionalValues()
        
        eventsDests.forEach { dests in
            dests.reportEvent(appReport: self, data: data, additionalValues: values)
        }
    }
    
    
}
