//
//  Tests.swift
//  Tests
//
//  Created by Shabeer Hussain on 10/03/2022.
//

import XCTest
@testable import CodingExercise_Binance


class Tests: XCTestCase {
    
    func testExample()  {
        let sut = TransactionProgram()
        sut.set(key: "foo", value: "123")
        var result = sut.getValue(for: "foo")
        XCTAssertEqual("123", result)
        
        sut.beginTransaction()
        sut.set(key: "foo", value: "456")
        result = sut.getValue(for: "foo")
        XCTAssertEqual("456", result)
        
        sut.rollbackTransaction()
        result = sut.getValue(for: "foo")
        XCTAssertEqual("123", result)
        
        sut.beginTransaction()
        sut.set(key: "foo", value: "1000")
        result = sut.getValue(for: "foo")
        XCTAssertEqual("1000", result)
        sut.commitTransaction()
        result = sut.getValue(for: "foo")
        XCTAssertEqual("1000", result)
        
        sut.rollbackTransaction()
        result = sut.getValue(for: "foo")
        XCTAssertEqual("1000", result)
        
        sut.beginTransaction()
        sut.set(key: "foo", value: "2000")
        result = sut.getValue(for: "foo")
        XCTAssertEqual("2000", result)
        sut.rollbackTransaction()
        result = sut.getValue(for: "foo")
        XCTAssertEqual("1000", result)
    }

}
