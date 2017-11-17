//
//  ViewController.swift
//  AlamofireTest
//
//  Created by liqunfei on 2017/11/16.
//  Copyright © 2017年 LQF. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view .addSubview(dataTableView)
        dataTableView.addSubview(showImageView)
    }
    
    fileprivate let dataSource = ["Making a Request",
                      "responseJSON",
                      "response",
                      "responseData",
                      "responseString",
                      "Chained Response Handlers",
                      "Response Handler Queue",
                      "Manual Validation",
                      "Automatic Validation",
                      "GET Request With URL-Encoded Parameters",
                      "POST Request With URL-Encoded Parameters",
                      "POST Request with JSON-Encoded Parameters",
                      "Custom Encoding",
                      "Manual Parameter Encoding of a URLRequest",
                      "HTTP Headers",
                      "HTTP Basic Authentication",
                      "Authorization header",
                      "Authentication with URLCredential",
                      "Download File Destination",
                      "suggested download destination API",
                      "Download Progress",
                      "The downloadProgress API also takes a queue parameter",
                      "Timeline",
                      "URL Session Task Metrics",
                      "CustomStringConvertible",
                      "CustomDebugStringConvertible"
    ]
    
    fileprivate lazy var dataTableView: UITableView = {
        let tvRect = CGRect.init(x: 0,
                                 y: 0,
                                 width: UIScreen.main.bounds.width,
                                 height: UIScreen.main.bounds.height)
        let tableView = UITableView(frame: tvRect, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        return tableView
    }()
    
    fileprivate lazy var showImageView = {
        return UIImageView(frame: CGRect.init(x: UIScreen.main.bounds.width - 150, y: 40, width: 100, height: 100))
    }()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 25.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.description()))
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: String(describing: UITableViewCell.description()))
            cell?.textLabel?.textColor = UIColor.blue
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 12.0)
        }
        cell?.textLabel?.text = dataSource[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            Alamofire.request("https://httpbin.org/get")
        case 1:
            Alamofire.request("https://httpbin.org/get").responseJSON(completionHandler: { (response) in
                // original url request
                print("Request:\(String(describing: response.request))")
                // http url response
                print("Response:\(String(describing: response.response))")
                // response serialization result
                print("Result: \(response.result)")
                
                if let json = response.result.value {
                    // serialized json response
                    print("Json: \(json)")
                }
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    // original server data as UTF8 string
                    print("Data: \(utf8Text)")
                }
            })
        case 2:
            /*
             The response handler does NOT evaluate any of the response data. It merely forwards on all information directly from the URL session delegate.
             */
            Alamofire.request("https://httpbin.org/get").response(completionHandler: { (response) in
                print("Request: \(String(describing: response.request))")
                print("Response: \(String(describing: response.response))")
                print("Error: \(String(describing: response.error))")
                
                if let data = response.data,let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                }
            })
        case 3:
            Alamofire.request("https://httpbin.org/get").responseData(completionHandler: { (response) in
                if let data = response.result.value, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                }
            })
        case 4:
            Alamofire.request("https://httpbin.org/get").responseString(completionHandler: { (response) in
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(String(describing: response.result.value))")
            })
        case 5:
            Alamofire.request("https://httpbin.org/get").responseString(completionHandler: { (response) in
                print("Response String: \(String(describing: response.result.value))")
            })
                .responseJSON(completionHandler: { (response) in
                    print("Response JSON: \(String(describing: response.result.value))")
                })
        case 6:
            //创建队列
            let utilityQueue = DispatchQueue.global(qos: .utility)
            
            Alamofire.request("https://httpbin.org/get").responseJSON(queue: utilityQueue, completionHandler: { (response) in
                print("Executing response handler on utility queue.")
            })
        case 7:
            Alamofire.request("https://httpbin.org/get").validate(statusCode: 200..<300).validate(contentType: ["application/json"]).responseData(completionHandler: { (response) in
                switch response.result {
                case .success:
                    print("Validation Successful")
                case .failure(let error):
                    print(error)
                }
            })
        case 8:
            Alamofire.request("https://httpbin.org/get").validate().responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success:
                    print("Validation Successful")
                case .failure(let error):
                    print(error)
                }
            })
        case 9:
            
            let parameters: Parameters = ["foo" : "bar"]
            
            //            Alamofire.request("https://httpbin.org/get", parameters: parameters)
            //            Alamofire.request("https://httpbin.org/get", parameters: parameters, encoding: URLEncoding.default)
            Alamofire.request("https://httpbin.org/get", parameters: parameters, encoding: URLEncoding(destination: .methodDependent)).responseJSON(completionHandler: { (response) in
                if let json = response.result.value {
                    // serialized json response
                    print("Json: \(json)")
                }
            })
        case 10:
            let parameters: Parameters = [
                "foo" : "bar",
                "baz" : ["a",1],
                "qux" : [
                    "x" : 1,
                    "y" : 2,
                    "z" : 3
                ]
            ]
            
//            Alamofire.request("https://httpbin.org/post", method: .post, parameters: parameters)
//            Alamofire.request("https://httpbin.org/post", method: .post, parameters: parameters, encoding: URLEncoding.default)
            Alamofire.request("https://httpbin.org/post", method: .post, parameters: parameters, encoding: URLEncoding.httpBody).responseJSON(completionHandler: { (response) in
                if let json = response.result.value {
                    // serialized json response
                    print("Json: \(json)")
                }
            })
        case 11:
            let parameters: Parameters = [
                "foo" : [1,2,3],
                "bar" : [
                    "baz" : "qux"
                ]
            ]
            
//            Alamofire.request("https://httpbin.org/post", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            Alamofire.request("https://httpbin.org/post", method: .post, parameters: parameters, encoding: JSONEncoding(options: [])).responseJSON(completionHandler: { (response) in
                if let json = response.result.value {
                    // serialized json response
                    print("Json: \(json)")
                }
            })
        case 12:
            print("Custom Encoding")
        case 13:
            let url = URL(string: "https://httpbin.org/get")!
            var urlRequest = URLRequest(url: url)
            
            let parameters: Parameters = ["foo": "bar"]
            /*未找到飘红原因*/
//            let encodedURLRequest = try URLEncoding.queryString.encode(urlRequest, with: parameters)
        case 14:
            let headers: HTTPHeaders = [
                "Authorization": "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==",
                "Accept": "application/json"
            ]
            
            Alamofire.request("https://httpbin.org/headers", headers: headers).responseJSON(completionHandler: { (response) in
                debugPrint("debugPrint:\(response)")
                print("print:\(response)")
            })
        case 15:
            let user = "user"
            let password = "password"
            
            Alamofire.request("https://httpbin.org/basic-auth/\(user)/\(password)").authenticate(user: user, password: password).responseJSON { response in
                debugPrint(response)
            }
        case 16:
            let user = "user"
            let password = "password"
            
            var headers: HTTPHeaders = [:]
            
            if let authorizationHeader = Request.authorizationHeader(user: user, password: password) {
                headers[authorizationHeader.key] = authorizationHeader.value
            }
            
            Alamofire.request("https://httpbin.org/basic-auth/user/password", headers: headers).responseJSON(completionHandler: { (response) in
                debugPrint(response)
            })
        case 17:
            let user = "user"
            let password = "password"
            
            let credential = URLCredential(user: user, password: password, persistence: .forSession)
            
            Alamofire.request("https://httpbin.org/basic-auth/\(user)/\(password)").authenticate(usingCredential: credential).responseJSON { response in
                debugPrint(response)
            }
        case 18:
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent("pig.png")
                
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            
            Alamofire.download("https://httpbin.org/image/png", to: destination).response(completionHandler: { (response) in
                if response.error == nil, let imagePath = response.destinationURL?.path {
                    let image = UIImage(contentsOfFile: imagePath)
                    self.showImageView.image = image
                }
            })
        case 19:
            let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
            Alamofire.download("https://httpbin.org/image/png", to: destination).response(completionHandler: { (response) in
                if response.error == nil, let imagePath = response.destinationURL?.path {
                    debugPrint(imagePath)
                    let image = UIImage(contentsOfFile: imagePath)
                    self.showImageView.image = image
                }
            })
        case 20:
            Alamofire.download("https://httpbin.org/image/png").downloadProgress(closure: { (progress) in
                print("Download Progress: \(progress.fractionCompleted)")
            }).responseData(completionHandler: { (response) in
                if let data = response.result.value {
                    let image = UIImage(data: data)
                    self.showImageView.image = image
                }
            })
        case 21:
            let utilityQueue = DispatchQueue.global(qos: .utility)
            
            Alamofire.download("https://httpbin.org/image/png")
                .downloadProgress(queue: utilityQueue) { progress in
                    print("Download Progress: \(progress.fractionCompleted)")
                }
                .responseData { response in
                    if let data = response.result.value {
                        let image = UIImage(data: data)
                        self.showImageView.image = image
                    }
            }
        case 22:
            Alamofire.request("https://httpbin.org/get").responseJSON(completionHandler: { (response) in
                print(response.timeline)
            })
        case 23:
            Alamofire.request("https://httpbin.org/get").responseJSON(completionHandler: { (response) in
                if #available(iOS 10.0, *) {
                    print(response.metrics!)
                }
            })
        case 24:
            let request = Alamofire.request("https://httpbin.org/ip")
            print(request)
        case 25:
            let request = Alamofire.request("https://httpbin.org/get", parameters: ["foo" : "bar"])
            debugPrint(request)
        default:
            print("No way")
        }
    }
}

struct JSONStringArrayEncoding: ParameterEncoding {
    private let array: [String]
    
    init(array: [String]) {
        self.array = array
    }
    
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        
        let data = try JSONSerialization.data(withJSONObject: array, options: [])
        
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        urlRequest.httpBody = data
        
        return urlRequest
    }
}

