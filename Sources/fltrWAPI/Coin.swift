//===----------------------------------------------------------------------===//
//
// This source file is part of the fltrWAPI open source project
//
// Copyright (c) 2022 fltrWallet AG and the fltrWAPI project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
import fltrTx

public extension HD {
    struct Coin: Identifiable {
        public let outpoint: Tx.Outpoint
        public let amount: UInt64
        
        public enum ReceivedState: Hashable {
            case confirmed(Int)
            case unconfirmed(Int)
            case rollback(Int)
            
            public var isPending: Bool {
                switch self {
                case .confirmed, .rollback:
                    return false
                case .unconfirmed:
                    return true
                }
            }
            
            public var isReceived: Bool {
                switch self {
                case .confirmed:
                    return true
                case .rollback, .unconfirmed:
                    return false
                }
            }
        }
        
        public let receivedState: ReceivedState

        public struct Spent: Equatable {
            public let height: Int
            public let changeOuts: [UInt8]
            public let tx: Tx.AnyTransaction
            
            public init(height: Int,
                        changeOuts: [UInt8],
                        tx: Tx.AnyTransaction) {
                self.height = height
                self.changeOuts = changeOuts
                self.tx = tx
            }
        }
        
        public enum SpentState: Equatable {
            case unspent
            case pending(Spent)
            case spent(Spent)
            
            public var isAvailable: Bool {
                switch self {
                case .pending, .unspent:
                    return true
                case .spent:
                    return false
                }
            }

            public var isPending: Bool {
                switch self {
                case .pending:
                    return true
                case .spent, .unspent:
                    return false
                }
            }
            
            public var isUnspent: Bool {
                switch self {
                case .unspent:
                    return true
                case .pending, .spent:
                    return false
                }
            }
        }
        
        public let spentState: SpentState
        public let source: HD.Source
        public let path: UInt32
        public let _id: Id
        public var id: Int {
            self._id.value
        }
        
        public enum Id: Hashable {
            case append
            case id(Int)
            
            var value: Int {
                switch self {
                case .append:
                    return -1
                case .id(let value):
                    return value
                }
            }
        }
        
        public var isSpendable: Bool {
            switch (self.receivedState, self.spentState) {
            case (.confirmed, .unspent):
                return true
            case (.confirmed, .pending),
                 (.confirmed, .spent),
                 (.unconfirmed, _),
                 (.rollback, _):
                return false
            }
        }
        
        public func rank(id: Int) -> Self {
            Self.init(outpoint: self.outpoint,
                      amount: self.amount,
                      receivedState: self.receivedState,
                      spentState: self.spentState,
                      source: self.source,
                      path: self.path,
                      id: .id(id))
        }
        
        public func unranked() -> Self {
            Self.init(outpoint: self.outpoint,
                      amount: self.amount,
                      receivedState: self.receivedState,
                      spentState: self.spentState,
                      source: self.source,
                      path: self.path,
                      id: .append)
        }

        public init(outpoint: Tx.Outpoint,
                    amount: UInt64,
                    receivedState: ReceivedState,
                    spentState: SpentState,
                    source: HD.Source,
                    path: UInt32) {
            self.outpoint = outpoint
            self.amount = amount
            self.receivedState = receivedState
            self.spentState = spentState
            self.source = source
            self.path = path
            self._id = .append
        }
        
        private init(outpoint: Tx.Outpoint,
                     amount: UInt64,
                     receivedState: ReceivedState,
                     spentState: SpentState,
                     source: HD.Source,
                     path: UInt32,
                     id: Id) {
            self.outpoint = outpoint
            self.amount = amount
            self.receivedState = receivedState
            self.spentState = spentState
            self.source = source
            self.path = path
            self._id = id
        }
    }
}


extension HD.Coin: Comparable {
    public static func < (lhs: HD.Coin, rhs: HD.Coin) -> Bool {
        switch (lhs.receivedState, rhs.receivedState) {
        case (.unconfirmed(let lhs), .unconfirmed(let rhs)),
             (.unconfirmed(let lhs), .confirmed(let rhs)),
             (.unconfirmed(let lhs), .rollback(let rhs)),
             (.confirmed(let lhs), .unconfirmed(let rhs)),
             (.confirmed(let lhs), .confirmed(let rhs)),
             (.confirmed(let lhs), .rollback(let rhs)),
             (.rollback(let lhs), .unconfirmed(let rhs)),
             (.rollback(let lhs), .confirmed(let rhs)),
             (.rollback(let lhs), .rollback(let rhs)):
            return lhs < rhs
        }
    }
}

public extension HD.Coin {
    @inlinable
    var receivedHeight: Int {
        switch self.receivedState {
        case .confirmed(let height), .unconfirmed(let height),
             .rollback(let height):
            return height
        }
    }
}

public typealias Tally = Array<HD.Coin>

public extension Tally { //Sequence where Element == HD.Coin {
    @inlinable
    func filter(greater than: UInt64) -> Tally? {
        self.filter(predicate: >, amount: than)
    }
    
    func filter(smaller than: UInt64) -> Tally? {
        self.filter(predicate: <, amount: than)
    }
    
    @usableFromInline
    internal func filter(predicate: (UInt64, UInt64) -> Bool, amount: UInt64) -> Tally? {
        let result = self.filter {
            predicate($0.amount, amount)
        }
        .sorted()
        
        guard result.count > 0
        else { return nil }
        
        return result
    }
    
    @inlinable
    func inputs() -> [Tx.In] {
        self.map { coin in
            Tx.In(outpoint: coin.outpoint,
                  scriptSig: [],
                  sequence: .disable) {
                nil
            }
        }
    }
    
    @inlinable
    mutating func sort() {
        self.sort(by: self.sortPredicate(lhs:rhs:))
    }

    @usableFromInline
    internal func sortPredicate(lhs: HD.Coin, rhs: HD.Coin) -> Bool {
        lhs.amount < rhs.amount
    }
    
    @inlinable
    func sorted() -> Tally {
        self.sorted(by: self.sortPredicate(lhs:rhs:))
    }
    
    @inlinable
    func total() -> UInt64 {
        self
            .map(\.amount)
            .reduce(0, +)
    }
}

extension HD.Coin.Id: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .append:
            return ".append"
        case .id(let height):
            return ".id(\(height))"
        }
    }
}

extension HD.Coin.ReceivedState: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .confirmed(let height):
            return ".confirmed(\(height))"
        case .unconfirmed(let height):
            return ".unconfirmed(\(height))"
        case .rollback(let height):
            return ".rollback(\(height))"
        }
    }
}

extension HD.Coin.SpentState: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .pending(let height):
            return ".pending(\(height))"
        case .spent(let height):
            return ".spent(\(height))"
        case .unspent:
            return ".unspent"
        }
    }
}

extension HD.Coin: CustomDebugStringConvertible {
    public var debugDescription: String {
        var s = [String]()
        s.append("HD.Coin(id: \(self.id)")
        s.append("outpoint: \(self.outpoint.transactionId):\(self.outpoint.index)")
        s.append("amount: \(self.amount)")
        s.append("receivedState: \(self.receivedState)")
        s.append("spentState: \(self.spentState)")
        s.append("source: \(self.source)")
        s.append("path: \(self.path))")
        
        return s.joined(separator: ", ")
    }
}
