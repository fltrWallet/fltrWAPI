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

public struct SpentOutpoint: Hashable {
    public enum TransactionOutputs: Hashable {
        case refund(UInt64, ScriptPubKey)
        case outgoing(UInt64, [UInt8])
        
        var amount: UInt64 {
            switch self {
            case .refund(let amount, _),
                    .outgoing(let amount, _):
                return amount
            }
        }
        
        var opcodes: [UInt8] {
            switch self {
            case .refund(_, let wrapped):
                return wrapped.opcodes
            case .outgoing(_, let opcodes):
                return opcodes
            }
        }
        
        var refund: Bool {
            switch self {
            case .refund: return true
            case .outgoing: return false
            }
        }
    }
    
    public let outpoint: Tx.Outpoint
    public let outputs: [TransactionOutputs]
    public let tx: Tx.AnyTransaction

    public init(outpoint: Tx.Outpoint,
                outputs: [TransactionOutputs],
                tx: Tx.AnyTransaction) {
        self.outpoint = outpoint
        self.outputs = outputs
        self.tx = tx
    }
    
    @inlinable
    public var changeIndices: [UInt8] {
        self.outputs
        .enumerated()
        .compactMap { index, output in
            guard index < 255
            else { return nil }
            
            switch output {
            case .refund(_, let scriptPubKey):
                guard let sourceRepo = HD.Source(rawValue: scriptPubKey.tag),
                      sourceRepo.change
                else { return nil }
                
                return UInt8(index)
            case .outgoing:
                return nil
            }
        }
    }
}

extension SpentOutpoint: CustomDebugStringConvertible {
    public var debugDescription: String {
        var str = [ "SpentOutpoint(" ]
        str.append("\(String(reflecting: self.outpoint)) ")
        str.append("txID🔖[\(Tx.AnyIdentifiableTransaction(self.tx).txId)] ")
        if let opcodes = self.tx.vout.first?.scriptPubKey {
            str.append("opcodes💾(\(opcodes.count))[\(opcodes.hexEncodedString)]")
        }
        return str.joined()
    }
}
