//
//  Camera.swift
//  OCRTest
//
//  Created by 최효원 on 2023/07/09.
//

import SwiftUI
import AVFoundation
import Photos

//MARK: - AVCapturePhotoCaptureDelegate를 이용하려면 NSObject 추가
class Camera: NSObject, ObservableObject {
    var session = AVCaptureSession()
    var videoDeviceInput: AVCaptureDeviceInput!
    let output = AVCapturePhotoOutput()
    var photoData = Data(count: 0)
  //플래시 온오프
    var flashMode: AVCaptureDevice.FlashMode = .off
    
    @Published var recentImage: UIImage?
  //사진이 완전히 처리되기 전에 또 다시 셔터가 눌리는 불상사를 막기 위해 만든 버튼
    @Published var isCameraBusy = false

    //MARK: - 카메라 셋업 과정을 담당하는 함수,
    func setUpCamera() {
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                for: .video, position: .back) {
            do { // 카메라가 사용 가능하면 세션에 input과 output을 연결
                videoDeviceInput = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(videoDeviceInput) {
                    session.addInput(videoDeviceInput)
                }
                
                if session.canAddOutput(output) {
                    session.addOutput(output)
                    output.isHighResolutionCaptureEnabled = true
                    output.maxPhotoQualityPrioritization = .quality
                }
                session.startRunning() // 세션 시작
            } catch {
                print(error) // 에러 프린트
            }
        }
    }
    
  //MARK: - 카메라 권한 상태 확인
    func requestAndCheckPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            // 권한 요청
            AVCaptureDevice.requestAccess(for: .video) { [weak self] authStatus in
                if authStatus {
                    DispatchQueue.main.async {
                        self?.setUpCamera()
                    }
                }
            }
        case .restricted:
            break
        case .authorized:
            // 이미 권한 받은 경우 셋업
            setUpCamera()
        default:
            // 거절했을 경우
            print("Permession declined")
        }
    }
    
  //MARK: - 사진 옵션 세팅, 사진 촬영
    func capturePhoto() {
    //플래쉬 옵션 설정, falshMode변경 후 photoSettings에 반영
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = self.flashMode
        
      //사진 촬영
        self.output.capturePhoto(with: photoSettings, delegate: self)
        print("[Camera]: Photo's taken")
    }
    
  //MARK: - 사진 저장
//    func savePhoto(_ imageData: Data) {
//      //Data를 UIImage로 바꾸는 작업
//        guard let image = UIImage(data: imageData) else { return }
//      //사진 저장, UIImageWriteToSavedPhotosAlbum은 Data 타입이 아니라 UIImage를 입력받음
//        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//        print("[Camera]: Photo's saved")
//    }
  
  func savePhoto(_ imageData: Data) {
    PHPhotoLibrary.shared().performChanges({
        let creationRequest = PHAssetCreationRequest.forAsset()
        creationRequest.addResource(with: .photo, data: imageData, options: nil)
    }) { success, error in
        if success {
            print("사진이 갤러리에 저장되었습니다.")
        } else if let error = error {
            print("사진을 갤러리에 저장하는 도중 오류가 발생했습니다: \(error.localizedDescription)")
        } else {
            print("사진을 갤러리에 저장하는 도중 알 수 없는 오류가 발생했습니다.")
        }
    }
}
    
  //MARK: - 줌 기능
    func zoom(_ zoom: CGFloat){
        let factor = zoom < 1 ? 1 : zoom
        let device = self.videoDeviceInput.device
        
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = factor
            device.unlockForConfiguration()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
}

extension Camera: AVCapturePhotoCaptureDelegate {
  //카메라 셔터 버튼이 눌리자마자 실행, 셔터 버튼 잠금
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        self.isCameraBusy = true
    }
    
  //사진 촬영 후 처리가 완료된 뒤 실행 -> 사진 저장
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
      //사진 데이터 -> fileDataRepresentation 으로 받아옴
        guard let imageData = photo.fileDataRepresentation() , let image = UIImage(data: imageData) else {
          print("사진 데이터를 가져올 수 없습니다.")
          return
      }
        print("[CameraModel]: Capture routine's done")
      
      let screenSize = UIScreen.main.bounds.size
      let scale = UIScreen.main.scale
      
      UIGraphicsBeginImageContextWithOptions(screenSize, false, scale)
      image.draw(in: CGRect(origin: .zero, size: screenSize))
      let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
        
//        self.photoData = resize
//      //사진데이터를 UIImage로 저장
//        self.recentImage = UIImage(data: imageData)
//        self.savePhoto(imageData)
//        self.isCameraBusy = false
      
      if let resizedImageData = resizedImage?.jpegData(compressionQuality: 1.0) {
             savePhoto(resizedImageData)
         } else {
             print("사진을 리사이즈할 수 없습니다.")
         }
    }
}
