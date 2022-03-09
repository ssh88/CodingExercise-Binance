//
//  main.swift
//  Binance
//
//  Created by Shabeer Hussain on 08/03/2022.
//

import Foundation

var store = [String: String]()

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

func runLoop() {
    guard let args = readLine()?.components(separatedBy: " ") else {
        print("Please enter a command")
        runLoop()
        return
    }
    
    if args[0] == "exit" { exit(1) }
    
    let rawCommand = args[0]
 
    guard let command = Command(rawValue: rawCommand) else {
        print("Unrecognised command, please try again")
        runLoop()
        return
    }
    
    switch command {
    case .set:
        set(key: args[1], value: args[2])
    case .get:
        getValue(for: args[1])
    case .delete:
        deleteKey(args[1])
    case .count:
        count(value: args[1])
    case .begin:
        break
    case .commit:
        commit()
    case .rollback:
        break
    case .help:
        printHelp()
    }
    
    runLoop()
}

func printHelp() {
    print("SET <key> <value> // store the value for key")
    print("GET <key> // return the current value for key")
    print("DELETE <key> // remove the entry for key")
    print("COUNT <value> // return the number of keys that have the given value")
    print("BEGIN // start a new transaction")
    print("COMMIT // complete the current transaction")
    print("ROLLBACK // revert to state prior to BEGIN call")
}

func set(key: String, value: String) {
    store[key] = value
}

func getValue(for key: String) {
    guard let value = store[key] else {
        print("key not set")
        return
    }
    print(value)
}

func deleteKey(_ key: String) {
    store[key] = nil
}

func commit() {
//        print("no transaction")
}

func count(value: String) {
    let keys = store.keys
    var count = 0
    for key in keys {
        if store[key] == value {
            count += 1
        }
    }
    print("\(count)")
}

print("Please start a transaction by using the BEGIN command")
print("use 'help' for a list of commands")
runLoop()

