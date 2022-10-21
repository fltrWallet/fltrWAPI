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

public struct FundingOutpoint: Hashable {
    public let outpoint: Tx.Outpoint
    public let amount: UInt64
    public let scriptPubKey: ScriptPubKey

    
    
    public init(outpoint: Tx.Outpoint,
                amount: UInt64,
                scriptPubKey: ScriptPubKey) {
        self.outpoint = outpoint
        self.amount = amount
        self.scriptPubKey = scriptPubKey
    }
}

extension FundingOutpoint: CustomDebugStringConvertible {
    public var debugDescription: String {
        let opcodes = self.scriptPubKey.opcodes
        var str = [ "FundingOutpoint(" ]
        str.append("\(String(reflecting: self.outpoint)) ")
        str.append("💰[\(self.amount)] ")
        str.append("🏷[\(self.scriptPubKey.tag)] ")
        str.append("#️⃣[\(self.scriptPubKey.index)] ")
        str.append("opcodes(\(opcodes.count))[\(opcodes.hexEncodedString)]")
        str.append(")")
        return str.joined()
    }
}
