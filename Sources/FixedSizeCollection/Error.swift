//
//  FixedSizeCollectionError.swift
//
//
//  Created by Carlyn Maw on 2/4/24.
//

public enum FSCError: Error {
  case unknownError(message: String)
  case outOfRange
}
