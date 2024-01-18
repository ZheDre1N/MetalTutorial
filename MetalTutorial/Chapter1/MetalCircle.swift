//
//  MetalCircle.swift
//  MetalTutorial
//
//  Created by Eugene Dudkin on 18.01.2024.
//

import MetalKit
import Alloy

class MetalCircle: UIView {
    let context = try! MTLContext()
    lazy var commandQueue = context.commandQueue
    lazy var device = context.device

    lazy var mtkView: MTKView = {
        let view = MTKView(frame: CGRect(x: 0, y: 0, width: 600, height: 600), device: device)
        view.clearColor = MTLClearColor(red: 1, green: 1, blue: 0.8, alpha: 1)

        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        drawAlloyView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MetalCircle {
    func drawAlloyView() {
        try! context.schedule { commandBuffer in
            let allocator = MTKMeshBufferAllocator(device: device)
            let mdlMesh = MDLMesh(sphereWithExtent: [0.75, 0.75, 0.75],
                                  segments: [100, 100],
                                  inwardNormals: false,
                                  geometryType: .triangles,
                                  allocator: allocator)
            let mesh = try! MTKMesh(mesh: mdlMesh, device: device)

            let shader = """
            #include <metal_stdlib>
            using namespace metal;

            struct VertexIn {
              float4 position [[attribute(0)]];
            };

            vertex float4 vertex_main(const VertexIn vertex_in [[stage_in]]) {
              return vertex_in.position;
            }

            fragment float4 fragment_main() {
              return float4(1, 0, 0, 1);
            }
            """
            let library = try! device.makeLibrary(source: shader, options: nil)
            let vertexFunction = library.makeFunction(name: "vertex_main")
            let fragmentFunction = library.makeFunction(name: "fragment_main")

            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction

            pipelineDescriptor.vertexDescriptor =
              MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)

            let pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)

            guard let renderPassDescriptor = mtkView.currentRenderPassDescriptor,
                  let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor:  renderPassDescriptor)
            else {
                fatalError()
            }

            renderEncoder.setRenderPipelineState(pipelineState)

            renderEncoder.setVertexBuffer(
              mesh.vertexBuffers[0].buffer, offset: 0, index: 0)

            guard let submesh = mesh.submeshes.first else {
              fatalError()
            }

            renderEncoder.drawIndexedPrimitives(
              type: .triangle,
              indexCount: submesh.indexCount,
              indexType: submesh.indexType,
              indexBuffer: submesh.indexBuffer.buffer,
              indexBufferOffset: 0)

            renderEncoder.endEncoding()
            guard let drawable = mtkView.currentDrawable else {
              fatalError()
            }
            commandBuffer.present(drawable)
        }
        
        addSubview(mtkView)
        mtkView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mtkView.topAnchor.constraint(equalTo: self.topAnchor),
            mtkView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            mtkView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            mtkView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }

}
