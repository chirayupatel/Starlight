//
//  Constants.swift
//  Starlight
//
//  Created by Terry Latanville on 2015-09-03.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import CoreGraphics

struct Constants {
    static let CGFloatEpsilon: CGFloat = 0.000001
    static let RuleRefreshRate: CFTimeInterval = 10
    static let Font = "BEBAS"
    static let Username = "<#Username#>"
    static let Password = "<#Password#>"
    static let Player = "Player"
    static let Enemy = "Enemy"

    struct Context {
        static let TimeIndex = 0
        static let Time = "time"
        static let BoostIndex = 1
        static let Boost = "boost"
        static let LocationIndex = 2
        static let Location = "location"
        static let WeatherIndex = 3
        static let Weather = "weather"
        static let GyroIndex = 4
        static let Gyro = "gyro"
    }
    struct Rules {
        static let Boost = "Boost"
        static let Location = "Location"
        static let Weather = "Weather"
    }

    static func contextIndexToRulePrefix(contextIndex: Int) -> String {
        switch contextIndex {
        case 0:
            return Constants.Context.Time
        case 1:
            return Constants.Context.Boost
        case 2:
            return Constants.Context.Location
        case 3:
            return Constants.Context.Weather
        case 4:
            return Constants.Context.Gyro
        default:
            return "NO_SUCH_RULE"
        }
    }

    static func rulePrefixToContextIndex(rulePrefix: String) -> Int {
        switch rulePrefix {
        case Constants.Rules.Boost:
            return 1
        case Constants.Rules.Location:
            return 3
        case Constants.Rules.Weather:
            return 4
        default:
            return -1
        }
    }
}
