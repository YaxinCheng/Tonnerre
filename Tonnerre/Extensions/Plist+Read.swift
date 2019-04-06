//
//  Plist+Read.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-04-04.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

extension PropertyListSerialization {
  public static func read<Type>(_ fileURL: URL) -> Result<Type, Error> {
    do {
      let fileData = try Data(contentsOf: fileURL)
      let content = try propertyList(from: fileData, format: nil)
      if let casted = content as? Type {
        return .success(casted)
      } else {
        return .failure(ReadError.wrongType)
      }
    } catch {
      return .failure(error)
    }
  }
  
  public static func read<Type>(fileName: String) -> Result<Type, Error> {
    guard let filePath = Bundle.main.url(forResource: fileName, withExtension: "plist") else {
      return .failure(ReadError.unableToLocateFile)
    }
    return read(filePath)
  }
  
  enum ReadError: Error {
    case unableToLocateFile
    case wrongType
  }
}
