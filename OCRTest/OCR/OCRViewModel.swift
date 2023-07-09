//
//  OCRViewModel.swift
//  OCRTest
//
//  Created by 최효원 on 2023/07/09.
//
import SwiftUI
import Vision
import VisionKit

class OCRViewModel : ObservableObject {
  @Published var OCRString: String?
  
  //이미지 분석 메소드
  func recognaizeText(image: UIImage) {
    guard let image = image.cgImage else {fatalError("이미지 오류")}
    /*
     Vision은 VNImageRequestHandler를 통해 요청을 전달하고 처리.
     CGImage, data, url 등 다양한 파라미터를 받아 이미지를 처리
     */
    let handler = VNImageRequestHandler(cgImage: image, options: [:])
    
    /*
     VNRecognizeTextRequest : 이미지에서 텍스트를 찾고 분석하는 Request
     Face, Body, Animal, Object 등이 가능
     결과는 VNRecognizedTextObservation 객체로 반환
     */
    let request = VNRecognizeTextRequest{ [weak self] request, error in
      guard let result = request.results as? [VNRecognizedTextObservation],
            error == nil else {return}
      //result에서 1번째 후보를 string으로 변환 -> 첫번째 사진
      let text = result.compactMap{ $0.topCandidates(1).first?.string }
        .joined(separator: "\n")
      
      self?.OCRString = text
    }
    
    if #available(iOS 16.0, *) {
      request.revision = VNRecognizeTextRequestRevision3
      request.recognitionLanguages = ["ko-KR"]
    } else {
      request.recognitionLanguages = ["en-US"]
      
    }
    //정확도와 속도 중 어느것에 초점
    request.recognitionLevel = .accurate
    //언어를 인식하고 수정하는 과정을 거침
    request.usesLanguageCorrection = true
    
    
    do {
      print(try request.supportedRecognitionLanguages())
      //VNImageRequestHandler를 통해 VRRecognizeTextRequest를 요청
      try handler.perform([request])
    } catch {
      print(error)
    }
  }
}
