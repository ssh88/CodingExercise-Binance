//
//  TransactionError.swift
//  CodingExercise-Binance
//
//  Created by Shabeer Hussain on 10/03/2022.
//

import Foundation

enum TransactionError: Error, LocalizedError {
    case invalidCommand
    case invalidKeyValue
    case invalidKey
    case invalidValue
    case noTransaction
    case keyNotSet
    
    var errorDescription: String? {
        switch self {
        case .invalidCommand:
            return "Please enter a valid command"
        case .invalidKeyValue:
            return "Please enter and KEY and VALUE"
        case .invalidKey:
            return "Please enter a KEY"
        case .invalidValue:
            return "Please enter a VALUE"
        case .noTransaction:
            return "no transaction"
        case .keyNotSet:
            return "key not set"
        }
    }
}
