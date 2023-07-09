//
//  OCRView.swift
//  OCRTest
//
//  Created by 최효원 on 2023/07/09.
//

import SwiftUI

struct OCRView: View {
  @ObservedObject private var viewModel = OCRViewModel()
  var image: UIImage
  var body: some View {
    imageView
      .onAppear {
        viewModel.recognaizeText(image: image)
      }
  }
  
  
  var imageView: some View {
    VStack() {
      Image(uiImage: image)
        .resizable()
        .scaledToFit()
      ScrollView {
        Text(viewModel.OCRString ?? "")
          .lineLimit(nil)
          .multilineTextAlignment(.leading)
      }
    }
  }
}
