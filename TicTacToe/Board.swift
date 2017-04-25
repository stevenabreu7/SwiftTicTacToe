//
//  Board.swift
//  TicTacToe
//
//  Created by Steven Abreu on 25.04.17.
//  Copyright © 2017 stevenabreu. All rights reserved.
//

import Foundation

class Board {
    
    enum Result {
        case playerWon
        case opponentWon
        case draw
        case undecided
    }
    
    var fields: [[Int]]
    var current: Int
    
    init() {
        self.fields = Array(repeating: Array(repeating: 0, count: 3), count: 3)
        self.current = 1
    }
    
    init(fields: [[Int]], current: Int) {
        self.fields = fields
        self.current = current
    }
    
    func printBoard() {
        print(fields[0][0], fields[0][1], fields[0][2], separator: " | ", terminator: "\n")
        print(fields[1][0], fields[1][1], fields[1][2], separator: " | ", terminator: "\n")
        print(fields[2][0], fields[2][1], fields[2][2], separator: " | ", terminator: "\n\n")
    }
    
    func getField(row: Int, col: Int) -> Int {
        return self.fields[row][col]
    }
    
    func getCurrentPlayer() -> Int {
        return self.current
    }
    
    func simulateMove(row: Int, col: Int, player: Int) {
        self.fields[row][col] = player
    }
    
    private func getOpponent() -> Int {
        if self.current == 1 {
            return 2
        } else {
            return 1
        }
    }
    
    func makeMove(row: Int, col: Int) {
        // check for illegal move!!
        if true {
            self.fields[row][col] = self.current
            self.current = self.getOpponent()
        }
    }
    
    func hasWon(player: Int) -> Bool {
        // diagonal
        var count = 0
        for i in 0...2 {
            if self.fields[i][i] == player {
                count += 1
            }
        }
        if count == 3 {
            return true
        }
        // other diagonal
        count = 0
        for i in 0...2 {
            if self.fields[i][2-i] == player {
                count += 1
            }
        }
        if count == 3 {
            return true
        }
        // check rows
        for row in 0...2 {
            count = 0
            for col in 0...2 {
                if self.fields[row][col] == player {
                    count += 1
                }
            }
            if count == 3 {
                return true
            }
        }
        // check columns
        for col in 0...2 {
            count = 0
            for row in 0...2 {
                if self.fields[row][col] == player {
                    count += 1
                }
            }
            if count == 3 {
                return true
            }
        }
        // everything checked
        return false
    }
    
    func isFull() -> Bool {
        for row in 0...2 {
            for col in 0...2 {
                if self.fields[row][col] == 0 {
                    return false
                }
            }
        }
        return true
    }
    
    func getResult() -> Result {
        if self.hasWon(player: 1) {
            return .playerWon
        } else if self.hasWon(player: 2) {
            return .opponentWon
        } else if self.isFull() {
            return .draw
        } else {
            return .undecided
        }
    }
    
    func isOver() -> Bool {
        return (self.getResult() != .undecided)
    }
    
    func getPossibleMoves() -> [(Int, Int)] {
        var possibleMoves = [(Int, Int)]()
        for row in 0...2 {
            for col in 0...2 {
                if self.fields[row][col] == 0 {
                    possibleMoves.append((row, col))
                }
            }
        }
        return possibleMoves
    }
}
