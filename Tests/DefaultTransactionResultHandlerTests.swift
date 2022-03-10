//
//  DefaultTransactionResultHandlerTests.swift
//  CodingExercise-Binance
//
//  Created by Shabeer Hussain on 10/03/2022.
//

import XCTest
@testable import CodingExercise_Binance

class DefaultTransactionResultHandlerTests: XCTestCase {
    
    func test_success_with_string() {
        let sut = DefaultTransactionResultHandler()
        let result = sut.handleResult(.success("transaction completed"))
        XCTAssertEqual(result, "transaction completed")
    }
    
    func test_success_no_string() {
        let sut = DefaultTransactionResultHandler()
        let result = sut.handleResult(.success(nil))
        XCTAssertNil(result)
    }
    
    func test_failure_invalidCommand() {
        let sut = DefaultTransactionResultHandler()
        let result = sut.handleResult(.failure(.invalidCommand))
        XCTAssertEqual(result, "Please enter a valid command")
    }
    
    func test_failure_noTransaction() {
        let sut = DefaultTransactionResultHandler()
        let result = sut.handleResult(.failure(.noTransaction))
        XCTAssertEqual(result, "no transaction")
    }
    
    func test_failure_keyNotSet() {
        let sut = DefaultTransactionResultHandler()
        let result = sut.handleResult(.failure(.keyNotSet))
        XCTAssertEqual(result, "key not set")
    }
    
    func test_failure_invalidKeyValue() {
        let sut = DefaultTransactionResultHandler()
        let result = sut.handleResult(.failure(.invalidKeyValue))
        XCTAssertEqual(result, "Please enter and KEY and VALUE")
    }
    
    func test_failure_invalidKey() {
        let sut = DefaultTransactionResultHandler()
        let result = sut.handleResult(.failure(.invalidKey))
        XCTAssertEqual(result, "Please enter a KEY")
    }
    
    func test_failure_invalidValue() {
        let sut = DefaultTransactionResultHandler()
        let result = sut.handleResult(.failure(.invalidValue))
        XCTAssertEqual(result, "Please enter a VALUE")
    }
}
