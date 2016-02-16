//
//  Linq.swift
//  Linq
//
//  Created by Tom Bartels on 06/02/16.
//  Copyright © 2016 IceMobile. All rights reserved.
//

import Foundation

import Foundation

extension SequenceType {
    
    @warn_unused_result
    public func all(@noescape predicate: (Self.Generator.Element) throws -> Bool) rethrows -> Bool {
        return try self.none({ (element) -> Bool in
            return try !predicate(element)
        })
    }

    public func any() -> Bool {
        return self.any({ _ in return true })
    }
    
    @warn_unused_result
    public func any(@noescape predicate: (Self.Generator.Element) throws -> Bool) rethrows -> Bool {
        return try self.filter(predicate).count > 0
    }
    
    @warn_unused_result
    public func none(@noescape predicate: (Self.Generator.Element) throws -> Bool) rethrows -> Bool {
        return try self.filter(predicate).count == 0
    }

    @warn_unused_result
    public func ofType<T>(type : AnyClass) throws -> [T] {
        return try self.filter({ return $0 is T }).cast(type)
    }
    
    @warn_unused_result
    public func cast<T>(type : AnyClass) throws -> [T] {
        return self.map({ $0 as! T })
    }
    
    @warn_unused_result
    public func select<T>(@noescape query: (Self.Generator.Element) throws -> T) rethrows -> [T] {
        return try self.map(query)
    }
    
    @warn_unused_result
    public func `where`(@noescape predicate: (Self.Generator.Element) throws -> Bool) rethrows -> [Self.Generator.Element] {
        return try self.filter(predicate);
    }
    
    @warn_unused_result
    public func except(@noescape predicate: (Self.Generator.Element) throws -> Bool) rethrows -> [Self.Generator.Element] {
        return try self.filter({ return try !predicate($0) })
    }
    
    @warn_unused_result
    public func first(@noescape query: (Self.Generator.Element) throws -> Bool) rethrows -> Self.Generator.Element? {
        for element in self {
            if try query(element) == true {
                return element;
            }
        }
        
        return nil
    }
    
    @warn_unused_result
    public func last(@noescape query: (Self.Generator.Element) throws -> Bool) rethrows -> Self.Generator.Element? {
        return try self.reverse().first(query)
    }
    
    @warn_unused_result
    public func sortDesc(@noescape compare: (Self.Generator.Element, Self.Generator.Element) -> Bool) -> [Self.Generator.Element] {
        return sort { compare($1, $0) }
    }
    
    
    
    @warn_unused_result
    public func groupBy<T>(@noescape query : (Self.Generator.Element) throws -> T) rethrows -> [T: [Self.Generator.Element]] {
        var result : [T: [Self.Generator.Element]] = [:]
        
        try self.forEach { (element) -> () in
            let key = try query(element)
            var values = result[key] ?? []
            values.append(element)
            result[key] = values
        }
        
        return result
    }
}