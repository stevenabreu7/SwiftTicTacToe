//
//  GameScene.swift
//  TicTacToe
//
//  Created by Steven Abreu on 25.04.17.
//  Copyright © 2017 stevenabreu. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // difficulty
    enum Difficulty {
        case random
        case smart
        case ai
    }
    var difficultyDict = [Difficulty.random : "RANDOM", Difficulty.smart : "SMART", Difficulty.ai : "PERFECT"]
    var level = Difficulty.random
    
    // nodes
    var label = SKLabelNode()
    var leftLine = SKShapeNode()
    var outerRectangle = SKShapeNode()
    var gameLabel = SKLabelNode()
    
    // node collections
    var elements = [SKSpriteNode]()
    var fields: [[SKShapeNode]] = Array(repeating: Array(repeating: SKShapeNode(), count: 3), count: 3)
    
    // helper variables
    var fieldSize: CGSize = CGSize()
    var positions: [[CGPoint]] = Array(repeating: Array(repeating: CGPoint(), count: 3), count: 3)
    
    // game logic
    var board = Board()
    var player = Player(name: "")
    var cpu = Player(name: "")
    var playerToMove = false
    var cpuThinking = false
    
    override func didMove(to view: SKView) {
        // initially setup the scene
        setupScene()
    }
    
    func setupScene() {
        // clear any nodes that might be laying around
        self.removeAllChildren()
        
        // title 
        for i in 0...2 {
            let title = SKLabelNode(text: "TIC TAC TOE")
            title.position = CGPoint(x: Double(i) * 7.5, y: Double(0.375 * self.size.height - CGFloat(i) * 5.0))
            title.fontColor = UIColor(white: CGFloat(0.1490196078) + CGFloat(i) * 0.3, alpha: 1.0)
            title.fontSize = 160
            title.zPosition = CGFloat(10 - i)
            title.fontName = "Futura-CondensedMedium"
            self.addChild(title)
        }
        
        // game label
        gameLabel = SKLabelNode(text: self.difficultyDict[self.level])
        gameLabel.position = CGPoint(x: 0, y: 0.275 * self.size.height)
        gameLabel.fontSize = 40
        gameLabel.fontName = "Futura-CondensedMedium"
        gameLabel.fontColor = UIColor.lightGray
        self.addChild(gameLabel)
        
        // label to start game
        label = SKLabelNode(text: "START")
        label.position = CGPoint(x: 0, y: -0.4 * self.size.height)
        label.fontColor = UIColor.black
        label.fontSize = 70
        label.zPosition = 10
        label.fontName = "Futura-CondensedMedium"
        self.addChild(label)
        let labelbg = SKShapeNode(rect: CGRect(x: -0.2 * self.size.width, y: -0.4 * self.size.height - 35, width: 0.4 * self.size.width, height: 120), cornerRadius: 0)
        labelbg.fillColor = UIColor.lightGray
        labelbg.strokeColor = UIColor.clear
        self.addChild(labelbg)
        
        // outer rectangle
        outerRectangle = SKShapeNode(rect: CGRect(x: -0.45 * self.size.width, y: -0.45 * self.size.width, width: 0.9 * self.size.width, height: 0.9 * self.size.width))
        outerRectangle.fillColor = UIColor.lightGray
        outerRectangle.strokeColor = UIColor.darkGray
        self.addChild(outerRectangle)
        
        // fields
        fieldSize = CGSize(width: CGFloat(0.25) * self.size.width, height: CGFloat(0.25) * self.size.width)
        // nested loop to created all 9 fields
        for i in 0...2 {
            for j in 0...2 {
                let x = (-0.3 + Double(j) * 0.3) * Double(self.size.width)
                let y = (0.3 - Double(i) * 0.3) * Double(self.size.width)
                positions[i][j] = CGPoint(x: x - 0.5 * Double(fieldSize.width), y: y - 0.5 * Double(fieldSize.height))
                fields[i][j] = SKShapeNode(rect: CGRect(origin: positions[i][j], size: fieldSize))
                positions[i][j] = CGPoint(x: x, y: y)
                fields[i][j].fillColor = UIColor.clear
                fields[i][j].strokeColor = UIColor.clear
                self.outerRectangle.addChild(fields[i][j])
            }
        }
        
        // separation lines
        let lineOffset = 0.025 * Double(self.size.width)
        let lineSize = CGSize(width: 5.0, height: 0.9 * self.size.width - 2.0 * CGFloat(lineOffset))
        // loop to create all 4 lines
        for i in 0...1 {
            // vertical lines
            var x = (-0.15 + 0.3 * Double(i)) * Double(self.size.width)
            var y = (-0.45) * Double(self.size.width)
            var linePoint = CGPoint(x: x - 0.5 * Double(lineSize.width), y: y + lineOffset)
            var lineRect = CGRect(origin: linePoint, size: lineSize)
            var line = SKShapeNode(rect: lineRect, cornerRadius: 5.0)
            line.fillColor = UIColor.black
            line.strokeColor = UIColor.black
            self.outerRectangle.addChild(line)
            // horizontal lines
            let flippedLineSize = CGSize(width: lineSize.height, height: lineSize.width)
            x = (-0.45) * Double(self.size.width)
            y = (-0.15 + 0.3 * Double(i)) * Double(self.size.width)
            linePoint = CGPoint(x: x + lineOffset, y: y - 0.5 * Double(flippedLineSize.height))
            lineRect = CGRect(origin: linePoint, size: flippedLineSize)
            line = SKShapeNode(rect: lineRect, cornerRadius: 5.0)
            line.fillColor = UIColor.black
            line.strokeColor = UIColor.black
            self.outerRectangle.addChild(line)
        }
    }
    
    // ***********************
    // **** Game behavior ****
    // ***********************
    
    func startGame() {
        // set up game logic
        board = Board()
        player = HumanPlayer(name: "human")
        switch level {
        case .random:
            cpu = RandomPlayer(name: "random")
        case .smart:
            cpu = SmartPlayer(name: "smart")
        case .ai:
            cpu = SmarterPlayer(name: "smarter")
        }
        playerToMove = true
    }
    
    func checkGame() {
        // check if game is over. if cpu is to move, then make that move. otherwise, wait for player move.
        if self.board.isOver() {
            gameOver()
        } else if !playerToMove {
            cpuMove()
        }
    }
    
    func gameOver() {
        // send messages according to game result
        let result = self.board.getResult()
        if result == .draw {
            gameLabel.text = "DRAW!"
        } else if result == .opponentWon {
            gameLabel.text = "YOU LOSE!"
        } else if result == .playerWon {
            gameLabel.text = "YOU WIN!"
        } else {
          print("ERRORRRR!")
        }
        playerToMove = false
    }
    
    func cleanupGame() {
        // remove all game sprites
        for e in self.elements {
            e.removeFromParent()
        }
        self.elements.removeAll()
        gameLabel.text = difficultyDict[self.level]
    }
    
    func cpuMove() {
        // execute CPU move
        let (row, col) = self.cpu.getMove(board: self.board)
        self.board.makeMove(row: row, col: col)
        self.makeCircle(row: row, col: col)
        playerToMove = true
        checkGame()
    }
    
    // ***********************
    // *** Game appearance ***
    // ***********************
    
    func makeCircle(row: Int, col: Int) {
        // make opponent move (circle)
        let circleTexture = SKTexture(image: #imageLiteral(resourceName: "circle"))
        let circle = SKSpriteNode(texture: circleTexture)
        circle.position = positions[row][col]
        circle.size.width = self.fieldSize.width * 0.8
        circle.size.height = self.fieldSize.height * 0.8
        self.elements.append(circle)
        self.outerRectangle.addChild(circle)
    }
    
    func makeCross(row: Int, col: Int) {
        // make player move (cross)
        let crossTexture = SKTexture(image: #imageLiteral(resourceName: "cross"))
        let cross = SKSpriteNode(texture: crossTexture)
        cross.position = positions[row][col]
        cross.size.width = self.fieldSize.width * 0.8
        cross.size.height = self.fieldSize.height * 0.8
        self.elements.append(cross)
        self.outerRectangle.addChild(cross)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let touchedNodes = nodes(at: t.location(in: self))
            // start node
            if touchedNodes.contains(label) {
                if label.text == "START" {
                    label.text = "CLEAR"
                    startGame()
                } else if label.text == "CLEAR" {
                    label.text = "START"
                    cleanupGame()
                }
            }
            // game label
            if touchedNodes.contains(gameLabel) {
                if self.level == .random {
                    self.level = .smart
                } else if self.level == .smart {
                    self.level = .ai
                } else {
                    self.level = .random
                }
                self.gameLabel.text = self.difficultyDict[self.level]
            }
            // fields
            for i in 0...2 {
                for j in 0...2 {
                    if touchedNodes.contains(fields[i][j]) {
                        if playerToMove {
                            if self.board.getField(row: i, col: j) == 0 {
                                // if field is empty and player is to move, then make this move
                                self.board.makeMove(row: i, col: j)
                                makeCross(row: i, col: j)
                                playerToMove = false
                                checkGame()
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
