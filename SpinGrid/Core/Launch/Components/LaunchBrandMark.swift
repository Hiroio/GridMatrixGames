//
//  LaunchBrandMark.swift
//  SpinGrid
//

import SwiftUI

struct LaunchBrandMark: View {
  var pulseScale: CGFloat = 1

  var body: some View {
    ZStack {
      ForEach(0..<12, id: \.self) { index in
        RoundedRectangle(cornerRadius: 1, style: .continuous)
          .fill(AppDesign.accent.opacity(index.isMultiple(of: 2) ? 0.2 : 0.1))
          .frame(width: 2, height: index.isMultiple(of: 2) ? 28 : 22)
          .offset(y: -38)
          .rotationEffect(.degrees(Double(index) * 30))
      }

      RoundedRectangle(cornerRadius: AppDesign.cardCorner, style: .continuous)
        .stroke(AppDesign.gridLineStrong, lineWidth: 2)
        .frame(width: 88, height: 88)

      Text("S")
        .font(.system(size: 44, weight: .bold, design: .rounded))
        .foregroundStyle(AppDesign.accent)
        .scaleEffect(pulseScale)
    }
    .frame(width: 132, height: 132)
  }
}
