//
//  StudioSegmentedControl.swift
//  SlayGem
//

import SwiftUI

struct StudioSegmentedControl: View {
  @Binding var selection: StudioSegment

  var body: some View {
    HStack(spacing: AppDesign.spacingS) {
      ForEach(StudioSegment.allCases) { segment in
        let isSelected = selection == segment
        Button {
          withAnimation(AppDesign.segmentAnimation) {
            selection = segment
          }
        } label: {
          Text(segment.title)
            .font(.subheadline.weight(.bold))
            .foregroundStyle(isSelected ? AppDesign.ctaTextOnAccent : AppDesign.secondaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
              isSelected ? AppDesign.accent : AppDesign.surface,
              in: RoundedRectangle(cornerRadius: AppDesign.chipCorner, style: .continuous)
            )
            .overlay {
              RoundedRectangle(cornerRadius: AppDesign.chipCorner, style: .continuous)
                .stroke(AppDesign.gridLine, lineWidth: 1)
            }
            .animation(AppDesign.segmentAnimation, value: isSelected)
        }
        .contentShape(Rectangle())
        .buttonStyle(.plain)
      }
    }
  }
}
