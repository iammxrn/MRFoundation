//
//  MREnumCodable.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 25.02.2022.
//  Copyright © 2022 mxrn. All rights reserved.
//

import Foundation

/**
 MREnumCodable almost works like typical Codable protocol, but if you recieve an unknown value it automatically assign it as **unknown** without throwing error.
 
 ```
 enum ErrorCode: String, EnumCodable {
     case invalidData = "invalid_data"
     case connectionLost = "connection_lost"
     case unknown
     
     static var unknownValue: ErrorCode { .unknown }
     
 }
 ```
 */
public protocol MREnumCodable: DirectTypesEnumCodable {
    
    associatedtype CodingKeys: CodingKey
}

public protocol DirectTypesEnumCodable: Codable & CaseIterable & RawRepresentable where RawValue: Codable, AllCases: BidirectionalCollection {
    
    associatedtype UnknownType: DirectTypesEnumCodable
     
    static var unknownValue: UnknownType { get }
}

extension MREnumCodable {
    
    public init(from decoder: Decoder) throws {
        if let unknownValue = Self.unknownValue as? Self {
            self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? unknownValue
        } else {
            throw NSError(
                domain: .defaultDomain,
                code: -999,
                userInfo: [NSLocalizedDescriptionKey: "Type mismatching. unknownValue must be of the same type as \(Self.self)"]
            )
        }
    }
}
