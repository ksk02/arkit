//
//  ViewController.swift
//  arkit_gradation2
//
//  Created by 原啓祐 on 2019/11/26.
//  Copyright © 2019 ksk. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneview: ARSCNView!
    private let device = MTLCreateSystemDefaultDevice()!
    var worldMapURL: URL = {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("worldMapURL")
        } catch {
            fatalError("No such file")
        }
    }()
    
    @IBAction func loaderButtonPressed(_ sender: Any) {
        
    }
}
