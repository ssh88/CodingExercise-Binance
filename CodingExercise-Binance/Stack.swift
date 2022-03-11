//
//  Stack.swift
//  CodingExercise-Binance
//
//  Created by Shabeer Hussain on 10/03/2022.
//

import Foundation

class Stack<T> {
    private var storage = [T]()
    
    func push(_ element: T) {
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
