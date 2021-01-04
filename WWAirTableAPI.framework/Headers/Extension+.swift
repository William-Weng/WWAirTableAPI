//
//  Extension+.swift
//  WWAirTableAPI
//
//  Created by William.Weng on 2021/1/4.
//  Copyright © 2021 William.Weng. All rights reserved.
//

import UIKit

// MARK: - String (class function)
extension String {
    
    /// URL編碼 (百分比)
    /// - 是在哈囉 => %E6%98%AF%E5%9C%A8%E5%93%88%E5%9B%89
    /// - Parameter characterSet: 字元的判斷方式
    /// - Returns: String?
    func _encodingURL(characterSet: CharacterSet = .urlQueryAllowed) -> String? { return addingPercentEncoding(withAllowedCharacters: characterSet) }
    
    /// 字串 => 資料
    /// - Parameters:
    ///   - encoding: 字元編碼
    ///   - isLossyConversion: 失真轉換
    /// - Returns: Data?
    func _data(encoding: String.Encoding = .utf8, isLossyConversion: Bool = true) -> Data? {
        let data = self.data(using: encoding, allowLossyConversion: isLossyConversion)
        return data
    }
}

// MARK: - URLRequest (class function)
extension URLRequest {
    
    /// enum版的.setValue(_,forHTTPHeaderField:_)
    /// - Parameters:
    ///   - value: 要設定的值
    ///   - field: 要設定的欄位
    mutating func _setValue(_ value: Utility.ContentType, forHTTPHeaderField field: Utility.HTTPHeaderField) {
        self.setValue("\(value)", forHTTPHeaderField: field.rawValue)
    }
}
