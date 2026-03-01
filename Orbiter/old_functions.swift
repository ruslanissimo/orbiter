//
//  old_functions.swift
//  Orbiter
//
//  Created by Руслан Шаяхметов on 22.02.2021.
//

import Foundation
import SpriteKit
import GameplayKit

func vec_sum(vectorA: CGVector, vectorB: CGVector) -> CGVector {
        var vectorC = vectorA
        vectorC.dx += vectorB.dx
        vectorC.dy += vectorB.dy
        return vectorC
    }
func vec_sub(vectorA: CGVector, vectorB: CGVector) -> CGVector {
    var vectorC = vectorA
    vectorC.dx -= vectorB.dx
    vectorC.dy -= vectorB.dy
    return vectorC
}

func vec_init(from: CGPoint, to: CGPoint) -> CGVector {
    let x = to.x - from.x
    let y = to.y - from.y
    return CGVector(dx: x, dy: y)
}

func inv_vec(vec: CGVector) -> CGVector {
    let x = -vec.dx
    let y = -vec.dy
    return CGVector(dx: x, dy: y)
}

func scalar_mult(vector: CGVector, scalar: CGFloat) -> CGVector {
    var vectorA = vector
    vectorA.dx *= scalar
    vectorA.dy *= scalar
    return vectorA
}
func move_point(vector: CGVector, point: CGPoint) -> CGPoint {
    var pointA = point
    pointA.x += vector.dx
    pointA.y += vector.dy
    return pointA
}
func dist_between(pointA: CGPoint, pointB: CGPoint) -> CGFloat {
    let dx = pointA.x-pointB.x
    let dy = pointA.y-pointB.y
    let outcome = (dx*dx) + (dy*dy)
    return sqrt(outcome)
}

func average(array: [CGVector]) -> CGVector {
    var result = CGVector(dx: 0, dy: 0)
    for each in array {
        result.dx += each.dx
        result.dy += each.dy
    }
    result.dx /= CGFloat(array.count)
    result.dy /= CGFloat(array.count)
    return result
}

func angle(vector: CGVector) -> CGFloat {
    let angle = atan2(vector.dx, vector.dy)
    return angle
}

func rotate_at(angle: CGFloat, vector: CGVector) -> CGVector {
    var result = vector
    let x = vector.dx
    let y = vector.dy
    result.dx = (x*cos(angle))-(y*sin(angle))
    result.dy = (x*sin(angle))+(y*cos(angle))
    return result
}

func modul(vec: CGVector) -> CGFloat{
    let one = vec.dx*vec.dx
    let two = vec.dy*vec.dy
    return sqrt(one+two)
}

func add_mark(pos: CGPoint, radius: CGFloat) -> SKShapeNode {
    var radius_in = radius
    if radius<20 { radius_in = 20 }
    let mark = SKShapeNode(rect: CGRect(x: -radius_in, y: -radius_in, width: 2*radius_in, height: 2*radius_in), cornerRadius: radius_in/2)
    mark.strokeColor = UIColor(red: 0.7872, green: 0.2666, blue: 0.196, alpha: 0.8)
    mark.position = pos
    mark.lineWidth = 5
    mark.zPosition = 3
    return mark
}

func add_bonuse(star: Star) -> SKSpriteNode {
    
    var target = SKSpriteNode()
    
    if(Double.random(in: 0...1)>0.8) {
        //Extra Life
        target = SKSpriteNode(imageNamed: "ship")
        target.addChild(SKNode())
    } else {
        //Extra Barrels
        target = SKSpriteNode(imageNamed: "barrel")
    }
    
    //Random position in the circle
    let rad = (13*star.radius) + 257
    var x = rad
    var y = rad
    var r = sqrt(x*x+y*y)
    while r>(rad)||r<(2*star.radius) {
        x = CGFloat.random(in: -rad...rad)
        y = CGFloat.random(in: -rad...rad)
        r = sqrt(x*x+y*y)
    }
    target.position = CGPoint(x: x+star.body.position.x,
                              y: y+star.body.position.y)
    
    
    target.setScale(0.03)
    let frame = add_mark(pos: CGPoint.zero, radius: 1000)
    frame.lineWidth = 75
    frame.strokeColor = UIColor.yellow
    
    
    //Actions
    let ScaleUp =   SKAction.scale(to: 1, duration: 0.3)
    let ScaleDown = SKAction.scale(to: 0.75, duration: 0.3)
    let RotateCW =  SKAction.rotate(byAngle: -2*CGFloat.pi, duration: 2)
    let RotateCCW = SKAction.rotate(byAngle: 2*CGFloat.pi, duration: 2)
    let Scale = SKAction.sequence([ScaleUp, ScaleDown])
    let frameAction = SKAction.group([SKAction.repeatForever(RotateCW),
                                      SKAction.repeatForever(Scale)])
    target.run(SKAction.repeatForever(RotateCCW))
    frame.run(frameAction)
    
    target.addChild(frame)
    star.bonuses.append(target)
    return target
}
