//
//  AppBackgroundView.swift
//  SpinGrid
//

import SwiftUI

struct AppBackgroundView: View {
  var showsAmbientGrid = true

  var body: some View {
    ZStack {
      AppDesign.background.ignoresSafeArea()
      if showsAmbientGrid {
        AmbientGridPattern()
          .ignoresSafeArea()
      }
    }
  }
}
