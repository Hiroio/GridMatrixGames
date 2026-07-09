//
//  AmbientGridPattern.swift
//  SpinGrid
//

import SwiftUI

struct AmbientGridPattern: View {
  private let pitch: CGFloat = 24

  var body: some View {
    Canvas { context, size in
      let cols = Int(size.width / pitch) + 2
      let rows = Int(size.height / pitch) + 2
      for row in 0..<rows {
        for col in 0..<cols {
          let point = CGPoint(x: CGFloat(col) * pitch, y: CGFloat(row) * pitch)
          let rect = CGRect(x: point.x, y: point.y, width: 1.2, height: 1.2)
          context.fill(Path(ellipseIn: rect), with: .color(AppDesign.ambientGrid))
        }
      }
    }
    .allowsHitTesting(false)
  }
}
