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
import bech32
import fltrTx

public struct NetworkParameters: Equatable {
    public let BITCOIN_BIP44_VERSION_PREFIX: BIP44
    public let BITCOIN_BIP84_VERSION_PREFIX: BIP84
    public let BITCOIN_NETWORK_MAGIC: BitcoinNetworkMagic
    public let BITCOIN_LEGACY_ADDRESS_PREFIX: BitcoinLegacyAddressPrefix
    public let BITCOIN_WITNESS_ADDRESS_HRP: Bech32.HumanReadablePart
    
    public static let main = NetworkParameters(BITCOIN_BIP44_VERSION_PREFIX: .main,
                                               BITCOIN_BIP84_VERSION_PREFIX: .main,
                                               BITCOIN_NETWORK_MAGIC: .main,
                                               BITCOIN_LEGACY_ADDRESS_PREFIX: .main,
                                               BITCOIN_WITNESS_ADDRESS_HRP: .main)
    public static let testnet = NetworkParameters(BITCOIN_BIP44_VERSION_PREFIX: .testnet,
                                                  BITCOIN_BIP84_VERSION_PREFIX: .testnet,
                                                  BITCOIN_NETWORK_MAGIC: .testnet3,
                                                  BITCOIN_LEGACY_ADDRESS_PREFIX: .testnet,
                                                  BITCOIN_WITNESS_ADDRESS_HRP: .testnet)
}

public enum BitcoinNetworkMagic: UInt32 {
    case main = 0xD9B4BEF9
    case testnet = 0xDAB5BFFA
    case testnet3 = 0x0709110B
    case namecoin = 0xFEB4BEF9
}

public protocol BIP32VersionSerialization: RawRepresentable
where RawValue == (public: UInt32, private: UInt32) {
    var externalPath: HD.Path { get }
    var changePath: HD.Path { get }

    var rawValue: (public: UInt32, private: UInt32) { get }
}

public enum BIP44: RawRepresentable, BIP32VersionSerialization {
    case main
    case testnet
    
    private static let mainPublic: UInt32 = 0x0488B21E
    private static let mainPrivate: UInt32 = 0x0488ADE4
    private static let testnetPublic: UInt32 = 0x043587CF
    private static let testnetPrivate: UInt32 = 0x04358394
    
    public init?(rawValue: (public: UInt32, private: UInt32)) {
        switch rawValue {
        case (Self.mainPublic, Self.mainPrivate):
            self = .main
        case (Self.testnetPublic, Self.testnetPrivate):
            self = .testnet
        default:
            return nil
        }
    }
        
    public var rawValue: (public: UInt32, private: UInt32) {
        switch self {
        case .main:
            return (Self.mainPublic, Self.mainPrivate)
        case .testnet:
            return (Self.testnetPublic, Self.testnetPrivate)
        }
    }
    
    public var externalPath: HD.Path {
        switch self {
        case .main:
            return [ .hardened(44), .hardened(0), .hardened(0), .normal(0) ]
        case .testnet:
            return [ .hardened(44), .hardened(1), .hardened(0), .normal(0) ]
        }
    }
    
    public var changePath: HD.Path {
        switch self {
        case .main:
            return [ .hardened(44), .hardened(0), .hardened(1), .normal(0) ]
        case .testnet:
            return [ .hardened(44), .hardened(1), .hardened(1), .normal(0) ]
        }
    }
}

public enum BIP84: RawRepresentable, BIP32VersionSerialization {
    case main
    case testnet
    
    private static let mainPublic: UInt32 = 0x04b24746
    private static let mainPrivate: UInt32 = 0x04b2430c
    private static let testnetPublic: UInt32 = 0x045f1cf6
    private static let testnetPrivate: UInt32 = 0x045f18bc
    
    public init?(rawValue: (public: UInt32, private: UInt32)) {
        switch rawValue {
        case (Self.mainPublic, Self.mainPrivate):
            self = .main
        case (Self.testnetPublic, Self.testnetPrivate):
            self = .testnet
        default:
            return nil
        }
    }
        
    public var rawValue: (public: UInt32, private: UInt32) {
        switch self {
        case .main:
            return (Self.mainPublic, Self.mainPrivate)
        case .testnet:
            return (Self.testnetPublic, Self.testnetPrivate)
        }
    }
    
    public var externalPath: HD.Path {
        switch self {
        case .main:
            return [ .hardened(84), .hardened(0), .hardened(0), .normal(0) ]
        case .testnet:
            return [ .hardened(84), .hardened(1), .hardened(0), .normal(0) ]
        }
    }
    
    public var changePath: HD.Path {
        switch self {
        case .main:
            return [ .hardened(84), .hardened(0), .hardened(1), .normal(0) ]
        case .testnet:
            return [ .hardened(84), .hardened(1), .hardened(1), .normal(0) ]
        }
    }
}
