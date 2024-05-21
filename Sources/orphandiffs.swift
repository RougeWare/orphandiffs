// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation
import RegexBuilder

import SwiftLibgit2
import SimpleLogging



@main
struct Orphandiffs: ParsableCommand {
    
    @Argument(help: "Path to a file containing a newline-separated list of commit hashes")
    var commitHashesListFilePath: String
    
    
    
    func run() throws {
        let workingDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let repo: Repository
        
        do {
            repo = try Repository(openAt: workingDir)
//            repo = try Repository.open(at: pwd)
        }
        catch {
            log(error: error, "Couldn't open repository at \(workingDir.path)")
            throw error
        }
        
        guard let headTree = try? repo.headTree else {
            throw EnvironmentError.noRepoHead
        }
        
        
        let url = URL(fileURLWithPath: commitHashesListFilePath)
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw FundamentalError.noSuchFile(atPath: commitHashesListFilePath)
        }
        
        
        let content = try String(contentsOf: url)
        
        try processLines(in: content, comparingAgainst: headTree, in: repo)
    }
}



enum FundamentalError: LocalizedError {
    case noSuchFile(atPath: String)
    
    
    var errorDescription: String? {
        switch self {
        case .noSuchFile(atPath: let path):
            "No file exists at the given path: \(path)"
        }
    }
}



enum EnvironmentError: LocalizedError {
    case noRepoHead
    
    
    var errorDescription: String? {
        switch self {
        case .noRepoHead:
            "This repo has no HEAD state, but this tool requires a HEAD to diff orphans against. Please set some commit to be the HEAD commit in order for this tool to give you diffs against the HEAD"
        }
    }
}

