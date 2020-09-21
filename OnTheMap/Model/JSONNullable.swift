//
//  JSONNullable.swift
//  OnTheMap
//
//  Created by Daniel Soutar on 21/09/2020.
//  Copyright © 2020 Daniel Soutar. All rights reserved.
//

import Foundation

// Class for decoding potentially null-valued JSON.
class JSONNullable: Decodable, Hashable {

    public static func == (lhs: JSONNullable, rhs: JSONNullable) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    public var hashValue: Int {
        return 0  // Not sure how to implement this?
    }

    public func hash(into hasher: inout Hasher) {
        // No-op
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNullable.self,
                                             DecodingError.Context(
                                                codingPath: decoder.codingPath,
                                                debugDescription: "Incorrect type for JSONNullable"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
