//
//  CameraViewModel.swift
//  OCRTest
//
//  Created by 최효원 on 2023/07/09.
//

import SwiftUI
import AVFoundation
import Combine

class CameraViewModel: ObservableObject {
  private let model: Camera
  private let session: AVCaptureSession
  private var subscriptions = Set<AnyCancellable>()
  private var isCameraBusy = false
  
  let cameraPreview: AnyView
  //화면 햅틱 반응
  let hapticImpact = UIImpactFeedbackGenerator()
  
  //너무 빠르게 줌이 되는 것을 방지
  var currentZoomFactor: CGFloat = 1.0
  var lastScale: CGFloat = 1.0
  
  @Published var selectedImage: UIImage?
  @Published var imagePickerPresented: Bool =  false
  @Published var OCRViewPresented: Bool = false
  
  @Published var showPreview = false
  //화면 깜박임
  @Published var shutterEffect = false
  @Published var recentImage: UIImage?
  @Published var isFlashOn = false
  
  //MARK: - 초기 세팅
  func configure() {
    model.requestAndCheckPermissions()
  }
  
  //MARK: - 플래시 온오프
  func switchFlash() {
    isFlashOn.toggle()
    model.flashMode = isFlashOn == true ? .on : .off
  }
  
  //MARK: - 사진 촬영
  func capturePhoto() {
    if isCameraBusy == false {
      hapticImpact.impactOccurred()
      //셔터가 깜박이는 효과
      withAnimation(.easeInOut(duration: 0.1)) {
        shutterEffect = true
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        withAnimation(.easeInOut(duration: 0.1)) {
          self.shutterEffect = false
        }
      }
      
      model.capturePhoto()
      print("[CameraViewModel]: Photo captured!")
    } else {
      print("[CameraViewModel]: Camera's busy.")
    }
  }
  
  //MARK: - 줌
  func zoom(factor: CGFloat) {
    let delta = factor / lastScale
    lastScale = factor
    
    let newScale = min(max(currentZoomFactor * delta, 1), 5)
    model.zoom(newScale)
    currentZoomFactor = newScale
  }
  
  func zoomInitialize() {
    lastScale = 1.0
  }
  
  init() {
    model = Camera()
    session = model.session
    cameraPreview = AnyView(CameraPreviewView(session: session))
    
    //model의 변수를 싱크대처럼 빨아온다 == sink
    model.$recentImage.sink { [weak self] (photo) in
      //recent가 optional이었으므로 Nil 때문에 프로그램 터지는거 방지
      guard let pic = photo else { return }
      self?.recentImage = pic
    }
    //sink 값 저장 (Set<AnyCancellable>)
    .store(in: &self.subscriptions)
    
    model.$isCameraBusy.sink { [weak self] (result) in
      self?.isCameraBusy = result
    }
    .store(in: &self.subscriptions)
  }
}
