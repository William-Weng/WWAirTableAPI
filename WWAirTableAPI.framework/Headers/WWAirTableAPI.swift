//
//  WWAirTableAPI.swift
//  WWAirTableAPI
//
//  Created by William.Weng on 2021/1/4.
//  Copyright © 2021 William.Weng. All rights reserved.
//
/// [Yahoo奇摩電影](https://movies.yahoo.com.tw/)
/// [利用 Airtable 製作 iOS App 連結的後台資料](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/利用-airtable-製作-ios-app-連結的後台資料-e22378536acb)
/// [串接 Airtable的 API 開發 iOS App. 在之前的文章，我們介紹了如何利用 Airtable 製作 iOS App… | by 彼得潘的 iOS App Neverland | 彼得潘的 Swift iOS App 開發問題解答集 | Dec, 2020 | Medium](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/串接-airtable的-api-開發-ios-app-5e5c86c8ca7d)
/// [使用 URLSession 串接 http get，post，delete，put API，以 Reqres API 為例 | by 彼得潘的 iOS App Neverland | 彼得潘的 Swift iOS App 開發問題解答集 | Dec, 2020 | Medium](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/使用-urlsession-串接-http-get-post-delete-put-api-以-reqres-api-為例-f977ec876c33)
/// [#135 利用 Airtable 開發 iOS App，比方電影 App - 彼得潘的 100 道 Swift iOS App 謎題 - Medium](https://medium.com/彼得潘的試煉-勇者的-100-道-swift-ios-app-謎題/135-利用-airtable-開發-ios-app-比方電影-app-db88fc3bf6c2)
/// [Airtable 中文介紹 & 教學（上）｜從與 Excel 比較談起 | by 許嘉文 (Evan Hsu) | Medium](https://medium.com/@evanhsu__0910/airtable-vs-excel-eeeb969bb7dc)
/// [Airtable 中文介紹 & 教學（中）｜表格、問卷視角－初階應用 | by 許嘉文 (Evan Hsu) | Medium](https://medium.com/@evanhsu__0910/airtable-grid-form-b0f0d56ef48c)
/// [Airtable 中文介紹 & 教學（下）｜日曆、卡片、看板視角－進階應用 | by 許嘉文 (Evan Hsu) | Medium](https://medium.com/@evanhsu__0910/airtable-calender-gallery-kanban-a4de8e54685f)
/// [Airtable 中文介紹 & 教學（番外篇）｜5 個實際使用範本不藏私分享 | by 許嘉文 (Evan Hsu) | Medium](https://medium.com/@evanhsu__0910/airtable-sample-c2c22c0d3534)
/// [Swift 4 新功能詳盡介紹：Codable, Dictionaries優化, 多行字符串等等 | AppCoda](https://www.appcoda.com.tw/swift4-changes/)

import UIKit

public protocol WWAirTableCallable {
    func jsonString() -> String?
}

// MARK: - WWAirTableAPI
final public class WWAirTableAPI {
    
    /// [資料的排序](https://airtable.com/api)
    public enum Direction: String {
        case asc = "asc"
        case desc = "desc"
    }
    
    /// [URL的參數名稱](https://airtable.com/api)
    public enum QueryString: String {
        case maxRecords = "maxRecords"
        case sort = "sort"
        case field = "field"
        case direction = "direction"
    }
    
    /// [函數名稱](https://support.airtable.com/hc/en-us/articles/203255215-Formula-field-reference)
    public enum Formula {
        case none
        case isSame
        case isAfter
        case isBefore
    }

    public typealias SortInformation = (field: String, direction: Direction)
    public typealias FilterInformation = (field: String, value: String, formula: Formula)
    
    private let rootURLString: String
    private let appKey: String
    private let apiKey: String
    
    private var tablename: String?
    private var maxRecords: Int?

    private var sortInformations: [SortInformation] = []
    private var filterInformations: [FilterInformation] = []
    private var deleteIdentities: [String] = []

    /// 初始化
    /// - Parameters
    ///   - rootURLString: [API的rootURL](https://airtable.com/api)
    ///   - appID: [Database ID](https://airtable.com/api)
    ///   - apiKey: [API Key](https://airtable.com/account)
    public init(rootURLString: String = "https://api.airtable.com/v0", appID: String, apiKey: String) {
        self.rootURLString = rootURLString
        self.appKey = appID
        self.apiKey = apiKey
    }
    
    /// 要設定的資料庫名稱
    /// - 記得要換轉成百分比編碼
    /// - Parameter tablename: 資料庫名稱
    /// - Returns: self
    public func tablename(_ tablename: String?) -> WWAirTableAPI {
        self.tablename = tablename?._encodingURL()
        return self
    }
    
    /// 清除「排序」+「過濾」的設定值
    /// - Returns: self
    public func clear() -> WWAirTableAPI {
        
        self.tablename = nil
        self.maxRecords = nil
        
        self.sortInformations = []
        self.filterInformations = []
        self.deleteIdentities = []
        
        return self
    }
}

// MARK: - 取得資料 (search)
extension WWAirTableAPI {
    
    /// 取得資料 (GET)
    /// - Parameter result: Result<Data?, Error>
    public func getJSON(result: @escaping (Result<Data?, Error>) -> Void) {
        self.request(httpMethod: .GET) { (_result) in result(_result) }
    }
    
    /// 執行URLRequest
    /// - Parameter result: Result<Data?, Error>
    public func request(httpMethod: Utility.HttpMethod = .GET, result: @escaping (Result<Data?, Error>) -> Void) {
        
        guard let request = request(httpMethod: httpMethod) else { result(.failure(Utility.MyError.isEmpty)); return }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error { result(.failure(error)); return }
            result(.success(data))
            
        }.resume()
    }
    
    /// 產生URLRequest
    /// - 包含認證的URLRequest => Authorization: Bearer <API_Key>
    /// - Returns: URLRequest?
    public func request(httpMethod: Utility.HttpMethod = .GET) -> URLRequest? {
        
        guard let url = url() else { return nil }
        
        var request = URLRequest(url: url)
        
        request._setValue(.bearer(forKey: apiKey), forHTTPHeaderField: .authorization)
        request.httpMethod = httpMethod.rawValue
        
        return request
    }
    
    /// 組合URL
    /// - URL字串 => https://api.airtable.com/v0/<appID>/<table>?sort[0][field]=name&filterByFormula=AND({imdb}='7.5')
    /// - Returns: URL?
    public func url() -> URL? {
        
        guard let tablename = tablename,
              let urlString = Optional.some("\(rootURLString)/\(appKey)/\(tablename)")
        else {
            return nil
        }
        
        guard let parameters = combineParameter() else { return URL(string: "\(urlString)") }
        
        return URL(string: "\(urlString)?\(parameters)")
    }
    
    /// 組合完整的參數
    /// - 參數 => sort[0][field]=name&filterByFormula=AND({imdb}='7.5')
    /// - Returns: String?
    private func combineParameter() -> String? {
        
        var parameters: [String] = []
        
        if let parameter = sortParameter() { parameters.append(parameter) }
        if let parameter = filterParameter() { parameters.append(parameter) }
        if let parameter = maxRecords { parameters.append("\(QueryString.maxRecords)=\(parameter)") }
        if let parameter = deleteParameter() { parameters.append(parameter) }
        
        if parameters.isEmpty { return nil }
        
        return parameters.joined(separator: "&")
    }
}

// MARK: - 排序資料 (search)
extension WWAirTableAPI {
    
    /// 資料排序
    /// - Parameters:
    ///   - field: 要排序的欄位名稱
    ///   - direction: 順著排(asc) / 倒著排(desc)
    /// - Returns: self
    public func sort(field: String, direction: Direction = .asc) -> WWAirTableAPI {
        
        let info: SortInformation = (field: field, direction: direction)
        sortInformations.append(info)
        
        return self
    }
    
    /// 傳回資料的最大筆數
    /// - mmaxRecords=100
    /// - Parameter maxRecords: 最大的筆數
    /// - Returns: self
    public func maxRecords(_ maxRecords: Int) -> WWAirTableAPI {
        self.maxRecords = maxRecords
        return self
    }
    
    /// 組合排序參數
    /// - 參數 => sort[0][field]=name&sort[0][direction]=desc&sort[1][field]=imdb&sort[1][direction]=desc
    /// - Returns: String?
    private func sortParameter() -> String? {

        if sortInformations.isEmpty { return nil }
        
        var parameters = ""
        
        for index in 0..<sortInformations.count {
            
            let info = sortInformations[index]
            var parameter = String()
            
            if info.direction == .asc {
                parameter = "\(QueryString.sort)[\(index)][\(QueryString.field)]=\(info.field)"
            } else {
                parameter = "\(QueryString.sort)[\(index)][\(QueryString.field)]=\(info.field)&\(QueryString.sort)[\(index)][\(QueryString.direction)]=\(info.direction)"
            }
            
            if (index < sortInformations.count - 1) { parameter += "&" }
            parameters += parameter
        }
        
        return parameters
    }
}

// MARK: - 過濾資料 (search)
extension WWAirTableAPI {
    
    /// 過濾資料
    /// - Parameters:
    ///   - info: 要過濾的(欄位, 數值)
    /// - Returns: self
    public func filter(info: WWAirTableAPI.FilterInformation) -> WWAirTableAPI {
        self.filterInformations.append(info)
        return self
    }
    
    /// 過濾資料 => filter(info:_)的Array版
    /// - Parameter infos: 要過濾的[(欄位, 數值)]
    /// - Returns: self
    public func filters(infos: [WWAirTableAPI.FilterInformation]) -> WWAirTableAPI {
        infos.forEach { (info) in self.filterInformations.append(info) }
        return self
    }
    
    /// 組合過濾參數
    /// - 參數 => filterByFormula=OR({name}='坑爹大作戰',{imdb="7.5"})
    /// - Parameter isInverted: 過濾類型 => filterByFormula=AND({name}='坑爹大作戰',{imdb}='7.5',IS_AFTER({releaseDate},'2020-12-10'),IS_BEFORE({releaseDate},'2020-12-12'))
    /// - Returns: String?
    private func filterParameter(type: Utility.FilterType = .and) -> String? {
        
        if filterInformations.isEmpty { return nil }
        
        let filters = filterInformations.compactMap { (field, value, formula) -> String? in
            
            switch formula {
            case .none: return "{\(field)}='\(value)'"
            case .isAfter: return "IS_AFTER({\(field)},'\(value)')"
            case .isBefore: return "IS_BEFORE({\(field)},'\(value)')"
            case .isSame: return "IS_SAME({\(field)},'\(value)')"
            }
            
        }.joined(separator: ",")
        
        guard let encodingFilters = filters._encodingURL() else { return nil }
        
        return "filterByFormula=\(type)(\(encodingFilters))"
    }
}

// MARK: - 上傳資料 (insert)
extension WWAirTableAPI {
    
    /// 上傳資料 (JSON)
    /// - Parameters:
    ///   - httpMethod: http方法 (GET/POST/DELETE ...)
    ///   - info: 要上傳的資料 (要符合Encodable)
    ///   - dateFormat: 時間的格式 (yyyy/mm/dd)
    ///   - result: Result<Data?, Error>
    public func uploadJSON<T: Encodable>(info: T?, dateFormat: Utility.DateFormat = .short, result: @escaping (Result<Data?, Error>) -> Void) {
        
        guard self.tablename != nil,
              var request = self.request(httpMethod: .POST)
        else {
            result(.failure(Utility.MyError.notOpenURL)); return
        }
        
        request._setValue(.json, forHTTPHeaderField: .contentType)
        request.httpBody = httpBody(with: info, dateFormat: dateFormat)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data else { result(.success(nil)); return }
            result(.success(data))
            
        }.resume()
    }
    
    /// 產生URLRequest的httpBody
    /// - Parameters:
    ///   - info: 要上傳的資料 (要符合Encodable)
    ///   - dateFormat: 時間的格式 (yyyy/mm/dd)
    /// - Returns: Data?
    private func httpBody<T: Encodable>(with info: T?, dateFormat: Utility.DateFormat = .short) -> Data? {
        
        guard let info = info,
              let encoder = Optional.some(JSONEncoder()),
              let formatter = Optional.some(DateFormatter())
        else {
            return nil
        }
        
        formatter.dateFormat = dateFormat.rawValue
        encoder.dateEncodingStrategy = .formatted(formatter)
        
        return try? encoder.encode(info)
    }
}

// MARK: - 刪除資料 (delete)
extension WWAirTableAPI {
    
    /// 刪除資料 (DELETE)
    /// - Parameter result: Result<Data?, Error>
     public func deleteJSON(result: @escaping (Result<Data?, Error>) -> Void) {
        self.request(httpMethod: .DELETE) { (_result) in result(_result) }
    }
    
    /// 設定要刪除的資料id
    /// - Parameter id: 刪除的資料id
    /// - Returns: self
    public func delete(id: String) -> WWAirTableAPI {
        self.deleteIdentities.append(id)
        return self
    }
    
    public func deletes(ids: [String]) -> WWAirTableAPI {
        ids.forEach { (id) in self.deleteIdentities.append(id) }
        return self
    }
    
    /// 組合排序參數
    /// - 參數 => records[]=<id1>&records[]=<id2>
    /// - Returns: String?
    private func deleteParameter() -> String? {
        
        if deleteIdentities.isEmpty { return nil }
        
        var parameters = ""
        
        for index in 0..<deleteIdentities.count {
            
            let identity = deleteIdentities[index]
            var parameter = String()

            parameter += "records[]=\(identity)"
            
            if (index < sortInformations.count - 1) { parameter += "&" }
            parameters += parameter
        }
        
        return parameters
    }
}

// MARK: - 修改資料 (update)
extension WWAirTableAPI {
    
    /// 修改資料
    /// - Parameters:
    ///   - json: 要修改的資料
    ///   - dateFormat: 時間格式
    ///   - result: Result<Data?, Error>
    func updateJSON(json: String?, dateFormat: Utility.DateFormat = .short, result: @escaping (Result<Data?, Error>) -> Void) {
        
        guard let json = json,
              self.tablename != nil,
              var request = self.request(httpMethod: .PATCH)
        else {
            result(.failure(Utility.MyError.notOpenURL)); return
        }
        
        request._setValue(.json, forHTTPHeaderField: .contentType)
        request.httpBody = json._data()
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data else { result(.success(nil)); return }
            result(.success(data))
            
        }.resume()
    }
}
