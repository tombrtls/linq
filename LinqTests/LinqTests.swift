//
//  LinqTests.swift
//  LinqTests
//
//  Created by Tom Bartels on 06/02/16.
//  Copyright © 2016 IceMobile. All rights reserved.
//

import XCTest
@testable import Linq

public enum Function {
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
        let listOfTeamMembers = company.projects.select({ $0.teamMembers });
        XCTAssertEqual(listOfTeamMembers.count, 2)
        XCTAssertEqual(listOfTeamMembers[0], company.projects[0].teamMembers)
        XCTAssertEqual(listOfTeamMembers[1], company.projects[1].teamMembers)
        
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
    }
    
    public func testFindNonExistingProject() {
        let project = company.projects.first { $0.name == "Project 3"}
        XCTAssertNil(project)
    }
    
    public func testFilterProject1Project() {
        let projects = company.projects.except { $0.name == "Project 1" }
        XCTAssertEqual(projects.count, 1)
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
        company.projects = [generateFirstProject(), generateSecondProject()]
        company.name = "Company Name B.V."
        return company
    }
    
    private func generateFirstProject() -> Project {
        return generateProjectWithName("Project 1", members: ["John #1": Function.InteractionDesigner,
            "John #2": Function.InteractionDesigner,
            "John #3": Function.InteractionDesigner,
            "John #4": Function.VisualDesigner,
            "John #5": Function.VisualDesigner,
            "John #6": Function.AndroidDeveloper,
            "John #7": Function.AndroidDeveloper,
            "John #8": Function.AndroidDeveloper,
            "John #9": Function.AndroidDeveloper,
            "John #10": Function.iOSDeveloper,
            "John #11": Function.iOSDeveloper,
            "John #12": Function.iOSDeveloper,
            "John #13": Function.iOSDeveloper,
            "John #14": Function.ManagerOrSomething,
            "John #15": Function.ManagerOrSomething,
            "John #16": Function.ManagerOrSomething,
            "John #17": Function.Tester,
            "John #18": Function.Tester,
            "John #19": Function.iOSDeveloper])
    }
    
    private func generateSecondProject() -> Project {
        return generateProjectWithName("Project 2", members: [
            "John #1": Function.InteractionDesigner,
            "John #2": Function.VisualDesigner,
            "John #3": Function.AndroidDeveloper,
            "John #4": Function.AndroidDeveloper,
            "John #5": Function.Tester,
            "John #6": Function.iOSDeveloper,
            "John #7": Function.iOSDeveloper,
            "John #8": Function.ManagerOrSomething,
            "John #9": Function.ManagerOrSomething])
    }
    
    private func generateProjectWithName(name : String, members : [String: Function]) -> Project {
        var people : [Person] = []
        members.forEach { (name, function) -> () in
            let person = Person(firstName: name, function: function)
            people.append(person)
        }
        return Project(name: name, teamMembers: people)
    }
}
