//
//  Animation.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

import Combine
import QuartzCore

class Animation {

    var dst: Any?
    var duration: Float = 1
    var easeing: (Float) -> Float = linear(_:)

    init() {}

    init(_ duration: Float?, _ easeing: String?) {
        if let duration = duration {
            self.duration = duration
        }
        if let easeing = easeing,
           let mode = Ease(rawValue: easeing) {
            self.easeing = Ease.fun(for: mode)
        }
    }

    convenience init(_ dst: Float, _ duration: Float?, _ easeing: String?) {
        self.init(duration, easeing)
        self.dst = dst
    }

    convenience init(_ dst: simd_float2, _ duration: Float?, _ easeing: String?) {
        self.init(duration, easeing)
        self.dst = dst
    }

    convenience init(_ dst: simd_float3, _ duration: Float?, _ easeing: String?) {
        self.init(duration, easeing)
        self.dst = dst
    }

    convenience init(_ dst: simd_float4, _ duration: Float?, _ easeing: String?) {
        self.init(duration, easeing)
        self.dst = dst
    }

    convenience init(_ dst: simd_quatf, _ duration: Float?, _ easeing: String?) {
        self.init(duration, easeing)
        self.dst = dst
    }

    deinit {
        print("Animation.deinit")
    }

    func start(src: Float, target: inout Published<Float>.Publisher) {
        guard let dst = dst as? Float else { return }
        NormalizedTimer(duration: duration)
            .map{ self.easeing($0) }
            .map{ $0 * dst + (1-$0) * src }
            .assign(to: &target)
    }

    func start(src: simd_float2, target: inout Published<simd_float2>.Publisher) {
        guard let dst = dst as? simd_float2 else { return }
        NormalizedTimer(duration: duration)
            .map{ self.easeing($0) }
            .map{ $0 * dst + (1-$0) * src }
            .assign(to: &target)
    }

    func start(src: simd_float3, target: inout Published<simd_float3>.Publisher) {
        guard let dst = dst as? simd_float3 else { return }
        NormalizedTimer(duration: duration)
            .map{ self.easeing($0) }
            .map{ $0 * dst + (1-$0) * src }
            .assign(to: &target)
    }

    func start(src: simd_float4, target: inout Published<simd_float4>.Publisher) {
        guard let dst = dst as? simd_float4 else { return }
        NormalizedTimer(duration: duration)
            .map{ self.easeing($0) }
            .map{ $0 * dst + (1-$0) * src }
            .assign(to: &target)
    }

    func start(src: simd_quatf, target: inout Published<simd_quatf>.Publisher) {
        guard let dst = dst as? simd_quatf else { return }
        print("src", src, "dst", dst)
        NormalizedTimer(duration: duration)
            .map{ self.easeing($0) }
            .map{ simd_slerp(src, dst, $0) }
            .map { print($0); return $0; }
            .assign(to: &target)
    }

}

class ElapsedTimer: Publisher {
    typealias Output = Float
    typealias Failure = Never

    let manager = PassthroughSubject<Output, Failure>()
    let duration: Double
    let start = CACurrentMediaTime()
    var token: AnyCancellable?

    init(duration: Float) {
        self.duration = Double(duration)
        token = engine.animationTick.sink(receiveValue: {
            let elapsed = CACurrentMediaTime() - self.start
            self.manager.send(Float(elapsed))
            if elapsed >= self.duration {
                self.manager.send(completion: .finished)
                self.token?.cancel()
            }
        })
    }

    deinit {
    }

    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        manager.receive(subscriber: subscriber)
    }

}

class NormalizedTimer: Publisher {
    typealias Output = Float
    typealias Failure = Never

    let manager = PassthroughSubject<Output, Failure>()
    let duration: Double
    let start = CACurrentMediaTime()
    var token: AnyCancellable?

    init(duration: Float) {
        self.duration = Double(duration)
        token = engine.animationTick.sink(receiveValue: {
            let elapsed = CACurrentMediaTime() - self.start
            let fraction = Swift.min(1.0, elapsed / self.duration)
            self.manager.send(Float(fraction))
            if elapsed >= self.duration {
                self.manager.send(completion: .finished)
                self.token?.cancel()
            }
        })
    }

    deinit {
    }

    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        manager.receive(subscriber: subscriber)
    }

}
