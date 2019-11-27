//
//  ViewController.swift
//  arkit_gradation
//
//  Created by 原啓祐 on 2019/10/03.
//  Copyright © 2019 ksk. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneView: ARSCNView!
    private let device = MTLCreateSystemDefaultDevice()!
    var worldMapURL: URL = {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("worldMapURL")
        } catch {
            fatalError("No such file")
        }
    }()
    
    var sphereColor = UIColor.red
    var ringRadius = 1.0
    
    @IBAction func changeGreenButtonPressed(_ sender: Any) {
        self.sphereColor = UIColor.green
    }
    
    @IBAction func changeBlueButtonPressed(_ sender: Any) {
        self.sphereColor = UIColor.blue
    }
    
    @IBAction func changeYellowButtonPressed(_ sender: Any) {
        self.sphereColor = UIColor.yellow
    }
    
    @IBAction func changeRedButtonPressed(_ sender: Any) {
        self.sphereColor = UIColor.red
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        sender.maximumValue = 100.0
        sender.minimumValue = 0.1
        self.ringRadius = Double(sender.value)
    }

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

        let torusNode = SCNNode(geometry: SCNTorus(ringRadius: CGFloat(self.ringRadius), pipeRadius: 0.05))
    torusNode.geometry?.firstMaterial?.diffuse.contents = self.sphereColor

        let position = SCNVector3(x: 0, y: 1, z: -0.5) // ノードの位置は、左右：0m 上下：0m　奥に50cm
        if let camera = sceneView.pointOfView {
            torusNode.position = camera.convertPosition(position, to: nil) // カメラ位置からの偏差で求めた位置
        }

        sceneView.scene.rootNode.addChildNode(torusNode)
    }

    // 平面を検出したときに呼ばれる
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // guard !(anchor is ARPlaneAnchor) else { return }
        guard let planeAnchor = anchor as? ARPlaneAnchor else {fatalError()}

        // 平面ジオメトリの検出
        let planeGeometry = ARSCNPlaneGeometry(device: device)!
        planeGeometry.update(from: planeAnchor.geometry)
        // α値 透明度の設定
        planeGeometry.materials.first?.diffuse.contents = UIColor.red

        // 平面ノードの作成
        let planeNode = SCNNode()
        planeNode.geometry = planeGeometry

        // ノードの追加
        node.addChildNode(planeNode)

        // 平面の形状が更新されたときに呼ばれる
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
            guard let planeGeometry = node.childNodes.first!.geometry as? ARSCNPlaneGeometry else {return}

            // 平面の形状をアップデート
            planeGeometry.update(from: planeAnchor.geometry)
        }
    }


}
