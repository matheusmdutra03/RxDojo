//
//  APICore.swift
//  Events
//
//  Created by Matheus Dutra on 19/06/19.
//  Copyright © 2019 Matheus Dutra. All rights reserved.
//

import Foundation

protocol APIProvider: AnyObject {
    func request<T>(url: [CoreURL], httpMethod: HttpMethod, success: @escaping (T)->Void, failure: @escaping (Error) -> Void) where T : Decodable
}

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
    case put = "PUT"
}

enum HttpResponse {
    case success
    case error
}

enum CoreURL: String {
    case base = "http://5b840ba5db24a100142dcd8c.mockapi.io/api"
    case events = "/events"
}

final class APICore: APIProvider {
    
    func request<T>(url: [CoreURL], httpMethod: HttpMethod, success: @escaping (T)->Void, failure: @escaping (Error) -> Void) where T : Decodable {
        guard let request = makeRequest(
            url: url,
            method: httpMethod) else { return }
        
        #if DEBUG
        printRequestLog(request: request)
        #endif
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let response = response as? HTTPURLResponse else {
                failure(AppError.unknown)
                return
            }
            
            #if DEBUG
            self.printResponseLog(response: (data, response, error))
            #endif
            
            switch response.statusCode {
            case 400..<600:
                failure(AppError.unknown)
            default:
                guard let data = data else { return }
                
                do  {
                    let object = try JSONDecoder().decode(T.self, from: data)
                    success(object)
                } catch let jsonError {
                    #if DEBUG
                    failure(jsonError)
                    #else
                    failure(AppError.unknown)
                    #endif
                }
            }
            }
            .resume()
    }
    
    private func makeRequest(url: [CoreURL], method: HttpMethod) -> URLRequest? {
        let currentUrl = url.reduce("") { $0 + $1.rawValue }
        guard let `url` = URL(string: currentUrl) else { return nil}
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = method.rawValue
        return request
    }
    
    private func printRequestLog(request: URLRequest) {
        
        print("\n========== REQUEST BEGIN ==========")
        print("URL: \(request.url?.absoluteString ?? "-")")
        print("Method: \(request.httpMethod ?? "-")")
        if let body = request.httpBody {
            print("Body:\n\(String(data: body, encoding: .utf8) ?? "body data to string conversion failed")")
        }
        print("========== REQUEST END ==========\n")
    }
    
    private func printResponseLog(response: (Data?, URLResponse?, Error?)) {
        
        guard let httpResponse = response.1 as? HTTPURLResponse else {
            print("\nNO RESPONSE!!!!")
            return
        }
        
        print("\n========== RESPONSE BEGIN ==========")
        print("CODE: \(httpResponse.statusCode)")
        print("URL: \(response.1?.url?.absoluteString ?? "-")")
        print("Error:\n\(response.2?.localizedDescription ?? "-")")
        
        var debugData: String?
        if let data = response.0 {
            debugData = String(data: data, encoding: .utf8)
        }
        print("Body:\n" + (debugData ?? "-"))
        print("========== RESPONSE END ==========\n")
    }
}
