//
//  AstronomyCalculator.swift
//  mokyoil
//
//  Created by Yumin on 6/10/25.
//

import Foundation

struct AltAz {
    let altitude: Double
    let azimuth: Double
}

struct AstronomyCalculator {
    static func calculateAltAz(for star: Star, date: Date, lat: Double, lon: Double) -> AltAz {
        // Julian Day
        let jd = julianDay(from: date)
        let gst = greenwichSiderealTime(jd: jd)
        let lst = gst + lon / 15.0

        let ha = lst - star.ra
        let haRad = ha * .pi / 12.0
        let decRad = star.dec * .pi / 180.0
        let latRad = lat * .pi / 180.0

        let sinAlt = sin(decRad) * sin(latRad) + cos(decRad) * cos(latRad) * cos(haRad)
        let alt = asin(sinAlt) * 180 / .pi

        let cosAz = (sin(decRad) - sinAlt * sin(latRad)) / (cos(asin(sinAlt)) * cos(latRad))
        let az = acos(cosAz) * 180 / .pi

        return AltAz(altitude: alt, azimuth: az)
    }

    static func julianDay(from date: Date) -> Double {
        let calendar = Calendar(identifier: .gregorian)
        var comps = calendar.dateComponents([.year, .month, .day], from: date)
        let y = comps.year!
        let m = comps.month!
        let d = Double(comps.day!)

        var yy = y
        var mm = m
        if mm <= 2 {
            yy -= 1
            mm += 12
        }

        let a = floor(Double(yy) / 100)
        let b = 2 - a + floor(a / 4)

        return floor(365.25 * Double(yy + 4716)) + floor(30.6001 * Double(mm + 1)) + d + b - 1524.5
    }

    static func greenwichSiderealTime(jd: Double) -> Double {
        let T = (jd - 2451545.0) / 36525.0
        var gst = 280.46061837 + 360.98564736629 * (jd - 2451545.0) + 0.000387933 * T * T - T * T * T / 38710000.0
        gst = gst.truncatingRemainder(dividingBy: 360.0)
        if gst < 0 { gst += 360.0 }
        return gst / 15.0 // convert to hours
    }
}
