//
//  main.swift
//  Binance
//
//  Created by Shabeer Hussain on 08/03/2022.
//

import Foundation

class Stack<T> {
    private var storage = [T]()
    
    func append(_ element: T) {
        storage.append(element)
    }
    
    func pop() -> T? {
        guard storage.count > 0 else { return nil }
        let last = storage.popLast()
        return last
    }
    
    func peek() -> T? {
        guard storage.count > 0 else { return nil }
        let last = storage[storage.count - 1]
        return last
    }
}

typealias Transaction = [String: String]
var transactions = Stack<Transaction>()


struct TransactionProgram {
    
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
            count(value: args[1])
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

extension TransactionProgram {
    
    func beginTransaction() {
        let new = Transaction()
        transactions.append(new)
    }
    
    func rollbackTransaction() {
        var temp = [Transaction]()
        var canRollBack = false
        
        while canRollBack == false {
            // find transaction that we can rollback
            if let transaction = transactions.peek() {
                if transaction["completed"] == "1" {
                    // if a transaction is completed, we cant roll this back so we temporarily pop it
                    temp.append(transactions.pop()!)
                } else {
                    canRollBack = true
                }
            }
        }
        
        if canRollBack {
            // the last item in the stack should be the one we want to rollback
            let _ = transactions.pop()
        } else {
            print("no transaction")
        }
        
        // finally add the completed transactions back
        for transaction in temp {
            transactions.append(transaction)
        }
    }
    
    func commitTransaction() {
        guard var transaction = transactions.pop() else { return }
        transaction["completed"] = "1"
        transactions.append(transaction)
    }
}

// MARK: - Get /  Set / Del

extension TransactionProgram {
    
    func set(key: String, value: String) {
        var transaction = Transaction()
        if let current = transactions.pop() {
            transaction = current
        }
        transaction[key] = value
        transactions.append(transaction)
    }
    
    func getValue(for key: String) {
        guard let value = transactions.peek()?[key] else {
            print("key not set")
            return
        }
        print(value)
    }
    
    func deleteKey(_ key: String) {
        guard var transaction = transactions.pop() else { return }
        transaction[key] = nil
        transactions.append(transaction)
    }
}

// MARK: - Helper

extension TransactionProgram {
    
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
    
    func count(value: String) {
        guard let transaction = transactions.peek() else { return }
        let keys = transaction.keys
        var count = 0
        for key in keys {
            if transaction[key] == value {
                count += 1
            }
        }
        print("\(count)")
    }
}

print("Start a transaction by using the 'BEGIN' command")
print("use 'help' for a list of commands")
print("----------------------------------------")
print("")
print("")
TransactionProgram().getUserInput()


