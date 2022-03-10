//
//  TransactionManagerTests.swift
//  CodingExercise-Binance
//
//  Created by Shabeer Hussain on 10/03/2022.
//

import XCTest
@testable import CodingExercise_Binance

class Tests: XCTestCase {
    
    // system under test
    var sut: TransactionManager!
    var resultHandler: MockTransactionResultHandler!
    
    override func setUp() {
        super.setUp()
        sut = TransactionManager()
        resultHandler = MockTransactionResultHandler()
    }
    
    override func tearDown() {
        sut = nil
        resultHandler = nil
        super.tearDown()
    }
    
    func test_invalidCommand() {
        sut.processCommand("PATCH foo", with: resultHandler)
        let result = resultHandler.transactionResult
        XCTAssertEqual(result, .failure(.invalidCommand))
    }
    
    func test_set_incorrecNumberOfArgs() {
        let resultHandler = MockTransactionResultHandler()
        sut.processCommand("SET foo", with: resultHandler)
        let result = resultHandler.transactionResult
        XCTAssertEqual(result, .failure(.invalidKeyValue))
    }

    func test_set_get()  {
        sut.processCommand("GET foo", with: resultHandler)
        var result = resultHandler.transactionResult
        XCTAssertEqual(result, .failure(.keyNotSet))
        
        sut.processCommand("SET foo 123")
        sut.processCommand("GET foo", with: resultHandler)
        result = resultHandler.transactionResult
        XCTAssertEqual(result, .success("123"))
    }
    
    func test_get_noKey()  {
        sut.processCommand("GET", with: resultHandler)
        let result = resultHandler.transactionResult
        XCTAssertEqual(result, .failure(.invalidKey))
    }
    
    func test_delete() {
        sut.processCommand("SET foo 123")
        var result = resultHandler.transactionResult
        sut.processCommand("DELETE foo")
        sut.processCommand("GET foo", with: resultHandler)
        result = resultHandler.transactionResult
        XCTAssertEqual(result, .failure(.keyNotSet))
    }
    
    func test_delete_noTransaction() {
        sut.processCommand("DELETE foo", with: resultHandler)
        let result = resultHandler.transactionResult
        XCTAssertEqual(result, .failure(.noTransaction))
    }
    
    func test_delete_noKey() {
        sut.processCommand("DELETE", with: resultHandler)
        let result = resultHandler.transactionResult
        XCTAssertEqual(result, .failure(.invalidKey))
    }
    
    func test_count() {
        sut.processCommand("SET foo 123")
        sut.processCommand("SET bar 456")
        sut.processCommand("SET baz 123")

        sut.processCommand("COUNT 123", with: resultHandler)
        var result = resultHandler.transactionResult
        XCTAssertEqual(result, .success("2"))

        sut.processCommand("COUNT 456", with: resultHandler)
        result = resultHandler.transactionResult
        XCTAssertEqual(result, .success("1"))
    }
    
    func test_count_noTransaction() {
        sut.processCommand("COUNT 123", with: resultHandler)
        let result = resultHandler.transactionResult
        XCTAssertEqual(result, .failure(.noTransaction))
    }
    
    func test_count_noValue() {
        sut.processCommand("COUNT", with: resultHandler)
        let result = resultHandler.transactionResult
        XCTAssertEqual(result, .failure(.invalidValue))
    }
    
    func test_commit() {
        sut.processCommand("BEGIN")
        sut.processCommand("SET foo 456")
        sut.processCommand("COMMIT")
        sut.processCommand("ROLLBACK", with: resultHandler)
        var result = resultHandler.transactionResult
        XCTAssertEqual(result, .failure(.noTransaction))

        sut.processCommand("GET foo", with: resultHandler)
        result = resultHandler.transactionResult
        XCTAssertEqual(result, .success("456"))
    }
    
    func test_rollback() {
        sut.processCommand("SET foo 123")
        sut.processCommand("SET bar abc")
        
        sut.processCommand("BEGIN")
        sut.processCommand("SET foo 456")
        
        sut.processCommand("GET foo", with: resultHandler)
        var result = resultHandler.transactionResult
        XCTAssertEqual(result, .success("456"))
        
        sut.processCommand("SET bar def")
        sut.processCommand("GET bar", with: resultHandler)
        result = resultHandler.transactionResult
        XCTAssertEqual(result, .success("def"))
        
        sut.processCommand("ROLLBACK")
        sut.processCommand("GET foo", with: resultHandler)
        result = resultHandler.transactionResult
        XCTAssertEqual(result, .success("123"))
        
        sut.processCommand("GET bar", with: resultHandler)
        result = resultHandler.transactionResult
        XCTAssertEqual(result, .success("abc"))
        
        sut.processCommand("COMMIT", with: resultHandler)
        result = resultHandler.transactionResult
        XCTAssertEqual(result, .failure(.noTransaction))
    }
    
    func test_help() {
        sut.processCommand("help", with: resultHandler)
        switch resultHandler.transactionResult {
        case .success(let output):
            XCTAssertTrue(output!.contains("SET <key> <value> // store the value for key"))
            XCTAssertTrue(output!.contains("GET <key> // return the current value for key"))
            XCTAssertTrue(output!.contains("DELETE <key> // remove the entry for key"))
            XCTAssertTrue(output!.contains("COUNT <value> // return the number of keys that have the given value"))
            XCTAssertTrue(output!.contains("BEGIN // start a new transaction"))
            XCTAssertTrue(output!.contains("COMMIT // complete the current transaction"))
            XCTAssertTrue(output!.contains("ROLLBACK // revert to state prior to BEGIN call"))
        default:
            XCTFail()
        }
    }
}
