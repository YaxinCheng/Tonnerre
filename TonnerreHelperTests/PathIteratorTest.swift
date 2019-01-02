//
//  PathIteratorTest.swift
//  TonnerreTests
//
//  Created by Yaxin Cheng on 2019-01-02.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import XCTest
@testable import TonnerreIndexHelper

class PathIteratorTest: XCTestCase {
  
  private var firstLevelPaths: Set<URL>!
  private var secondLevelPaths: Set<URL>!
  private var hiddenPaths: Set<URL>!
  private var packagePaths: Set<URL>!
  private var testPath: URL!
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    testPath = URL(fileURLWithPath: "/private/tmp/test")
    try! FileManager.default.createDirectory(at: testPath, withIntermediateDirectories: true, attributes: nil)
    
    let file1 = testPath.appendingPathComponent("file1")
    FileManager.default.createFile(atPath: file1.path, contents: nil, attributes: nil)
    let file2 = testPath.appendingPathComponent("file2")
    FileManager.default.createFile(atPath: file2.path, contents: nil, attributes: nil)
    let subdir = URL(fileURLWithPath: "/private/tmp/test/subdir/")
    try! FileManager.default.createDirectory(at: subdir, withIntermediateDirectories: true, attributes: nil)
    let file3 = subdir.appendingPathComponent("file3")
    FileManager.default.createFile(atPath: file3.path, contents: nil, attributes: nil)
    
    let hiddenFile = testPath.appendingPathComponent(".hiddenFile")
    FileManager.default.createFile(atPath: hiddenFile.path, contents: nil, attributes: nil)
    let hiddenDir = URL(fileURLWithPath: "/private/tmp/test/.hiddenDir/")
    try! FileManager.default.createDirectory(at: hiddenDir, withIntermediateDirectories: true, attributes: nil)
    let hiddenDescendant = hiddenDir.appendingPathComponent("hiddenDescendant")
    FileManager.default.createFile(atPath: hiddenDescendant.path, contents: nil, attributes: nil)
    
    let package = URL(fileURLWithPath: "/private/tmp/test/subdir/package.tne/")
    try! FileManager.default.createDirectory(at: package, withIntermediateDirectories: true, attributes: nil)
    let packageDescendant = package.appendingPathComponent("packageDescendant")
    FileManager.default.createFile(atPath: packageDescendant.path, contents: nil, attributes: nil)
    
    firstLevelPaths = [testPath, file1, file2, subdir]
    secondLevelPaths = [file3, package]
    hiddenPaths = [hiddenFile, hiddenDir, hiddenDescendant]
    packagePaths = [packageDescendant]
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    try! FileManager.default.removeItem(at: testPath)
  }
  
  func testIterateLevel1Files() {
    let iterator = PathIterator(beginURL: testPath,
                                options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants])
    var shouldAppearPaths = firstLevelPaths!
    XCTAssertFalse(shouldAppearPaths.isEmpty)
    for fileURL in iterator {
      shouldAppearPaths.remove(fileURL)
    }
    XCTAssertTrue(shouldAppearPaths.isEmpty)
  }
  
  func testIterateAllLevelFiles() {
    let iterator = PathIterator(beginURL: testPath,
                                options: [.skipsHiddenFiles, .skipsPackageDescendants])
    var shouldAppearPaths = firstLevelPaths
                              .union(secondLevelPaths)
    XCTAssertFalse(shouldAppearPaths.isEmpty)
    for fileURL in iterator {
      shouldAppearPaths.remove(fileURL)
    }
    XCTAssertTrue(shouldAppearPaths.isEmpty)
  }
  
  func testIterateAllLevelWithHiddenFiles() {
    let iterator = PathIterator(beginURL: testPath,
                                options: [.skipsPackageDescendants])
    var shouldAppearPaths = firstLevelPaths
                              .union(secondLevelPaths)
                              .union(hiddenPaths)
    XCTAssertFalse(shouldAppearPaths.isEmpty)
    for fileURL in iterator {
      shouldAppearPaths.remove(fileURL)
    }
    XCTAssertTrue(shouldAppearPaths.isEmpty)
  }
  
  func testIterateAllFiles() {
    let iterator = PathIterator(beginURL: testPath)
    var shouldAppearPaths = firstLevelPaths
                              .union(secondLevelPaths)
                              .union(hiddenPaths)
                              .union(packagePaths)
    XCTAssertFalse(shouldAppearPaths.isEmpty)
    for fileURL in iterator {
      shouldAppearPaths.remove(fileURL)
    }
    XCTAssertTrue(shouldAppearPaths.isEmpty)
  }
}
