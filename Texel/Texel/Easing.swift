//
//  Easing.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

func linear(_ x: Float) -> Float {
    x
}

func inSine(_ x: Float) -> Float {
    1 - cos((x * Float.pi) / 2)
}

func outSine(_ x: Float) -> Float {
    sin((x * Float.pi) / 2)
}

func inOutSine(_ x: Float) -> Float {
    -(cos(Float.pi * x) - 1) / 2
}

func inCubic(_ x: Float) -> Float {
    x * x * x
}

func outCubic(_ x: Float) -> Float {
    1 - pow(1 - x, 3)
}

func inOutCubic(_ x: Float) -> Float {
    x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2
}

func inQuint(_ x: Float) -> Float {
    x * x * x * x * x
}

func outQuint(_ x: Float) -> Float {
    1 - pow(1 - x, 5)
}

func inOutQuint(_ x: Float) -> Float {
    x < 0.5 ? 16 * x * x * x * x * x : 1 - pow(-2 * x + 2, 5) / 2
}

func inCirc(_ x: Float) -> Float {
    1 - sqrt(1 - pow(x, 2))
}

func outCirc(_ x: Float) -> Float {
    sqrt(1 - pow(x - 1, 2))
}

func inOutCirc(_ x: Float) -> Float {
    return x < 0.5
      ? (1 - sqrt(1 - pow(2 * x, 2))) / 2
      : (sqrt(1 - pow(-2 * x + 2, 2)) + 1) / 2
}

func inElastic(_ x: Float) -> Float {
    let c4 = (2 * Float.pi) / 3
    return x == 0
      ? 0
      : x == 1
      ? 1
      : -pow(2, 10 * x - 10) * sin((x * 10 - 10.75) * c4)
}

func outElastic(_ x: Float) -> Float {
    let c4 = (2 * Float.pi) / 3
    return x == 0
      ? 0
      : x == 1
      ? 1
      : pow(2, -10 * x) * sin((x * 10 - 0.75) * c4) + 1
}

func inOutElastic(_ x: Float) -> Float {
    let c5 = (2 * Float.pi) / 4.5
    return x == 0
      ? 0
      : x == 1
      ? 1
      : x < 0.5
      ? -(pow(2, 20 * x - 10) * sin((20 * x - 11.125) * c5)) / 2
      : (pow(2, -20 * x + 10) * sin((20 * x - 11.125) * c5)) / 2 + 1
}

func inQuad(_ x: Float) -> Float {
    x * x
}

func outQuad(_ x: Float) -> Float {
    1 - (1 - x) * (1 - x)
}

func inOutQuad(_ x: Float) -> Float {
    x < 0.5 ? 2 * x * x : 1 - pow(-2 * x + 2, 2) / 2
}

func inQuart(_ x: Float) -> Float {
    x * x * x * x
}

func outQuart(_ x: Float) -> Float {
    1 - pow(1 - x, 4)
}

func inOutQuart(_ x: Float) -> Float {
    x < 0.5 ? 8 * x * x * x * x : 1 - pow(-2 * x + 2, 4) / 2
}

func inExpo(_ x: Float) -> Float {
    x == 0 ? 0 : pow(2, 10 * x - 10)
}

func outExpo(_ x: Float) -> Float {
    x == 1 ? 1 : 1 - pow(2, -10 * x)
}

func inOutExpo(_ x: Float) -> Float {
    return x == 0
      ? 0
      : x == 1
      ? 1
      : x < 0.5 ? pow(2, 20 * x - 10) / 2
      : (2 - pow(2, -20 * x + 10)) / 2
}

func inBack(_ x: Float) -> Float {
    let c1: Float = 1.70158
    let c3 = c1 + 1
    return c3 * x * x * x - c1 * x * x
}

func outBack(_ x: Float) -> Float {
    let c1: Float = 1.70158
    let c3 = c1 + 1
    return 1 + c3 * pow(x - 1, 3) + c1 * pow(x - 1, 2)
}

func inOutBack(_ x: Float) -> Float {
    let c1: Float = 1.70158
    let c2 = c1 * 1.525
    return x < 0.5
      ? (pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2
      : (pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2
}

func inBounce(_ x: Float) -> Float {
    1 - outBounce(1 - x)
}

func outBounce(_ x: Float) -> Float {
    let n1: Float = 7.5625
    let d1: Float = 2.75
    if (x < 1 / d1) {
        return n1 * x * x
    } else if (x < 2 / d1) {
        let dx = x - 1.5 / d1;
        return n1 * (dx) * dx + 0.75
    } else if (x < 2.5 / d1) {
        let dx = x - 2.25 / d1
        return n1 * (dx) * dx + 0.9375
    } else {
        let dx = x - 2.625 / d1
        return n1 * (dx) * dx + 0.984375
    }
}

func inOutBounce(_ x: Float) -> Float {
    return x < 0.5
      ? (1 - outBounce(1 - 2 * x)) / 2
      : (1 + outBounce(2 * x - 1)) / 2
}

enum Ease: String, CaseIterable {

    static func fun(for mode: Ease) -> (Float) -> Float {
        switch mode {
        case .linear:
            return linear(_:)
        case .inSine:
            return inSine(_:)
        case .outSine:
            return outSine(_:)
        case .inOutSine:
            return inOutSine(_:)
        case .inCubic:
            return inCubic(_:)
        case .outCubic:
            return outCubic(_:)
        case .inOutCubic:
            return inOutCubic(_:)
        case .inQuint:
            return inQuint(_:)
        case .outQuint:
            return outQuint(_:)
        case .inOutQuint:
            return inOutQuint(_:)
        case .inCirc:
            return inCirc(_:)
        case .outCirc:
            return outCirc(_:)
        case .inOutCirc:
            return inOutCirc(_:)
        case .inElastic:
            return inElastic(_:)
        case .outElastic:
            return outElastic(_:)
        case .inOutElastic:
            return inOutElastic(_:)
        case .inQuad:
            return inQuad(_:)
        case .outQuad:
            return outQuad(_:)
        case .inOutQuad:
            return inOutQuad(_:)
        case .inQuart:
            return inQuart(_:)
        case .outQuart:
            return outQuart(_:)
        case .inOutQuart:
            return inOutQuart(_:)
        case .inExpo:
            return inExpo(_:)
        case .outExpo:
            return outExpo(_:)
        case .inOutExpo:
            return inOutExpo(_:)
        case .inBack:
            return inBack(_:)
        case .outBack:
            return outBack(_:)
        case .inOutBack:
            return inOutBack(_:)
        case .inBounce:
            return inBounce(_:)
        case .outBounce:
            return outBounce(_:)
        case .inOutBounce:
            return inOutBounce(_:)
        }
    }

    case linear
    case inSine
    case outSine
    case inOutSine
    case inCubic
    case outCubic
    case inOutCubic
    case inQuint
    case outQuint
    case inOutQuint
    case inCirc
    case outCirc
    case inOutCirc
    case inElastic
    case outElastic
    case inOutElastic
    case inQuad
    case outQuad
    case inOutQuad
    case inQuart
    case outQuart
    case inOutQuart
    case inExpo
    case outExpo
    case inOutExpo
    case inBack
    case outBack
    case inOutBack
    case inBounce
    case outBounce
    case inOutBounce
}
