# WWAirTableAPI
簡易基本款的AirTableAPI (上傳至Cocoapods)

[![Swift 5.0](https://img.shields.io/badge/Swift-4.2-orange.svg?style=flat)](https://developer.apple.com/swift/) [![Version](https://img.shields.io/cocoapods/v/WWRadioButton.svg?style=flat)](http://cocoapods.org/pods/WWRadioButton) [![Platform](https://img.shields.io/cocoapods/p/WWRadioButton.svg?style=flat)](http://cocoapods.org/pods/WWRadioButton) [![License](https://img.shields.io/cocoapods/l/WWRadioButton.svg?style=flat)](http://cocoapods.org/pods/WWRadioButton)

![簡易基本款的AirTableAPI (上傳至Cocoapods)](WWAirTableAPI.gif)

# [使用範例 - DEMO](https://github.com/William-Weng/Cocoapods/WWAirTableAPI)

```swift
import UIKit
import WWAirTableAPI

final class ViewController: UIViewController {

    private let AirTableUrlString = "https://api.airtable.com/v0"
    private let ApplicationID = "<YOUR_ApplicationID>"
    private let APIKey = "<YOUR_APIKey>"
    private let TableName = "電影"
        
    @IBOutlet weak var resultTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func getJSON(_ sender: UIBarButtonItem) {
        
        let airTableURL = WWAirTableAPI(rootURLString: AirTableUrlString, appID: ApplicationID, apiKey: APIKey)
                                       .clear()
                                       .tablename(TableName)
                                       .maxRecords(5)
                                       .sort(field: "imdb", direction: .desc)
                                       .sort(field: "releaseDate")
        
        airTableURL.getJSON { (_result) in
            
            switch _result {
            case .failure(let error): DispatchQueue.main.async { self.resultTextView.text = "\(error)" }
            case .success(let data): DispatchQueue.main.async {
                guard let data = data else { return }
                self.resultTextView.text = data._string()
                }
            }
        }
    }
    
    @IBAction func filterJSON(_ sender: UIBarButtonItem) {
        
        let filterInformations: [WWAirTableAPI.FilterInformation] = [
            ("imdb", "6.7", .none),
            ("name", "求婚好意外", .none),
            ("releaseDate", "2020-12-23", .isAfter),
            ("releaseDate", "2020-12-25", .isBefore),
        ]
        
        let airTableURL = WWAirTableAPI(rootURLString: AirTableUrlString, appID: ApplicationID, apiKey: APIKey)
                                       .clear()
                                       .tablename(TableName)
                                       .filters(infos: filterInformations)
                                       .sort(field: filterInformations[0].field)
        
        airTableURL.getJSON { (_result) in
            
            switch _result {
            case .failure(let error): DispatchQueue.main.async { self.resultTextView.text = "\(error)" }
            case .success(let data): DispatchQueue.main.async {
                guard let data = data else { return }
                self.resultTextView.text = data._string()
                }
            }
        }
    }
    
    @IBAction func deleteJSON(_ sender: UIBarButtonItem) {
        
        let airTableURL = WWAirTableAPI(rootURLString: AirTableUrlString, appID: ApplicationID, apiKey: APIKey)
                                       .clear()
                                       .tablename(TableName)
                                       .delete(id: "deleteID")
        
        airTableURL.deleteJSON() { (_result) in
            switch _result {
            case .failure(let error): DispatchQueue.main.async { self.resultTextView.text = "\(error)" }
            case .success(let data): DispatchQueue.main.async {
                guard let data = data else { return }
                self.resultTextView.text = data._string()
                }
            }
        }
    }
    
    @IBAction func uploadJSON(_ sender: UIBarButtonItem) {

        let airTableURL = WWAirTableAPI(rootURLString: AirTableUrlString, appID: ApplicationID, apiKey: APIKey)
                                       .clear()
                                       .tablename(TableName)
        let info = movieBody()
        
        airTableURL.uploadJSON(info: info) { (_result) in
            
            switch _result {
            case .failure(let error): DispatchQueue.main.async { self.resultTextView.text = "\(error)" }
            case .success(let data):
                DispatchQueue.main.async {
                    guard let data = data else { return }
                    self.resultTextView.text = data._string()
                }
            }
        }
    }
}

extension ViewController {
    
    /// [測試用資料](https://movies.yahoo.com.tw/)
    /// - Returns: MovieBody?
    private func movieBody() -> CreateRecord? {
        
        guard let fields_1 = CreateRecord.Fields.build(name: "求婚好意外", imdb: 6.7,
                                                       releaseDate: ("2020-12-11", .short),
                                                       genre: ["喜劇"],
                                                       images: ["https://movies.yahoo.com.tw/i/o/production/movies/November2020/HLffjMYa7OknPGBsy1v8-757x1080.jpg"]),
              let fields_2 = CreateRecord.Fields.build(name: "信用詐欺師JP：公主篇",
                                                       imdb: 7.0,
                                                       releaseDate: ("2020-12-11", .short),
                                                       genre: ["劇情", "喜劇"],
                                                       images: ["https://movies.yahoo.com.tw/i/o/production/movies/December2020/SctoAzwvQ8KuDVIChKyj-756x1080.jpg"]),
              let fields_3 = CreateRecord.Fields.build(name: "真愛鄰距離",
                                                       imdb: 5.4,
                                                       releaseDate: ("2020-12-24", .short),
                                                       genre: ["愛情", "喜劇"],
                                                       images: ["https://movies.yahoo.com.tw/i/o/production/movies/December2020/u1c1LEsKLbqI1oyreXex-757x1080.jpg"])
        else {
            return nil
        }
        
        return CreateRecord(records: [.init(fields: fields_1), .init(fields: fields_2), .init(fields: fields_3), ])
    }
}

```