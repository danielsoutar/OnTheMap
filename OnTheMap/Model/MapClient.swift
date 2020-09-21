//
//  MapClient.swift
//  OnTheMap
//
//  Created by Daniel Soutar on 13/09/2020.
//  Copyright © 2020 Daniel Soutar. All rights reserved.
//

import Foundation

class MapClient {
    
    // TODO: Figure out how to improve on this as best as you reasonably can.
    private static let apiKey = "" // "173d8f390a237e0ed6cec5855d2e5474"
    
    // No Auth struct, since there is zero usage of it in subsequent network calls.
    // Only username and password are sent in raw text... brilliant.
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case postSession
        case deleteSession
        case getLocations(String, String, String, String)
        case getUserInfo
        case createLocation
        case updateLocation(String)

        var stringValue: String {
            switch self {
            case .postSession: return Endpoints.base + "/session"
            case .deleteSession: return Endpoints.base + "/session"
            case .getLocations(let limit, let skip, let order, let key):
                return Endpoints.base + "/StudentLocation" + limit + skip + order + key
            case .getUserInfo: return Endpoints.base + "/users/\(LocationModel.currentUserAccount!.key)"
            case .createLocation: return Endpoints.base + "/StudentLocation"
            case .updateLocation(let objectID): return Endpoints.base + "/StudentLocation/\(objectID)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }

    // Note that we always call the completion handler on the main thread, meaning async blocks
    // can be hoisted out of the corresponding view controller.
    class func taskForGETRequest<ResponseType: Decodable>(url: URL,
                responseType: ResponseType.Type, shouldPreprocess: Bool,
                completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        // No special characters at the beginning for some get requests, but the
        // user info request does, so have a default flag to enable the skipping.
        let preprocess = { (data: Data) -> Data in return data.subdata(in: 5..<data.count) }

        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, requestError in
            guard let data = data, requestError == nil else {
                DispatchQueue.main.async {
                    completion(nil, requestError)
                }
                return
            }
            let preprocessedData = shouldPreprocess ? preprocess(data) : data
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(responseType.self,
                                                        from: preprocessedData)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        return task
    }
    
    class func loadRecentLocations(count: Int, completionHandler: @escaping ([StudentInformation]?, Error?) -> Void) {
        let task = taskForGETRequest(url: Endpoints.getLocations("?limit=\(count)", "", "&order=-updatedAt", "").url,
                                     responseType: StudentInformationResults.self,
                                     shouldPreprocess: false) {
                                        (response, error) in
                                        if let response = response {
                                            completionHandler(response.results, nil)
                                        } else {
                                            print("Invalid response: error is nil = \(error == nil)")
                                            completionHandler([], error)
                                        }
        }
        task.resume()
    }
    
    class func loadUserLocation(key: String, completionHandler: @escaping (StudentInformation?, Error?) -> Void) {
        let task = taskForGETRequest(url: Endpoints.getLocations("", "", "", "?uniqueKey=\(key)").url,
                                     responseType: StudentInformationResults.self,
                                     shouldPreprocess: false) {
                                        (response, error) in
                                        if let response = response {
                                            completionHandler(response.results[0], nil)
                                        } else {
                                            print("Invalid response: error is nil = \(error == nil)")
                                            completionHandler(nil, error)
                                        }
        }
        task.resume()
    }
    
    class func taskForUdacityRequest<ResponseType: Decodable>(
        urlRequest: URLRequest, responseType: ResponseType.Type, shouldPreprocess: Bool,
        completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        let preprocess = { (data: Data) -> Data in return data.subdata(in: 5..<data.count) }

        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { data, response, error in
            guard let data = data else {
                // Add a async method in case the completion handler somehow involves the UI
                // (Unlikely for a POST request but not impossible)
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let preprocessedData = shouldPreprocess ? preprocess(data) : data
                let responseObject = try decoder.decode(ResponseType.self, from: preprocessedData)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        return task
    }

    class func initialiseSession(_ username: String, password: String,
                                 completion: @escaping (Bool, Error?) -> Void) {
        // Set up the post request
        var urlRequest = URLRequest(url: Endpoints.postSession.url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // This is really ugly, although I'm not sure if this encoding issue
        // can be circumvented in the Codable structs somehow.
        urlRequest.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: .utf8)

        let task = taskForUdacityRequest(urlRequest: urlRequest,
                                         responseType: MapAuthResponse.self, shouldPreprocess: true) {
            (response, error) -> Void in
            if let response = response {
                LocationModel.currentUserAccount = response.account
                print("Current user key: \(LocationModel.currentUserAccount!.key)")
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
        task.resume()
    }
    
    class func getUserData(completion: @escaping (Bool, Error?) -> Void) {
        let task = taskForGETRequest(url: Endpoints.getUserInfo.url,
                                     responseType: UserInformation.self,
                                     shouldPreprocess: true) {
            (response, error) in
            if let response = response {
                LocationModel.currentUserInformation = response
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
        task.resume()
    }

    class func deleteSession(completion: @escaping (Bool, Error?) -> Void) {
        // Configure the request
        var urlRequest = URLRequest(url: Endpoints.deleteSession.url)
        urlRequest.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
          if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
          urlRequest.setValue(xsrfCookie.value,
                              forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = taskForUdacityRequest(urlRequest: urlRequest,
                                         responseType: MapDeauthResponse.self,
                                         shouldPreprocess: true) {
            (response, error) -> Void in
            if response != nil {
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
        task.resume()
    }
    
    class func createNewUserLocation(with newLatitude: Double, newLongitude: Double,
                                     locationString: String, newMediaURL: String,
                                     completion: @escaping (Bool, Error?) -> Void) -> URLSessionTask {
        var urlRequest = URLRequest(url: Endpoints.createLocation.url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let key = LocationModel.currentUserAccount!.key
        let payload = MapUpdateLocationRequest(uniqueKey: key,
                                               firstName: LocationModel.currentUserInformation!.firstName,
                                               lastName: LocationModel.currentUserInformation!.lastName,
                                               mapString: locationString,
                                               mediaURL: newMediaURL,
                                               latitude: newLatitude,
                                               longitude: newLongitude)
        urlRequest.httpBody = try! JSONEncoder().encode(payload)
        return taskForUdacityRequest(urlRequest: urlRequest,
                                     responseType: MapCreateLocationResponse.self,
                                     shouldPreprocess: false) {
            (response, error) -> Void in
            if response != nil {
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    class func updateUserLocation(with newLatitude: Double, newLongitude: Double,
                                  locationString: String, newMediaURL: String,
                                  completion: @escaping (Bool, Error?) -> Void) -> URLSessionTask {
        var urlRequest = URLRequest(url: Endpoints.updateLocation(LocationModel.currentUserLocation!.objectId).url)
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let user = LocationModel.currentUserLocation
        let payload = MapUpdateLocationRequest(uniqueKey: user!.uniqueKey,
                                               firstName: "Daniel",
                                               lastName: "Powter",
                                               mapString: locationString,
                                               mediaURL: newMediaURL,
                                               latitude: newLatitude,
                                               longitude: newLongitude)
        urlRequest.httpBody = try! JSONEncoder().encode(payload)
        return taskForUdacityRequest(urlRequest: urlRequest,
                                     responseType: MapCreateLocationResponse.self,
                                     shouldPreprocess: false) {
            (response, error) -> Void in
            if response != nil {
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    class func addOrUpdateWithLocation(with newLatitude: Double, newLongitude: Double,
                                       locationString: String, newMediaURL: String,
                                       completion: @escaping (Bool, Error?) -> Void) {
        // Check if user has any prior locations in the location model...
        let hasPriorLocationInModel = LocationModel.currentUserLocationKnown
        var task: URLSessionTask?
        // If so, update.
        if hasPriorLocationInModel {
            task = updateUserLocation(with: newLatitude, newLongitude: newLongitude,
                                      locationString: locationString, newMediaURL: newMediaURL,
                                      completion: completion)
        // Otherwise, try to add.
        } else {
            task = createNewUserLocation(with: newLatitude, newLongitude: newLongitude,
                                         locationString: locationString, newMediaURL: newMediaURL,
                                         completion: completion)
        }
        task!.resume()
        // Location will now be known - the latest one added.
        LocationModel.currentUserLocationKnown = true
    }
}
