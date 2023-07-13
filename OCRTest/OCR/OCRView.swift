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
        viewModel.recognizeText(image: image)
      }
    
  }
  
  
  var imageView: some View {
    GeometryReader { geometry in
      VStack {
        ZStack {
          Image(uiImage: image)
            .resizable()
            .scaledToFit()
          
          ForEach(viewModel.textObservations.reversed(), id: \.self) { observation in
            let transformedRect = CGRect(
              x: observation.boundingBox.origin.x * geometry.size.width,
              y: (1 - observation.boundingBox.origin.y - observation.boundingBox.size.height) * geometry.size.height,
              width: observation.boundingBox.size.width * geometry.size.width,
              height: observation.boundingBox.size.height * geometry.size.height
            )
            
            Rectangle()
              .stroke(Color.green, lineWidth: 2)
              .frame(width: transformedRect.width, height: transformedRect.height)
              .position(x: transformedRect.midX, y: transformedRect.midY)
          }
        }
      }
    }
  }
}
  
