//
//  QRCode.swift
//  Real Estate
//
//  Created by Rion on 24.11.25.
//

import SwiftUI
import CoreImage.CIFilterBuiltins


struct QRCodeView : View {
    let text : String
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    var body: some View {
        if let uiImage = generateQRCode(from: text){
            Image(uiImage: uiImage)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 5)
        }
    }
    
    private func generateQRCode(from string:String) -> UIImage?{
        filter.message = Data(string.utf8)
        if let output = filter.outputImage,
           let cgimg = context.createCGImage(output.transformed(by: CGAffineTransform(scaleX: 10, y: 10)), from: output.extent) {
            return UIImage(cgImage: cgimg)
        }
        return nil
    }
}
