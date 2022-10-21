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
public enum HD {}

public extension HD {
    struct Path: Hashable, ExpressibleByArrayLiteral, Sequence, Codable {
        public let value: [HD.ChildNumber]

        private init(_ value: [HD.ChildNumber]) {
            self.value = value
        }
        
        public init(_ first: HD.ChildNumber, _ value: HD.ChildNumber...) {
            self.init(
                Array(
                    [ [first],
                      value
                    ]
                    .joined()
                )
            )
        }
        
        public init<S>(_ sequence: S)
        where S: Sequence, S.Element == HD.ChildNumber {
            self.value = Array(sequence)
        }
        
        public init(arrayLiteral elements: HD.ChildNumber...) {
            precondition(elements.count > 0)
            self.init(elements)
        }
        
        public static func hardened(_ index: UInt32) -> Self {
            Self.init([ .hardened(index) ])
        }
        
        public static func normal(_ index: UInt32) -> Self {
            Self.init([ .normal(index) ])
        }

        public static let empty: HD.Path = {
            .init([])
        }()
        
        public func appending(_ tail: HD.ChildNumber) -> HD.Path {
            HD.Path(self.value + [tail])
        }
        
        public static func +(lhs: HD.Path, rhs: HD.Path) -> HD.Path {
            HD.Path([HD.ChildNumber]([ lhs, rhs ].joined()))
        }
        
        public var count: Int {
            self.value.count
        }
        
        public func matchPrefix(_ path: HD.Path) -> (prefix: HD.Path, remaining: HD.Path)? {
            var selfPath = self.value[...]
            var callPath = path.value[...]
            
            var prefix: [HD.ChildNumber] = []
            while let selfHead = selfPath.popFirst() {
                guard let callHead = callPath.popFirst(), callHead == selfHead
                else { return nil }
                
                prefix.append(callHead)
            }
            
            guard !callPath.isEmpty
            else { return nil }
            
            return (prefix: .init(prefix), remaining: .init(Array(callPath)))
        }
        
        public struct Iterator: IteratorProtocol {
            var slice: ArraySlice<HD.ChildNumber>
            
            init(_ value: [HD.ChildNumber]) {
                self.slice = value[...]
            }
            
            public mutating func next() -> HD.ChildNumber? {
                self.slice.popFirst()
            }
        }
        
        public func makeIterator() -> HD.Path.Iterator {
            Iterator(self.value)
        }
    }
}

extension HD.Path: RandomAccessCollection {
    public func index(after i: Array<HD.ChildNumber>.Index) -> Array<HD.ChildNumber>.Index {
        self.value.index(after: i)
    }
    
    public subscript(position: Array<HD.ChildNumber>.Index) -> HD.ChildNumber {
        self.value[position]
    }
    
    public var startIndex: Int {
        self.value.startIndex
    }
    
    public var endIndex: Int {
        self.value.endIndex
    }
    
    public typealias Index = Array<HD.ChildNumber>.Index
}

// MARK: ChildNumber
public extension HD {
    enum ChildNumber: Equatable, Hashable {
        case hardened(UInt32)
        case normal(UInt32)
        case master

        public func index() -> UInt32 {
            var index: UInt32 = 0
            switch self {
            case .hardened(let i):
                index = 1 << 31
                fallthrough
            case .normal(let i):
                precondition(i < 0x80_00_00_00)
                return index + i
            case .master:
                return 0
            }
        }
        
        public static func child(for number: UInt32) -> Self {
            if number >> 31 == 1 {
                let index = number & 0x7f_ff_ff_ff
                return .hardened(index)
            } else {
                return .normal(number)
            }
        }
        
        public var isHardened: Bool {
            switch self {
            case .hardened:
                return true
            case .normal, .master:
                return false
            }
        }
    }
}

extension HD.Path: CustomStringConvertible {
    public var description: String {
        func format(_ child: HD.ChildNumber) -> String {
            switch child {
            case .hardened(let i):
                return "\(i)'"
            case .normal(let i):
                return "\(i)"
            case .master:
                return "m"
            }
        }
        
        return self
        .map(format(_:))
        .joined(separator: "/")
    }
}

extension HD.Path: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "HD.Path(\(String(describing: self)))"
    }
}

extension HD.ChildNumber: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .hardened(let i):
            return ".hardened(\(i))"
        case .normal(let i):
            return ".normal(\(i))"
        case .master:
            return ".master"
        }
    }
}

extension HD.ChildNumber: Codable {
    enum CodingKeys: String, CodingKey  {
        case hardened
        case normal
        case master
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .hardened(let value):
            try container.encode(value, forKey: .hardened)
        case .normal(let value):
            try container.encode(value, forKey: .normal)
        case .master:
            try container.encodeNil(forKey: .master)
        }
    }
    
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let key = values.allKeys.first
        else {
            struct DecodingKeyNotFound: Swift.Error {}
            throw DecodingKeyNotFound()
        }
        
        switch key {
        case .hardened:
            let associatedValue = try values.decode(UInt32.self, forKey: key)
            self = .hardened(associatedValue)
        case .normal:
            let associatedValue = try values.decode(UInt32.self, forKey: key)
            self = .normal(associatedValue)
        case .master:
            _ = try values.decodeNil(forKey: key)
            self = .master
        }
    }
}

/* Not really useful yet as prime character can not be defined
   it is a unicode character. Also, binding for postfix requires
   parantheses around value, which is less than desirable.
 
   what we want:
   let path: HD.Path = 0/1'/2
 
   what we get now
   let path: HD.Path = 0/(1′)/2

 extension HD.ChildNumber: ExpressibleByIntegerLiteral {
     public init(integerLiteral value: UInt32) {
         precondition(value < 0x80_00_00_00)
         self = .normal(value)
     }
 }

 postfix operator ′

 postfix func ′(operand: UInt32) -> HD.ChildNumber {
     precondition(operand < 0x80_00_00_00)
     return .hardened(operand)
 }

 infix operator /: MultiplicationPrecedence

 func /(lhs: HD.ChildNumber, rhs: HD.ChildNumber) -> HD.Path {
     [ lhs, rhs ]
 }

 func /(lhs: HD.ChildNumber, rhs: HD.Path) -> HD.Path {
     [ lhs ] + rhs
 }

 func /(lhs: HD.Path, rhs: HD.ChildNumber) -> HD.Path {
     lhs + [ rhs ]
 }


// var path: HD.Path = 0/1/2/3
// var path2 = path + (1′)/4/(5′)
*/

