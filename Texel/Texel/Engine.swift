//
//  Engine.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

import simd
import Combine
import MetalKit
import Dispatch


// The 256 byte aligned size of our uniform structure
let alignedUniformsSize = (MemoryLayout<Uniforms>.size      + 0xFF) & -0x100
let alignedVerticesSize = (MemoryLayout<Vertex>.size * 4    + 0xFF) & -0x100

/**
 * Holds all metal ressources needed.
 */
class Engine {
//    let colorPixelFormat: MTLPixelFormat = .bgra8Unorm
    let colorPixelFormat: MTLPixelFormat = .bgra10_xr
    let depthStencilPixelFormat: MTLPixelFormat = .depth32Float_stencil8
    let sampleCount = 1
    var clearColor = simd_float4(0,0,0,1)

    var scene = Scene()

    let device: MTLDevice

    /// Used by the Filter content.
    let coreImageContext: CIContext
    /// Used by the ImageContent. No need to create a seperate one for each Image.
    let textureLoader: MTKTextureLoader
    /// Used by the MovieContent to convert CVImageBuffer to metal textures.
    var textureCache: CVMetalTextureCache!

    /// Projection and view matrix
    var uniformsBuffer: MTLBuffer
    /// Our one quad that is used to draw all layers and contents
    var verticesBuffer: MTLBuffer
    var uniforms: UnsafeMutablePointer<Uniforms>
    var vertices: UnsafeMutablePointer<Vertex>

    /// Tell metal how our vertices are laid out
    var vertexDescriptor = MTLVertexDescriptor()

    let library: MTLLibrary
    let pipelineDescriptor: MTLRenderPipelineDescriptor

    let pipelineLayer: MTLRenderPipelineState
    let pipelineContent: MTLRenderPipelineState
    let pipelineContentFlipped: MTLRenderPipelineState
    let pipelineContentYUVTriplanar: MTLRenderPipelineState
    let pipelineStencil: MTLRenderPipelineState
    let pipelineTicker: MTLRenderPipelineState

    let depthStencilIncrementState: MTLDepthStencilState
    let depthStencilDecrementState: MTLDepthStencilState
    let depthStencilTestState: MTLDepthStencilState

    /// All metal views conneczs to issue a draw call
    let displayTick = PassthroughSubject<Void, Never>()
    /// All animations connects to update their values
    let animationTick = PassthroughSubject<Void, Never>();
    /// Movies connects to update their texures and push audio samples to the audio system
    let contentTick = PassthroughSubject<Void, Never>();

    /// Used to block any ticks that are to fast
    let semaphore = DispatchSemaphore(value: 1)

    /// Our "tick" generator
    let displayLink = DisplayLink()

    init() throws {
        self.device = MTLCreateSystemDefaultDevice()!
        self.textureLoader = MTKTextureLoader.init(device: device)
        if CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &textureCache) != kCVReturnSuccess {
            print("error", Fehler.CVMetalTextureCacheCreate)
        }
        self.coreImageContext = CIContext(mtlDevice: device)

        self.uniformsBuffer = device.makeBuffer(length:alignedUniformsSize, options:[MTLResourceOptions.storageModeShared])!
        self.uniformsBuffer.label = "UniformsBuffer"
        uniforms = uniformsBuffer.contents().bindMemory(to: Uniforms.self, capacity:1)
        uniforms[0].projectionMatrix = matrix_identity_float4x4
        uniforms[0].viewMatrix = matrix_identity_float4x4

        self.verticesBuffer = device.makeBuffer(length: alignedVerticesSize, options: [MTLResourceOptions.storageModeShared])!
        self.verticesBuffer.label = "VerticesBuffer"
        vertices = verticesBuffer.contents().bindMemory(to:Vertex.self, capacity: 4)
        vertices[0] = Vertex(position: simd_float3(0, 0, 0), uv: simd_float2(0, 1))
        vertices[1] = Vertex(position: simd_float3(0, 1, 0), uv: simd_float2(0, 0))
        vertices[2] = Vertex(position: simd_float3(1, 0, 0), uv: simd_float2(1, 1))
        vertices[3] = Vertex(position: simd_float3(1, 1, 0), uv: simd_float2(1, 0))

        do {
            guard let library = device.makeDefaultLibrary() else {
                throw Fehler.makeDefaultLibrary
            }
            self.library = library

            vertexDescriptor.attributes[VertexAttribute.position.rawValue].bufferIndex = BufferIndex.vertices.rawValue
            vertexDescriptor.attributes[VertexAttribute.position.rawValue].format = MTLVertexFormat.float3
            vertexDescriptor.attributes[VertexAttribute.position.rawValue].offset = 0
            vertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].bufferIndex = BufferIndex.vertices.rawValue
            vertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].format = MTLVertexFormat.float2
            vertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].offset =  MemoryLayout<simd_float3>.stride
            vertexDescriptor.layouts[BufferIndex.vertices.rawValue].stride = MemoryLayout<Vertex>.stride
            vertexDescriptor.layouts[BufferIndex.vertices.rawValue].stepRate = 1
            vertexDescriptor.layouts[BufferIndex.vertices.rawValue].stepFunction = MTLVertexStepFunction.perVertex

            pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexDescriptor = vertexDescriptor
            pipelineDescriptor.stencilAttachmentPixelFormat = depthStencilPixelFormat
            pipelineDescriptor.depthAttachmentPixelFormat = depthStencilPixelFormat
            pipelineDescriptor.rasterSampleCount = sampleCount

            /// Blending should be pre-multiplied
            pipelineDescriptor.colorAttachments[0].pixelFormat                  = colorPixelFormat
            pipelineDescriptor.colorAttachments[0].isBlendingEnabled            = true
            pipelineDescriptor.colorAttachments[0].rgbBlendOperation            = .add
            pipelineDescriptor.colorAttachments[0].alphaBlendOperation          = .add
            pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor         = .one
            pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor       = .one
            pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor    = .oneMinusSourceAlpha
            pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor  = .oneMinusSourceAlpha

            pipelineDescriptor.label = "Layer"
            pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexLayer")
            pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentLayer")
            pipelineLayer = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)

            pipelineDescriptor.label = "Content"
            pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexContent")
            pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentContent")
            pipelineContent = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)

            pipelineDescriptor.label = "ContentFlipped"
            pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexContentFlipped")
            pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentContent")
            pipelineContentFlipped = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)

            pipelineDescriptor.label = "ContentYUVTriplanar"
            pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexContentYUVTriplanar")
            pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentContentYUVTriplanar")
            pipelineContentYUVTriplanar = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)

            pipelineDescriptor.label = "Ticker"
            pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexTicker")
            pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentTicker")
            pipelineTicker = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)

            pipelineDescriptor.label = "Stencil"
            pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexStencil")
            pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentStencil")
            pipelineStencil = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)

            let depthStencilDescriptor = MTLDepthStencilDescriptor()

            depthStencilDescriptor.frontFaceStencil.depthStencilPassOperation = .incrementWrap
            depthStencilDescriptor.frontFaceStencil.stencilCompareFunction = .always
            guard let depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor) else {
                throw Fehler.makeDepthStencilState
            }
            depthStencilIncrementState = depthStencilState

            depthStencilDescriptor.frontFaceStencil.depthStencilPassOperation = .decrementWrap
            depthStencilDescriptor.frontFaceStencil.stencilCompareFunction = .always
            guard let  depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor) else {
                throw Fehler.makeDepthStencilState
            }
            depthStencilDecrementState = depthStencilState

            depthStencilDescriptor.frontFaceStencil.depthStencilPassOperation = .keep
            depthStencilDescriptor.frontFaceStencil.stencilCompareFunction = .equal
            guard let depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor) else {
                throw Fehler.makeDepthStencilState
            }
            depthStencilTestState = depthStencilState

        } catch {
            print("Unable to compile render pipeline state.  Error info: \(error)")
            throw error
        }

        displayLink.start {
            if self.semaphore.wait(timeout: .now()) == .timedOut { return }
            Task {
                await self.scene.interpretEvents() // user input update
            }
            self.displayTick.send() // when nothing has changed this is not neccesarry
            self.animationTick.send() // animations update
            self.contentTick.send() // content update
            self.semaphore.signal()
        }

        DispatchQueue.global(qos: .utility).async {
            NodeStart() // run nodejs in some background thread
        }

    }

    deinit {
        displayLink.stop()
    }

}

let engine = try! Engine()
