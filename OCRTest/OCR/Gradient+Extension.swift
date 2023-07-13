//
//  Gradient+Extension.swift
//  OCRTest
//
//  Created by 최효원 on 2023/07/12.
//

import Foundation


import SwiftUI

extension LinearGradient {
  static func myGradient() -> LinearGradient {
    return LinearGradient(
      stops: [
        Gradient.Stop(color: Color(red: 0, green: 0.83, blue: 0.65), location: 0.00),
        Gradient.Stop(color: Color(red: 0, green: 0.58, blue: 1), location: 1.00),
      ],
      startPoint: UnitPoint(x: 0.09, y: 0),
      endPoint: UnitPoint(x: 1.34, y: 3.1)
    )
  }
}

