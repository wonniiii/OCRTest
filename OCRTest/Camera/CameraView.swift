//
//  CameraView.swift
//  OCRTest
//
//  Created by 최효원 on 2023/07/09.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
  @ObservedObject var viewModel = CameraViewModel()
  
  var body: some View {
    ZStack {
      viewModel.cameraPreview.ignoresSafeArea()
        .onAppear {
          viewModel.configure()
        }
      //줌 기능, MagnificationGesture -> 기본 카메라 스타일의 핀치 제스처 이용 가능
        .gesture(MagnificationGesture()
          .onChanged { val in
            viewModel.zoom(factor: val)
          }
          .onEnded { _ in
            viewModel.zoomInitialize()
          }
        )
      VStack {
        //플래시 온오프
        Button(action: {viewModel.switchFlash()}) {
          Image(systemName: viewModel.isFlashOn ?
                "speaker.fill" : "speaker")
          .foregroundColor(viewModel.isFlashOn ? .yellow : .white)
        }
        .padding(.horizontal, 30)
        
        Spacer()
        
        HStack {
          //찍은 사진 미리보기
          Button {
            viewModel.imagePickerPresented.toggle()
          } label: {
            if let previewImage = viewModel.recentImage {
              Image(uiImage: previewImage)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .aspectRatio(1, contentMode: .fit)
                .padding()
              
            } else {
              RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 2)
                .frame(width: 50, height: 50)
                .padding()
            }
          }
          
          Spacer()
          
          // 사진찍기 버튼
          Button(action: {viewModel.capturePhoto()}) {
            Circle()
              .stroke(lineWidth: 5)
              .frame(width: 75, height: 75)
              .padding()
          }
          Spacer()
        }
      }
      .foregroundColor(.white)
    }
    /// ImagePicker
    .sheet(isPresented: $viewModel.imagePickerPresented, onDismiss: {
      viewModel.OCRViewPresented.toggle()
    }) {
      ImagePicker(image: $viewModel.selectedImage, isPresented: $viewModel.imagePickerPresented)
    }
    /// OCRView
    .sheet(isPresented: $viewModel.OCRViewPresented) {
      if let image = viewModel.selectedImage {
        OCRView(image: image)
      }
    }
  }
}



struct CameraPreviewView: UIViewRepresentable {
  class VideoPreviewView: UIView {
    override class var layerClass: AnyClass {
      AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
      return layer as! AVCaptureVideoPreviewLayer
    }
  }
  
  let session: AVCaptureSession
  
  func makeUIView(context: Context) -> VideoPreviewView {
    let view = VideoPreviewView()
    //카메라 세션 지정 (필수)
    //https://developer.apple.com/documentation/avfoundation/capture_setup/setting_up_a_capture_session
    view.videoPreviewLayer.session = session
    //기본 백그라운드 색
    view.backgroundColor = .black
    //카메라 프리뷰 ratio 조절 (fit, fill)
    view.videoPreviewLayer.videoGravity = .resizeAspectFill
    //프리뷰 모서리에 corner radius
    view.videoPreviewLayer.cornerRadius = 0
    // 비디오 기본 방향 지정, .portrait => 세로모드
    view.videoPreviewLayer.connection?.videoOrientation = .portrait
    
    return view
  }
  
  func updateUIView(_ uiView: VideoPreviewView, context: Context) {
    
  }
}

struct CameraView_Previews: PreviewProvider {
  static var previews: some View {
    CameraView()
  }
}
