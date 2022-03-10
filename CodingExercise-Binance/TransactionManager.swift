//
//  TransactionManager.swift
//  CodingExercise-Binance
//
//  Created by Shabeer Hussain on 10/03/2022.
//

import Foundation

public struct TransactionManager {
    typealias Transaction = [String: String]
    var transactions = Stack<Transaction>()
    
    enum Command: String {
        case set = "SET"
        case get = "GET"
        case delete = "DELETE"
        case count = "COUNT"
        case begin = "BEGIN"
        case commit = "COMMIT"
        case rollback = "ROLLBACK"
        case help = "help"
        case exit = "exit"
    }
    
    enum TransactionKey: String {
        case completed
        case valid
    }
    
    func getUserInput() {
        guard let args = readLine()?.components(separatedBy: " ") else {
            print("Please enter a command")
            getUserInput()
            return
        }
        
        guard let command = Command(rawValue: args[0]) else {
            print("Unrecognised command, please try again")
            getUserInput()
            return
        }
        
        switch command {
        case .set:
            if args.count > 2 {
                set(key: args[1], value: args[2])
            } else {
                print("Please enter and KEY and VALUE")
            }
        case .get:
            getValue(for: args[1])
        case .delete:
            deleteKey(args[1])
        case .count:
            if let count = count(value: args[1]) {
                print(count)
            }
        case .begin:
            beginTransaction()
        case .commit:
            commitTransaction()
        case .rollback:
            rollbackTransaction()
        case .help:
            printHelp()
        case .exit:
            exit(1)
        }
        
        // recursively call getUserInput for next command
        getUserInput()
    }
}
 
// MARK: - Transactions

extension TransactionManager {
    
    func beginTransaction() {
        var new = Transaction()
        new[TransactionKey.valid.rawValue] = "1"
        transactions.append(new)
    }
    @discardableResult
    func rollbackTransaction() -> String? {
        var temp = [Transaction]()
        
        var errorMessage: String? = nil
        if let _ = transactionToRollback(temp: &temp)        {
            // the last item in the stack should be the one we want to rollback
            let _ = transactions.pop()
        } else {
            errorMessage = "no transaction"
            print(errorMessage!)
        }
        
        // finally add the completed transactions back
        for transaction in temp {
            transactions.append(transaction)
        }
        return errorMessage
    }
    
    /**
     Recursively traverse the stack to find a transaction that is not completed, so we can rollback
     */
    func transactionToRollback(temp: inout [Transaction]) -> Transaction? {
        if let transaction = transactions.peek() {
            guard transaction[TransactionKey.completed.rawValue] == nil else {
                temp.append(transactions.pop()!)
                return transactionToRollback(temp: &temp)
            }
            return transaction
        } else {
            return nil
        }
    }
    
    @discardableResult
    func commitTransaction() -> String? {
        guard
            var transaction = transactions.pop(),
            let _ = transaction[TransactionKey.valid.rawValue]
        else {
            let errorMessage = "no transaction"
            print(errorMessage)
            return errorMessage
        }
        transaction[TransactionKey.completed.rawValue] = "1"
        transactions.append(transaction)
        return nil
    }
}

// MARK: - Get /  Set / Del

extension TransactionManager {
    
    func set(key: String, value: String) {
        var transaction = Transaction()
        if let current = transactions.pop() {
            transaction = current
        }
        transaction[key] = value
        transactions.append(transaction)
    }
    
    @discardableResult
    func getValue(for key: String) -> String {
        guard let value = transactions.peek()?[key] else {
            let errorMessage = "key not set"
            print(errorMessage)
            return errorMessage
        }
        print(value)
        return value
    }
    
    func deleteKey(_ key: String) {
        guard var transaction = transactions.pop() else { return }
        transaction[key] = nil
        transactions.append(transaction)
    }
}

// MARK: - Helper

extension TransactionManager {
    
    func printHelp() {
        print("")
        print("")
        print("================================================")
        print("SET <key> <value> // store the value for key")
        print("GET <key> // return the current value for key")
        print("DELETE <key> // remove the entry for key")
        print("COUNT <value> // return the number of keys that have the given value")
        print("BEGIN // start a new transaction")
        print("COMMIT // complete the current transaction")
        print("ROLLBACK // revert to state prior to BEGIN call")
        print("--------")
        print("help // print list of commands")
        print("exit // terminates the program")
        print("================================================")
        print("")
        print("")
    }
    
    func count(value: String) -> String? {
        guard let transaction = transactions.peek() else { return nil }
        let keys = transaction.keys
        var count = 0
        for key in keys {
            if transaction[key] == value {
                count += 1
            }
        }
        return "\(count)"
    }
}
