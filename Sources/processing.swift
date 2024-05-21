//
//  processing.swift
//  
//
//  Created by Ky on 2024-05-14.
//

import Foundation
import RegexBuilder

import SwiftLibgit2
import SimpleLogging



internal extension Orphandiffs {
    func processLines(in content: String, comparingAgainst referenceTree: Tree, in repo: Repository) throws {
        var lineCounter = 1
        
        content.enumerateLines { line, stop in
            defer { lineCounter += 1 }
            
            do {
                try processLine(line, comparingAgainst: referenceTree, in: repo)
            }
            catch {
                log(error: error, "Error processing line \(lineCounter): \(line)")
            }
        }
        
        OutputCoordinator.shared.flushOutput()
    }
}



private extension Orphandiffs {
    
    func processLine(_ line: String, comparingAgainst referenceTree: Tree, in repo: Repository) throws {
        guard let hashString = try hash(onLine: line).get() else {
            return
        }
        
        print(queueing: "Processing all commits found matching", hashString)
        
        //        let (commit, reference): (Commit?, Reference?) = try repo.revision(matching: String(hashString))
        //        guard let commit else {
        //            throw LineProcessingError.noCommitFoundForHash(hash: String(hashString))
        //        }
        
        let commits: [Commit]
        
        do {
            commits = try repo.allCommits(revspec: .init(hashString))
        }
        catch let error as GitError {
            switch error.errorCode {
            case -12:
                throw LineProcessingError.hashWasNotCommitHash(hash: .init(hashString))
                
            default:
                throw error
            }
        }
        
        guard !commits.isEmpty else {
            throw LineProcessingError.noCommitFoundForHash(hash: .init(hashString))
        }
        
        //        print(commits.count, "commits found matching", hashString)
        
        processOrphanedCommits(commits, comparingAgainst: referenceTree, in: repo)
    }
    
    
    /// Attempts to extract the hash from the given line of unreachables
    ///
    /// - Parameters:
    ///   - line:        The line in the unreachables file to look over
    ///   - commitsOnly: _optional_ - Whether to only look at lines about unreachable commits. If you're processing a raw list of hashes (without preamble labeling each line), then set this to `false`.
    ///                  Defaults to `true`
    ///
    /// - Returns: The hash on the given line, or `nil` if the hash on that line shouldn't be used. If you receive `nil` from this, it's safe to just silentlyskip this line.
    ///
    /// - Throws: A ``LineProcessingError`` describing any problems found (e.g. the line has no hash). This function is **guaranteed** to only ever throw errors of type ``LineProcessingError``
    func hash(onLine line: String, commitsOnly: Bool = true) -> Result<Substring?, LineProcessingError> {
        do {
            guard let justTheHash = try findHashRegex.firstMatch(in: line)?.output else {
                return .failure(.noHashFound(lineWithoutHash: line))
            }
            
            let useThisParticularHash: Bool
            
            if commitsOnly {
                let isCommitLineRegex = Regex {
                    Anchor.wordBoundary
                    "commit "
                    findHashRegex
                }
                
                useThisParticularHash = try nil != isCommitLineRegex.firstMatch(in: line)
            }
            else {
                useThisParticularHash = true
            }
            
            guard useThisParticularHash else {
                log(verbose: "Safely skipping this line because it's not what we're looking for")
                return .success(nil)
            }
            
            return .success(justTheHash)
        }
        catch {
            log(error: error, "Swift Regex failed to parse a Regex... somehow")
            return .failure(.impossibleError(error))
        }
    }
    
    
    func processOrphanedCommits(_ commits: [Commit], comparingAgainst referenceTree: Tree, in repo: Repository) {
        print(queueing: "  Processing", commits.count, "commits")
        for commit in commits {
            let commitTree: Tree
            do {
                commitTree = try commit.tree
            }
            catch {
                log(error: error, "Commit \(commit.objectID) had no tree")
                continue
            }
            
            let diff: Diff
            do {
                diff = try repo.diff(referenceTree, commitTree)
            }
            catch {
                log(error: error, "Could not diff between the reference commit and this one (\(commit.objectID))")
                continue
            }
            
            print(queueing: "    Commit", commit.objectID, "has", diff.endIndex, "differences from the reference")
        }
    }
}



enum LineProcessingError: LocalizedError {
    case noHashFound(lineWithoutHash: String)
    case noCommitFoundForHash(hash: String)
    case hashWasNotCommitHash(hash: String)
    
    /// Okay well obviously this isn't truly _impossible_ or this case wouldn't exist, but this respesents errors that are only caused by circumstances that are fully accounted-for.
    /// An example would be if a system/library API breaks its contracts/documentations and throws some error that goes against what it says it does
    case impossibleError(Error)
    
    
    var errorDescription: String? {
        switch self {
        case .noHashFound(let lineWithoutHash):
            "I couldn't find a hash on this line: \(lineWithoutHash)"
            
        case .noCommitFoundForHash(hash: let hash):
            "I couldn't find a commit matching this hash: \(hash)"
            
        case .hashWasNotCommitHash(hash: let hash):
            "The hash pointed to something which wasn't a commit: \(hash)"
            
        case .impossibleError(let error):
            """
            Please tell Ky that this crashed in a way that shouldn't be possible. Include as much information as possible (like the console output). Ky publish their contact info at https://KyLeggiero.me
            The error was: \(error)
            """
        }
    }
}



fileprivate final class OutputCoordinator: @unchecked Sendable {
    
    private var output = String()
    private let q: DispatchQueue
    
    
    private init() {
        q = .init(label: "\(Self.self) \(UUID())")
    }
    
    
    deinit {
        flushOutput()
    }
    
    
    func prepare(outputLine line: String) { q.async { [weak self] in
        guard let self else { return }
        output += line
        output += "\n"
    }}
    
    
    func flushOutput() { q.async { [weak self] in
        guard let self else { return }
        defer { output = .init() }
        Swift.print(output)
    }}
    
    
    
    static let shared = OutputCoordinator()
}



func print(queueing items: Any...) {
    let line = items.map(String.init(describing:)).joined(separator: " ")
    OutputCoordinator.shared.prepare(outputLine: line)
}



// unreachable commit 140177eae0f394330346c9fa6d81b08454b52f6e
// unreachable tree e77b2b65f998fb75eb43b90794d8672615d76e99
let findHashRegex = /\b[a-z0-9]{40}\b/.ignoresCase()

extension Regex: @unchecked Sendable {}
