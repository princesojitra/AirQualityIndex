//
//  UIDouble+Extension.swift
//  AirQuality
//
//  Created by Prince Sojitra on 09/01/22.
//

import Foundation

extension Double {
    func roundingToDecimal(place: Int) -> Double {
        let multiplier = pow(10, Double(place))
        return Darwin.round(self * multiplier) / multiplier
    }
}
