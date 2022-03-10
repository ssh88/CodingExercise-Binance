//
//  MockTransactionResultHandler.swift
//  CodingExercise-Binance
//
//  Created by Shabeer Hussain on 10/03/2022.
//

import Foundation

class MockTransactionResultHandler: TransactionResultHandler {
    var transactionResult: TransactionResult?
    func handleResult(_ result: TransactionResult) -> String? {
        transactionResult = result
        return nil
    }
}
