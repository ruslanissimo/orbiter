//
//  GameScene.swift
//  Orbiter
//
//  Created by Руслан Шаяхметов on 20.02.2021.
//

import SpriteKit
import GameplayKit
import UIKit
import AudioToolbox

class GameScene: SKScene, SKPhysicsContactDelegate {
    var ui_counter = CGVector(dx: 0, dy: 0)
    var game_over = false
    let cam = SKCameraNode()
    var stars: [Star] = []
    var ship: [Ship] = []
    var big_bang_time = TimeInterval.zero
    var time = TimeInterval.zero
    var barrels = 10
    var barrel_label = SKLabelNode(fontNamed: "Roboto Mono")
    var time_label = SKLabelNode(fontNamed: "Roboto Mono")
    var vel_label = SKLabelNode(fontNamed: "Roboto Mono")
    var pointers: [SKLabelNode] = []
    let taptic_engine = UIImpactFeedbackGenerator(style: .heavy)
    let sound_node = SKNode()
    
    func add_barrels(value: Int) {
        barrels += value
        barrel_label.text = "BARRELS: \(barrels)"
        let attention = SKAction.sequence([SKAction.scale(to: 1.5, duration: 0.2), SKAction.scale(to: 1.0, duration: 0.2)])
        barrel_label.run(attention)
    }
    
    func sound(name: String) {
        let sound = SKAction.playSoundFileNamed("\(name).mp3", waitForCompletion: false)
        sound_node.run(sound)
    }
    
    func add_ship() {
        var position = ship.first!.body.position
        let velocity = ship.first!.body.physicsBody!.velocity
        position.x -= 0.3*velocity.dx
        position.y -= 0.3*velocity.dy
        //let velocity_value = modul(vec: velocity)
        ship.append(Ship(scene: self, position: position, velocity: velocity))
    }
    
    override func didMove(to view: SKView) {
        
        //Vibration
        taptic_engine.prepare()
        //Sound
        scene?.addChild(sound_node)
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.speed = 1.0
        
        scene?.backgroundColor = UIColor(red: 0.2197, green: 0.1804, blue: 0.7373, alpha: 1.0)
        let sun=Star(scene: self)
        ship.append(Ship(scene: self, master: sun,
                         orbit: CGFloat.random(in: 2*sun.radius...(13*sun.radius+257))))
        //camera
        self.addChild(cam)
        self.camera = cam
        
        //barrel label
        barrel_label.fontSize = 30
        barrel_label.text = "BARRELS: \(barrels)"
        barrel_label.fontColor = UIColor(red: 0.7872, green: 0.2666, blue: 0.196, alpha: 0.8)
        barrel_label.position = CGPoint(x: -scene!.size.width/2.52, y: scene!.size.height/2.4)
        scene!.camera!.addChild(barrel_label)
        
        //time label
        time_label.fontSize = 30
        time_label.text = "TIME: \(Int(time))"
        time_label.fontColor = UIColor(red: 0.7872, green: 0.2666, blue: 0.196, alpha: 0.8)
        time_label.position = CGPoint(x: scene!.size.width/2.52, y: scene!.size.height/2.4)
        scene!.camera!.addChild(time_label)
        
        //velocity label
        vel_label.fontSize = 30
        vel_label.text = "VELOCITY: 0"
        vel_label.fontColor = UIColor(red: 0.7872, green: 0.2666, blue: 0.196, alpha: 0.8)
        vel_label.position = CGPoint(x: 0, y: scene!.size.height/2.4)
        scene!.camera!.addChild(vel_label)
        
        //pointers
        for _ in 1...7 {
            let point = SKLabelNode(fontNamed: "Roboto Mono")
            point.fontSize = 90
            point.text = "^"
            point.fontColor = UIColor(red: 0.7872, green: 0.2666, blue: 0.196, alpha: 0.8)
            let radius = scene!.size.height/2.5
            let angle = CGFloat.pi/4
            point.position = CGPoint(x: radius*sin(angle), y: radius*cos(angle))
            point.zRotation = -angle
            point.zPosition = 100
            scene!.camera!.addChild(point)
            pointers.append(point)
        }
    }
    
    func restart() {
        let red = UIColor(red: 0.7872, green: 0.2666, blue: 0.196, alpha: 0.8)
        self.physicsWorld.speed = 0.05
        for each in stars {
            each.setSpeed(speed: 0.05)
        }
        ship.first!.body.removeAllActions()
        scene?.removeAllActions()
        ship.first?.wind?.stop()
        ship.first?.plasma.isHidden = true
        game_over = true
        
        let wait_frame = SKAction.wait(forDuration: 1)
        
        let tap_to_continue = SKLabelNode(fontNamed: "Roboto Mono")
        tap_to_continue.fontColor = red
        tap_to_continue.fontSize = 40
        tap_to_continue.text = "Tap to continue"
        tap_to_continue.position = CGPoint(x: 0, y: -self.size.height/4)
        tap_to_continue.zPosition = 100
        tap_to_continue.alpha = 0
        cam.addChild(tap_to_continue)
        
        let title = SKLabelNode(fontNamed: "Roboto Mono")
        title.fontColor = red
        title.fontSize = 100
        title.text = "Fatal Error"
        title.position = CGPoint(x: 0, y: self.size.height/4)
        title.zPosition = 100
        title.alpha = 0
        cam.addChild(title)
        let appear = SKAction.fadeAlpha(to: 0.5, duration: 0.4)
        let wait = SKAction.wait(forDuration: 0.4)
        let dissappear = SKAction.fadeAlpha(to: 0, duration: 0.4)
        var seq = SKAction.sequence([appear, wait, dissappear])
        title.run(SKAction.sequence([wait_frame, SKAction.repeatForever(seq)]))
        
        let error_frame = SKShapeNode(rect: CGRect(x: -350, y: self.size.height/4-20, width: 700, height: 120), cornerRadius: 10)
        error_frame.lineWidth = 3
        error_frame.strokeColor = red
        error_frame.alpha = 0
        cam.addChild(error_frame)
        error_frame.run(SKAction.sequence([wait_frame, SKAction.repeatForever(seq)]))
        
        let back = SKShapeNode(rect: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
        back.fillColor = UIColor.black
        back.alpha = 0
        back.zPosition = 99
        let back_act = SKAction.fadeAlpha(to: 0.3, duration: 1)
        back.run(back_act)
        cam.addChild(back)
        
        let frame = SKShapeNode(rect: CGRect(x: (-self.size.width/2)+25, y: (-self.size.height/2)+25,
                                             width: self.size.width-50, height: self.size.height-50), cornerRadius: 10)
        frame.lineWidth = 5
        frame.strokeColor = red
        frame.alpha = 0.5
        frame.setScale(0.01)
        let scale = SKAction.scale(by: 100, duration: 1)
        frame.run(scale)
        cam.addChild(frame)
        
        seq = SKAction.sequence([wait_frame, appear])
        tap_to_continue.run(seq)
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if game_over { return }
        
        if (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask) == 0b101 {
            sound(name: "crash_star")
            taptic_engine.impactOccurred()
            if (ship.count < 2||ship.first!.body.parent == nil) {
                restart()
            } else {
                let wave = SKSpriteNode(imageNamed: "atmosphere")
                wave.setScale(0.01)
                wave.position = contact.contactPoint
                scene?.addChild(wave)
                let rise = SKAction.scale(to: CGFloat(0.05), duration: 1)
                let disappear = SKAction.fadeAlpha(to: 0.0, duration: 1)
                wave.run(rise)
                wave.run(disappear)
                if contact.bodyA.categoryBitMask == 0b1 {
                    contact.bodyA.categoryBitMask = 0
                    contact.bodyA.node?.removeFromParent()
                    
                } else {
                    contact.bodyB.categoryBitMask = 0
                    contact.bodyB.node?.removeFromParent()
                }
            }
        }
        
        if (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask) == 0b11 {
            let hit_act = SKAction.repeat(SKAction.sequence([SKAction.rotate(toAngle: 0.1, duration: 0.01), SKAction.rotate(toAngle: -0.2, duration: 0.02), SKAction.rotate(toAngle: 0.1, duration: 0.01)]), count: 10)
            cam.run(hit_act)
            let wave = SKSpriteNode(imageNamed: "atmosphere")
            wave.setScale(0.01)
            contact.bodyB.node!.addChild(wave)
            let rise = SKAction.scale(to: CGFloat(0.1), duration: 1)
            let disappear = SKAction.fadeAlpha(to: 0.0, duration: 1)
            wave.run(rise)
            wave.run(disappear)
            sound(name: "hit")
            taptic_engine.impactOccurred()
        }
        
        if (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask) == 0b110 {
            let wave = SKSpriteNode(imageNamed: "atmosphere")
            wave.setScale(0.01)
            wave.position = contact.contactPoint
            scene?.addChild(wave)
            let rise = SKAction.scale(to: CGFloat(0.05), duration: 1)
            let disappear = SKAction.fadeAlpha(to: 0.0, duration: 1)
            wave.run(rise)
            wave.run(disappear)
            
            if contact.bodyA.categoryBitMask == 0b10 {
                contact.bodyA.categoryBitMask = 0
                contact.bodyA.node?.removeFromParent()
                
            } else {
                contact.bodyB.categoryBitMask = 0
                contact.bodyB.node?.removeFromParent()
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if game_over { return }
        
        //Remove all ships from array that was removed from scene
        var isnt_clear = true
        while isnt_clear {
            for each in ship.enumerated() {
                if each.element.body.parent == nil {
                    ship.remove(at: each.offset)
                    break
                }
                if each.offset == ship.count-1 {
                    isnt_clear = false
                }
            }
        }
        
        //Pointers
        for each in stars.enumerated() {
            let vec = vec_init(from: ship.first!.body.position, to: each.element.body.position)
            let ang = angle(vector: vec)
            let distance = modul(vec: vec)
            let radius = scene!.size.height/2.5
            pointers[each.offset].position = CGPoint(x: radius*sin(ang), y: radius*cos(ang))
            pointers[each.offset].zRotation = -ang
            pointers[each.offset].alpha = 1
            if distance > 3000 {
                pointers[each.offset].alpha = CGFloat(2-distance/3000)
            }
            if distance < 2.5*radius {
                pointers[each.offset].alpha = 0
            }
        }
            
        //Ship update
        var master: Ship? = nil
        var center: Star? = nil
        for each in ship.enumerated() {
            if each.offset == 0 {
                //master ship
                master = each.element
                center = master!.update(scene: self, cam: cam)
            } else {
                each.element.update_as_slave(master: master!, my_num: each.offset, center: center!)
            }
        }
        
        //Time calc
        if big_bang_time == TimeInterval.zero {
            big_bang_time = currentTime
        }
        time = currentTime-big_bang_time
        time_label.text = "TIME: \(Int(time))"
        vel_label.text = "VELOCITY: \(Int(modul(vec: ship.first!.body.physicsBody!.velocity)))"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if game_over {
            let scene = GameScene(size: CGSize(width: 1334, height: 750))
            view?.presentScene(scene, transition: SKTransition.fade(with: UIColor(red: 0.145, green: 0.1333, blue: 0.498, alpha: 1.0), duration: 1))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            ui_counter.dy = touch.location(in: self).y-touch.previousLocation(in: self).y
            ui_counter.dx = touch.location(in: self).x-touch.previousLocation(in: self).x
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if barrels > 0 {
            add_barrels(value: -1)
            for each in ship {
                let barrel = Barrel(scene: self, position: each.body.position, velocity: each.body.physicsBody!.velocity)
                if abs(ui_counter.dx)>abs(ui_counter.dy) {
                    each.body.physicsBody?.applyImpulse(CGVector(dx: sign(-Double(ui_counter.dx))*3, dy: 0))
                    barrel.body.position.x += CGFloat(sign(Double(ui_counter.dx))*33)
                    barrel.body.physicsBody?.applyImpulse(CGVector(dx: sign(Double(ui_counter.dx))*3, dy: 0))
                } else {
                    each.body.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 3*sign(-Double(ui_counter.dy))))
                    barrel.body.position.y += CGFloat(sign(Double(ui_counter.dy))*33)
                    barrel.body.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 3*sign(Double(ui_counter.dy))))
                }
            }
        }
    }
}
