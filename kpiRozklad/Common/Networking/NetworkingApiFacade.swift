//
//  NetworkingApiFacade.swift
//  testPresent
//
//  Created by Денис Данилюк on 22.03.2020.
//  Copyright © 2020 Денис Данилюк. All rights reserved.
//

import Foundation
import PromiseKit


struct NetworkingApiFacade {
    
    private let apiService: APIService
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    func getStudentLessons(forGroupWithId groupId: Int) -> Promise<[Lesson]> {
        return apiService.getStudentLessons(groupId: groupId).map({ (response) -> [Lesson] in
            return response.data
        })
    }
    
    func getTeacherLessons(forTeacherWithId teacherId: Int) -> Promise<[Lesson]> {
        return apiService.getTeacherLessons(teacherId: teacherId).map({ (response) -> [Lesson] in
            return response.data
        })
    }
    
    func getAllGroups() -> Promise<[Group]> {
        return apiService.getAllGroups().map({ (response) -> [Group] in
            return response.data
        })
    }
    
    func getAllTeachers() -> Promise<[Teacher]> {
        return apiService.getAllTeachers().map({ (response) -> [Teacher] in
            return response.data
        })
    }
    
    func getTeachersOfGroup(forGroupWithId groupId: Int) -> Promise<[Teacher]> {
        return apiService.getTeachersOfGroup(groupId: groupId).map({ (response) -> [Teacher] in
            return response.data
        })
    }
    
}
