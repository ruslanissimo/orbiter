//
//  InitScene.swift
//  Orbiter
//
//  Created by Руслан Шаяхметов on 30.03.2021.
//

import Foundation
import SpriteKit

class InitScene: SKScene {
    
    override func didMove(to view: SKView) {
        scene?.backgroundColor = UIColor(red: 0.2197, green: 0.1804, blue: 0.7373, alpha: 1.0)
        
        for _ in 0...100 {
            let bkgrd_star = SKShapeNode(circleOfRadius: CGFloat(Int.random(in: 1...3)))
            bkgrd_star.alpha = 0.75
            bkgrd_star.fillColor = UIColor.white
            let x = CGFloat.random(in: 0...size.width)
            let y = CGFloat.random(in: 0...size.height)
            bkgrd_star.position = CGPoint(x: x, y: y)
            addChild(bkgrd_star)
            
            //Blink motherfacker
            let period = TimeInterval.random(in: 0.1...2)
            let blink = SKAction.sequence([SKAction.fadeAlpha(to: 0, duration: period), SKAction.fadeAlpha(to: 0.75, duration: period)])
            if CGFloat.random(in: 0...1) > 0.4 {
                bkgrd_star.run(SKAction.repeatForever(blink))
            }
        }
        
        //STAR
        var position = CGPoint(x: 150, y: size.height/2)
        var radius = CGFloat(200)
        let body = SKShapeNode(circleOfRadius: radius)
        body.fillColor = UIColor(hue: CGFloat.random(in: 0...1),
                                 saturation: CGFloat.random(in: 0.5...1),
                                 brightness: 1, alpha: 1)
        body.lineWidth = 0
        body.position = position
        addChild(body)
        
        let core = SKShapeNode(circleOfRadius: radius*0.8)
        core.fillColor = body.fillColor
        core.lineWidth = 0
        core.zPosition = 1
        core.position = position
        addChild(core)
        
        let oreol = SKSpriteNode(imageNamed: "Star_oreol")
        oreol.scale(to: CGSize(width: 2*radius, height: 2*radius))
        oreol.position = position
        addChild(oreol)
        
        //Planet
        radius = 100
        position.x = size.width-150
        
        let body_p = SKShapeNode(circleOfRadius: radius)
        body_p.fillColor = UIColor(hue: CGFloat.random(in: 0...1),
                                   saturation: 1,
                                   brightness: CGFloat.random(in: 0.25...0.75),
                                   alpha: 1)
        body_p.lineWidth = 0
        body_p.position = position
        addChild(body_p)
        
        let shadow = SKSpriteNode(imageNamed: "shadow")
        shadow.scale(to: CGSize(width: 2*radius, height: 2*radius))
        shadow.position = position
        addChild(shadow)
        
        let appearing = SKAction.fadeAlpha(to: 1, duration: 1)
        let wait = SKAction.wait(forDuration: 1)
        
        let name = SKLabelNode(fontNamed: "Roboto Mono")
        name.text = "SHAIAKHMETOV RUSLAN"
        name.fontSize = 50
        name.fontColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
        name.alpha = 0
        name.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(name)
        name.run(SKAction.sequence([wait,appearing]))
        
        let dev = SKLabelNode(fontNamed: "Roboto Mono")
        dev.text = "DEVELOPED BY"
        dev.fontSize = 50
        dev.alpha = 0
        dev.fontColor = UIColor(red: 0.7872, green: 0.2666, blue: 0.196, alpha: 0.8)
        dev.position = CGPoint(x: size.width/2, y: size.height/1.5)
        addChild(dev)
        dev.run(appearing)
        
        let domen = SKLabelNode(fontNamed: "Roboto Mono")
        domen.text = ".dev"
        domen.fontSize = 50
        domen.fontColor = UIColor(red: 0.7872, green: 0.2666, blue: 0.196, alpha: 0.8)
        domen.position = CGPoint(x: 300, y: 0)
        
        let site = SKLabelNode(fontNamed: "Roboto Mono")
        site.addChild(domen)
        site.text = "www.shaiakhmetov"
        site.fontSize = 50
        site.alpha = 0
        site.fontColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
        site.position = CGPoint(x: size.width/2.2, y: size.height/3)
        addChild(site)
        site.run(SKAction.sequence([wait,wait,appearing]))
        
        let destryer = SKNode()
        addChild(destryer)
        destryer.run(SKAction.sequence([wait,wait,wait,appearing,SKAction.run({ self.start_game() })]))
    }
    func start_game() {
        let scene = GameScene(size: CGSize(width: 1334, height: 750))
        view?.presentScene(scene, transition: SKTransition.fade(with: UIColor(red: 0.145, green: 0.1333, blue: 0.498, alpha: 1.0), duration: 1))
    }
}
