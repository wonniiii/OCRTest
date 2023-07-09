//
//  ImagePicker.swift
//  OCRTest
//
//  Created by 최효원 on 2023/07/09.
//

import SwiftUI

//MARK: - 16.0부터 PhotosPicker 지원

struct ImagePicker {
  @Binding var image: UIImage?
  @Binding var isPresented: Bool
}


/*
 카메라로 찍은 사진을 선택해 가져와야 하는데 SwiftUI에서 ImagePicker 지원 X
 UIImagePickerController를 Representable로 가져와 사용
 */
extension ImagePicker : UIViewControllerRepresentable {
  
  typealias UIViewControllerType = UIViewController
  
  func makeUIViewController(context: Context) -> UIViewController {
    let picker = UIImagePickerController()
    picker.delegate = context.coordinator
    return picker
  }
  
  func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    
  }
  
  /*
   Coordinator로 delegate를 처리,
   이미지를 선택하면 선택한 이미지를 image 프로퍼티에 할당,
   ImagePicker 뷰 닫음
   */
  
  func makeCoordinator() -> Coordinator {
    return Coordinator(self)
  }
  
  class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    let parent: ImagePicker
    
    init(_ parent: ImagePicker) {
      self.parent = parent
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      guard let image = info[.originalImage] as? UIImage else { return }
      self.parent.image = image
      self.parent.isPresented = false
    }
  }
}
