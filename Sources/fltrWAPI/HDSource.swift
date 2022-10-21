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
public extension HD {
    enum Source: UInt8, Hashable, Codable, CaseIterable {
        case legacy0
        case legacy0Change
        case legacy44
        case legacy44Change
        case legacySegwit
        case legacySegwitChange
        case segwit0
        case segwit0Change
        case segwit
        case segwitChange
        case taprootChange
        case taproot
    }
}

public extension HD.Source {
    var change: Bool {
        switch self {
        case .legacy0Change, .legacy44Change, .legacySegwitChange,
                .segwit0Change, .segwitChange, .taprootChange:
            return true
        case .legacy0, .legacy44, .legacySegwit,
                .segwit0, .segwit, .taproot:
            return false
        }
    }
    
    var mirror: [Self] {
        var result: [Self] = [ self ]
        
        switch self {
        case .legacy0: result.append(.segwit0)
        case .legacy0Change: result.append(.segwit0Change)
        case .legacy44: break
        case .legacy44Change: break
        case .legacySegwit: break
        case .legacySegwitChange: break
        case .segwit0: result.append(.legacy0)
        case .segwit0Change: result.append(.legacy0Change)
        case .segwit: break
        case .segwitChange: break
        case .taproot: break
        case .taprootChange: break
        }
        
        return result
    }
    
    @inlinable
    static var uniqueCases: [Self] {
        Self.allCases.filter {
            switch $0 {
            case .legacy0, .legacy0Change,
                    .legacy44, .legacy44Change,
                    .legacySegwit, .legacySegwitChange,
                    .segwit, .segwitChange,
                    .taproot, .taprootChange:
                return true
            case .segwit0, .segwit0Change:
                return false
            }
        }
    }
    
    var witness: Bool {
        switch self {
        case .legacy0, .legacy0Change,
                .legacy44, .legacy44Change:
            return false
        case .legacySegwit, .legacySegwitChange,
                .segwit, .segwitChange,
                .segwit0, .segwit0Change,
                .taproot, .taprootChange:
            return true
        }
    }

    var xPoint: Bool {
        switch self {
        case .legacy0, .legacy0Change,
                .legacy44, .legacy44Change,
                .legacySegwit, .legacySegwitChange,
                .segwit0, .segwit0Change,
                .segwit, .segwitChange:
            return false
        case .taproot, .taprootChange:
            return true
        }
    }
}

extension HD.Source: CustomStringConvertible {
    public var description: String {
        switch self {
        case .legacy0:
            return "Legacy 0 repository"
        case .legacy0Change:
            return "Legacy 0 Change repository"
        case .legacy44:
            return "Legacy 44 repository"
        case .legacy44Change:
            return "Legacy 44 Change repository"
        case .legacySegwit:
            return "Legacy Segwit repository"
        case .legacySegwitChange:
            return "Legacy Segwit Change repository"
        case .segwit0:
            return "Segwit 0 repository"
        case .segwit0Change:
            return "Segwit 0 Change repository"
        case .segwit:
            return "Segwit repository"
        case .segwitChange:
            return "Segwit Change repository"
        case .taproot:
            return "Taproot repository"
        case .taprootChange:
            return "Taproot Change repository"
        }
    }
}

extension HD.Source: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .legacy0:
            return ".legacy0"
        case .legacy0Change:
            return ".legacy0Change"
        case .legacy44:
            return ".legacy44"
        case .legacy44Change:
            return ".legacy44Change"
        case .legacySegwit:
            return ".legacySegwit"
        case .legacySegwitChange:
            return ".legacySegwitChange"
        case .segwit0:
            return ".segwit0"
        case .segwit0Change:
            return ".segwit0Change"
        case .segwit:
            return ".segwit"
        case .segwitChange:
            return ".segwitChange"
        case .taprootChange:
            return ".taprootChange"
        case .taproot:
            return ".taproot"
        }
    }
}
