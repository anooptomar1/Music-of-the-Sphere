//
//  GameViewController.swift
//  Mesh
//
//  Created by Ben Hambrecht on 05.06.16.
//  Copyright (c) 2016 Ben Hambrecht. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import OpenGLES



let π = Float(M_PI)



class GameViewController: UIViewController, SCNSceneRendererDelegate {
    
    
    var currentXAngle: Float = 0.0
    var currentYAngle: Float = 0.0
    
    var geometryNode = SCNNode()
    var cameraNode = SCNNode()
    var lightNode = SCNNode()
    var animationStep = 0 as Int
    
    // geometry primitives
    var perfectCylinder = SCNNode()
    var perfectSphere = SCNNode()
    
    // discretized
    var sphere = SCNNode()
    var sphylinder = SCNNode()
    var cylinder = SCNNode()
    
    // with single colored tile
    var sphere2 = SCNNode()
    var sphylinder2 = SCNNode()
    var cylinder2 = SCNNode()
    
    // smoother discretization to morph "perfect" sphere to cylinder
    var sphere3 = SCNNode()
    var cylinder3 = SCNNode()
    
    // folded-out cylinder
    var cylinder4 = SCNNode() // with a seam
    var rectangle = SCNNode()
    
//    var line = SCNNode()
//    var line2 = SCNNode()
//    var line3 = SCNNode()
    var cylinderPyramid = SCNNode()
    var sphylinderPyramid = SCNNode()
    var spherePyramid = SCNNode()
    
    
    var ddtheta = 0 as Float
    var ddphi = 0 as Float
    
    
    let startColor = UIColor(red: 0.4, green: 0.125, blue: 0.375, alpha: 1.0)
    

    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene()
        
        
        let originNode = SCNNode()
        originNode.position = SCNVector3Make(0, 0, 0)
        
        
        scene.rootNode.addChildNode(geometryNode)
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.name = "camera"
        cameraNode.camera?.zFar = 600
        cameraNode.constraints = [SCNLookAtConstraint(target:originNode)]
        cameraNode.position = SCNVector3(x: 400, y: 0, z: 300)
        //cameraNode.eulerAngles = SCNVector3Make(-1.79, -0.01, -0.26)
        cameraNode.eulerAngles = SCNVector3Make(0, 0, π/2)
        cameraNode.camera!.yFov = 40
        cameraNode.camera?.usesOrthographicProjection = false
        cameraNode.constraints?.append(SCNLookAtConstraint(target: originNode))
        
        scene.rootNode.addChildNode(cameraNode)
        self.cameraNode = cameraNode
        
        
        // create and add lights to the scene
        self.lightNode.light = SCNLight()
        self.lightNode.light!.type = SCNLightTypeOmni
        self.lightNode.light!.color = UIColor.whiteColor()
        self.lightNode.light!.castsShadow = true
        self.lightNode.light!.zFar = 20
        self.lightNode.light!.zNear = 0
        self.lightNode.position = SCNVector3(x: 1, y: 3, z: 2)
        scene.rootNode.addChildNode(self.lightNode)
        //lightNode.constraints = [SCNLookAtConstraint(target:originNode)]
        
        let lightNode3 = SCNNode()
        lightNode3.light = SCNLight()
        lightNode3.light!.type = SCNLightTypeAmbient
        lightNode3.light!.color = UIColor.whiteColor()
        scene.rootNode.addChildNode(lightNode3)
        
        
        
        // add a tap gesture recognizer
        let tapGR = UITapGestureRecognizer(target: self, action: "handleTap")
        view.gestureRecognizers = [tapGR]

        let scnView = self.view as! SCNView
        scnView.scene = scene
        scnView.allowsCameraControl = false
        scnView.showsStatistics = false
        let backgroundColor = UIColor.blackColor()
        scnView.backgroundColor = backgroundColor
        scnView.delegate = self
        
        self.geometryDefinitions()
        
        geometryNode.addChildNode(self.perfectSphere)

        
        
    }
    
    
    
    
    func handleTap() {
        
        let animationDuration = 3.0
        
        switch self.animationStep {
            
        case 0:
            self.approachCamera(animationDuration)

            
        case 1:
            
            self.perfectSphere.removeFromParentNode()
            self.geometryNode.addChildNode(self.sphere)
            
        // morph a little bit so the reflection is shown
            
        case 2:
            SCNTransaction.begin()
            //SCNTransaction.animationDuration = animationDuration
            self.sphere.morpher?.setWeight(0.0001, forTargetAtIndex: 0)
            SCNTransaction.commit()
            
        // first morph from sphere to cylinder
            
        case 3:
            SCNTransaction.begin()
            //SCNTransaction.animationDuration = animationDuration
            self.sphere.morpher?.setWeight(1.0, forTargetAtIndex: 0)
            SCNTransaction.commit()
            
        case 4:
            SCNTransaction.begin()
            //SCNTransaction.animationDuration = animationDuration
            self.sphere.morpher?.setWeight(0.0, forTargetAtIndex: 0)
            self.sphere.morpher?.setWeight(1.0, forTargetAtIndex: 1)
            SCNTransaction.commit()
        
        // and back to sphere
            
        case 5:
            SCNTransaction.begin()
            //SCNTransaction.animationDuration = animationDuration
            self.sphere.morpher?.setWeight(0.0, forTargetAtIndex: 1)
            self.sphere.morpher?.setWeight(1.0, forTargetAtIndex: 0)
            SCNTransaction.commit()
            
        case 6:
            SCNTransaction.begin()
            //SCNTransaction.animationDuration = animationDuration
            self.sphere.morpher?.setWeight(0.0, forTargetAtIndex: 0)
            SCNTransaction.commit()
            
            
        // move camera to equator
            
        case 7:
            SCNTransaction.begin()
            //SCNTransaction.animationDuration = animationDuration
            self.cameraNode.position = SCNVector3(50, 0, 0)
            SCNTransaction.commit()
            
        // second morph from sphere to cylinder
            
        case 8:
            SCNTransaction.begin()
            //SCNTransaction.animationDuration = animationDuration
            self.sphere.morpher?.setWeight(1.0, forTargetAtIndex: 0)
            SCNTransaction.commit()
            
        case 9:
            SCNTransaction.begin()
            //SCNTransaction.animationDuration = animationDuration
            self.sphere.morpher?.setWeight(0.0, forTargetAtIndex: 0)
            self.sphere.morpher?.setWeight(1.0, forTargetAtIndex: 1)
            SCNTransaction.commit()
            
        // and back to sphere
            
        case 10:
            SCNTransaction.begin()
            //SCNTransaction.animationDuration = animationDuration
            self.sphere.morpher?.setWeight(0.0, forTargetAtIndex: 1)
            self.sphere.morpher?.setWeight(1.0, forTargetAtIndex: 0)
            SCNTransaction.commit()
            
        case 11:
            SCNTransaction.begin()
            //SCNTransaction.animationDuration = animationDuration
            self.sphere.morpher?.setWeight(0.0, forTargetAtIndex: 0)
            SCNTransaction.commit()
            
//        // move camera to north pole
//            
//        case 12:
//            SCNTransaction.begin()
//            SCNTransaction.animationDuration = animationDuration
//            self.cameraNode.position = SCNVector3(0, 0, 50)
//            SCNTransaction.commit()
//            
//        // third morph from sphere to cylinder
//            
//        case 13:
//            SCNTransaction.begin()
//            SCNTransaction.animationDuration = animationDuration
//            self.sphere.morpher?.setWeight(0.95, forTargetAtIndex: 0)
//            SCNTransaction.commit()
//            
//        case 14:
//            SCNTransaction.begin()
//            SCNTransaction.animationDuration = animationDuration
//            self.sphere.morpher?.setWeight(0.0, forTargetAtIndex: 0)
//            self.sphere.morpher?.setWeight(1.0, forTargetAtIndex: 1)
//            SCNTransaction.commit()
//            
//        // and back to sphere
//            
//        case 15:
//            SCNTransaction.begin()
//            SCNTransaction.animationDuration = animationDuration
//            self.sphere.morpher?.setWeight(0.0, forTargetAtIndex: 1)
//            self.sphere.morpher?.setWeight(0.95, forTargetAtIndex: 0)
//            SCNTransaction.commit()
//            
//        case 16:
//            SCNTransaction.begin()
//            SCNTransaction.animationDuration = animationDuration
//            self.sphere.morpher?.setWeight(0.0, forTargetAtIndex: 0)
//            SCNTransaction.commit()
            
        // move camera back into original position
            
        case 17:
            self.approachCamera(animationDuration)
            
        // show single colored tile
            
        case 18:
            self.sphere.removeFromParentNode()
            self.geometryNode.addChildNode(self.sphere2)
            
            // morph a little bit so the reflection is shown
            
        case 19:
            SCNTransaction.begin()
            //SCNTransaction.animationDuration = animationDuration
            self.sphere2.morpher?.setWeight(0.0001, forTargetAtIndex: 0)
            SCNTransaction.commit()
            
            // morph into cylinder
            
        case 20:
            SCNTransaction.begin()
            //SCNTransaction.animationDuration = animationDuration
            self.sphere2.morpher?.setWeight(1.0, forTargetAtIndex: 0)
            SCNTransaction.commit()
            
        case 21:
            SCNTransaction.begin()
            //SCNTransaction.animationDuration = animationDuration
            self.sphere2.morpher?.setWeight(0.0, forTargetAtIndex: 0)
            self.sphere2.morpher?.setWeight(1.0, forTargetAtIndex: 1)
            SCNTransaction.commit()
            
        // move camera to north pole
            
        case 22:
            print("move camera to north pole")
            SCNTransaction.begin()
            //SCNTransaction.animationDuration = animationDuration
            self.cameraNode.position = SCNVector3(0, 0, 50)
            SCNTransaction.commit()
            
        case 23:
            self.geometryNode.addChildNode(self.cylinderPyramid)
            
        case 24:
            print("move camera to north pole")
            print(self.cameraNode.eulerAngles.x*180/π)
            print(self.cameraNode.eulerAngles.y*180/π)
            print(self.cameraNode.eulerAngles.z*180/π)
            SCNTransaction.begin()
            //SCNTransaction.animationDuration = animationDuration
            self.cameraNode.eulerAngles.z -= π/3 - self.ddphi/2
            SCNTransaction.commit()
            
            
        case 25:
            print("morph from cylinder to sphylinder")
            SCNTransaction.begin()
            //SCNTransaction.animationDuration = animationDuration
            self.sphere2.morpher?.setWeight(0.0, forTargetAtIndex: 1)
            self.sphere2.morpher?.setWeight(0.95, forTargetAtIndex: 0)
//            self.line.morpher?.setWeight(1.0, forTargetAtIndex: 0)
            self.cylinderPyramid.morpher?.setWeight(1.0, forTargetAtIndex: 0)
            
            SCNTransaction.commit()
            
        // move camera to equator
            
        case 26:
            print("move camera to equator")
            SCNTransaction.begin()
            //SCNTransaction.animationDuration = animationDuration
            self.cameraNode.position = SCNVector3(50/pow(2.0, 0.5), -50/pow(2.0,0.5), 0)
            SCNTransaction.commit()
            
            
        case 27:
            print("move camera to equator")
            SCNTransaction.begin()
            //SCNTransaction.animationDuration = animationDuration
            self.cameraNode.eulerAngles.z += π/16
            SCNTransaction.commit()
            
        // move from sphylinder to sphere
            
        case 28:
            print("move from sphylinder to sphere")
            SCNTransaction.begin()
            //SCNTransaction.animationDuration = animationDuration
            self.sphere2.morpher?.setWeight(0.0, forTargetAtIndex: 0)
            //self.line.morpher?.setWeight(0.0, forTargetAtIndex: 0)
            //self.line.morpher?.setWeight(1.0, forTargetAtIndex: 1)
            self.cylinderPyramid.morpher?.setWeight(0.0, forTargetAtIndex: 0)
            self.cylinderPyramid.morpher?.setWeight(1.0, forTargetAtIndex: 1)
            
            SCNTransaction.commit()
        
        case 29:
            approachCamera(animationDuration)
            //self.line.removeFromParentNode()
            self.cylinderPyramid.removeFromParentNode()
            print("removing line")
            
        case 30:
            SCNTransaction.begin()
            //SCNTransaction.animationDuration = animationDuration
            cameraNode.eulerAngles = SCNVector3Make(0, 0, π/2)
            SCNTransaction.commit()
            
        // morph one last time discretised sphere into cylinder,
        // thi stime directly
            
        case 31:
            print("morphing one last time into cylinder, this time directly")
            SCNTransaction.begin()
            //SCNTransaction.animationDuration = animationDuration
            self.sphere2.morpher?.setWeight(1.0, forTargetAtIndex: 1)
            SCNTransaction.commit()
            
        case 32:
            print("and back")
            SCNTransaction.begin()
            //SCNTransaction.animationDuration = animationDuration
            self.sphere2.morpher?.setWeight(0.0, forTargetAtIndex: 1)
            SCNTransaction.commit()
            
        // replace with "perfect" sphere
            
        case 33:
            print("replacing with 'perfect' sphere")
            SCNTransaction.begin()
            //SCNTransaction.animationDuration = animationDuration
            self.sphere2.removeFromParentNode()
            self.geometryNode.addChildNode(self.sphere3)
            SCNTransaction.commit()
            
        // morph a little bit so the reflection is shown
            
        case 34:
            print("morph a little bit so the reflection is shown")
            SCNTransaction.begin()
            //SCNTransaction.animationDuration = animationDuration
            self.sphere3.morpher?.setWeight(0.0001, forTargetAtIndex: 0)
            SCNTransaction.commit()

        // morph into "perfect" cylinder
            
        case 35:
            print("morph into 'perfect' cylinder")
            SCNTransaction.begin()
            //SCNTransaction.animationDuration = animationDuration
            self.sphere3.morpher?.setWeight(1.0, forTargetAtIndex: 0)
            SCNTransaction.commit()
            
//        // replace sneakily with cylinder with seam
//            
//        case 36:
//            print("replace sneakily with cylinder with seam")
//            SCNTransaction.begin()
//            SCNTransaction.animationDuration = animationDuration
//            self.sphere3.removeFromParentNode()
//            self.geometryNode.addChildNode(self.cylinder4)
//            SCNTransaction.commit()
//            
//        case 37:
//            print("zooming out")
//            SCNTransaction.begin()
//            SCNTransaction.animationDuration = animationDuration
//            self.cameraNode.position = SCNVector3(80, 0, 60)
//            SCNTransaction.commit()
//            
//        case 38:
//            print("unfolding cylinder")
//            SCNTransaction.begin()
//            SCNTransaction.animationDuration = animationDuration
//            self.cylinder4.morpher?.setWeight(1.0, forTargetAtIndex: 0)
//            SCNTransaction.commit()
            
        default:
            print("default case")
            
            
        }
        
        
        self.animationStep += 1
        
    }
    
    
    
    
    func approachCamera(duration: Double) {
        
        SCNTransaction.begin()
        //SCNTransaction.setAnimationDuration(duration)
        //SCNTransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        self.cameraNode.position = SCNVector3(40, 0, 30)
        let myCam = self.cameraNode.camera as SCNCamera?
        myCam!.yFov = 4
        SCNTransaction.commit()
        
        
    }
    
    
//    
//    func panGesture(sender: UIPanGestureRecognizer) {
//        
//        let translation = sender.translationInView(sender.view!)
//        
//        if (sender.numberOfTouches() == 1) {
//            
//            //var newAngle = (Float)(translation.x)*(Float)(M_PI)/180.0 / 5
//            //newAngle += currentXAngle
//            var dphi = 0.0 as Float
//            if (translation.x > 0) {
//                dphi = 0.02
//            } else if (translation.x < 0) {
//                dphi = -0.02
//            }
//            
//            for node in self.geometryNode.childNodes {
//                node.transform = SCNMatrix4Mult(SCNMatrix4MakeRotation(dphi, 0, 0, 1), node.transform)
//            }
//            
//            
//            
//            //            if(sender.state == UIGestureRecognizerState.Ended) {
//            //                currentXAngle = newAngle
//            //            }
//            
//        } else if (sender.numberOfTouches() == 2) {
//            
//            
//            //let newAngle = (Float)(translation.y)*(Float)(M_PI)/180.0 / 5
//            //newAngle += currentYAngle
//            var dtheta = 0.0 as Float
//            if (translation.y > 0) {
//                dtheta = 0.02
//            } else if (translation.y < 0) {
//                dtheta = -0.02
//            }
//            
//            if (fabs(self.cameraNode.position.x) > 1.0) {
//                
//                print(self.cameraNode.position.x)
//                // for node in self.geometryNode.childNodes {
//                self.cameraNode.transform = SCNMatrix4Mult(self.cameraNode.transform, SCNMatrix4MakeRotation(dtheta, 0, 1, 0))
//                
//            } else {
//                print(self.cameraNode.position.x)
//                self.cameraNode.position.x = 0
//                self.cameraNode.position.y = 0
//                
//            }
//            
//            
//            //            if(sender.state == UIGestureRecognizerState.Ended) {
//            //                currentYAngle = newAngle
//            //            }
//            
//        }
//    }
//    
//    func rotateCamera(cameraNode: SCNNode) {
//        
//        // Rotating the box
//        let cameraRotation = CABasicAnimation.init(keyPath:"transform")
//        cameraRotation.toValue = NSValue(SCNMatrix4: SCNMatrix4Rotate(cameraNode.transform, π, 0, 0, 1))
//        
//        //cameraRotation.timingFunction =
//        //[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//        cameraRotation.repeatCount = 1e6;
//        cameraRotation.duration = 2.0;
//        
//        cameraNode.addAnimation(cameraRotation, forKey: "RotateTheBox")
//        
//        
//    }
//    
//    
//    func animate(node: SCNNode) {
//        SCNTransaction.begin()
//        SCNTransaction.setAnimationDuration(2.0)
//        
//        switch self.animationStep {
//        case 0:
//            node.morpher?.setWeight(1.0, forTargetAtIndex: 0)
//        case 1:
//            node.morpher?.setWeight(0.0, forTargetAtIndex: 0)
//            node.morpher?.setWeight(1.0, forTargetAtIndex: 1)
//        case 2:
//            node.morpher?.setWeight(0.0, forTargetAtIndex: 1)
//            node.morpher?.setWeight(1.0, forTargetAtIndex: 0)
//        case 3:
//            node.morpher?.setWeight(0.0, forTargetAtIndex: 0)
//        default:
//            print("nothing to do")
//        }
//        
//        self.animationStep = (self.animationStep + 1) % 4
//        
//        
//        SCNTransaction.commit()
//    }
//    
//    
//    func handleSingleTap(gestureRecognizer: UITapGestureRecognizer) {
//        
//        if (gestureRecognizer.numberOfTouches() == 1) {
//            
//            print("handling single tap")
//            
//            //let scene = ((view as? SCNView)?.scene)! as SCNScene
//            
//            let animation = SCNAction.runBlock({ node in
//                self.animate(node)
//            })
//            
//            
//            
//            for effectNode in geometryNode.childNodes {
//                
//                if (effectNode.name == "sphere" || effectNode.name == "sphylinder" || effectNode.name == "cylinder") {
//                    effectNode.runAction(animation)
//                }
//            }
//            
//        } else if (gestureRecognizer.numberOfTouches() == 2 && self.animationStep == 0) {
//            
//            
//            
//            var oldTransform = SCNMatrix4()
//            
//            for node in self.geometryNode.childNodes {
//                if node.name == "sphere" {
//                    node.removeFromParentNode()
//                    self.geometryNode.addChildNode(self.sphere)
//                    oldTransform = node.transform
//                }
//            }
//            
//            self.sphere.transform = oldTransform
//            self.sphylinder.transform = oldTransform
//            self.cylinder.transform = oldTransform
//            
//            
//        } else if (gestureRecognizer.numberOfTouches() == 3) {
//            
//            print("three fingers")
//            
//            let dphi = 0.01 as Float
//            
//            for i in 1...100 {
//                for node in self.geometryNode.childNodes {
//                    node.transform = SCNMatrix4Mult(SCNMatrix4MakeRotation(Float(i)*dphi, 0, 0, 1), node.transform)
//                    self.view.setNeedsDisplay()
//                }
//                
//            }
//            
//            
//        }
//        
//        
//        
//        
//        
//        
//        
//        
//    }
//    
//    func handleDoubleTap(gestureRecognizer: UITapGestureRecognizer) {
//        
//        print("handling double tap")
//        
//    }
//
    //
    //    func rotateHorizontally() {
    //
    //
    //            //SCNTransaction.begin()
    //            //SCNTransaction.setAnimationDuration(2.0)
    //
    //            //self.cameraNode.transform = SCNMatrix4Mult(self.cameraNode.transform, SCNMatrix4MakeRotation(π/10, 0, 0, 1))
    //
    //
    //            //SCNTransaction.commit()
    //
    //            let rotation = SCNAction.rotateByAngle(CGFloat(π), aroundAxis:SCNVector3(0, 0, 1), duration: 0.5)
    //
    //            self.geometryNode.runAction(rotation)
    //            self.lightNode.runAction(rotation)
    //        
    //        
    //    }
    //    
    //    
 
    
    
    
    
    
    
    
    //        let lightNode2 = SCNNode()
    //        lightNode2.light = SCNLight()
    //        lightNode2.light!.type = SCNLightTypeOmni
    //        lightNode2.light!.color = UIColor.whiteColor()
    //        lightNode2.light!.castsShadow = false
    //        lightNode2.light!.zFar = 20
    //        lightNode2.light!.zNear = 0
    //        lightNode2.position = SCNVector3(x: 3, y: 0, z: 3)
    //        scene.rootNode.addChildNode(lightNode2)
    //
    //        lightNode2.constraints = [SCNLookAtConstraint(target:originNode)]
    
    
    
    
    
    
    
    //        //// PLANE ////
    //
    //        let plane = SCNPlane(width: 100.0, height: 100.0)
    //        let planeNode = SCNNode(geometry: plane)
    //        planeNode.position = SCNVector3Make(0, 0, 0)
    //
    //
    //        let planeMaterial = SCNMaterial()
    //        planeMaterial.diffuse.contents = UIColor.grayColor()
    //        planeMaterial.shininess = 0.0
    //        planeMaterial.doubleSided = true
    //        plane.materials = [planeMaterial]
    
    //scene.rootNode.addChildNode(planeNode)
    
    
    
    
    
    
    //        let povNode = (view as? SCNView)?.pointOfView as SCNNode?
    //
    //        print("position")
    //        print(povNode?.position.x)
    //        print(povNode?.position.y)
    //        print(povNode?.position.z)
    //        print("fov")
    //        print(povNode?.camera!.xFov)
    //        print(povNode?.camera!.yFov)
    //        print("Euler angles")
    //        print(povNode?.eulerAngles.x)
    //        print(povNode?.eulerAngles.y)
    //        print(povNode?.eulerAngles.z)
    
    
    
    
    
    
    
    //        let scene = ((view as? SCNView)?.scene)! as SCNScene
    //
    //        let animation = SCNAction.runBlock({ node in
    //            self.rotateCamera(node)
    //        })
    //
    //        for effectNode in scene.rootNode.childNodes {
    //
    //            if (effectNode.name == "camera") {
    //                effectNode.runAction(animation)
    //            }
    //        }

    
    
    
    
    
    //        SCNTransaction.begin()
    //        SCNTransaction.setAnimationDuration(0.5)
    //
    //        //let rotation = SCNAction.rotateByAngle(0.1*3.1415926, aroundAxis: SCNVector3Make(0,0,-1), duration: 0.5)
    //        //cameraNode.runAction(SCNAction.repeatActionForever(rotation))
    //
    //        let position = cameraNode.position
    //        let newPosition = SCNVector3Make(position.x + 0.1*position.y, position.y - 0.1*position.x, position.z)
    //        cameraNode.position = newPosition
    //
    //        SCNTransaction.commit()
    
    
    //        let moveTo = SCNAction.moveTo(SCNVector3(x:0,y:0,z:-40), duration: 40);
    //        cameraNode.runAction(moveTo)
    

    
    
    
    func geometryDefinitions() {
        
        
        var nbTheta = 24 as UInt16
        var nbThetaInt = 24 as Int
        
        var dtheta = π/Float(nbTheta)
        self.ddtheta = dtheta
        
        var nbPhi = 48 as UInt16
        var nbPhiInt = 48 as Int
        var dphi = 2.0*π/Float(nbPhi)
        self.ddphi = dphi
        
        let ii = 20 as UInt16
        let jj = 7 as UInt16
        
        
        
        //// FACELET MATERIALS ////
        
        
        // red tiles
        let faceletMaterial1 = SCNMaterial()
        faceletMaterial1.shininess = 1.0
        faceletMaterial1.doubleSided = true
        faceletMaterial1.specular.intensity = 1.0
        faceletMaterial1.locksAmbientWithDiffuse = true
        faceletMaterial1.diffuse.contents = UIColor.init(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0)
        faceletMaterial1.specular.contents = UIColor.whiteColor()
        
        // blue tiles
        let faceletMaterial2 = SCNMaterial()
        faceletMaterial2.shininess = 1.0
        faceletMaterial2.doubleSided = true
        faceletMaterial2.specular.intensity = 1.0
        faceletMaterial2.locksAmbientWithDiffuse = true
        faceletMaterial2.diffuse.contents = UIColor.init(red: 0.3, green: 0.25, blue: 0.75, alpha: 1.0)
        faceletMaterial2.specular.contents = UIColor.whiteColor()
        
        
        // darker red tiles
        let faceletMaterial11 = SCNMaterial()
        faceletMaterial11.shininess = 1.0
        faceletMaterial11.doubleSided = true
        faceletMaterial11.specular.intensity = 1.0
        faceletMaterial11.locksAmbientWithDiffuse = true
        faceletMaterial11.diffuse.contents = UIColor.init(red: 0.45, green: 0.2, blue: 0.2, alpha: 0.7)
        faceletMaterial11.specular.contents = UIColor.whiteColor()
        
        // darker blue tiles
        let faceletMaterial21 = SCNMaterial()
        faceletMaterial21.shininess = 1.0
        faceletMaterial21.doubleSided = true
        faceletMaterial21.specular.intensity = 1.0
        faceletMaterial21.locksAmbientWithDiffuse = true
        faceletMaterial21.diffuse.contents = UIColor.init(red: 0.35, green: 0.325, blue: 0.575, alpha: 0.7)
        faceletMaterial21.specular.contents = UIColor.whiteColor()
        
        // highlighted tile
        let faceletMaterial3 = SCNMaterial()
        faceletMaterial3.shininess = 1.0
        faceletMaterial3.doubleSided = true
        faceletMaterial3.specular.intensity = 1.0
        faceletMaterial3.locksAmbientWithDiffuse = true
        faceletMaterial3.diffuse.contents = UIColor.init(red: 1.0, green: 0.7, blue: 0.0, alpha: 1.0)
        faceletMaterial3.specular.contents = UIColor.whiteColor()
        
        
        
        
        //// SPHERE ////
        
        
        let mySphere = SCNSphere(radius: 1.0)
        mySphere.segmentCount = 100
        mySphere.geodesic = false
        self.perfectSphere = SCNNode(geometry: mySphere)
        self.perfectSphere.position = SCNVector3Make(0, 0, 0)
        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents = self.startColor
        sphereMaterial.specular.contents = UIColor.init(red: 0.4, green: 0.125, blue: 0.375, alpha: 1.0)
        sphereMaterial.shininess = 1.0
        sphereMaterial.doubleSided = true
        mySphere.materials = [sphereMaterial]
        
        
        
        
        //// CYLINDER ////
        
        
        let myCylinder = SCNTube(innerRadius: 1, outerRadius: 1.01, height: 2)
        myCylinder.radialSegmentCount = 100
        self.perfectCylinder = SCNNode(geometry: myCylinder)
        self.perfectCylinder.position = SCNVector3Make(0, 0, 1)
        self.perfectCylinder.eulerAngles = SCNVector3Make(π*0.5, 0, 0)
        //geometryNode.addChildNode(cylinderNode)
        let cylinderMaterial = SCNMaterial()
        let cylinderColor = UIColor.purpleColor().colorWithAlphaComponent(0.3)
        cylinderMaterial.diffuse.contents = cylinderColor
        sphereMaterial.specular.contents = UIColor.whiteColor()
        cylinderMaterial.doubleSided = true
        myCylinder.materials = [cylinderMaterial]
        
        
        
        /// DISCRETIZED SPHERE ///
        
        
        
        // create sphere vertices and normals
        
        var sphereVertices = [] as [SCNVector3]
        var sphereNormals = [] as [SCNVector3]
        
        for i in 0...nbThetaInt {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.0001
            if theta > 0.5*π { theta = 0.5*π - 0.0001 }
            
            for j in 0..<nbPhiInt {
                let phi = Float(j) * dphi
                
                let vertex = SCNVector3Make(cos(theta)*sin(phi),
                                            cos(theta)*cos(phi),
                                            sin(theta))
                
                let normal = vertex
                
                sphereVertices.append(vertex)
                sphereVertices.append(vertex)
                sphereNormals.append(normal)
                sphereNormals.append(normal)
                
                //self.drawNormal(vertex, normal: normal)
                
                
            }
            
        }
        
        
        
        var sphereFacelets1Indices = [] as [UInt16]
        var sphereFacelets2Indices = [] as [UInt16]
        
        // vertex indices for the even-colored facelet geometry element
        
        for i in 1..<nbTheta {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.0001
            if theta > 0.5*π { theta = 0.5*π - 0.0001 }
            
            for j in 0..<nbPhi {
                if (i+j)%2 == 0 {
                    // indices of the vertices for the two triangles
                    let nextJ = (j+1) % nbPhi
                    
                    if (theta >= -1.0e-2) {
                        
                        sphereFacelets1Indices.append(2 * (i * nbPhi + j))
                        sphereFacelets1Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        sphereFacelets1Indices.append(2 * ((i+1) * nbPhi + j) + 1)
                        
                        sphereFacelets1Indices.append(2 * (i * nbPhi + j))
                        sphereFacelets1Indices.append(2 * (i * nbPhi + nextJ))
                        sphereFacelets1Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        
                    }
                    
                    if (theta <= 1.0e-2) {
                        
                        sphereFacelets2Indices.append(2 * (i * nbPhi + j))
                        sphereFacelets2Indices.append(2 * ((i-1) * nbPhi + j) + 1)
                        sphereFacelets2Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        
                        sphereFacelets2Indices.append(2 * (i * nbPhi + j))
                        sphereFacelets2Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        sphereFacelets2Indices.append(2 * (i * nbPhi + nextJ))
                        
                    }
                }
            }
        }
        
        
        // vertex indices for the odd-colored facelet geometry element
        
        
        for i in 1..<nbTheta {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.0001
            if theta > 0.5*π { theta = 0.5*π - 0.0001 }
            
            for j in 0..<nbPhi {
                if (i+j)%2 == 1 {
                    // indices of the vertices for the two triangles
                    let nextJ = (j+1) % nbPhi
                    
                    if (theta >= -1.0e-2) {
                        
                        sphereFacelets2Indices.append(2 * (i * nbPhi + j))
                        sphereFacelets2Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        sphereFacelets2Indices.append(2 * ((i+1) * nbPhi + j) + 1)
                        
                        sphereFacelets2Indices.append(2 * (i * nbPhi + j))
                        sphereFacelets2Indices.append(2 * (i * nbPhi + nextJ))
                        sphereFacelets2Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        
                    }
                    
                    if (theta <= 1.0e-2) {
                        
                        sphereFacelets1Indices.append(2 * (i * nbPhi + j))
                        sphereFacelets1Indices.append(2 * ((i-1) * nbPhi + j) + 1)
                        sphereFacelets1Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        
                        
                        sphereFacelets1Indices.append(2 * (i * nbPhi + j))
                        sphereFacelets1Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        sphereFacelets1Indices.append(2 * (i * nbPhi + nextJ))
                        
                    }
                }
            }
        }
        
        
        
        let sphereVerticesGeometrySource = SCNGeometrySource(vertices: sphereVertices, count: 2*(nbThetaInt+1) * nbPhiInt)
        let sphereNormalsGeometrySource = SCNGeometrySource(normals: sphereNormals, count: 2*(nbThetaInt+1) * nbPhiInt)
        
        let sphereFacelets1Element = SCNGeometryElement(indices: sphereFacelets1Indices, primitiveType: .Triangles)
        let sphereFacelets2Element = SCNGeometryElement(indices: sphereFacelets2Indices, primitiveType: .Triangles)
        
        
        let sphereFaceletGeometry = SCNGeometry(sources: [sphereVerticesGeometrySource, sphereNormalsGeometrySource], elements:[sphereFacelets1Element,sphereFacelets2Element])
        
        
        sphereFaceletGeometry.materials = [faceletMaterial1, faceletMaterial2]
        
        
        self.sphere = SCNNode(geometry: sphereFaceletGeometry)
        self.sphere.position = SCNVector3(x: 0, y: 0, z: 0)
        self.sphere.name = "sphere"
        
        
        /// SPHYLINDER ///
        
        var sphylinderVertices = [] as [SCNVector3]
        var sphylinderNormals = [] as [SCNVector3]
        
        for i in 0...nbThetaInt {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.001
            if theta > 0.5*π { theta = 0.5*π - 0.001 }
            
            for j in 0..<nbPhiInt {
                let phi = Float(j) * dphi
                
                let vertex = SCNVector3Make(cos(theta)*sin(phi),
                                            cos(theta)*cos(phi),
                                            sin(theta))
                
                let vertexMinus = SCNVector3Make(cos(theta-dtheta)*sin(phi),
                                                 cos(theta-dtheta)*cos(phi),
                                                 sin(theta))
                
                let vertexPlus = SCNVector3Make(cos(theta+dtheta)*sin(phi),
                                                cos(theta+dtheta)*cos(phi),
                                                sin(theta))
                
                let normal = SCNVector3Make(sin(phi), cos(phi), 0)
                
                sphylinderVertices.append(vertex)
                //self.drawNormal(vertex, normal: normal)
                
                if (theta > 1.0e-2) {
                    sphylinderVertices.append(vertexMinus)
                    //self.drawNormal(vertexMinus, normal: normal)
                    
                } else if (theta < -1.0e-2) {
                    
                    sphylinderVertices.append(vertexPlus)
                    //self.drawNormal(vertexPlus, normal: normal)
                    
                } else {
                    
                    sphylinderVertices.append(vertex)
                    //self.drawNormal(vertex, normal: normal)
                }
                
                sphylinderNormals.append(normal)
                sphylinderNormals.append(normal)
            }
        }
        
        var sphylinderFacelets1Indices = [] as [UInt16]
        var sphylinderFacelets2Indices = [] as [UInt16]
        
        // vertex indices for the even-colored facelet geometry element
        
        for i in 1..<nbTheta {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.001
            if theta > 0.5*π { theta = 0.5*π - 0.001 }
            
            for j in 0..<nbPhi {
                if (i+j)%2 == 0 {
                    // indices of the vertices for the two triangles
                    let nextJ = (j+1) % nbPhi
                    
                    if (theta >= -1.0e-2) {
                        
                        sphylinderFacelets1Indices.append(2 * (i * nbPhi + j))
                        sphylinderFacelets1Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        sphylinderFacelets1Indices.append(2 * ((i+1) * nbPhi + j) + 1)
                        
                        sphylinderFacelets1Indices.append(2 * (i * nbPhi + j))
                        sphylinderFacelets1Indices.append(2 * (i * nbPhi + nextJ))
                        sphylinderFacelets1Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        
                    }
                    
                    if (theta <= 1.0e-2) {
                        
                        sphylinderFacelets2Indices.append(2 * (i * nbPhi + j))
                        sphylinderFacelets2Indices.append(2 * ((i-1) * nbPhi + j) + 1)
                        sphylinderFacelets2Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        
                        sphylinderFacelets2Indices.append(2 * (i * nbPhi + j))
                        sphylinderFacelets2Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        sphylinderFacelets2Indices.append(2 * (i * nbPhi + nextJ))
                        
                    }
                }
            }
        }
        
        
        // vertex indices for the odd-colored facelet geometry element
        
        
        for i in 1..<nbTheta {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.001
            if theta > 0.5*π { theta = 0.5*π - 0.001 }
            
            for j in 0..<nbPhi {
                if (i+j)%2 == 1 {
                    // indices of the vertices for the two triangles
                    let nextJ = (j+1) % nbPhi
                    
                    if (theta >= -1.0e-2) {
                        
                        sphylinderFacelets2Indices.append(2 * (i * nbPhi + j))
                        sphylinderFacelets2Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        sphylinderFacelets2Indices.append(2 * ((i+1) * nbPhi + j) + 1)
                        
                        sphylinderFacelets2Indices.append(2 * (i * nbPhi + j))
                        sphylinderFacelets2Indices.append(2 * (i * nbPhi + nextJ))
                        sphylinderFacelets2Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        
                    }
                    
                    if (theta <= 1.0e-2) {
                        
                        sphylinderFacelets1Indices.append(2 * (i * nbPhi + j))
                        sphylinderFacelets1Indices.append(2 * ((i-1) * nbPhi + j) + 1)
                        sphylinderFacelets1Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        
                        sphylinderFacelets1Indices.append(2 * (i * nbPhi + j))
                        sphylinderFacelets1Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        sphylinderFacelets1Indices.append(2 * (i * nbPhi + nextJ))
                        
                    }
                }
            }
        }
        
        
        let sphylinderVerticesGeometrySource = SCNGeometrySource(vertices: sphylinderVertices, count: 2*(nbThetaInt+1) * nbPhiInt)
        let sphylinderNormalsGeometrySource = SCNGeometrySource(normals: sphylinderNormals, count: 2*(nbThetaInt+1) * nbPhiInt)
        
        let sphylinderFacelets1Element = SCNGeometryElement(indices: sphylinderFacelets1Indices, primitiveType: .Triangles)
        let sphylinderFacelets2Element = SCNGeometryElement(indices: sphylinderFacelets2Indices, primitiveType: .Triangles)
        
        
        let sphylinderFaceletGeometry = SCNGeometry(sources: [sphylinderVerticesGeometrySource, sphylinderNormalsGeometrySource], elements:[sphylinderFacelets1Element,sphylinderFacelets2Element])
        
        sphylinderFaceletGeometry.materials = [faceletMaterial1, faceletMaterial2]
        
        self.sphylinder = SCNNode(geometry: sphylinderFaceletGeometry)
        self.sphylinder.position = SCNVector3(x: 0, y: 0, z: 0)
        self.sphylinder.name = "sphylinder"
        
        
        
        /// CYLINDER ///
        
        
        var cylinderVertices = [] as [SCNVector3]
        var cylinderNormals = [] as [SCNVector3]
        
        
        for i in 0...nbThetaInt {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.001
            if theta > 0.5*π { theta = 0.5*π - 0.001 }
            
            for j in 0..<nbPhiInt {
                let phi = Float(j) * dphi
                
                let vertex = SCNVector3Make(sin(phi),
                                            cos(phi),
                                            sin(theta))
                
                let normal = SCNVector3Make(sin(phi), cos(phi), 0)
                
                cylinderVertices.append(vertex)
                //self.drawNormal(vertex, normal: normal)
                
                if (theta > 1.0e-2) {
                    cylinderVertices.append(vertex)
                    //self.drawNormal(vertex, normal: normal)
                    
                } else if (theta < -1.0e-2) {
                    
                    cylinderVertices.append(vertex)
                    //self.drawNormal(vertex, normal: normal)
                    
                } else {
                    
                    cylinderVertices.append(vertex)
                    //self.drawNormal(vertex, normal: normal)
                }
                
                cylinderNormals.append(normal)
                cylinderNormals.append(normal)
            }
        }
        
        
        
        var cylinderFacelets1Indices = [] as [UInt16]
        var cylinderFacelets2Indices = [] as [UInt16]
        
        // vertex indices for the even-colored facelet geometry element
        
        for i in 1..<nbTheta {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.001
            if theta > 0.5*π { theta = 0.5*π - 0.001 }
            
            for j in 0..<nbPhi {
                if (i+j)%2 == 0 {
                    // indices of the vertices for the two triangles
                    let nextJ = (j+1) % nbPhi
                    
                    if (theta >= -1.0e-2) {
                        
                        cylinderFacelets1Indices.append(2 * (i * nbPhi + j))
                        cylinderFacelets1Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        cylinderFacelets1Indices.append(2 * ((i+1) * nbPhi + j) + 1)
                        
                        cylinderFacelets1Indices.append(2 * (i * nbPhi + j))
                        cylinderFacelets1Indices.append(2 * (i * nbPhi + nextJ))
                        cylinderFacelets1Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        
                    }
                    
                    if (theta <= 1.0e-2) {
                        
                        cylinderFacelets2Indices.append(2 * (i * nbPhi + j))
                        cylinderFacelets2Indices.append(2 * ((i-1) * nbPhi + j) + 1)
                        cylinderFacelets2Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        
                        cylinderFacelets2Indices.append(2 * (i * nbPhi + j))
                        cylinderFacelets2Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        cylinderFacelets2Indices.append(2 * (i * nbPhi + nextJ))
                        
                    }
                }
            }
        }
        
        
        // vertex indices for the odd-colored facelet geometry element
        
        
        for i in 1..<nbTheta {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.001
            if theta > 0.5*π { theta = 0.5*π - 0.001 }
            
            for j in 0..<nbPhi {
                if (i+j)%2 == 1 {
                    // indices of the vertices for the two triangles
                    let nextJ = (j+1) % nbPhi
                    
                    if (theta >= -1.0e-2) {
                        
                        cylinderFacelets2Indices.append(2 * (i * nbPhi + j))
                        cylinderFacelets2Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        cylinderFacelets2Indices.append(2 * ((i+1) * nbPhi + j) + 1)
                        
                        cylinderFacelets2Indices.append(2 * (i * nbPhi + j))
                        cylinderFacelets2Indices.append(2 * (i * nbPhi + nextJ))
                        cylinderFacelets2Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        
                    }
                    
                    if (theta <= 1.0e-2) {
                        
                        cylinderFacelets1Indices.append(2 * (i * nbPhi + j))
                        cylinderFacelets1Indices.append(2 * ((i-1) * nbPhi + j) + 1)
                        cylinderFacelets1Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        
                        cylinderFacelets1Indices.append(2 * (i * nbPhi + j))
                        cylinderFacelets1Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        cylinderFacelets1Indices.append(2 * (i * nbPhi + nextJ))
                        
                    }
                }
            }
        }
        
        
        
        let cylinderVerticesGeometrySource = SCNGeometrySource(vertices: cylinderVertices, count: 2*(nbThetaInt+1) * nbPhiInt)
        let cylinderNormalsGeometrySource = SCNGeometrySource(normals: cylinderNormals, count: 2*(nbThetaInt+1) * nbPhiInt)
        
        let cylinderFacelets1Element = SCNGeometryElement(indices: cylinderFacelets1Indices, primitiveType: .Triangles)
        let cylinderFacelets2Element = SCNGeometryElement(indices: cylinderFacelets2Indices, primitiveType: .Triangles)
        
        
        let cylinderFaceletGeometry = SCNGeometry(sources: [cylinderVerticesGeometrySource, cylinderNormalsGeometrySource], elements:[cylinderFacelets1Element,cylinderFacelets2Element])
        
        cylinderFaceletGeometry.materials = [faceletMaterial1, faceletMaterial2]
        
        self.cylinder = SCNNode(geometry: cylinderFaceletGeometry)
        self.cylinder.position = SCNVector3(x: 0, y: 0, z: 0)
        self.cylinder.name = "cylinder"
        
        
        
        
        
        /// DISCRETIZED SPHERE WITH COLORED FACELET ///
        
        
        
        var sphere2Vertices = [] as [SCNVector3]
        var sphere2Normals = [] as [SCNVector3]
        
        
        for i in 0...nbThetaInt {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.0001
            if theta > 0.5*π { theta = 0.5*π - 0.0001 }
            
            for j in 0..<nbPhiInt {
                let phi = Float(j) * dphi
                
                let vertex = SCNVector3Make(cos(theta)*sin(phi),
                                            cos(theta)*cos(phi),
                                            sin(theta))
                
                let normal = vertex
                
                sphere2Vertices.append(vertex)
                sphere2Vertices.append(vertex)
                sphere2Normals.append(normal)
                sphere2Normals.append(normal)
                
                //self.drawNormal(vertex, normal: normal)
                
                
            }
            
        }
        
        
        
        var sphere2Facelets1Indices = [] as [UInt16]
        var sphere2Facelets2Indices = [] as [UInt16]
        var sphere2Facelets3Indices = [] as [UInt16]
        
        // vertex indices for the even-colored facelet geometry element
        
        for i in 1..<nbTheta {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.0001
            if theta > 0.5*π { theta = 0.5*π - 0.0001 }
            
            for j in 0..<nbPhi {
                if ((i+j)%2 == 0 && !(i == ii && j == jj)) {
                    // indices of the vertices for the two triangles
                    let nextJ = (j+1) % nbPhi
                    
                    if (theta >= -1.0e-2) {
                        
                        sphere2Facelets1Indices.append(2 * (i * nbPhi + j))
                        sphere2Facelets1Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        sphere2Facelets1Indices.append(2 * ((i+1) * nbPhi + j) + 1)
                        
                        sphere2Facelets1Indices.append(2 * (i * nbPhi + j))
                        sphere2Facelets1Indices.append(2 * (i * nbPhi + nextJ))
                        sphere2Facelets1Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        
                    }
                    
                    if (theta <= 1.0e-2) {
                        
                        sphere2Facelets2Indices.append(2 * (i * nbPhi + j))
                        sphere2Facelets2Indices.append(2 * ((i-1) * nbPhi + j) + 1)
                        sphere2Facelets2Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        
                        sphere2Facelets2Indices.append(2 * (i * nbPhi + j))
                        sphere2Facelets2Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        sphere2Facelets2Indices.append(2 * (i * nbPhi + nextJ))
                        
                    }
                } else if (i == ii && j == jj) {let nextJ = (j+1) % nbPhi
                    
                    if (theta >= -1.0e-2) {
                        
                        sphere2Facelets3Indices.append(2 * (i * nbPhi + j))
                        sphere2Facelets3Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        sphere2Facelets3Indices.append(2 * ((i+1) * nbPhi + j) + 1)
                        
                        sphere2Facelets3Indices.append(2 * (i * nbPhi + j))
                        sphere2Facelets3Indices.append(2 * (i * nbPhi + nextJ))
                        sphere2Facelets3Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        
                    }
                    
                    if (theta <= 1.0e-2) {
                        
                        sphere2Facelets3Indices.append(2 * (i * nbPhi + j))
                        sphere2Facelets3Indices.append(2 * ((i-1) * nbPhi + j) + 1)
                        sphere2Facelets3Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        
                        sphere2Facelets3Indices.append(2 * (i * nbPhi + j))
                        sphere2Facelets3Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        sphere2Facelets3Indices.append(2 * (i * nbPhi + nextJ))
                        
                    }
                    
                }
            }
        }
        
        
        // vertex indices for the odd-colored facelet geometry element
        
        
        for i in 1..<nbTheta {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.0001
            if theta > 0.5*π { theta = 0.5*π - 0.0001 }
            
            for j in 0..<nbPhi {
                if ((i+j)%2 == 1 && !(i == ii && j == jj)) {
                    // indices of the vertices for the two triangles
                    let nextJ = (j+1) % nbPhi
                    
                    if (theta >= -1.0e-2) {
                        
                        sphere2Facelets2Indices.append(2 * (i * nbPhi + j))
                        sphere2Facelets2Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        sphere2Facelets2Indices.append(2 * ((i+1) * nbPhi + j) + 1)
                        
                        sphere2Facelets2Indices.append(2 * (i * nbPhi + j))
                        sphere2Facelets2Indices.append(2 * (i * nbPhi + nextJ))
                        sphere2Facelets2Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        
                    }
                    
                    if (theta <= 1.0e-2) {
                        
                        sphere2Facelets1Indices.append(2 * (i * nbPhi + j))
                        sphere2Facelets1Indices.append(2 * ((i-1) * nbPhi + j) + 1)
                        sphere2Facelets1Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        
                        sphere2Facelets1Indices.append(2 * (i * nbPhi + j))
                        sphere2Facelets1Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        sphere2Facelets1Indices.append(2 * (i * nbPhi + nextJ))
                        
                    }
                } else if (i == ii && j == jj) {
                    // indices of the vertices for the two triangles
                    let nextJ = (j+1) % nbPhi
                    
                    if (theta >= -1.0e-2) {
                        
                        sphere2Facelets3Indices.append(2 * (i * nbPhi + j))
                        sphere2Facelets3Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        sphere2Facelets3Indices.append(2 * ((i+1) * nbPhi + j) + 1)
                        
                        sphere2Facelets3Indices.append(2 * (i * nbPhi + j))
                        sphere2Facelets3Indices.append(2 * (i * nbPhi + nextJ))
                        sphere2Facelets3Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        
                    }
                    
                    if (theta <= 1.0e-2) {
                        
                        sphere2Facelets3Indices.append(2 * (i * nbPhi + j))
                        sphere2Facelets3Indices.append(2 * ((i-1) * nbPhi + j) + 1)
                        sphere2Facelets3Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        
                        sphere2Facelets3Indices.append(2 * (i * nbPhi + j))
                        sphere2Facelets3Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        sphere2Facelets3Indices.append(2 * (i * nbPhi + nextJ))
                        
                    }
                }
            }
        }
        
        
        
        let sphere2VerticesGeometrySource = SCNGeometrySource(vertices: sphere2Vertices, count: 2*(nbThetaInt+1) * nbPhiInt)
        let sphere2NormalsGeometrySource = SCNGeometrySource(normals: sphere2Normals, count: 2*(nbThetaInt+1) * nbPhiInt)
        
        let sphere2Facelets1Element = SCNGeometryElement(indices: sphere2Facelets1Indices, primitiveType: .Triangles)
        let sphere2Facelets2Element = SCNGeometryElement(indices: sphere2Facelets2Indices, primitiveType: .Triangles)
        let sphere2Facelets3Element = SCNGeometryElement(indices: sphere2Facelets3Indices, primitiveType: .Triangles)
        
        
        let sphere2FaceletGeometry = SCNGeometry(sources: [sphere2VerticesGeometrySource, sphere2NormalsGeometrySource], elements:[sphere2Facelets1Element,sphere2Facelets2Element, sphere2Facelets3Element])
        
        sphere2FaceletGeometry.materials = [faceletMaterial11, faceletMaterial21, faceletMaterial3]
        
        
        self.sphere2 = SCNNode(geometry: sphere2FaceletGeometry)
        self.sphere2.position = SCNVector3(x: 0, y: 0, z: 0)
        self.sphere2.name = "sphere"
        
        
        
        
        //// SPHYLINDER WITH COLORED FACELET ///
        
        var sphylinder2Vertices = [] as [SCNVector3]
        var sphylinder2Normals = [] as [SCNVector3]
        
        
        for i in 0...nbThetaInt {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.0001
            if theta > 0.5*π { theta = 0.5*π - 0.0001 }
            
            for j in 0..<nbPhiInt {
                let phi = Float(j) * dphi
                
                let vertex = SCNVector3Make(cos(theta)*sin(phi),
                                            cos(theta)*cos(phi),
                                            sin(theta))
                
                let vertexMinus = SCNVector3Make(cos(theta-dtheta)*sin(phi),
                                                 cos(theta-dtheta)*cos(phi),
                                                 sin(theta))
                
                let vertexPlus = SCNVector3Make(cos(theta+dtheta)*sin(phi),
                                                cos(theta+dtheta)*cos(phi),
                                                sin(theta))
                
                let normal = SCNVector3Make(sin(phi), cos(phi), 0)
                
                sphylinder2Vertices.append(vertex)
                //self.drawNormal(vertex, normal: normal)
                
                if (theta > 1.0e-2) {
                    sphylinder2Vertices.append(vertexMinus)
                    //self.drawNormal(vertexMinus, normal: normal)
                    
                } else if (theta < -1.0e-2) {
                    
                    sphylinder2Vertices.append(vertexPlus)
                    //self.drawNormal(vertexPlus, normal: normal)
                    
                } else {
                    
                    sphylinder2Vertices.append(vertex)
                    //self.drawNormal(vertex, normal: normal)
                }
                
                sphylinder2Normals.append(normal)
                sphylinder2Normals.append(normal)
                
            }
            
        }
        
        
        
        var sphylinder2Facelets1Indices = [] as [UInt16]
        var sphylinder2Facelets2Indices = [] as [UInt16]
        var sphylinder2Facelets3Indices = [] as [UInt16]
        
        // vertex indices for the even-colored facelet geometry element
        
        for i in 1..<nbTheta {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.0001
            if theta > 0.5*π { theta = 0.5*π - 0.0001 }
            
            for j in 0..<nbPhi {
                if ((i+j)%2 == 0 && !(i == ii && j == jj)) {
                    // indices of the vertices for the two triangles
                    let nextJ = (j+1) % nbPhi
                    
                    if (theta >= -1.0e-2) {
                        
                        sphylinder2Facelets1Indices.append(2 * (i * nbPhi + j))
                        sphylinder2Facelets1Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        sphylinder2Facelets1Indices.append(2 * ((i+1) * nbPhi + j) + 1)
                        
                        sphylinder2Facelets1Indices.append(2 * (i * nbPhi + j))
                        sphylinder2Facelets1Indices.append(2 * (i * nbPhi + nextJ))
                        sphylinder2Facelets1Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        
                    }
                    
                    if (theta <= 1.0e-2) {
                        
                        sphylinder2Facelets2Indices.append(2 * (i * nbPhi + j))
                        sphylinder2Facelets2Indices.append(2 * ((i-1) * nbPhi + j) + 1)
                        sphylinder2Facelets2Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        
                        sphylinder2Facelets2Indices.append(2 * (i * nbPhi + j))
                        sphylinder2Facelets2Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        sphylinder2Facelets2Indices.append(2 * (i * nbPhi + nextJ))
                        
                    }
                } else if (i == ii && j == jj) {let nextJ = (j+1) % nbPhi
                    
                    if (theta >= -1.0e-2) {
                        
                        sphylinder2Facelets3Indices.append(2 * (i * nbPhi + j))
                        sphylinder2Facelets3Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        sphylinder2Facelets3Indices.append(2 * ((i+1) * nbPhi + j) + 1)
                        
                        sphylinder2Facelets3Indices.append(2 * (i * nbPhi + j))
                        sphylinder2Facelets3Indices.append(2 * (i * nbPhi + nextJ))
                        sphylinder2Facelets3Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        
                    }
                    
                    if (theta <= 1.0e-2) {
                        
                        sphylinder2Facelets3Indices.append(2 * (i * nbPhi + j))
                        sphylinder2Facelets3Indices.append(2 * ((i-1) * nbPhi + j) + 1)
                        sphylinder2Facelets3Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        
                        sphylinder2Facelets3Indices.append(2 * (i * nbPhi + j))
                        sphylinder2Facelets3Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        sphylinder2Facelets3Indices.append(2 * (i * nbPhi + nextJ))
                        
                    }
                    
                }
            }
        }
        
        
        // vertex indices for the odd-colored facelet geometry element
        
        
        for i in 1..<nbTheta {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.0001
            if theta > 0.5*π { theta = 0.5*π - 0.0001 }
            
            for j in 0..<nbPhi {
                if ((i+j)%2 == 1 && !(i == ii && j == jj)) {
                    // indices of the vertices for the two triangles
                    let nextJ = (j+1) % nbPhi
                    
                    if (theta >= -1.0e-2) {
                        
                        sphylinder2Facelets2Indices.append(2 * (i * nbPhi + j))
                        sphylinder2Facelets2Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        sphylinder2Facelets2Indices.append(2 * ((i+1) * nbPhi + j) + 1)
                        
                        sphylinder2Facelets2Indices.append(2 * (i * nbPhi + j))
                        sphylinder2Facelets2Indices.append(2 * (i * nbPhi + nextJ))
                        sphylinder2Facelets2Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        
                    }
                    
                    if (theta <= 1.0e-2) {
                        
                        sphylinder2Facelets1Indices.append(2 * (i * nbPhi + j))
                        sphylinder2Facelets1Indices.append(2 * ((i-1) * nbPhi + j) + 1)
                        sphylinder2Facelets1Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        
                        sphylinder2Facelets1Indices.append(2 * (i * nbPhi + j))
                        sphylinder2Facelets1Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        sphylinder2Facelets1Indices.append(2 * (i * nbPhi + nextJ))
                        
                    }
                } else if (i == ii && j == jj) {
                    // indices of the vertices for the two triangles
                    let nextJ = (j+1) % nbPhi
                    
                    if (theta >= -1.0e-2) {
                        
                        sphylinder2Facelets3Indices.append(2 * (i * nbPhi + j))
                        sphylinder2Facelets3Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        sphylinder2Facelets3Indices.append(2 * ((i+1) * nbPhi + j) + 1)
                        
                        sphylinder2Facelets3Indices.append(2 * (i * nbPhi + j))
                        sphylinder2Facelets3Indices.append(2 * (i * nbPhi + nextJ))
                        sphylinder2Facelets3Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        
                    }
                    
                    if (theta <= 1.0e-2) {
                        
                        sphylinder2Facelets3Indices.append(2 * (i * nbPhi + j))
                        sphylinder2Facelets3Indices.append(2 * ((i-1) * nbPhi + j) + 1)
                        sphylinder2Facelets3Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        
                        sphylinder2Facelets3Indices.append(2 * (i * nbPhi + j))
                        sphylinder2Facelets3Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        sphylinder2Facelets3Indices.append(2 * (i * nbPhi + nextJ))
                        
                    }
                }
            }
        }
        
        
        
        let sphylinder2VerticesGeometrySource = SCNGeometrySource(vertices: sphylinder2Vertices, count: 2*(nbThetaInt+1) * nbPhiInt)
        let sphylinder2NormalsGeometrySource = SCNGeometrySource(normals: sphylinder2Normals, count: 2*(nbThetaInt+1) * nbPhiInt)
        
        let sphylinder2Facelets1Element = SCNGeometryElement(indices: sphylinder2Facelets1Indices, primitiveType: .Triangles)
        let sphylinder2Facelets2Element = SCNGeometryElement(indices: sphylinder2Facelets2Indices, primitiveType: .Triangles)
        let sphylinder2Facelets3Element = SCNGeometryElement(indices: sphylinder2Facelets3Indices, primitiveType: .Triangles)
        
        
        let sphylinder2FaceletGeometry = SCNGeometry(sources: [sphylinder2VerticesGeometrySource, sphylinder2NormalsGeometrySource], elements:[sphylinder2Facelets1Element,sphylinder2Facelets2Element, sphylinder2Facelets3Element])
        
        sphylinder2FaceletGeometry.materials = [faceletMaterial11, faceletMaterial21, faceletMaterial3]
        
        
        self.sphylinder2 = SCNNode(geometry: sphylinder2FaceletGeometry)
        self.sphylinder2.position = SCNVector3(x: 0, y: 0, z: 0)
        self.sphylinder2.name = "sphylinder"
        
        
        
        //// CYLINDER WITH COLORED FACELET ///
        
        var cylinder2Vertices = [] as [SCNVector3]
        var cylinder2Normals = [] as [SCNVector3]
        
        
        for i in 0...nbThetaInt {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.0001
            if theta > 0.5*π { theta = 0.5*π - 0.0001 }
            
            for j in 0..<nbPhiInt {
                let phi = Float(j) * dphi
                
                let vertex = SCNVector3Make(sin(phi),
                                            cos(phi),
                                            sin(theta))
                let normal = SCNVector3Make(sin(phi), cos(phi), 0)
                
                cylinder2Vertices.append(vertex)
                //self.drawNormal(vertex, normal: normal)
                
                cylinder2Vertices.append(vertex)
                //self.drawNormal(vertex, normal: normal)
                
                
                cylinder2Normals.append(normal)
                cylinder2Normals.append(normal)
                
            }
            
        }
        
        
        
        var cylinder2Facelets1Indices = [] as [UInt16]
        var cylinder2Facelets2Indices = [] as [UInt16]
        var cylinder2Facelets3Indices = [] as [UInt16]
        
        // vertex indices for the even-colored facelet geometry element
        
        for i in 1..<nbTheta {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.0001
            if theta > 0.5*π { theta = 0.5*π - 0.0001 }
            
            for j in 0..<nbPhi {
                if ((i+j)%2 == 0 && !(i == ii && j == jj)) {
                    // indices of the vertices for the two triangles
                    let nextJ = (j+1) % nbPhi
                    
                    if (theta >= -1.0e-2) {
                        
                        cylinder2Facelets1Indices.append(2 * (i * nbPhi + j))
                        cylinder2Facelets1Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        cylinder2Facelets1Indices.append(2 * ((i+1) * nbPhi + j) + 1)
                        
                        cylinder2Facelets1Indices.append(2 * (i * nbPhi + j))
                        cylinder2Facelets1Indices.append(2 * (i * nbPhi + nextJ))
                        cylinder2Facelets1Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        
                    }
                    
                    if (theta <= 1.0e-2) {
                        
                        cylinder2Facelets2Indices.append(2 * (i * nbPhi + j))
                        cylinder2Facelets2Indices.append(2 * ((i-1) * nbPhi + j) + 1)
                        cylinder2Facelets2Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        
                        cylinder2Facelets2Indices.append(2 * (i * nbPhi + j))
                        cylinder2Facelets2Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        cylinder2Facelets2Indices.append(2 * (i * nbPhi + nextJ))
                        
                    }
                } else if (i == ii && j == jj) {let nextJ = (j+1) % nbPhi
                    
                    if (theta >= -1.0e-2) {
                        
                        cylinder2Facelets3Indices.append(2 * (i * nbPhi + j))
                        cylinder2Facelets3Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        cylinder2Facelets3Indices.append(2 * ((i+1) * nbPhi + j) + 1)
                        
                        cylinder2Facelets3Indices.append(2 * (i * nbPhi + j))
                        cylinder2Facelets3Indices.append(2 * (i * nbPhi + nextJ))
                        cylinder2Facelets3Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        
                    }
                    
                    if (theta <= 1.0e-2) {
                        
                        cylinder2Facelets3Indices.append(2 * (i * nbPhi + j))
                        cylinder2Facelets3Indices.append(2 * ((i-1) * nbPhi + j) + 1)
                        cylinder2Facelets3Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        
                        cylinder2Facelets3Indices.append(2 * (i * nbPhi + j))
                        cylinder2Facelets3Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        cylinder2Facelets3Indices.append(2 * (i * nbPhi + nextJ))
                        
                    }
                    
                }
            }
        }
        
        
        // vertex indices for the odd-colored facelet geometry element
        
        
        for i in 1..<nbTheta {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.0001
            if theta > 0.5*π { theta = 0.5*π - 0.0001 }
            
            for j in 0..<nbPhi {
                if ((i+j)%2 == 1 && !(i == ii && j == jj)) {
                    // indices of the vertices for the two triangles
                    let nextJ = (j+1) % nbPhi
                    
                    if (theta >= -1.0e-2) {
                        
                        cylinder2Facelets2Indices.append(2 * (i * nbPhi + j))
                        cylinder2Facelets2Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        cylinder2Facelets2Indices.append(2 * ((i+1) * nbPhi + j) + 1)
                        
                        cylinder2Facelets2Indices.append(2 * (i * nbPhi + j))
                        cylinder2Facelets2Indices.append(2 * (i * nbPhi + nextJ))
                        cylinder2Facelets2Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        
                    }
                    
                    if (theta <= 1.0e-2) {
                        
                        cylinder2Facelets1Indices.append(2 * (i * nbPhi + j))
                        cylinder2Facelets1Indices.append(2 * ((i-1) * nbPhi + j) + 1)
                        cylinder2Facelets1Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        
                        cylinder2Facelets1Indices.append(2 * (i * nbPhi + j))
                        cylinder2Facelets1Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        cylinder2Facelets1Indices.append(2 * (i * nbPhi + nextJ))
                        
                    }
                } else if (i == ii && j == jj) {
                    // indices of the vertices for the two triangles
                    let nextJ = (j+1) % nbPhi
                    
                    if (theta >= -1.0e-2) {
                        
                        cylinder2Facelets3Indices.append(2 * (i * nbPhi + j))
                        cylinder2Facelets3Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        cylinder2Facelets3Indices.append(2 * ((i+1) * nbPhi + j) + 1)
                        
                        cylinder2Facelets3Indices.append(2 * (i * nbPhi + j))
                        cylinder2Facelets3Indices.append(2 * (i * nbPhi + nextJ))
                        cylinder2Facelets3Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        
                    }
                    
                    if (theta <= 1.0e-2) {
                        
                        cylinder2Facelets3Indices.append(2 * (i * nbPhi + j))
                        cylinder2Facelets3Indices.append(2 * ((i-1) * nbPhi + j) + 1)
                        cylinder2Facelets3Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        
                        cylinder2Facelets3Indices.append(2 * (i * nbPhi + j))
                        cylinder2Facelets3Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        cylinder2Facelets3Indices.append(2 * (i * nbPhi + nextJ))
                        
                    }
                }
            }
        }
        
        
        
        let cylinder2VerticesGeometrySource = SCNGeometrySource(vertices: cylinder2Vertices, count: 2*(nbThetaInt+1) * nbPhiInt)
        let cylinder2NormalsGeometrySource = SCNGeometrySource(normals: cylinder2Normals, count: 2*(nbThetaInt+1) * nbPhiInt)
        
        let cylinder2Facelets1Element = SCNGeometryElement(indices: cylinder2Facelets1Indices, primitiveType: .Triangles)
        let cylinder2Facelets2Element = SCNGeometryElement(indices: cylinder2Facelets2Indices, primitiveType: .Triangles)
        let cylinder2Facelets3Element = SCNGeometryElement(indices: cylinder2Facelets3Indices, primitiveType: .Triangles)
        
        
        let cylinder2FaceletGeometry = SCNGeometry(sources: [cylinder2VerticesGeometrySource, cylinder2NormalsGeometrySource], elements:[cylinder2Facelets1Element,cylinder2Facelets2Element, cylinder2Facelets3Element])
        
        cylinder2FaceletGeometry.materials = [faceletMaterial11, faceletMaterial21, faceletMaterial3]
        
        
        self.cylinder2 = SCNNode(geometry: cylinder2FaceletGeometry)
        self.cylinder2.position = SCNVector3(x: 0, y: 0, z: 0)
        self.cylinder2.name = "cylinder"
        
        
        
        
        
        /// SMOOTHER SPHERE ///
        
        
        nbTheta = 120 as UInt16
        nbThetaInt = 120 as Int
        
        dtheta = π/Float(nbTheta)
        
        nbPhi = 240 as UInt16
        nbPhiInt = 240 as Int
        dphi = 2.0*π/Float(nbPhi)
        
        
        
        //// FACELET MATERIALS ////
        
        let faceletMaterial4 = SCNMaterial()
        faceletMaterial4.shininess = 1.0
        faceletMaterial4.doubleSided = true
        faceletMaterial4.specular.intensity = 1.0
        faceletMaterial4.locksAmbientWithDiffuse = true
        faceletMaterial4.diffuse.contents = self.startColor
        faceletMaterial4.specular.contents = UIColor.whiteColor()
        
        
        // create sphere vertices and normals
        
        var sphere3Vertices = [] as [SCNVector3]
        var sphere3Normals = [] as [SCNVector3]
        
        for i in 0...nbThetaInt {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.0001
            if theta > 0.5*π { theta = 0.5*π - 0.0001 }
            
            for j in 0..<nbPhiInt {
                let phi = Float(j) * dphi
                
                let vertex = SCNVector3Make(cos(theta)*sin(phi),
                                            cos(theta)*cos(phi),
                                            sin(theta))
                
                let normal = vertex
                
                sphere3Vertices.append(vertex)
                sphere3Vertices.append(vertex)
                sphere3Normals.append(normal)
                sphere3Normals.append(normal)
                
                //self.drawNormal(vertex, normal: normal)
                
                
            }
            
        }
        
        
        
        var sphere3Facelets1Indices = [] as [UInt16]
        var sphere3Facelets2Indices = [] as [UInt16]
        
        // vertex indices for the even-colored facelet geometry element
        
        for i in 1..<nbTheta {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.0001
            if theta > 0.5*π { theta = 0.5*π - 0.0001 }
            
            for j in 0..<nbPhi {
                if (i+j)%2 == 0 {
                    // indices of the vertices for the two triangles
                    let nextJ = (j+1) % nbPhi
                    
                    if (theta >= -1.0e-2) {
                        
                        sphere3Facelets1Indices.append(2 * (i * nbPhi + j))
                        sphere3Facelets1Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        sphere3Facelets1Indices.append(2 * ((i+1) * nbPhi + j) + 1)
                        
                        sphere3Facelets1Indices.append(2 * (i * nbPhi + j))
                        sphere3Facelets1Indices.append(2 * (i * nbPhi + nextJ))
                        sphere3Facelets1Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        
                    }
                    
                    if (theta <= 1.0e-2) {
                        
                        sphere3Facelets2Indices.append(2 * (i * nbPhi + j))
                        sphere3Facelets2Indices.append(2 * ((i-1) * nbPhi + j) + 1)
                        sphere3Facelets2Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        
                        sphere3Facelets2Indices.append(2 * (i * nbPhi + j))
                        sphere3Facelets2Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        sphere3Facelets2Indices.append(2 * (i * nbPhi + nextJ))
                        
                    }
                }
            }
        }
        
        
        // vertex indices for the odd-colored facelet geometry element
        
        
        for i in 1..<nbTheta {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.0001
            if theta > 0.5*π { theta = 0.5*π - 0.0001 }
            
            for j in 0..<nbPhi {
                if (i+j)%2 == 1 {
                    // indices of the vertices for the two triangles
                    let nextJ = (j+1) % nbPhi
                    
                    if (theta >= -1.0e-2) {
                        
                        sphere3Facelets2Indices.append(2 * (i * nbPhi + j))
                        sphere3Facelets2Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        sphere3Facelets2Indices.append(2 * ((i+1) * nbPhi + j) + 1)
                        
                        sphere3Facelets2Indices.append(2 * (i * nbPhi + j))
                        sphere3Facelets2Indices.append(2 * (i * nbPhi + nextJ))
                        sphere3Facelets2Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        
                    }
                    
                    if (theta <= 1.0e-2) {
                        
                        sphere3Facelets1Indices.append(2 * (i * nbPhi + j))
                        sphere3Facelets1Indices.append(2 * ((i-1) * nbPhi + j) + 1)
                        sphere3Facelets1Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        
                        
                        sphere3Facelets1Indices.append(2 * (i * nbPhi + j))
                        sphere3Facelets1Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        sphere3Facelets1Indices.append(2 * (i * nbPhi + nextJ))
                        
                    }
                }
            }
        }
        
        
        
        let sphere3VerticesGeometrySource = SCNGeometrySource(vertices: sphere3Vertices, count: 2*(nbThetaInt+1) * nbPhiInt)
        let sphere3NormalsGeometrySource = SCNGeometrySource(normals: sphere3Normals, count: 2*(nbThetaInt+1) * nbPhiInt)
        
        let sphere3Facelets1Element = SCNGeometryElement(indices: sphere3Facelets1Indices, primitiveType: .Triangles)
        let sphere3Facelets2Element = SCNGeometryElement(indices: sphere3Facelets2Indices, primitiveType: .Triangles)
        
        
        let sphere3FaceletGeometry = SCNGeometry(sources: [sphere3VerticesGeometrySource, sphere3NormalsGeometrySource], elements:[sphere3Facelets1Element,sphere3Facelets2Element])
        
        
        sphere3FaceletGeometry.materials = [faceletMaterial4, faceletMaterial4]
        
        
        self.sphere3 = SCNNode(geometry: sphere3FaceletGeometry)
        self.sphere3.position = SCNVector3(x: 0, y: 0, z: 0)
        self.sphere3.name = "sphere"
        
        
        
        
        // smoother cylinder
        
        var cylinder3Vertices = [] as [SCNVector3]
        var cylinder3Normals = [] as [SCNVector3]
        
        
        for i in 0...nbThetaInt {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.001
            if theta > 0.5*π { theta = 0.5*π - 0.001 }
            
            for j in 0..<nbPhiInt {
                let phi = Float(j) * dphi
                
                let vertex = SCNVector3Make(sin(phi),
                                            cos(phi),
                                            sin(theta))
                
                let normal = SCNVector3Make(sin(phi), cos(phi), 0)
                
                cylinder3Vertices.append(vertex)
                //self.drawNormal(vertex, normal: normal)
                
                if (theta > 1.0e-2) {
                    cylinder3Vertices.append(vertex)
                    //self.drawNormal(vertex, normal: normal)
                    
                } else if (theta < -1.0e-2) {
                    
                    cylinder3Vertices.append(vertex)
                    //self.drawNormal(vertex, normal: normal)
                    
                } else {
                    
                    cylinder3Vertices.append(vertex)
                    //self.drawNormal(vertex, normal: normal)
                }
                
                cylinder3Normals.append(normal)
                cylinder3Normals.append(normal)
            }
        }
        
        
        
        var cylinder3Facelets1Indices = [] as [UInt16]
        var cylinder3Facelets2Indices = [] as [UInt16]
        
        // vertex indices for the even-colored facelet geometry element
        
        for i in 1..<nbTheta {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.001
            if theta > 0.5*π { theta = 0.5*π - 0.001 }
            
            for j in 0..<nbPhi {
                if (i+j)%2 == 0 {
                    // indices of the vertices for the two triangles
                    let nextJ = (j+1) % nbPhi
                    
                    if (theta >= -1.0e-2) {
                        
                        cylinder3Facelets1Indices.append(2 * (i * nbPhi + j))
                        cylinder3Facelets1Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        cylinder3Facelets1Indices.append(2 * ((i+1) * nbPhi + j) + 1)
                        
                        cylinder3Facelets1Indices.append(2 * (i * nbPhi + j))
                        cylinder3Facelets1Indices.append(2 * (i * nbPhi + nextJ))
                        cylinder3Facelets1Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        
                    }
                    
                    if (theta <= 1.0e-2) {
                        
                        cylinder3Facelets2Indices.append(2 * (i * nbPhi + j))
                        cylinder3Facelets2Indices.append(2 * ((i-1) * nbPhi + j) + 1)
                        cylinder3Facelets2Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        
                        cylinder3Facelets2Indices.append(2 * (i * nbPhi + j))
                        cylinder3Facelets2Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        cylinder3Facelets2Indices.append(2 * (i * nbPhi + nextJ))
                        
                    }
                }
            }
        }
        
        
        // vertex indices for the odd-colored facelet geometry element
        
        
        for i in 1..<nbTheta {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.001
            if theta > 0.5*π { theta = 0.5*π - 0.001 }
            
            for j in 0..<nbPhi {
                if (i+j)%2 == 1 {
                    // indices of the vertices for the two triangles
                    let nextJ = (j+1) % nbPhi
                    
                    if (theta >= -1.0e-2) {
                        
                        cylinder3Facelets2Indices.append(2 * (i * nbPhi + j))
                        cylinder3Facelets2Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        cylinder3Facelets2Indices.append(2 * ((i+1) * nbPhi + j) + 1)
                        
                        cylinder3Facelets2Indices.append(2 * (i * nbPhi + j))
                        cylinder3Facelets2Indices.append(2 * (i * nbPhi + nextJ))
                        cylinder3Facelets2Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        
                    }
                    
                    if (theta <= 1.0e-2) {
                        
                        cylinder3Facelets1Indices.append(2 * (i * nbPhi + j))
                        cylinder3Facelets1Indices.append(2 * ((i-1) * nbPhi + j) + 1)
                        cylinder3Facelets1Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        
                        cylinder3Facelets1Indices.append(2 * (i * nbPhi + j))
                        cylinder3Facelets1Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        cylinder3Facelets1Indices.append(2 * (i * nbPhi + nextJ))
                        
                    }
                }
            }
        }
        
        
        
        let cylinder3VerticesGeometrySource = SCNGeometrySource(vertices: cylinder3Vertices, count: 2*(nbThetaInt+1) * nbPhiInt)
        let cylinder3NormalsGeometrySource = SCNGeometrySource(normals: cylinder3Normals, count: 2*(nbThetaInt+1) * nbPhiInt)
        
        let cylinder3Facelets1Element = SCNGeometryElement(indices: cylinder3Facelets1Indices, primitiveType: .Triangles)
        let cylinder3Facelets2Element = SCNGeometryElement(indices: cylinder3Facelets2Indices, primitiveType: .Triangles)
        
        
        let cylinder3FaceletGeometry = SCNGeometry(sources: [cylinder3VerticesGeometrySource, cylinder3NormalsGeometrySource], elements:[cylinder3Facelets1Element,cylinder3Facelets2Element])
        
        cylinder3FaceletGeometry.materials = [faceletMaterial4, faceletMaterial4]
        
        self.cylinder3 = SCNNode(geometry: cylinder3FaceletGeometry)
        self.cylinder3.position = SCNVector3(x: 0, y: 0, z: 0)
        self.cylinder3.name = "cylinder"
        
        
        
        
        // smoother cylinder with a seam
        
        var cylinder4Vertices = [] as [SCNVector3]
        var cylinder4Normals = [] as [SCNVector3]
        
        
        for i in 0...nbThetaInt {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.001
            if theta > 0.5*π { theta = 0.5*π - 0.001 }
            
            for j in 0..<nbPhiInt {
                let phi = Float(j) * dphi
                
                let vertex = SCNVector3Make(sin(phi),
                                            cos(phi),
                                            sin(theta))
                
                let normal = SCNVector3Make(sin(phi), cos(phi), 0)
                
                cylinder4Vertices.append(vertex)
                //self.drawNormal(vertex, normal: normal)
                
                if (theta > 1.0e-2) {
                    cylinder4Vertices.append(vertex)
                    //self.drawNormal(vertex, normal: normal)
                    
                } else if (theta < -1.0e-2) {
                    
                    cylinder4Vertices.append(vertex)
                    //self.drawNormal(vertex, normal: normal)
                    
                } else {
                    
                    cylinder4Vertices.append(vertex)
                    //self.drawNormal(vertex, normal: normal)
                }
                
                cylinder4Normals.append(normal)
                cylinder4Normals.append(normal)
            }
        }
        
        
        
        var cylinder4Facelets1Indices = [] as [UInt16]
        var cylinder4Facelets2Indices = [] as [UInt16]
        
        // vertex indices for the even-colored facelet geometry element
        
        for i in 1..<nbTheta {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.001
            if theta > 0.5*π { theta = 0.5*π - 0.001 }
            
            for j in 0..<nbPhi-1 {
                if (i+j)%2 == 0 {
                    // indices of the vertices for the two triangles
                    let nextJ = (j+1) % nbPhi
                    
                    if (theta >= -1.0e-2) {
                        
                        cylinder4Facelets1Indices.append(2 * (i * nbPhi + j))
                        cylinder4Facelets1Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        cylinder4Facelets1Indices.append(2 * ((i+1) * nbPhi + j) + 1)
                        
                        cylinder4Facelets1Indices.append(2 * (i * nbPhi + j))
                        cylinder4Facelets1Indices.append(2 * (i * nbPhi + nextJ))
                        cylinder4Facelets1Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        
                    }
                    
                    if (theta <= 1.0e-2) {
                        
                        cylinder4Facelets2Indices.append(2 * (i * nbPhi + j))
                        cylinder4Facelets2Indices.append(2 * ((i-1) * nbPhi + j) + 1)
                        cylinder4Facelets2Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        
                        cylinder4Facelets2Indices.append(2 * (i * nbPhi + j))
                        cylinder4Facelets2Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        cylinder4Facelets2Indices.append(2 * (i * nbPhi + nextJ))
                        
                    }
                }
            }
        }
        
        
        // vertex indices for the odd-colored facelet geometry element
        
        
        for i in 1..<nbTheta {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.001
            if theta > 0.5*π { theta = 0.5*π - 0.001 }
            
            for j in 0..<nbPhi-1 {
                if (i+j)%2 == 1 {
                    // indices of the vertices for the two triangles
                    let nextJ = (j+1) % nbPhi
                    
                    if (theta >= -1.0e-2) {
                        
                        cylinder4Facelets2Indices.append(2 * (i * nbPhi + j))
                        cylinder4Facelets2Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        cylinder4Facelets2Indices.append(2 * ((i+1) * nbPhi + j) + 1)
                        
                        cylinder4Facelets2Indices.append(2 * (i * nbPhi + j))
                        cylinder4Facelets2Indices.append(2 * (i * nbPhi + nextJ))
                        cylinder4Facelets2Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        
                    }
                    
                    if (theta <= 1.0e-2) {
                        
                        cylinder4Facelets1Indices.append(2 * (i * nbPhi + j))
                        cylinder4Facelets1Indices.append(2 * ((i-1) * nbPhi + j) + 1)
                        cylinder4Facelets1Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        
                        cylinder4Facelets1Indices.append(2 * (i * nbPhi + j))
                        cylinder4Facelets1Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        cylinder4Facelets1Indices.append(2 * (i * nbPhi + nextJ))
                        
                    }
                }
            }
        }
        
        
        
        let cylinder4VerticesGeometrySource = SCNGeometrySource(vertices: cylinder4Vertices, count: 2*(nbThetaInt+1) * nbPhiInt)
        let cylinder4NormalsGeometrySource = SCNGeometrySource(normals: cylinder4Normals, count: 2*(nbThetaInt+1) * nbPhiInt)
        
        let cylinder4Facelets1Element = SCNGeometryElement(indices: cylinder4Facelets1Indices, primitiveType: .Triangles)
        let cylinder4Facelets2Element = SCNGeometryElement(indices: cylinder4Facelets2Indices, primitiveType: .Triangles)
        
        
        let cylinder4FaceletGeometry = SCNGeometry(sources: [cylinder4VerticesGeometrySource, cylinder4NormalsGeometrySource], elements:[cylinder4Facelets1Element,cylinder4Facelets2Element])
        
        cylinder4FaceletGeometry.materials = [faceletMaterial4, faceletMaterial4]
        
        self.cylinder4 = SCNNode(geometry: cylinder3FaceletGeometry)
        self.cylinder4.position = SCNVector3(x: 0, y: 0, z: 0)
        self.cylinder4.name = "cylinder"
        
        
        
        // smoother cylinder folded out
        
        var rectangleVertices = [] as [SCNVector3]
        var rectangleNormals = [] as [SCNVector3]
        
        
        for i in 0...nbThetaInt {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.001
            if theta > 0.5*π { theta = 0.5*π - 0.001 }
            
            for j in 0..<nbPhiInt {
                let phi = Float(j) * dphi
                let phi2 = phi - π/2 - atan(0.75)
                
                let vertex = SCNVector3Make(-0.6 + 0.8*phi2,
                                            -0.8 - 0.6*phi2,
                                            sin(theta))
                
                let normal = SCNVector3Make(1, 0, 0)
                
                rectangleVertices.append(vertex)
                //self.drawNormal(vertex, normal: normal)
                
                if (theta > 1.0e-2) {
                    rectangleVertices.append(vertex)
                    //self.drawNormal(vertex, normal: normal)
                    
                } else if (theta < -1.0e-2) {
                    
                    rectangleVertices.append(vertex)
                    //self.drawNormal(vertex, normal: normal)
                    
                } else {
                    
                    rectangleVertices.append(vertex)
                    //self.drawNormal(vertex, normal: normal)
                }
                
                rectangleNormals.append(normal)
                rectangleNormals.append(normal)
            }
        }
        
        
        
        var rectangleFacelets1Indices = [] as [UInt16]
        var rectangleFacelets2Indices = [] as [UInt16]
        
        // vertex indices for the even-colored facelet geometry element
        
        for i in 1..<nbTheta {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.001
            if theta > 0.5*π { theta = 0.5*π - 0.001 }
            
            for j in 0..<nbPhi {
                if (i+j)%2 == 0 {
                    // indices of the vertices for the two triangles
                    let nextJ = (j+1) % nbPhi
                    
                    if (theta >= -1.0e-2) {
                        
                        rectangleFacelets1Indices.append(2 * (i * nbPhi + j))
                        rectangleFacelets1Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        rectangleFacelets1Indices.append(2 * ((i+1) * nbPhi + j) + 1)
                        
                        rectangleFacelets1Indices.append(2 * (i * nbPhi + j))
                        rectangleFacelets1Indices.append(2 * (i * nbPhi + nextJ))
                        rectangleFacelets1Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        
                    }
                    
                    if (theta <= 1.0e-2) {
                        
                        rectangleFacelets2Indices.append(2 * (i * nbPhi + j))
                        rectangleFacelets2Indices.append(2 * ((i-1) * nbPhi + j) + 1)
                        rectangleFacelets2Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        
                        rectangleFacelets2Indices.append(2 * (i * nbPhi + j))
                        rectangleFacelets2Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        rectangleFacelets2Indices.append(2 * (i * nbPhi + nextJ))
                        
                    }
                }
            }
        }
        
        
        // vertex indices for the odd-colored facelet geometry element
        
        
        for i in 1..<nbTheta {
            
            var theta = -0.5 * π + Float(i) * dtheta + 0.001
            if theta > 0.5*π { theta = 0.5*π - 0.001 }
            
            for j in 0..<nbPhi {
                if (i+j)%2 == 1 {
                    // indices of the vertices for the two triangles
                    let nextJ = (j+1) % nbPhi
                    
                    if (theta >= -1.0e-2) {
                        
                        rectangleFacelets2Indices.append(2 * (i * nbPhi + j))
                        rectangleFacelets2Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        rectangleFacelets2Indices.append(2 * ((i+1) * nbPhi + j) + 1)
                        
                        rectangleFacelets2Indices.append(2 * (i * nbPhi + j))
                        rectangleFacelets2Indices.append(2 * (i * nbPhi + nextJ))
                        rectangleFacelets2Indices.append(2 * ((i+1) * nbPhi + nextJ) + 1)
                        
                    }
                    
                    if (theta <= 1.0e-2) {
                        
                        rectangleFacelets1Indices.append(2 * (i * nbPhi + j))
                        rectangleFacelets1Indices.append(2 * ((i-1) * nbPhi + j) + 1)
                        rectangleFacelets1Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        
                        rectangleFacelets1Indices.append(2 * (i * nbPhi + j))
                        rectangleFacelets1Indices.append(2 * ((i-1) * nbPhi + nextJ) + 1)
                        rectangleFacelets1Indices.append(2 * (i * nbPhi + nextJ))
                        
                    }
                }
            }
        }
        
        
        
        let rectangleVerticesGeometrySource = SCNGeometrySource(vertices: rectangleVertices, count: 2*(nbThetaInt+1) * nbPhiInt)
        let rectangleNormalsGeometrySource = SCNGeometrySource(normals: rectangleNormals, count: 2*(nbThetaInt+1) * nbPhiInt)
        
        let rectangleFacelets1Element = SCNGeometryElement(indices: rectangleFacelets1Indices, primitiveType: .Triangles)
        let rectangleFacelets2Element = SCNGeometryElement(indices: rectangleFacelets2Indices, primitiveType: .Triangles)
        
        
        let rectangleFaceletGeometry = SCNGeometry(sources: [rectangleVerticesGeometrySource, rectangleNormalsGeometrySource], elements:[rectangleFacelets1Element,rectangleFacelets2Element])
        
        rectangleFaceletGeometry.materials = [faceletMaterial4, faceletMaterial4]
        
        self.rectangle = SCNNode(geometry: rectangleFaceletGeometry)
        self.rectangle.position = SCNVector3(x: 0, y: 0, z: 0)
        self.rectangle.name = "rectangle"
        

        /// define cylinder surface point at indexed tile ///
        
        let theta = -π/2 + Float(ii)*self.ddtheta
        let phi = Float(jj)*self.ddphi
        
        let cylinderSurfacePoint1 = SCNVector3Make(sin(phi),
                                                   cos(phi),
                                                   sin(theta))
        let cylinderSurfacePoint2 = SCNVector3Make(sin(phi+self.ddphi),
                                                   cos(phi+self.ddphi),
                                                   sin(theta))
        let cylinderSurfacePoint3 = SCNVector3Make(sin(phi+self.ddphi),
                                                   cos(phi+self.ddphi),
                                                   sin(theta+self.ddtheta))
        let cylinderSurfacePoint4 = SCNVector3Make(sin(phi),
                                                   cos(phi),
                                                   sin(theta+self.ddtheta))
        
        
        
        let sphylinderSurfacePoint1 = SCNVector3Make(sin(phi)*cos(theta),
                                                     cos(phi)*cos(theta),
                                                     sin(theta))
        let sphylinderSurfacePoint2 = SCNVector3Make(sin(phi+self.ddphi)*cos(theta),
                                                     cos(phi+self.ddphi)*cos(theta),
                                                     sin(theta))
        let sphylinderSurfacePoint3 = SCNVector3Make(sin(phi+self.ddphi)*cos(theta),
                                                     cos(phi+self.ddphi)*cos(theta),
                                                     sin(theta+self.ddtheta))
        let sphylinderSurfacePoint4 = SCNVector3Make(sin(phi)*cos(theta),
                                                     cos(phi)*cos(theta),
                                                     sin(theta+self.ddtheta))
        
        
        
        
        let sphereSurfacePoint1 = SCNVector3Make(sin(phi)*cos(theta),
                                                     cos(phi)*cos(theta),
                                                     sin(theta))
        let sphereSurfacePoint2 = SCNVector3Make(sin(phi+self.ddphi)*cos(theta),
                                                     cos(phi+self.ddphi)*cos(theta),
                                                     sin(theta))
        let sphereSurfacePoint3 = SCNVector3Make(sin(phi+self.ddphi)*cos(theta+self.ddtheta),
                                                     cos(phi+self.ddphi)*cos(theta+self.ddtheta),
                                                     sin(theta+self.ddtheta))
        let sphereSurfacePoint4 = SCNVector3Make(sin(phi)*cos(theta+self.ddtheta),
                                                     cos(phi)*cos(theta+self.ddtheta),
                                                     sin(theta+self.ddtheta))
        
        let projectedPoint = SCNVector3Make(0, 0, sin(theta))
        
        
        
        let cylinderPyramidVertices = [projectedPoint,
                                       cylinderSurfacePoint1,
                                       cylinderSurfacePoint2,
                                       cylinderSurfacePoint3,
                                       cylinderSurfacePoint4
        ]
        
        let sphylinderPyramidVertices = [projectedPoint,
                                       sphylinderSurfacePoint1,
                                       sphylinderSurfacePoint2,
                                       sphylinderSurfacePoint3,
                                       sphylinderSurfacePoint4
        ]
        
        let spherePyramidVertices = [SCNVector3(0, 0, 0),
                                       sphereSurfacePoint1,
                                       sphereSurfacePoint2,
                                       sphereSurfacePoint3,
                                       sphereSurfacePoint4
        ]
        
        let pyramidIndices = [
            0, 1, 4,
            0, 2, 1,
            0, 3, 2,
            0, 4, 3,
            1, 2, 4,
            2, 3, 4
            ] as [UInt16]
        
        let cylinderPyramidVerticesGeometrySource = SCNGeometrySource(vertices: cylinderPyramidVertices, count: 5)
        
        let cylinderPyramidGeometryElement = SCNGeometryElement(indices: pyramidIndices, primitiveType: .Triangles)
        
        
        let cylinderPyramidGeometry = SCNGeometry(sources: [cylinderPyramidVerticesGeometrySource], elements:[cylinderPyramidGeometryElement])
        
        cylinderPyramidGeometry.materials = [faceletMaterial3]
        
        self.cylinderPyramid = SCNNode(geometry: cylinderPyramidGeometry)
        
        
 
        let sphylinderPyramidVerticesGeometrySource = SCNGeometrySource(vertices: sphylinderPyramidVertices, count: 5)
        
        let sphylinderPyramidGeometryElement = SCNGeometryElement(indices: pyramidIndices, primitiveType: .Triangles)
        
        
        let sphylinderPyramidGeometry = SCNGeometry(sources: [sphylinderPyramidVerticesGeometrySource], elements:[sphylinderPyramidGeometryElement])
        
        sphylinderPyramidGeometry.materials = [faceletMaterial3]
        
        self.sphylinderPyramid = SCNNode(geometry: sphylinderPyramidGeometry)
        

        
        
        
        
        let spherePyramidVerticesGeometrySource = SCNGeometrySource(vertices: spherePyramidVertices, count: 5)
        
        let spherePyramidGeometryElement = SCNGeometryElement(indices: pyramidIndices, primitiveType: .Triangles)
        
        
        let spherePyramidGeometry = SCNGeometry(sources: [spherePyramidVerticesGeometrySource], elements:[cylinderPyramidGeometryElement])
        
        spherePyramidGeometry.materials = [faceletMaterial3]
        
        self.spherePyramid = SCNNode(geometry: spherePyramidGeometry)
        

        
        
//        // define line from cylinder surface point to projected point
//        
//        let positions: [Float32] = [cylinderSurfacePoint.x, cylinderSurfacePoint.y, cylinderSurfacePoint.z, projectedPoint.x, projectedPoint.y, projectedPoint.z]
//        let positionData = NSData(bytes: positions, length: sizeof(Float32)*positions.count)
//        let indices: [Int32] = [0, 1]
//        let indexData = NSData(bytes: indices, length: sizeof(Int32) * indices.count)
//        
//        let source = SCNGeometrySource(data: positionData, semantic: SCNGeometrySourceSemanticVertex, vectorCount: indices.count, floatComponents: true, componentsPerVector: 3, bytesPerComponent: sizeof(Float32), dataOffset: 0, dataStride: sizeof(Float32) * 3)
//        let element = SCNGeometryElement(data: indexData, primitiveType: SCNGeometryPrimitiveType.Line, primitiveCount: indices.count, bytesPerIndex: sizeof(Int32))
//        
//        
//        self.line = SCNNode(geometry: SCNGeometry(sources: [source], elements: [element]))
//        self.line.position = SCNVector3(0, 0, 0)
//
//        
//        
//        // define line from sphylinder surface point to projected point
//        
//        let positions2: [Float32] = [sphylinderSurfacePoint.x, sphylinderSurfacePoint.y, sphylinderSurfacePoint.z, projectedPoint.x, projectedPoint.y, projectedPoint.z]
//        let positionData2 = NSData(bytes: positions2, length: sizeof(Float32)*positions2.count)
//        let indices2: [Int32] = [0, 1]
//        let indexData2 = NSData(bytes: indices2, length: sizeof(Int32) * indices.count)
//        
//        let source2 = SCNGeometrySource(data: positionData2, semantic: SCNGeometrySourceSemanticVertex, vectorCount: indices2.count, floatComponents: true, componentsPerVector: 3, bytesPerComponent: sizeof(Float32), dataOffset: 0, dataStride: sizeof(Float32) * 3)
//        let element2 = SCNGeometryElement(data: indexData2, primitiveType: SCNGeometryPrimitiveType.Line, primitiveCount: indices2.count, bytesPerIndex: sizeof(Int32))
//        
//        self.line2 = SCNNode(geometry: SCNGeometry(sources: [source2], elements: [element2]))
//        self.line2.position = SCNVector3(0, 0, 0)
//        
//        // define line from sphere surface point to origin
//        
//        let positions3: [Float32] = [sphereSurfacePoint.x, sphereSurfacePoint.y, sphereSurfacePoint.z, 0.0, 0.0, 0.0]
//        let positionData3 = NSData(bytes: positions3, length: sizeof(Float32)*positions3.count)
//        let indices3: [Int32] = [0, 1]
//        let indexData3 = NSData(bytes: indices3, length: sizeof(Int32) * indices3.count)
//        
//        let source3 = SCNGeometrySource(data: positionData3, semantic: SCNGeometrySourceSemanticVertex, vectorCount: indices3.count, floatComponents: true, componentsPerVector: 3, bytesPerComponent: sizeof(Float32), dataOffset: 0, dataStride: sizeof(Float32) * 3)
//        let element3 = SCNGeometryElement(data: indexData3, primitiveType: SCNGeometryPrimitiveType.Line, primitiveCount: indices3.count, bytesPerIndex: sizeof(Int32))
//        
//        self.line3 = SCNNode(geometry: SCNGeometry(sources: [source3], elements: [element3]))
//        self.line3.position = SCNVector3(0, 0, 0)
       
       
        
        
        
        
        /// MORPHERS ///
        
        self.perfectSphere.morpher = SCNMorpher()
        self.perfectSphere.morpher?.targets = [self.perfectCylinder.geometry!]
        
        self.sphere.morpher = SCNMorpher()
        self.sphere.morpher?.targets = [self.sphylinder.geometry!, self.cylinder.geometry!]
        
        self.sphere2.morpher = SCNMorpher()
        self.sphere2.morpher?.targets = [self.sphylinder2.geometry!, self.cylinder2.geometry!]
        
        
        self.sphere3.morpher = SCNMorpher()
        self.sphere3.morpher?.targets = [self.cylinder3.geometry!]
        
        
        self.cylinder4.morpher = SCNMorpher()
        self.cylinder4.morpher?.targets = [self.rectangle.geometry!]
        
//        self.line.morpher = SCNMorpher()
//        self.line.morpher?.targets = [self.line2.geometry!, self.line3.geometry!]
        
        self.cylinderPyramid.morpher = SCNMorpher()
        self.cylinderPyramid.morpher?.targets = [self.sphylinderPyramid.geometry!, self.spherePyramid.geometry!]
        
        
        
    }

    
    
    
    func lineBetweenNodeA(nodeA: SCNNode, nodeB: SCNNode) -> () {
        let positions: [Float32] = [nodeA.position.x, nodeA.position.y, nodeA.position.z, nodeB.position.x, nodeB.position.y, nodeB.position.z]
        let positionData = NSData(bytes: positions, length: sizeof(Float32)*positions.count)
        let indices: [Int32] = [0, 1]
        let indexData = NSData(bytes: indices, length: sizeof(Int32) * indices.count)
        
        let source = SCNGeometrySource(data: positionData, semantic: SCNGeometrySourceSemanticVertex, vectorCount: indices.count, floatComponents: true, componentsPerVector: 3, bytesPerComponent: sizeof(Float32), dataOffset: 0, dataStride: sizeof(Float32) * 3)
        let element = SCNGeometryElement(data: indexData, primitiveType: SCNGeometryPrimitiveType.Line, primitiveCount: indices.count, bytesPerIndex: sizeof(Int32))
        
        let line = SCNGeometry(sources: [source], elements: [element])
        let node = SCNNode(geometry: line)
        node.position = SCNVector3Make(0, 0, 1)
        let scene = ((view as? SCNView)?.scene)! as SCNScene
        scene.rootNode.addChildNode(node)
    }
    
    func drawNormal(point: SCNVector3, normal: SCNVector3) -> () {
        let startNode = SCNNode()
        startNode.position = point
        let endNode = SCNNode()
        endNode.position = SCNVector3Make(point.x + 0.1*normal.x, point.y + 0.1*normal.y, point.z + 0.1*normal.z)
        self.lineBetweenNodeA(startNode, nodeB: endNode)
        
    }
    
    
    func renderer(aRenderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: NSTimeInterval) {
        //Makes the lines thicker
        glLineWidth(0.1)
    }
    
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
