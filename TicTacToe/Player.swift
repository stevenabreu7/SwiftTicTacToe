//
//  Player.swift
//  TicTacToe
//
//  Created by Steven Abreu on 25.04.17.
//  Copyright © 2017 stevenabreu. All rights reserved.
//

import Foundation

class Player {
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    func getName() -> String {
        return self.name
    }
    
    func getMove(board: Board) -> (Int, Int) {
        // This method must be overriden!
        return (0,0)
    }
}

class RandomPlayer: Player {
    override func getMove(board: Board) -> (Int, Int) {
        let possibleMoves = board.getPossibleMoves()
        let randomIndex = Int(arc4random_uniform(UInt32(possibleMoves.count)))
        return possibleMoves[randomIndex]
    }
}

class HumanPlayer: Player {
    override func getMove(board: Board) -> (Int, Int) {
        // this has to be done some other way.
        return (0,0)
    }
}

class SmartPlayer: Player {
    override func getMove(board: Board) -> (Int, Int) {
        let turn = board.getCurrentPlayer()
        var noLossMoves = [(Int, Int)]()
        let possibleMoves = board.getPossibleMoves()
        if possibleMoves.count == 9 {
            return (1,1)
        } else {
            // check winning move
            for (row, col) in possibleMoves {
                board.simulateMove(row: row, col: col, player: turn)
                if board.hasWon(player: turn) {
                    board.simulateMove(row: row, col: col, player: 0)
                    return (row, col)
                }
                board.simulateMove(row: row, col: col, player: 0)
            }
            // check prevent loss move
            for (row, col) in possibleMoves {
                var opponent = 1
                if turn == 1 {
                    opponent = 2
                }
                board.simulateMove(row: row, col: col, player: opponent)
                if board.hasWon(player: opponent) {
                    board.simulateMove(row: row, col: col, player: 0)
                    noLossMoves.append((row, col))
                }
                board.simulateMove(row: row, col: col, player: 0)
            }
            if noLossMoves.count != 0 {
                return noLossMoves[0]
            }
            // return random move
            let randomIndex = Int(arc4random_uniform(UInt32(possibleMoves.count)))
            return possibleMoves[randomIndex]
        }
    }
}

class SmarterPlayer: Player {
    
    var player = -1
    var opponent = -1
    var choice = (-1,-1)
    
    func evaluateGameState(board: Board, depth: Int) -> Int {
        // evaluate and return game state
        if board.hasWon(player: player) {
            return 10 - depth
        } else if board.hasWon(player: opponent) {
            return depth - 10
        } else {
            return 0
        }
    }
    
    func minimax(board: Board, depth: Int) -> Int {
        // minimax algorithm to not lose
        if board.isOver() {
            return evaluateGameState(board: board, depth: depth)
        }
        let dep = depth + 1
        var scores = [Int]()
        var moves = [(Int, Int)]()
        let possibleMoves = board.getPossibleMoves()
        // if divisible by two, that means it's player's turn. If not, it's the opponent's turn.
        let playersTurn = (depth % 2 == 0)
        
        for (row, col) in possibleMoves {
            // simulate move
            board.simulateMove(row: row, col: col, player: (playersTurn) ? player : opponent)
            // then, calculate the score of the board after making this move
            let score = minimax(board: board, depth: dep)
            scores.append(score)
            moves.append((row, col))
            // delete move again
            board.simulateMove(row: row, col: col, player: 0)
        }
        
        // return the minimum or maximum score (depending on whether its the players turn or the opponents)
        let index = scores.index(of: (playersTurn) ? scores.max()! : scores.min()!)!
        choice = moves[index]
        return (playersTurn) ? scores.max()! : scores.min()!
    }
    
    override func getMove(board: Board) -> (Int, Int) {
        //minor enhancement in the early stages of the game
        let possibleMoves = board.getPossibleMoves()
        if possibleMoves.count == 9 {
            return (1,1)
        } else if possibleMoves.count == 8 {
            return (board.getField(row: 1, col: 1) == 0) ? (1,1) : (0,0)
        }
        player = board.getCurrentPlayer()
        opponent = (player == 1) ? 2 : 1
        _ = minimax(board: board, depth: 0)
        return choice
    }
}
