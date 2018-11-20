/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A visualization of the edges of a 3D box.
 可视化3D框的边缘 正方体
*/

import Foundation
import SceneKit

class Wireframe: SCNNode {
    
    private var color = UIColor.appYellow
    
    var isHighlighted: Bool = false {
        didSet {
            /*
             geometry: SCNGeometry ：可以在场景中显示的三维形状（也称为模型或网格），具有定义其外观的附加材料。
             firstMaterial：第一种材料附着在几何体上。
             */
            geometry?.firstMaterial?.diffuse.contents = isHighlighted ? UIColor.red : color
        }
    }
    
    private var flashTimer: Timer?
    private var flashDuration = 0.1
    
    init(extent: float3, color: UIColor, scale: CGFloat = 1.0) {
        super.init()
        
        let box = SCNBox(width: CGFloat(extent.x), height: CGFloat(extent.y), length: CGFloat(extent.z), chamferRadius: 0)
        box.firstMaterial?.diffuse.contents = color
        box.firstMaterial?.isDoubleSided = true
        self.geometry = box
        
        self.color = color
        
        setupShader()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(flash),
                                               name: ObjectOrigin.movedOutsideBoxNotification,
                                               object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(extent: float3) {
        if let box = self.geometry as? SCNBox {
            box.width = CGFloat(extent.x)
            box.height = CGFloat(extent.y)
            box.length = CGFloat(extent.z)
        }
    }
    
    @objc
    func flash() {
        isHighlighted = true
        
        flashTimer?.invalidate()
        flashTimer = Timer.scheduledTimer(withTimeInterval: flashDuration, repeats: false) { _ in
            self.isHighlighted = false
        }
    }
    
    // MARK: - Shading 着色器
    
    func setupShader() {
        guard let path = Bundle.main.path(forResource: "wireframe_shader", ofType: "metal", inDirectory: "art.scnassets"),
            let shader = try? String(contentsOfFile: path, encoding: .utf8) else {
                return
        }
        
        geometry?.firstMaterial?.shaderModifiers = [.surface: shader]
    }
}
