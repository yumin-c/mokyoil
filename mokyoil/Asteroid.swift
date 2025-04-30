import Foundation
import SwiftUI

struct Asteroid: Identifiable {
    let id = UUID()
    var position: CGPoint
    var speed: CGFloat
}
