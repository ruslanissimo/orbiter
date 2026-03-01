//
//  Stars and Planet.swift
//  Orbiter
//
//  Created by Руслан Шаяхметов on 12.03.2021.
//

import Foundation
import SpriteKit
import GameplayKit

class Star {
    
    var body = SKShapeNode()
    var slaves: [Planet] = []
    var background_star: [SKNode] = []
    var is_star = true
    var is_center = false
    let gravity = SKFieldNode.radialGravityField()
    var radius = CGFloat.zero
    let interstellar = CGFloat(6000)
    var oreol = SKSpriteNode()
    var dist_to_ship = CGFloat.zero
    var asteroids: [Asteroid] = []
    var bonuses: [SKSpriteNode] = []
    
    func build_oreol() {
        let core = SKShapeNode(circleOfRadius: radius*0.8)
        core.fillColor = body.fillColor
        core.lineWidth = 0
        core.zPosition = 1
        body.addChild(core)
        
        oreol = SKSpriteNode(imageNamed: "Star_oreol")
        oreol.scale(to: CGSize(width: 2*radius, height: 2*radius))
        body.addChild(oreol)
    }
    
    func set_bonuses(time: TimeInterval) {
        //The difficulty of the game must be defined by time
        //the longer happend game the more difficult become game
        //Function of the difficulty:
        //
        //      number_of_bonuses(NOB) = 1/time
        //
        //For having the more control we add two constant:
        // - Maximum number of bonuses (MAX)
        //   The constant decide default easiest quantity of bonuses
        // - Complication factor (COMPX)
        //   The constant define duration of the complication curve
        //
        //Example, max = 10; complication = 1
        //
        //      number_of_bonuses = 10/time+1
        //
        let MAX = 10.0
        let COMPX = 300.0
        let NOB = Int((MAX*COMPX)/(time+COMPX))
        
        for _ in 1...NOB {
            body.scene!.addChild(add_bonuse(star: self))
        }
        for _ in 1...Int(time)+1 {
            let asteroid = Asteroid(scene: body.scene!, master: self,
                                    orbit: CGFloat.random(in: 2*radius...((13*radius)+257)))
            asteroids.append(asteroid)
        }
    }
    
    init(){}
    init(scene: GameScene, size: CGFloat, point: CGPoint, is_planet: Bool) {
        if size < 10 {return}
        is_star = !is_planet
        radius = size
        body = SKShapeNode(circleOfRadius: size)
        body.position = point
        body.fillColor = UIColor(hue: CGFloat.random(in: 0...1), saturation: CGFloat.random(in: 0.5...1), brightness: 1, alpha: 1)
        body.lineWidth = 0
        body.zPosition = 1
        body.physicsBody = SKPhysicsBody.init(circleOfRadius: size)
        body.physicsBody?.usesPreciseCollisionDetection = true
        body.physicsBody?.affectedByGravity = false
        body.physicsBody!.isDynamic = false
        body.physicsBody?.categoryBitMask = 0b100
        body.physicsBody?.contactTestBitMask = 0b1011
        gravity.strength = Float(10*body.physicsBody!.mass)
        body.addChild(gravity)
        scene.addChild(body)
        if is_star {
            scene.stars.append(self)
        }
        build_oreol()
    }
    
    convenience init(scene: GameScene) {
        self.init(scene: scene, size: CGFloat.random(in: 25...200), point: CGPoint.zero, is_planet: false)
        build_system()
        set_bonuses(time: scene.time)
        is_center = true
        
        //Background star
        for _ in 0...400 {
            let bkgrd_star = SKShapeNode(circleOfRadius: CGFloat(Int.random(in: 1...3)))
            bkgrd_star.alpha = 0.75
            bkgrd_star.fillColor = UIColor.white
            let rad = (interstellar/2)*1.2
            var x = rad
            var y = rad
            while sqrt(x*x+y*y)>(rad) {
                x = CGFloat.random(in: -rad...rad)
                y = CGFloat.random(in: -rad...rad)
            }
            bkgrd_star.position = CGPoint(x: x, y: y)
            body.parent!.addChild(bkgrd_star)
            background_star.append(bkgrd_star)
            
            //Blink motherfacker
            let period = TimeInterval.random(in: 0.1...2)
            let blink = SKAction.sequence([SKAction.fadeAlpha(to: 0, duration: period), SKAction.fadeAlpha(to: 0.75, duration: period)])
            if CGFloat.random(in: 0...1) > 0.4 {
                bkgrd_star.run(SKAction.repeatForever(blink))
            }
        }
        
        for index in 0...5 {
            let angle = CGFloat.pi*CGFloat(index)/3
            let position = CGPoint(x: interstellar*sin(angle), y: interstellar*cos(angle))
            let _=Star(scene: scene, size: CGFloat.random(in: 25...200), point: position, is_planet: false)
        }
    }
    
    func check_asteroid(v: SKShapeNode) -> [SKShapeNode] {
        var temp: [SKShapeNode] = []
        for each in asteroids {
            if each.body.intersects(v)&&(each.body.physicsBody?.categoryBitMask != 0) {
                temp.append(add_mark(pos: each.body.position, radius: 2*each.radius))
            }
        }
        return temp
    }
    
    func all_bodies() -> [Star] {
        var returnable: [Star] = []
        returnable.append(self)
        for planet in slaves {
            returnable.append((planet as Star))
            for satelite in planet.slaves {
                returnable.append((satelite as Star))
            }
        }
        return returnable
    }
    
    func all_atm() -> [SKSpriteNode] {
        var returnable: [SKSpriteNode] = []
        for planet in slaves {
            if planet.atmosphere != nil {
                returnable.append(planet.atmosphere!)
            }
            for satelite in planet.slaves {
                if satelite.atmosphere != nil {
                    returnable.append(satelite.atmosphere!)
                }
            }
        }
        return returnable
    }
    
    func delete_background_stars() {
        for each in background_star {
            each.removeAllActions()
            each.removeFromParent()
        }
        background_star.removeAll()
        is_center = false
        for each in bonuses {
            each.removeAllActions()
            each.removeFromParent()
        }
        bonuses.removeAll()
    }
    
    func delete() {
        if !is_star {
            print("Try to delete planet without a star");
            exit(1) }
        
        
        for each in asteroids {
            each.body.removeAllActions()
            each.body.removeFromParent()
        }
        asteroids.removeAll()
        
        for each in slaves {
            for each_of_each in each.slaves {
                each_of_each.body.removeFromParent()
            }
            each.slaves.removeAll()
            each.body.removeFromParent()
        }
        self.slaves.removeAll()
        body.removeFromParent()
    }
    
    func rebuild_universe(scene: GameScene) {
        
        var temp: [Star] = []
        for each in scene.stars {
            each.delete_background_stars()
            if dist_between(pointA: each.body.position, pointB: body.position) < 1.2*interstellar {
                temp.append(each)
            } else {
                each.delete()
            }
        }
        scene.stars.removeAll()
        for each in temp {
            scene.stars.append(each)
        }
        
        
        //Add stars that close to the center
        for index in 0...5 {
            let angle = CGFloat.pi*CGFloat(index)/3
            let position = CGPoint(x: interstellar*sin(angle)+body.position.x,
                                   y: interstellar*cos(angle)+body.position.y)
            var exist = false
            for each in scene.stars {
                let dist = dist_between(pointA: each.body.position, pointB:position)
                if dist<CGFloat(100) { exist = true; break }
            }
            if !exist {
                let new_star=Star(scene: scene, size: CGFloat.random(in: 25...200), point: position, is_planet: false)
                new_star.build_system()
            }
        }
        
        is_center = true
        set_bonuses(time: scene.time)
        
        //Background stars
        let appearing = SKAction.fadeAlpha(to: 0.75, duration: 3)
        for _ in 0...400 {
            let bkgrd_star = SKShapeNode(circleOfRadius: CGFloat(Int.random(in: 1...3)))
            bkgrd_star.alpha = 0
            bkgrd_star.fillColor = UIColor.white
            let rad = (interstellar/2)*1.2
            var x = rad
            var y = rad
            while sqrt(x*x+y*y)>(rad) {
                x = CGFloat.random(in: -rad...rad)
                y = CGFloat.random(in: -rad...rad)
            }
            bkgrd_star.position = CGPoint(x: x+body.position.x, y: y+body.position.y)
            body.parent!.addChild(bkgrd_star)
            background_star.append(bkgrd_star)
            
            //Blink motherfacker
            let period = TimeInterval.random(in: 0.1...2)
            let blink = SKAction.sequence([SKAction.fadeAlpha(to: 0, duration: period), SKAction.fadeAlpha(to: 0.75, duration: period)])
            if CGFloat.random(in: 0...1) > 0.6 {
                bkgrd_star.run(SKAction.repeatForever(blink))
            } else {
                bkgrd_star.run(appearing)
            }
        }
        
    }
    
    func build_system() {
        if !slaves.isEmpty {
            print("Attemt to build system for a star with slaves")
            print("Build_system method is available only for stars without slaves!!!")
            exit(1)
        }
        
        //The maximum orbit for star with radius 25 is 600
        //The maximum orbit for star with radius 200 is 3000
        //
        //The equation of the line dipendence between size and gravity field:
        //
        //      y = 13x + 257
        //
        var max_size = CGFloat(50)
        if !is_star {
            max_size = radius
        }
        
        var project_size: [CGFloat] = []
        var project_orbit: [CGFloat] = []
        
        var minimum_orbit = 2*self.radius
        let maximum_orbit = 13*self.radius + 257
        
        //Planning the system
        while minimum_orbit<maximum_orbit {
            project_size.append(CGFloat.random(in: 10...max_size))
            if project_size.last! > 30 {//then planet has atmosphere
                project_orbit.append(minimum_orbit + ((13 * project_size.last! + 257) / 2) + 5*project_size.last!)
                //The ammount defined accordint to equation above plus ten radius of the planet due to atmosphere
                minimum_orbit += 23*project_size.last!+257 
            } else {
                project_orbit.append(minimum_orbit + ((13 * project_size.last! + 257) / 2))
                //The ammount defined accordint to equation above plus two radius of the planet
                minimum_orbit += 15*project_size.last!+257
            }
        }
        
        //Remove excess
        project_size.removeLast()
        project_orbit.removeLast()
        
        //Empty system
        if project_orbit.isEmpty{ return }
        
        //Normalize the system
        let final_orbit = project_orbit.last!+((13*project_size.last!+257)/2)
        let norm_appendix = (maximum_orbit-final_orbit)/CGFloat(project_orbit.count)
        
        //Build the system
        for index in 0...project_orbit.count-1 {
            addSlave(size: project_size[index], orbit: project_orbit[index]+norm_appendix, atm: project_size[index]>30)
            if is_star {
                slaves.last?.build_system()
            }
        }
    }
    
    func addSlave(size: CGFloat, orbit: CGFloat, atm: Bool) {
        let slave = Planet(parent: self, size: size, orbit: orbit, atm: atm)
        slaves.append(slave)
    }
    
    func setSpeed(speed: CGFloat) {
        for each in slaves {
            for sub_each in each.slaves {
                sub_each.body.speed = speed
            }
            each.body.speed = speed
        }
    }
}

class Planet: Star {
    var moon_mov = SKAction()
    var period = TimeInterval(0)
    var velocity = CGFloat(0)
    var atmosphere: SKSpriteNode? = nil
    
    override func build_oreol() {
        oreol = SKSpriteNode(imageNamed: "shadow")
        oreol.scale(to: CGSize(width: 2*radius, height: 2*radius))
        body.addChild(oreol)
    }
    
    init(parent: Star, size: CGFloat, orbit: CGFloat, atm: Bool) {
        super.init(scene: parent.body.scene! as! GameScene, size: size, point: CGPoint(x: 0, y: 0), is_planet: true)
        body.fillColor = UIColor(hue: CGFloat.random(in: 0...1), saturation: 1, brightness: CGFloat.random(in: 0.25...0.75), alpha: 1)
        body.position = CGPoint(x: parent.body.position.x+orbit, y: parent.body.position.y)
        let path = UIBezierPath(arcCenter: CGPoint(x: -orbit, y: 0), radius: orbit, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        let path_node = SKShapeNode(path: path.cgPath)
        path_node.position = CGPoint(x: orbit, y: 0)
        path_node.alpha = 0.3
        velocity = 50000/orbit
        period = TimeInterval(2*CGFloat.pi*orbit/velocity)
        moon_mov = SKAction.repeatForever(SKAction.follow(path.cgPath, speed: 50000/orbit))
        if !parent.is_star {
            let gr_action = SKAction.group([(parent as! Planet).moon_mov, moon_mov])
            body.run(gr_action)
            
            //Shadow
            let stop_own_rot = SKAction.rotate(byAngle: -2*CGFloat.pi, duration: period)
            let parent_rot = SKAction.rotate(byAngle: 2*CGFloat.pi, duration: (parent as! Planet).period)
            oreol.run(SKAction.repeatForever(stop_own_rot))
            oreol.run(SKAction.repeatForever(parent_rot))
        } else {
            body.run(moon_mov)
        }
        parent.body.addChild(path_node)
        
        if atm {
            atmosphere = SKSpriteNode(imageNamed: "atmosphere")
            atmosphere!.scale(to: CGSize(width: size*10, height: size*10))
            atmosphere!.alpha = 0.2
            body.addChild(atmosphere!)
        }
    }
}

