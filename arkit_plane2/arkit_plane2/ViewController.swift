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

        // 平面検出
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }

    // 平面を検出したときに呼ばれる
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {fatalError()}

        // ノード作成
        let planeNode = SCNNode()

        // ジオメトリの作成する
        let geometry = SCNPlane(
            width: CGFloat(planeAnchor.extent.x),
            height: CGFloat(planeAnchor.extent.z)
        )
        geometry.materials.first?.diffuse.contents = UIColor.white.withAlphaComponent(0.5)

        // ノードにGeometryとTransformを指定
        planeNode.geometry = geometry
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)

        // 検出したアンカーに対応するノードに子ノードとして持たせる
        node.addChildNode(planeNode)
    }
}
