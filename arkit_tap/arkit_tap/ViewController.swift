//
//  ViewController.swift
//  arkit_tap
//
//  Created by 原啓祐 on 2019/07/27.
//  Copyright © 2019 ksk. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートを設定
        sceneView.delegate = self
        
        // シーンを作成して登録
        sceneView.scene = SCNScene()
        
        // 特徴点を表示する
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // ライトの追加
        sceneView.autoenablesDefaultLighting = true
        
        // 平面検出
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    // 画面をタップしたときに呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 最初にタップした座標を取り出す
        guard let touch = touches.first else {return}
        
        let touchPos = touch.location(in: sceneView)
        
        // タップされた位置のARアンカーを探す
        let hitTest = sceneView.hitTest(touchPos, types: .existingPlaneUsingExtent)
        if !hitTest.isEmpty {
            // タップした箇所が取得できていればアンカーを追加
            let anchor = ARAnchor(transform: hitTest.first!.worldTransform)
            sceneView.session.add(anchor: anchor)
        }
    }
    
    // 平面を検出したときに呼ばれる
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard !(anchor is ARPlaneAnchor) else { return }
        
        // 球のノードを作成
        let sphereNode = SCNNode()
        
        // ノードにGeometryとTransformを設定
        sphereNode.geometry = SCNSphere(radius: 0.05)
        // 検出面の子要素にする
        sphereNode.position.y += Float(0.05)
        
        node.addChildNode(sphereNode)
    }
}
