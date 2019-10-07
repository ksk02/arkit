//
//  ViewController.swift
//  arkit_featurepoint
//
//  Created by 原啓祐 on 2019/06/03.
//  Copyright © 2019 ksk. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // シーンを作成して登録
        sceneView.scene = SCNScene()
        
        // 特徴点を表示する
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // コンフィギュレーションの作成
        let configuration = ARWorldTrackingConfiguration()
        
        // セッション開始
        sceneView.session.run(configuration)
    }
}
