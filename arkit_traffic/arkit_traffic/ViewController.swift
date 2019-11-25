//
//  ViewController.swift
//  arkit_traffic
//
//  Created by 原啓祐 on 2019/10/08.
//  Copyright © 2019 ksk. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreBluetooth
import NetworkExtension

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

//    @IBAction func calcTrafficStrength(_ sender: Any) {
//        var trafficStrength = 0;
//        if (getWifiNumberOfActiveBars() != nil) {
//            trafficStrength = getWifiNumberOfActiveBars() ?? 0
//        }
//
//        if trafficStrength <= 0 {
//            self.sphereColor = UIColor.blue
//        }
//    }


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
        print("こんにちは")
        var peripheral: CBPeripheral?
        peripheral?.readRSSI()
        if (peripheral != nil) {
            peripheral?.readRSSI()
            print(peripheral?.readRSSI())
        }
        print(peripheral ?? 777)
        print("あああ")
        
//        var rssiTest: Int
//        rssiTest = getSignalStrength()
//        print(rssiTest)
        
//        getWifiNumberOfActiveBars()
        printRetrievedWifiNetwork()

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

        // 球の色を設定
        sphereNode.geometry!.materials.first?.diffuse.contents = self.sphereColor

        sceneView.scene.rootNode.addChildNode(sphereNode)
    }

    // 平面を検出したときに呼ばれる
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard !(anchor is ARPlaneAnchor) else { return }
    }
    
    // https://codeday.me/jp/qa/20190714/1258248.html
//    func peripheral(peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: NSError?) {
//        print("Peripheral!!!!!!!!!")
//        print("RSSI = \(RSSI)")
//    }
    
    // https://stackoverflow.com/questions/54039211/how-to-get-signal-strength-rsrp-rssi-rsrq-sinr-cell-id-lte-3g-2g-of-iphone
    func getSignalStrength() -> Int {

        let application = UIApplication.shared
        let statusBarView = application.value(forKey: "statusBar") as! UIView
        let foregroundView = statusBarView.value(forKey: "foregroundView") as! UIView
        let foregroundViewSubviews = foregroundView.subviews

        var dataNetworkItemView:UIView!

        for subview in foregroundViewSubviews {
            if subview.isKind(of: NSClassFromString("UIStatusBarSignalStrengthItemView")!) {
                dataNetworkItemView = subview
                break
            } else {
                return 0 //NO SERVICE
            }
        }

        return dataNetworkItemView.value(forKey: "signalStrengthBars") as! Int

    }

    private func getWifiNumberOfActiveBars() -> Int? {
        let app = UIApplication.shared
        var numberOfActiveBars: Int?
        // 自分で追加
        var statusBarManager: UIStatusBarManager?
//        guard let containerBar = app.value(forKey: "statusBar") as? UIView else { return nil }
        // 自分で追加
        guard let containerBar = UIApplication.shared.keyWindow as? UIView else { return nil }
        print(containerBar)
        print("BBB")
        return 0
        // 自分で追加
//        statusBarManager = UIApplication.shared.keyWindow?.windowScene?.statusBarManager
        guard let statusBarMorden = NSClassFromString("UIStatusBar_Modern"), containerBar .isKind(of: statusBarMorden), let statusBar = containerBar.value(forKey: "statusBar") as? UIView else { return nil }
        print(statusBarMorden)
        print("ccc")
//
//        guard let foregroundView = statusBar.value(forKey: "foregroundView") as? UIView else { return nil }
//
//        for view in foregroundView.subviews {
//            for v in view.subviews {
//                if let statusBarWifiSignalView = NSClassFromString("_UIStatusBarWifiSignalView"), v .isKind(of: statusBarWifiSignalView) {
//                    if let val = v.value(forKey: "numberOfActiveBars") as? Int {
//                        numberOfActiveBars = val
//                        break
//                    }
//                }
//            }
//            if let _ = numberOfActiveBars {
//                break
//            }
//        }

//        return numberOfActiveBars
    }

    func printRetrievedWifiNetwork() {
        let interfaces = NEHotspotHelper.supportedNetworkInterfaces()

        print("--- \(interfaces)") // Appleの許可が得られるまで、常に空

        for interface in interfaces as! [NEHotspotNetwork] {
            print("--- \(interfaces)")
            let ssid = interface.ssid
            let bssid = interface.bssid
            let secure = interface.isSecure
            let autoJoined = interface.didAutoJoin
            let signalStrength = interface.signalStrength

            print("ssid: \(ssid)")
            print("bssid: \(bssid)")
            print("secure: \(secure)")
            print("autoJoined: \(autoJoined)")
            print("signalStrength: \(signalStrength)")
        }
    }
}
