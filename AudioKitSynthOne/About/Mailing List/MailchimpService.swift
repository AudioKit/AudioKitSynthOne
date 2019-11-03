//
//  MailchimpService.swift
//  AudioKitSynthOne
//
//  Created by Matthias Frick on 31/10/2019.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import AudioKit
import Foundation

struct MailChimpUser {
    public var listId: String
    public var email_address: String
    public let status = "subscribed"
}

class MailChimp {
    public static let shared = MailChimp()
    public var apiKey: String = "" {
        didSet {
          let listNumber = apiKey.split(separator: "-")
          baseUrl = "https://\(listNumber[1]).api.mailchimp.com/3.0"
        }
    }
    typealias ChimpCallback = (Data?, URLResponse?, Error?) -> ()
    var baseUrl: String = "https://us15.api.mailchimp.com/3.0"

    public func addSubscriber(user: MailChimpUser, completionHandler: ChimpCallback?) {
        // prepare json data
        let parameters: [String: Any] = [
            "email_address": user.email_address,
            "status": user.status,
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)

        // create post request
        let url = "\(baseUrl)/lists/\(user.listId)/members"

        guard let requestUrl = URL(string: url) else { return }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue("Basic \(createBase64LoginString())", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                completionHandler?(nil, response, error)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                if (responseJSON["title"] as? String == "Member Exists") {
                    AKLog("Need to resubscribe")
                    self.resubscribe(user: user) { (data, response, error) in
                        completionHandler?(data, response, error)
                    }
              }
            }
        }
        task.resume()
    }

    public func resubscribe(user: MailChimpUser, completionHandler: ChimpCallback?) {
        // If a user previously unsubscribed, we will send him an opt-in instead
        // to avoid that others forcefully sign up third-parties
        let parameters: [String: Any] = [
            "status": "pending",
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)

        guard let userEndpoint = user.email_address.lowercased().hashed(.md5) else {
            return
        }
        let url = "\(baseUrl)/lists/\(user.listId)/members/\(userEndpoint)"

        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PUT"
        request.setValue("Basic \(createBase64LoginString())", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            completionHandler?(data, response, error)
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
        }
        task.resume()
    }

    // Helpers

    private func createBase64LoginString() -> String {
        let loginString = String(format: ":%@", apiKey)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        return base64LoginString
    }
}
