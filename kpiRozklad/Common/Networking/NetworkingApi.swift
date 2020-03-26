//
//  NetworkingApi.swift
//  testPresent
//
//  Created by Денис Данилюк on 22.03.2020.
//  Copyright © 2020 Денис Данилюк. All rights reserved.
//

import Foundation
import PromiseKit


// MARK: - API Service protocol

protocol APIService {
    
    func getStudentLessons(groupId: Int) -> Promise<ArrayDataResponse<Lesson>>
    
    func getTeacherLessons(teacherId: Int) -> Promise<ArrayDataResponse<Lesson>>
    
    func getTeachersOfGroup(groupId: Int) -> Promise<ArrayDataResponse<Teacher>>
    
    func getAllGroups() -> Promise<ArrayDataResponse<Group>>
    
    func getAllTeachers() -> Promise<ArrayDataResponse<Teacher>>
}


// MARK: - Common networking logic

class NetworkingApi {
    
    private enum NetworkingApiTarget {
        
        case getStudentLessons(groupId: Int)
        case getTeacherLessons(teacherId: Int)
        case getTeachersOfGroup(groupId: Int)
        case getAllGroups
        case getAllTeachers
        
    
        var url: URL {
            switch self {
               
            case .getStudentLessons(let groupId):
                return URL(string: "https://api.rozklad.org.ua/v2/groups/\(groupId)/lessons")!
            case .getTeacherLessons(let teacherId):
                return URL(string: "https://api.rozklad.org.ua/v2/teachers/\(teacherId)/lessons")!
            case .getTeachersOfGroup(let groupId):
                return URL(string: "https://api.rozklad.org.ua/v2/groups/\(groupId)/teachers")!
            case .getAllGroups:
                return URL(string: "https://api.rozklad.org.ua/v2/groups/?filter=%7B'showAll':true%7D")!
            case .getAllTeachers:
                return URL(string: "https://api.rozklad.org.ua/v2/teachers/?filter=%7B'showAll':true%7D")!
        
            }
        }
    }
    
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    
    private func executePromiseRequest<T: Decodable>(to target: NetworkingApiTarget) -> Promise<T> {
        
        return Promise(resolver: { (resolver) in
            session.dataTask(with: target.url, completionHandler: { [unowned self] (data, response, error) in
                if let error = error {
                    resolver.reject(error)
                } else if let data = data {
                    do {
                        let response = try self.decoder.decode(T.self, from: data)
                        resolver.fulfill(response)
                    } catch {
                        if let response = try? self.decoder.decode(ErrorMessageResponse.self, from: data) {
                            if response.message == "Group not found" {
                                resolver.reject(NetworkingApiError.groupNotFound)
                            } else if response.message == "Lessons not found"{
                                resolver.reject(NetworkingApiError.lessonsNotFound)
                            }
                        }
                        
                        print("Decoding error:", error)
                        print("Couldn't decode value from data:", String(data: data, encoding: .utf8) ?? "nil")
                        resolver.reject(error)
                    }
                } else {
                    resolver.reject(NetworkingApiError.noDataReturned)
                }
            }).resume()
        })
    }
    
}


// MARK: - Concrete APIService implementation

extension NetworkingApi: APIService {

    func getStudentLessons(groupId: Int) -> Promise<ArrayDataResponse<Lesson>> {
        return executePromiseRequest(to: .getStudentLessons(groupId: groupId))
    }
    
    func getAllGroups() -> Promise<ArrayDataResponse<Group>> {
        return executePromiseRequest(to: .getAllGroups)
    }
    
    func getAllTeachers() -> Promise<ArrayDataResponse<Teacher>> {
        return executePromiseRequest(to: .getAllTeachers)
    }
    
    func getTeacherLessons(teacherId: Int) -> Promise<ArrayDataResponse<Lesson>> {
        return executePromiseRequest(to: .getTeacherLessons(teacherId: teacherId))
    }
    
    func getTeachersOfGroup(groupId: Int) -> Promise<ArrayDataResponse<Teacher>> {
        return executePromiseRequest(to: .getTeachersOfGroup(groupId: groupId))
    }
        
}
