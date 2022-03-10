//
//  Tests.swift
//  Tests
//
//  Created by Shabeer Hussain on 10/03/2022.
//

import XCTest
@testable import CodingExercise_Binance

class Tests: XCTestCase {
    
    // system under test
    var sut: TransactionManager!
    
    override func setUp() {
        super.setUp()
        sut = TransactionManager()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_set_get()  {
        var result = sut.getValue(for: "foo")
        XCTAssertEqual(result, "key not set")
        
        sut.set(key: "foo", value: "123")
        result = sut.getValue(for: "foo")
        XCTAssertEqual("123", result)
    }
    
    func test_delete() {
        sut.set(key: "foo", value: "123")
        var result = sut.getValue(for: "foo")
        XCTAssertEqual("123", result)
        
        sut.deleteKey("foo")
        result = sut.getValue(for: "foo")
        XCTAssertEqual("key not set", result)
    }
    
    func test_count() {
        sut.set(key: "foo", value: "123")
        sut.set(key: "bar", value: "456")
        sut.set(key: "baz", value: "123")
        
        var result = sut.count(value: "123")
        XCTAssertEqual(result, "2")
        
        result = sut.count(value: "456")
        XCTAssertEqual(result, "1")
    }
    
    func test_commit() {
        sut.beginTransaction()
        sut.set(key: "foo", value: "456")
        sut.commitTransaction()

        var result = sut.rollbackTransaction()
        XCTAssertEqual(result, "no transaction")

        result = sut.getValue(for: "foo")
        XCTAssertEqual(result, "456")
    }
    
    func test_rollback() {
        sut.set(key: "foo", value: "123")
        sut.set(key: "bar", value: "abc")
        sut.beginTransaction()
        sut.set(key: "foo", value: "456")
        
        var result = sut.getValue(for: "foo")
        XCTAssertEqual(result, "456")
        
        sut.set(key: "bar", value: "def")
        result = sut.getValue(for: "bar")
        XCTAssertEqual(result, "def")
        
        sut.rollbackTransaction()
        result = sut.getValue(for: "foo")
        XCTAssertEqual(result, "123")
        
        result = sut.getValue(for: "bar")
        XCTAssertEqual(result, "abc")
        
        result = sut.commitTransaction() ?? ""
        XCTAssertEqual(result, "no transaction")
    }
}
