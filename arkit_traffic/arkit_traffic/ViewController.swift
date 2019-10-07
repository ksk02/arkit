//
//  ViewController.swift
//  arkit_traffic
//
//  Created by 原啓祐 on 2019/09/23.
//  Copyright © 2019 ksk. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneView: ARSCNView!
    var worldMapURL: URL = {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("worldMapURL")
        } catch {
            fatalError("No such file")
        }
    }()


    // シーンを保存する
    @IBAction func saveButtonPressed(_ sender: Any) {
        sceneView.session.getCurrentWorldMap { worldMap, error in guard let map = worldMap else { return }

            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true) else { return }

            guard ((try? data.write(to: self.worldMapURL)) != nil) else { return }
        }
    }

    // シーンを読み込む
    @IBAction func loadButtonPressed(_ sender: Any) {
        var data: Data? = nil
        do {
            try data = Data(contentsOf: self.worldMapURL)
        } catch { return }

        guard let worldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data!) else { return }

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.initialWorldMap = worldMap

        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

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

        // 球の色を設定
        sphereNode.geometry!.materials.first?.diffuse.contents = UIColor.red

        node.addChildNode(sphereNode)
    }
}
