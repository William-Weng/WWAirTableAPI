//
//  Utility.swift
//  WWAirTableAPI
//
//  Created by William.Weng on 2021/1/4.
//  Copyright © 2021 William.Weng. All rights reserved.
//

import UIKit

// MARK: - Utility (單例)
final public class Utility: NSObject {
    static let shared = Utility()
    private override init() {}
}

extension Utility {
    
    /// 過濾的方式 (AND/OR/NOT)
    public enum FilterType: String {
        case and = "AND"
        case or = "OR"
        case not = "NOT"
    }
    
    /// [HTTP 請求方法](https://developer.mozilla.org/zh-TW/docs/Web/HTTP/Methods)
    public enum HttpMethod: String {
        case GET = "GET"
        case HEAD = "HEAD"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DELETE"
        case CONNECT = "CONNECT"
        case OPTIONS = "OPTIONS"
        case TRACE = "TRACE"
        case PATCH = "PATCH"
    }

    /// 自訂錯誤
    public enum MyError: Error, LocalizedError {
        
        var errorDescription: String {
            switch self {
            case .unknown: return "未知錯誤"
            case .notOpenURL: return "打開URL錯誤"
            case .isEmpty: return "資料是空的"
            }
        }

        case unknown
        case isEmpty
        case notOpenURL
    }
    
    /// [時間的格式](http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns)
    public enum DateFormat: String {
        case full = "yyyy-MM-dd HH:mm:ss ZZZ"
        case long = "yyyy-MM-dd HH:mm:ss"
        case middle = "yyyy-MM-dd HH:mm"
        case short = "yyyy-MM-dd"
    }
    
    /// [HTTP標頭欄位](https://zh.wikipedia.org/wiki/HTTP头字段)
    public enum HTTPHeaderField: String {
        case acceptRanges = "Accept-Ranges"
        case authorization = "Authorization"
        case contentType = "Content-Type"
        case contentLength = "Content-Length"
        case contentRange = "Content-Range"
        case contentDisposition = "Content-Disposition"
        case date = "Date"
        case lastModified = "Last-Modified"
        case range = "Range"
    }
    
    /// [HTTP Content-Type](https://www.runoob.com/http/http-content-type.html) => Content-Type: application/json
    public enum ContentType: CustomStringConvertible {
        
        public var description: String { return toString() }
        
        case json
        case formUrlEncoded
        case formData
        case bearer(forKey: String)
        
        func toString() -> String {
            
            switch self {
            case .json: return "application/json"
            case .formUrlEncoded: return "application/x-www-form-urlencoded"
            case .formData: return "multipart/form-data"
            case .bearer(forKey: let key): return "Bearer \(key)"
            }
        }
    }
}
