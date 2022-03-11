# Binance Coding Exercise

## Overview

The solution to the coding task was created using Xcode's Command Line project template. This enabled me to create a simple Swift script and executable to run the program in the Command-Line.

## Usuage
You can use the program either in the Command-Line or Xcode.

### Command Line

To use via Command Line, open up your command line app, navigate to the root directory of the project and either run `.\binance` or open up the `binance` shell.

<img width="500" alt="Screenshot 2022-03-11 at 00 04 00" src="https://user-images.githubusercontent.com/3674185/157776093-e2f66d65-7d10-4291-8470-870e7be88f1b.png">

### Xcode

To use inside Xcode, navigate to the root directory of the project:

- open the CodingExercise-Binance.xcodeproj project file  
- Select the Binance scheme  
- Select your Mac as your device  
- Hit Run!  

You can now interact with the program in the Xcode console.

<img width="500" alt="Screenshot 2022-03-10 at 22 41 16" src="https://user-images.githubusercontent.com/3674185/157767094-f9cac9ea-2ab5-4b11-8be5-471d0cedb1d6.png">


## Implementation

The core parts of the implementation are as follows:

### Stack

I created a simple Stack object to manage the transactions. This gave me a simple mechanism to push and pop transactions. It also gave me the ability to look up a transaction via the peek function for the `COUNT` and `GET` commands.

```swift
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

```

### Enum's

For the transaction commands, I use an enum to provide a friendly API and avoid a stringly-typed codebase!

```swift
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
```

This is also done for the error messages.

```swift
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
```

### Begining and Committing Transactions

One of the more complicated parts of the task requirements was to be able to only commit a transaction if the `BEGIN` command had been previously used.   
To achieve this, anytime the `BEGIN` command is used, a new transaction object is created and set with the key `valid`, this is then pushed onto the stack. 

```swift
private func beginTransaction() {
    var new = Transaction()
    new[TransactionKey.valid.rawValue] = "1"
    transactions.push(new)
}
```

This ensures that when committing a transaction, we can check that it has the `valid` key, indicating the `BEGIN` command was used.


```swift
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

```
Once a transaction is committed, it is marked as completed by setting a `completed` key on it.   
This is important as another requirement was we can only roll back incomplete transactions.  
So setting a `completed` key ensures that when the `ROLLBACK` command is used, we do not roll back completed transactions.


###  Rolling Back Transactions

Given the datastore is a Stack, we can't iterate over each object in the stack, so instead, we check the transaction at the top of the stack, if it is completed we pop it and append it to a temporary array.  
We recursively do this until we find a transaction that is not completed.


```swift
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
```
Once we find a transaction that is not completed we pop it indefinitely.  
Finally, once we have rolled back the transaction we then push the completed transaction back onto the stack from the temporary array.

```swift
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
```

## Testing

To ensure we can unit test the entire `TransactionManager`, the `processCommand` function takes in an optional `TransactionResultHandler` which is a protocol.
```swift
protocol TransactionResultHandler {
    @discardableResult
    func handleResult(_ result: TransactionResult) -> String?
}
```
In the live code, the concrete object `DefaultTransactionResultHandler` is used, which prints all results to the console.
However when running the unit test suite, we inject a `MockTransactionResultHandler` instead, this allows us to run test cases against the output of the commands, including both success and error outputs.

We also inject the input into the `processCommand` function when running unit tests, however, in the live code we read the user's input by using the `readLine()` function.

```swift
private func transactionInput(from input: String?) -> String? {
    if input == nil {
        return readLine()
    } else {
        return input
    }
}
```

Using dependency injection and protocols allowed me to reach a 97%~ code coverage.

<img width="565" alt="Screenshot 2022-03-10 at 22 34 16" src="https://user-images.githubusercontent.com/3674185/157766900-5c7592cb-7f65-4798-bf78-5bc4a0a02ad0.png">

