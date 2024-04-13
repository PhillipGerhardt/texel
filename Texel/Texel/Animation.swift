//
//  Animation.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

import Combine
import QuartzCore

struct AnimationTarget: Hashable {
    let id: UUID
    let hash: Int

    init(_ object: any Identifiable<UUID>, keyPath: AnyKeyPath) {
        self.id = object.id
        self.hash = keyPath.hashValue
    }
}

class Animations {
    static let shared = Animations()

    fileprivate var store = [AnimationTarget:Animation]()

    func register(_ animation: Animation, for target: any Identifiable<UUID>, keyPath: AnyKeyPath) {
        let animationTarget = AnimationTarget(target, keyPath: keyPath)
        register(animation, for: animationTarget)
    }

    func register(_ animation: Animation, for target: AnimationTarget) {
        engine.serialQueue.async {
            self.store[target] = animation
        }
    }

    func deregister(_ animation: Animation) {
        engine.serialQueue.async {
            if let entry = self.store.first(where: { _, val in val === animation }) {
                self.store.removeValue(forKey: entry.key)
            }
        }
    }

    func stop(_ target: AnimationTarget) {
        engine.serialQueue.async {
            if let val = self.store[target] {
                val.cancel()
                self.store.removeValue(forKey: target)
            }
        }
    }

    func stop<T,V>(_ target: T, keyPath: KeyPath<T, Published<V>.Publisher>)
    where T: Identifiable<UUID>
    {
        let animationTarget = AnimationTarget(target, keyPath: keyPath)
        stop(animationTarget)
    }

}

/**
 * Animation are keept alive by referencing self in the closure of the start method.
 * Once their subscription to the NormalizedTimer is canceled they are freed (if not referenced elsewhere).
 */
class Animation {

    var dst: Any?
    var duration: Float = 1
    var easeing: (Float) -> Float = linear(_:)

    var timer: NormalizedTimer?

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
//        print("Animation.deinit")
    }

    func start<T: Identifiable<UUID>>(src: Float, target: T, keyPath: KeyPath<T, Published<Float>.Publisher>) {
        guard let dst = dst as? Float else { return }
        Animations.shared.register(self, for: target, keyPath: keyPath)
        var publisher = target[keyPath: keyPath]
        timer = NormalizedTimer(duration: duration)
        timer?
            .map{ self.easeing($0) }
            .map{ simd_mix(src, dst, $0) }
            .handleEvents(receiveCompletion: { _ in Animations.shared.deregister(self) })
            .assign(to: &publisher)
    }

    func start<T: Identifiable<UUID>>(src: simd_float2, target: T, keyPath: KeyPath<T, Published<simd_float2>.Publisher>) {
        guard let dst = dst as? simd_float2 else { return }
        Animations.shared.register(self, for: target, keyPath: keyPath)
        var publisher = target[keyPath: keyPath]
        timer = NormalizedTimer(duration: duration)
        timer?
            .map{ self.easeing($0) }
            .map{ mix(src, dst, t: $0) }
            .handleEvents(receiveCompletion: { _ in Animations.shared.deregister(self) })
            .assign(to: &publisher)
    }

    func start<T: Identifiable<UUID>>(src: simd_float3, target: T, keyPath: KeyPath<T, Published<simd_float3>.Publisher>) {
        guard let dst = dst as? simd_float3 else { return }
        Animations.shared.register(self, for: target, keyPath: keyPath)
        var publisher = target[keyPath: keyPath]
        timer = NormalizedTimer(duration: duration)
        timer?
            .map{ self.easeing($0) }
            .map{ mix(src, dst, t: $0) }
            .handleEvents(receiveCompletion: { _ in Animations.shared.deregister(self) })
            .assign(to: &publisher)
    }

    func start<T: Identifiable<UUID>>(src: simd_float4, target: T, keyPath: KeyPath<T, Published<simd_float4>.Publisher>) {
        guard let dst = dst as? simd_float4 else { return }
        Animations.shared.register(self, for: target, keyPath: keyPath)
        var publisher = target[keyPath: keyPath]
        timer = NormalizedTimer(duration: duration)
        timer?
            .map{ self.easeing($0) }
            .map{ mix(src, dst, t: $0) }
            .handleEvents(receiveCompletion: { _ in Animations.shared.deregister(self) })
            .assign(to: &publisher)
    }

    func start<T: Identifiable<UUID>>(src: simd_quatf, target: T, keyPath: KeyPath<T, Published<simd_quatf>.Publisher>) {
        guard let dst = dst as? simd_quatf else { return }
        Animations.shared.register(self, for: target, keyPath: keyPath)
        var publisher = target[keyPath: keyPath]
        timer = NormalizedTimer(duration: duration)
        timer?
            .map{ self.easeing($0) }
            .map{ simd_slerp(src, dst, $0) }
            .handleEvents(receiveCompletion: { _ in Animations.shared.deregister(self) })
            .assign(to: &publisher)
    }

//    func start(src: Float, target: inout Published<Float>.Publisher) {
//        guard let dst = dst as? Float else { return }
//        timer = NormalizedTimer(duration: duration)
//        timer?
//            .map{ self.easeing($0) }
//            .map{ simd_mix(src, dst, $0) }
//            .assign(to: &target)
//    }

//    func start(src: simd_float2, target: inout Published<simd_float2>.Publisher) {
//        guard let dst = dst as? simd_float2 else { return }
//        timer = NormalizedTimer(duration: duration)
//        timer?
//            .map{ self.easeing($0) }
//            .map{ mix(src, dst, t: $0) }
//            .assign(to: &target)
//    }

//    func start(src: simd_float3, target: inout Published<simd_float3>.Publisher) {
//        guard let dst = dst as? simd_float3 else { return }
//        timer = NormalizedTimer(duration: duration)
//        timer?
//            .map{ self.easeing($0) }
//            .map{ mix(src, dst, t: $0) }
//            .assign(to: &target)
//    }

//    func start(src: simd_float4, target: inout Published<simd_float4>.Publisher) {
//        guard let dst = dst as? simd_float4 else { return }
//        timer = NormalizedTimer(duration: duration)
//        timer?
//            .map{ self.easeing($0) }
//            .map{ mix(src, dst, t: $0) }
//            .assign(to: &target)
//    }

//    func start(src: simd_quatf, target: inout Published<simd_quatf>.Publisher) {
//        guard let dst = dst as? simd_quatf else { return }
//        timer = NormalizedTimer(duration: duration)
//        timer?
//            .map{ self.easeing($0) }
//            .map{ simd_slerp(src, dst, $0) }
//            .assign(to: &target)
//    }

    func cancel() {
        timer?.cancel()
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

/**
 * Output a value in the range of 0...1 during a set duration.
 */
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
//        Swift.print("NormalizedTimer.deinit")
    }

    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        manager.receive(subscriber: subscriber)
    }

    func cancel() {
        token?.cancel()
    }

}
