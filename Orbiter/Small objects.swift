//
//  Small objects.swift
//  Orbiter
//
//  Created by Руслан Шаяхметов on 12.03.2021.
//

import Foundation
import SpriteKit
import GameplayKit
import AVFoundation

class Asteroid {
    var body = SKNode()
    var radius = CGFloat(0)

    func type_of_body() {
        radius = CGFloat.random(in: 1...5)
        body = SKShapeNode(circleOfRadius: radius)
        (body as! SKShapeNode).lineWidth = 0
        let gray_scale = CGFloat.random(in: 0.5...0.9)
        (body as! SKShapeNode).fillColor = UIColor(red: gray_scale, green: gray_scale, blue: gray_scale, alpha: 1)
        body.physicsBody = SKPhysicsBody.init(circleOfRadius: radius)
    }
    
    init(scene: SKScene, position: CGPoint, velocity: CGVector) {
        type_of_body()
        body.zPosition = 1
        body.physicsBody?.usesPreciseCollisionDetection = true
        body.physicsBody?.affectedByGravity = false
        body.physicsBody!.isDynamic = true
        body.physicsBody?.linearDamping = 0.0
        body.physicsBody?.categoryBitMask = 0b10
        body.physicsBody?.contactTestBitMask = 0b1111
        scene.addChild(body)
        
        body.position = position
        body.physicsBody!.velocity = velocity
    }
    
    init(scene: SKScene, master: Star, orbit: CGFloat) {
        type_of_body()
        body.zPosition = 1
        body.physicsBody?.usesPreciseCollisionDetection = true
        body.physicsBody?.affectedByGravity = false
        body.physicsBody!.isDynamic = true
        body.physicsBody?.linearDamping = 0.0
        body.physicsBody?.categoryBitMask = 0b10
        body.physicsBody?.contactTestBitMask = 0b1111
        scene.addChild(body)
        
        //launching
        let angle = CGFloat.random(in: 0...2*CGFloat.pi)
        body.position.x = master.body.position.x + (orbit * sin(angle))
        body.position.y = master.body.position.y + (orbit * cos(angle))
        let circle_orbit_velocity = -1700*sqrt((CGFloat(master.gravity.strength)+body.physicsBody!.mass)/orbit)
        body.physicsBody?.velocity.dx = circle_orbit_velocity * cos(-angle)
        body.physicsBody?.velocity.dy = circle_orbit_velocity * sin(-angle)
    }
}

class Barrel: Asteroid {
    override func type_of_body() {
        body = SKSpriteNode(imageNamed: "barrel")
        body.setScale(CGFloat(0.02))
        (body as! SKSpriteNode).physicsBody = SKPhysicsBody(rectangleOf: (body as! SKSpriteNode).size)
    }
}

class Ship: Asteroid {
    var previous_ship_pos = CGPoint(x: 0, y: 0)
    var counter = 0
    var Pointer_navigate: [SKLabelNode] = []
    var UImarks: [SKNode] = []
    var star_alarm = false
    var asteroid_alarm = false
    var star_alarm_sound = SKAction()
    var asteroid_alarm_sound = SKAction()
    var asteroid_zone = SKShapeNode()
    let plasma = SKSpriteNode(imageNamed: "plasma")
    var wind: AVAudioPlayer? = nil
    
    override func type_of_body() {
        body = SKSpriteNode(imageNamed: "ship")
        body.setScale(CGFloat(0.05))
        (body as! SKSpriteNode).physicsBody = SKPhysicsBody(rectangleOf: (body as! SKSpriteNode).size)
        
        body.addChild(plasma)
        plasma.isHidden = true
    }
    
    override init(scene: SKScene, master: Star, orbit: CGFloat) {
        super.init(scene: scene, master: master, orbit: orbit)
        body.physicsBody?.categoryBitMask = 0b1
        body.physicsBody?.angularDamping = 1.2
        previous_ship_pos = body.position
        //blink
        let blink = SKSpriteNode(imageNamed: "blink")
        blink.setScale(CGFloat(1.25))
        blink.alpha = 0.0
        let appear = SKAction.fadeAlpha(to: 1.0, duration: 0.01)
        let disappear = SKAction.fadeAlpha(to: 0.0, duration: 0.01)
        let wait_short = SKAction.wait(forDuration: 0.05)
        let wait_long = SKAction.wait(forDuration: 2)
        let seq = SKAction.sequence([appear, wait_short, disappear, wait_short, appear, wait_short, disappear, wait_long])
        body.addChild(blink)
        blink.run(SKAction.repeatForever(seq))
        
        asteroid_zone = SKShapeNode(ellipseOf: CGSize(width: 4000, height: 8000))
        asteroid_zone.position = CGPoint(x: 0, y: 2000)
        asteroid_zone.isHidden = true
        body.addChild(asteroid_zone)
        
        star_alarm_sound = SKAction.repeatForever(SKAction.playSoundFileNamed("alarm1.mp3", waitForCompletion: true))
        asteroid_alarm_sound = SKAction.repeatForever(SKAction.playSoundFileNamed("alarm2.mp3", waitForCompletion: true))
        
        let path = Bundle.main.path(forResource: "wind.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        do {
            wind = try AVAudioPlayer(contentsOf: url)
        } catch {
            print("Wind.mp3 doesn't found")
            exit(1)
        }
            
    }
    
    override init(scene: SKScene, position: CGPoint, velocity: CGVector) {
        super.init(scene: scene, position: position, velocity: velocity)
        body.physicsBody?.categoryBitMask = 0b1
        body.physicsBody?.angularDamping = 1.2
        previous_ship_pos = body.position
        //blink
        let blink = SKSpriteNode(imageNamed: "blink")
        blink.setScale(CGFloat(1.25))
        blink.alpha = 0.0
        let appear = SKAction.fadeAlpha(to: 1.0, duration: 0.01)
        let disappear = SKAction.fadeAlpha(to: 0.0, duration: 0.01)
        let wait_short = SKAction.wait(forDuration: 0.05)
        let wait_long = SKAction.wait(forDuration: 2)
        let seq = SKAction.sequence([appear, wait_short, disappear, wait_short, appear, wait_short, disappear, wait_long])
        body.addChild(blink)
        blink.run(SKAction.repeatForever(seq))
        
        asteroid_zone = SKShapeNode(ellipseOf: CGSize(width: 4000, height: 8000))
        asteroid_zone.position = CGPoint(x: 0, y: 2000)
        asteroid_zone.isHidden = true
        body.addChild(asteroid_zone)
        
        star_alarm_sound = SKAction.repeatForever(SKAction.playSoundFileNamed("alarm1.mp3", waitForCompletion: true))
        asteroid_alarm_sound = SKAction.repeatForever(SKAction.playSoundFileNamed("alarm2.mp3", waitForCompletion: true))
    }
    
    func update_as_slave(master: Ship, my_num: Int, center: Star) {
        //Rotation controller
        let target_angle = atan2((body.physicsBody?.velocity.dy)!, (body.physicsBody?.velocity.dx)!)
        var torque = target_angle-body.zRotation-CGFloat.pi/2
        if torque < -CGFloat.pi {
            torque+=2*CGFloat.pi
        }
        if torque > CGFloat.pi {
            torque-=2*CGFloat.pi
        }
        body.physicsBody?.applyTorque(0.005*torque)
        
        //Position controller
        let force_factor = CGFloat(0.2)
        var vec = vec_init(from: body.position, to: master.body.position)
        vec = scalar_mult(vector: vec, scalar: force_factor)
        if modul(vec: vec) < 50 {
            body.physicsBody?.applyForce(vec)
            master.body.physicsBody?.applyForce(inv_vec(vec: vec))
        }
        
        //Tracking
        let velocity = modul(vec: body.physicsBody!.velocity)
        if counter == 0 {
            var path = [body.position, previous_ship_pos]
            let track = SKShapeNode(points: &path, count: 2)
            track.lineWidth = 4
            track.strokeColor = UIColor(red: 0.9098, green: 0.94901, blue: 0.8902, alpha: 0.5)
            previous_ship_pos = body.position
            master.body.scene!.addChild(track)
            if velocity>150 {
            counter = Int(2000/velocity)
            } else {counter = 13}
        }
        counter -= 1
        cheack_atm(center: center)
    }
    
    func update(scene: GameScene, cam: SKCameraNode) -> Star {
        //Rotation controller
        let target_angle = atan2((body.physicsBody?.velocity.dy)!, (body.physicsBody?.velocity.dx)!)
        var torque = target_angle-body.zRotation-CGFloat.pi/2
        if torque < -CGFloat.pi {
            torque+=2*CGFloat.pi
        }
        if torque > CGFloat.pi {
            torque-=2*CGFloat.pi
        }
        torque *= 0.005
        body.physicsBody?.applyTorque(torque)
        
        //Track
        let velocity = modul(vec: body.physicsBody!.velocity)
        if counter == 0 {
            var path = [body.position, previous_ship_pos]
            let track = SKShapeNode(points: &path, count: 2)
            track.lineWidth = 4
            track.strokeColor = UIColor(red: 0.9098, green: 0.94901, blue: 0.8902, alpha: 0.5)
            previous_ship_pos = body.position
            scene.addChild(track)
            if velocity>150 {
            counter = Int(2000/velocity)
            } else {counter = 13}
        }
        counter -= 1
        //camera
        cam.position.x = body.position.x
        cam.position.y = body.position.y
        
        if velocity>70 {
            let scale = SKAction.scale(to: (velocity/300)+0.7, duration: 1.5)
            cam.run(scale)
        } else { let scale = SKAction.scale(to: 0.933333, duration: 1.5)
            cam.run(scale) }
        
        //navigation marker
        //Dynamics loading
        struct dist_table {
            let distance: CGFloat
            let star: Star
        }
        var distances: [dist_table] = []
        for each in scene.stars {
            distances.append(dist_table(distance: dist_between(pointA: each.body.position, pointB: body.position), star: each))
        }
        let center = distances.min(by: ({ (a, b) -> Bool in return a.distance < b.distance }))
        if !center!.star.is_center {
            center?.star.rebuild_universe(scene: scene)
        }
        predict(scene: scene, center: center!.star)
        
        //checking reachability of the bonus
        for each in center!.star.bonuses.enumerated() {
            if dist_between(pointA: each.element.position, pointB: body.position) < CGFloat(50) {
                if each.element.children.count > 1 { //ship
                    scene.add_ship()
                } else {
                    scene.add_barrels(value: 3)
                }
                each.element.removeFromParent()
                center!.star.bonuses.remove(at: each.offset)
                scene.sound(name: "bonus")
                break
            }
        }
        cheack_atm(center: center!.star)
        return center!.star
    }
    
    func cheack_atm(center: Star) {
        let atm = center.all_atm()
        var in_atm = false
        for each in atm {
            if body.intersects(each) {
                if plasma.isHidden == true {
                    wind?.play()
                }
                plasma.isHidden = false
                in_atm = true
                break
            }
        }
        if !in_atm {
            wind?.stop()
            plasma.isHidden = true
        }
    }
    
    func predict(scene: GameScene, center: Star) {
        
        let old_star_alarm = star_alarm
        let old_asteroid_alarm = asteroid_alarm
        //track
        for each in UImarks {
            each.removeFromParent()
        }
        UImarks.removeAll()
        
        
        //_____Star alarm part______
        //
        //Types of data for star alarm
        struct closest_body {
            let body: Star
            let radius_vector: CGVector
        }
        let threshold_distance = CGFloat(1000)
        //The threshold angle defined as line function depends on distance
        //the +-90 degree at zero distance and +-0 degree at threshold distance
        //_____angle = k*dist + m
        func threshold_angle(dist: CGFloat) -> CGFloat {
            let limit_angle = CGFloat.pi/3
            let k = -limit_angle/threshold_distance
            let m = limit_angle
            let value = k*dist + m
            return value
        }
        
        //Planets checking
        star_alarm = false
        for each in center.all_bodies() {
            let radius_vector = vec_init(from: body.position, to: each.body.position)
            let dist = modul(vec: radius_vector)-each.radius
            if  dist < threshold_distance {
                // Ship very close to dangerous
                let ship_direction = angle(vector: body.physicsBody!.velocity)
                let dangerous_direction = angle(vector: radius_vector)
                let diff = abs(ship_direction - dangerous_direction)
                if  diff < threshold_angle(dist: dist) {
                    star_alarm = true
                    if !old_star_alarm {
                        body.run(star_alarm_sound, withKey: "Star_alarm")
                    }
                    //Make mark
                    let mark = add_mark(pos: each.body.position, radius: each.radius)
                    scene.addChild(mark)
                    UImarks.append(mark)
                    //Make track
                    var path = [body.position, each.body.position]
                    let track = SKShapeNode(points: &path, count: 2)
                    track.lineWidth = 4
                    track.strokeColor = UIColor(red: 0.7872, green: 0.2666, blue: 0.196, alpha: 0.8)
                    scene.addChild(track)
                    UImarks.append(track)
                    //Make label
                    let label = SKLabelNode(fontNamed: "Roboto Mono")
                    label.text = "\(Int(dist)) - IMPACT!!!"
                    label.fontColor = UIColor(red: 0.7872, green: 0.2666, blue: 0.196, alpha: 0.8)
                    label.fontSize = 40
                    label.position = each.body.position
                    if each.body.position.y>body.position.y {
                        label.position.y += 20+each.radius
                    } else {
                        label.position.y -= 20+each.radius
                    }
                    scene.addChild(label)
                    UImarks.append(label)
                }
            }
        }
        
        //________Asteroid alarm part__________
        //
        //
        asteroid_alarm = false
        let temp = center.check_asteroid(v: asteroid_zone)
        if temp != [] {
            asteroid_alarm = true
            for each in temp {
                scene.addChild(each)
                UImarks.append(each)
                if !old_asteroid_alarm {
                    body.run(asteroid_alarm_sound, withKey: "Asteroid_alarm")
                }
            }
        }
        if !star_alarm {
            body.removeAction(forKey: "Star_alarm")
        }
        if !asteroid_alarm {
            body.removeAction(forKey: "Asteroid_alarm")
        }
    }
}
