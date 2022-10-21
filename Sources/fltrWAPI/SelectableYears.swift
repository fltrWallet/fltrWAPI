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
public enum BlockChainYear: UInt16, CaseIterable, Identifiable {
    case year2009 = 2009
    case year2010
    case year2011
    case year2012
    case year2013
    case year2014
    case year2015
    case year2016
    case year2017
    case year2018
    case year2019
    case year2020
    case year2021
    case year2022
    
    public var id: UInt16 { self.rawValue }
}

public struct SelectableYears {
    public var years: [BlockChainYear] { Array(self.yearHeights.keys) }
    private let yearHeights: [ BlockChainYear : Int ]
    
    public func height(for year: BlockChainYear) -> Int? {
        self.yearHeights[year]
    }
    
    fileprivate init(_ years: [BlockChainYear : Int]) {
        self.yearHeights = years
    }
}

public extension SelectableYears {
    static var main: Self = {
        .init([
            .year2015: 336_861,
            .year2016: 391_182,
            .year2017: 446_033,
            .year2018: 501_961,
            .year2019: 556_459,
            .year2020: 610_691,
            .year2021: 663_913,
            .year2022: 716_599,
        ])
    }()
    
    static var testnet: Self {
        .init([
            .year2012: 0_000_514,
            .year2013: 0_046_016,
            .year2014: 0_154_932,
            .year2015: 0_316_147,
            .year2016: 0_629_827,
            .year2017: 1_063_226,
            .year2018: 1_256_955,
            .year2019: 1_450_356,
            .year2020: 1_637_224,
            .year2021: 1_901_675,
            .year2022: 2_133_952,
        ])
    }
}
