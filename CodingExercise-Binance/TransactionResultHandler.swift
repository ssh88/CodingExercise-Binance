//
//  DefaultTransactionResultHandler.swift
//  CodingExercise-Binance
//
//  Created by Shabeer Hussain on 10/03/2022.
//

import Foundation

protocol TransactionResultHandler {
    @discardableResult
    func handleResult(_ result: TransactionResult) -> String?
}

struct DefaultTransactionResultHandler: TransactionResultHandler {
    /**
     Prints the result to console if need be
     */
    @discardableResult
    func handleResult(_ result: TransactionResult) -> String? {
        switch result {
        case .success(let message):
            if let message = message {
                print(message)
                return message
            }
        case.failure(let error):
            print(error.localizedDescription)
            return error.localizedDescription
        }
        return nil
    }
}
