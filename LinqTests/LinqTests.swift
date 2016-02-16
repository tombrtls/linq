//
//  LinqTests.swift
//  LinqTests
//
//  Created by Tom Bartels on 06/02/16.
//  Copyright © 2016 IceMobile. All rights reserved.
//

import XCTest
@testable import Linq

public enum Function : Int {
    case iOSDeveloper
    case AndroidDeveloper
    case VisualDesigner
    case InteractionDesigner
    case Tester
    case ManagerOrSomething
}

public struct Company : Equatable {
    public var name : String!
    public var projects : [Project]!
}

public struct Project : Equatable {
    public var name : String!
    public var teamMembers : [Person]
    public var hasTeamMembers : Bool {
        get {
            return teamMembers.any()
        }
    }
}

public struct Person : Equatable {
    public var firstName : String!
    public var function : Function
}

public func ==(lhs: Company, rhs: Company) -> Bool {
    return lhs.name == rhs.name && lhs.projects == rhs.projects
}

public func ==(lhs: Project, rhs: Project) -> Bool {
    return lhs.name == rhs.name && lhs.teamMembers == rhs.teamMembers
}

public func ==(lhs: Person, rhs: Person) -> Bool {
    return lhs.firstName == rhs.firstName && lhs.function == rhs.function
}


public class LinqTests: XCTestCase {
    
    let data : [String] = ["luz", "bart", "rajayjay", "tom", "thomas", "thoma", "martijn"]
    var company : Company!
    
    
    public override func setUp() {
        company = self.generateTestCompany();
    }
}

// MARK: All
extension LinqTests {
    
    public func testAllMatchesWithAllElementsReturnTrue () {
        let result = data.all({ (element) in return true })
        XCTAssertTrue(result, "Not all the elements in data match")
    }
    
    public func testAllMatchesWithOneElementReturnTrue () {
        let result = data.all({ $0 == "John #1" })
        XCTAssertFalse(result, "All the elements in data match")
    }
    
    public func testAllMatchesWithNoElementReturnTrue () {
        let result = data.all({ (element) in return false })
        XCTAssertFalse(result, "All the elements in data match")
    }
}

// MARK: Any
extension LinqTests {
    
    public func testAnyMatchesWithAllElementsReturnTrue () {
        let result = data.any({ (element) in return true })
        XCTAssertTrue(result, "None of the elements in data match")
    }
    
    public func testAnyMatchesWithOneElementReturnTrue () {
        let result = data.any({ $0 == "luz" })
        XCTAssertTrue(result, "None of the elements in data match")
    }
    
    public func testAnyMatchesWithNoElementReturnTrue () {
        let result = data.any({ (element) in return false })
        XCTAssertFalse(result, "Some of the elements in data match")
    }
    
    public func testAnyWithFilledArray() {
        let result = data.any()
        XCTAssertTrue(result, "There are items in the list");
    }
    
    public func testAnyWithEmptyArray() {
        let result = [String]().any()
        XCTAssertFalse(result, "There are no items in the list")
    }
}

// MARK: None
extension LinqTests {
    
    public func testNoneMatchesWithAllElementsReturnTrue () {
        let result = data.none({ (element) in return true })
        XCTAssertFalse(result, "Some of the elements in data match")
    }
    
    public func testNoneyMatchesWithOneElementReturnTrue () {
        let result = data.none({ $0 == "luz" })
        XCTAssertFalse(result, "Some of the elements in data match")
    }
    
    public func testNoneMatchesWithNoElementReturnTrue () {
        let result = data.none({ (element) in return false })
        XCTAssertTrue(result)
    }
    
}

// MARK: Select and Where
extension LinqTests {
    public func testSelectingTeamMembers() {
        let listOfTeamMembers = company.projects.select({ $0.teamMembers })
        XCTAssertEqual(listOfTeamMembers.count, company.projects.count)
        for i in 0...listOfTeamMembers.count - 1 {
            XCTAssertEqual(listOfTeamMembers[i], company.projects[i].teamMembers)
        }
    }
    
    public func testSelectingTeamMembersAndConcatinating() {
        let listOfAllTeamMembers = company.projects.selectMany({ $0.teamMembers })
        XCTAssertNotNil(listOfAllTeamMembers)
        
        var allTeamMembers = [Person]()
        company.projects.forEach {
            allTeamMembers.appendContentsOf($0.teamMembers)
        }
        
        XCTAssertEqual(listOfAllTeamMembers.count, allTeamMembers.count)
        XCTAssertEqual(listOfAllTeamMembers, allTeamMembers)
    }
    
    public func testFilteringProjects() {
        let projects = company.projects.`where`({ $0.name == "Project 1" })
        XCTAssertEqual(projects.count, 1)
        XCTAssertEqual(projects[0], company.projects[0])
    }
    
    public func testFilteringAndSelecting() {
        var jumboTeamMembers = company.projects.`where`({ return $0.name == "Project 1" })
            .select({ $0.teamMembers })

        XCTAssertEqual(jumboTeamMembers.count, 1)
        XCTAssertEqual(jumboTeamMembers[0], company.projects[0].teamMembers)
    }
    
    public func testFindFirstProject() {
        let project = company.projects.first { $0.name == "Project 1"}
        XCTAssertNotNil(project)
        XCTAssertEqual(project, company.projects[0])
    }
    
    public func testFindLastProject() {
        
    }
    
    public func testFindNonExistingProject() {
        let project = company.projects.first { $0.name == "Unknown project"}
        XCTAssertNil(project)
    }
    
    public func testFilterProject1Project() {
        let projects = company.projects.except { $0.name == "Project 1" }
        XCTAssertEqual(projects.count, company.projects.count - 1)
        XCTAssertEqual(projects[0], company.projects[1])
    }
}

// MARK: Group By
extension LinqTests {
    
    public func testGroupTeamMembersByFunction() {
        let project = company.projects.first!
        let result = project.teamMembers.groupBy({ $0.function });
        XCTAssertEqual(result.count, 6)
        
        var total = 0
        for keyValue in result {
            total += keyValue.1.count
        }
        XCTAssertEqual(total, project.teamMembers.count)
        
        for teamMember in project.teamMembers {
            XCTAssertNotNil(result[teamMember.function])
            XCTAssertTrue(result[teamMember.function]!.contains(teamMember))
        }
    }
}

extension LinqTests {
    private func generateTestCompany() -> Company {
        var company = Company()
        company.projects = [generateProject(1), generateProject(2), generateProject(3)]
        company.name = "Company Name B.V."
        return company
    }
    
    private func generateProject(projectNumber : Int) -> Project {
        let numberOfTeamMembers = Int(arc4random_uniform(15) + 10)
        var teamMembers = [Person]()
        for i in 0...numberOfTeamMembers {
            teamMembers.append(Person(firstName: "John \(i)", function: Function(rawValue: i % 6)!))
        }
        
        return Project(name: "Project \(projectNumber)", teamMembers: teamMembers)
    }
}
