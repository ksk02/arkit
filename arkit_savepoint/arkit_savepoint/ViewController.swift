//
//  ViewController.swift
//  arkit_savepoint
//
//  Created by 原啓祐 on 2019/10/07.
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

    var sphereColor = UIColor.red


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

    @IBAction func changeColorButtonPressed(_ sender: Any) {
        self.sphereColor = UIColor.green
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

        // 球のノードを作成
        let sphereNode = SCNNode()

        // ノードにGeometryとTransformを設定
        sphereNode.geometry = SCNSphere(radius: 0.05)

        let position = SCNVector3(x: 0, y: 0, z: -0.5) // ノードの位置は、左右：0m 上下：0m　奥に50cm
        if let camera = sceneView.pointOfView {
            sphereNode.position = camera.convertPosition(position, to: nil) // カメラ位置からの偏差で求めた位置
        }

        var trafficStrength = 0;
        // if (getWifiNumberOfActiveBars() != nil) {
        //     trafficStrength = getWifiNumberOfActiveBars() ?? 0
        // }
        // var sphereColor = UIColor.green

        // if trafficStrength <= 0 {
        //     sphereColor = UIColor.blue
        // }

        // 球の色を設定
        sphereNode.geometry!.materials.first?.diffuse.contents = self.sphereColor

        sceneView.scene.rootNode.addChildNode(sphereNode)
    }

    // 平面を検出したときに呼ばれる
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard !(anchor is ARPlaneAnchor) else { return }
    }

    private func getWifiNumberOfActiveBars() -> Int? {
        let app = UIApplication.shared
        var numberOfActiveBars: Int?
        guard let containerBar = app.value(forKey: "statusBar") as? UIView else { return nil }
        guard let statusBarMorden = NSClassFromString("UIStatusBar_Modern"), containerBar .isKind(of: statusBarMorden), let statusBar = containerBar.value(forKey: "statusBar") as? UIView else { return nil }

        guard let foregroundView = statusBar.value(forKey: "foregroundView") as? UIView else { return nil }

        for view in foregroundView.subviews {
            for v in view.subviews {
                if let statusBarWifiSignalView = NSClassFromString("_UIStatusBarWifiSignalView"), v .isKind(of: statusBarWifiSignalView) {
                    if let val = v.value(forKey: "numberOfActiveBars") as? Int {
                        numberOfActiveBars = val
                        break
                    }
                }
            }
            if let _ = numberOfActiveBars {
                break
            }
        }

        return numberOfActiveBars
    }
}
