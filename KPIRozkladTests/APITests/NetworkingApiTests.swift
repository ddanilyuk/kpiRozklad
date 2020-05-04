//
//  KPIRozkladTests.swift
//  KPIRozkladTests
//
//  Created by Денис Данилюк on 28.04.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

@testable import KPI_Rozklad
import PromiseKit
import XCTest

class NetworkingApiTests: XCTestCase {
    var exp: XCTestExpectation!

    var API = NetworkingApiFacade(apiService: NetworkingApi())

    override func setUp() {
        exp = expectation(description: "Get and parse all JSONs")
    }

    override func tearDown() {
        exp = nil
    }

    func testNetworkingGroupsAPI() {
        API.getStudentLessons(forGroupWithId: 5489).done({ response in
            XCTAssertTrue(response.count > 0)
            self.exp.fulfill()
        }).catch({ error in
            XCTFail("Unable to parse: " + error.localizedDescription)
            self.exp.fulfill()
        })
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testNetworkingAllGroupsAPI() {
        API.getAllGroups().done({ response in
            XCTAssertTrue(response.count > 0)
            self.exp.fulfill()
        }).catch({ error in
            XCTFail("Unable to parse: " + error.localizedDescription)
            self.exp.fulfill()
        })
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testNetworkingAllTeachersAPI() {
        API.getAllTeachers().done({ response in
            XCTAssertTrue(response.count > 0)
            self.exp.fulfill()
        }).catch({ error in
            XCTFail("Unable to parse: " + error.localizedDescription)
            self.exp.fulfill()
        })
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testNetworkingTeachersOfGroupAPI() {
        API.getTeachersOfGroup(forGroupWithId: 5489).done({ response in
            XCTAssertTrue(response.count > 0)
            self.exp.fulfill()
        }).catch({ error in
            XCTFail("Unable to parse: " + error.localizedDescription)
            self.exp.fulfill()
        })
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testNetwork() {
        API.getTeacherLessons(forTeacherWithId: 294).done({ response in
            XCTAssertTrue(response.count > 0)
            self.exp.fulfill()
        }).catch({ error in
            XCTFail("Unable to parse: " + error.localizedDescription)
            self.exp.fulfill()
        })
        waitForExpectations(timeout: 10, handler: nil)
    }
}
