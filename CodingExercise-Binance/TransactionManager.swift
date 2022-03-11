//
//  TransactionManager.swift
//  CodingExercise-Binance
//
//  Created by Shabeer Hussain on 10/03/2022.
//

import Foundation

typealias TransactionResult = Result<String?, TransactionError>

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
    }
    
    enum TransactionKey: String {
        case completed
        case valid
    }
    
    func processCommand(_ input: String? = nil,
                        with resultHandler: TransactionResultHandler = DefaultTransactionResultHandler()) {
        var result: TransactionResult = .success(nil)
        
        guard
            let transactionInput = transactionInput(from: input),
            !transactionInput.isEmpty else {
            if input == nil { processCommand() }
            return
        }
        
        let args = transactionInput.components(separatedBy: " ")
        guard let command = Command(rawValue: args[0]) else {
            result = .failure(.invalidCommand)
            resultHandler.handleResult(result)
            if input == nil { processCommand() }
            return
        }
        
        switch command {
        case .set:
            if args.count > 2 {
                set(key: args[1], value: args[2])
            } else {
                result = .failure(.invalidKeyValue)
            }
        case .get:
            if args.count > 1 {
                result = getValue(for: args[1])
            } else {
                result = .failure(.invalidKey)
            }
        case .delete:
            if args.count > 1 {
                result = deleteKey(args[1])
            } else {
                result = .failure(.invalidKey)
            }
        case .count:
            if args.count > 1 {
                result = count(value: args[1])
            } else {
                result = .failure(.invalidValue)
            }
        case .begin:
            beginTransaction()
        case .commit:
            result = commitTransaction()
        case .rollback:
            result = rollbackTransaction()
        case .help:
            result = printHelp()
        }
        
        resultHandler.handleResult(result)
        if input == nil { processCommand() }
    }
}
 
// MARK: - Transactions

extension TransactionManager {
    
    private func beginTransaction() {
        var new = Transaction()
        new[TransactionKey.valid.rawValue] = "1"
        transactions.push(new)
    }
    
    private func rollbackTransaction() -> TransactionResult {
        var temp = [Transaction]()
        
        let result: TransactionResult
        
        if let _ = transactionToRollback(temp: &temp) {
            // the last item in the stack should now be the one we want to rollback
            let _ = transactions.pop()
            result = .success(nil)
        } else {
            result = .failure(.noTransaction)
        }
        
        // finally add the completed transactions back
        for transaction in temp {
            transactions.push(transaction)
        }
        return result
    }
    
    /**
     Recursively traverse the stack to find a transaction that is not completed, so we can rollback
     */
    private func transactionToRollback(temp: inout [Transaction]) -> Transaction? {
        if let transaction = transactions.peek() {
            guard transaction[TransactionKey.completed.rawValue] == nil else {
                /*
                 if this transaction has already been completed,
                 we cant rollback so we temporarily pop it
                 */
                temp.append(transactions.pop()!)
                return transactionToRollback(temp: &temp)
            }
            return transaction
        }
        return nil
    }
    
    private func commitTransaction() -> TransactionResult {
        guard
            var transaction = transactions.pop(),
            let _ = transaction[TransactionKey.valid.rawValue]
        else {
            return .failure(.noTransaction)
        }
        transaction[TransactionKey.completed.rawValue] = "1"
        transactions.push(transaction)
        return .success(nil)
    }
}

// MARK: - Get /  Set / Del

extension TransactionManager {
    
    private func set(key: String, value: String) {
        var transaction = Transaction()
        if let current = transactions.pop() {
            transaction = current
        }
        transaction[key] = value
        transactions.push(transaction)
    }
    
    private func getValue(for key: String) -> TransactionResult {
        guard let value = transactions.peek()?[key] else {
            return .failure(.keyNotSet)
        }
        return .success(value)
    }
    
    private func deleteKey(_ key: String) -> TransactionResult {
        guard var transaction = transactions.pop() else {
            return .failure(.noTransaction)
        }
        transaction[key] = nil
        transactions.push(transaction)
        return .success(nil)
    }
}

// MARK: - Helper

extension TransactionManager {
    
    private func printHelp() -> TransactionResult {
        var helpOutput = "\n\n"
        helpOutput.append("================================================\n")
        helpOutput.append("SET <key> <value> // store the value for key\n")
        helpOutput.append("GET <key> // return the current value for key\n")
        helpOutput.append("DELETE <key> // remove the entry for key\n")
        helpOutput.append("COUNT <value> // return the number of keys that have the given value\n")
        helpOutput.append("BEGIN // start a new transaction\n")
        helpOutput.append("COMMIT // complete the current transaction\n")
        helpOutput.append("ROLLBACK // revert to state prior to BEGIN call\n")
        helpOutput.append("================================================\n\n")
        return .success(helpOutput)
    }
    
    private func count(value: String) -> TransactionResult {
        guard let transaction = transactions.peek() else { return .failure(.noTransaction) }
        let keys = transaction.keys
        var count = 0
        for key in keys {
            if transaction[key] == value {
                count += 1
            }
        }
        return .success("\(count)")
    }
    
    /**
     Checks if the input has been injected (unit tests) or needs to be taken from user
     */
    private func transactionInput(from input: String?) -> String? {
        if input == nil {
            return readLine()
        } else {
            return input
        }
    }
}
