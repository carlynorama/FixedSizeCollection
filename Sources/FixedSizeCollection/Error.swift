//
//  FixedSizeCollectionError.swift
//
//
//  Created by Carlyn Maw on 2/4/24.
//


enum FixedSizeCollectionError: Error {
  case unknownError(message: String)
  case memcpyError
}
