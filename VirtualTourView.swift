//
//  VirtualTourView.swift
//  Real Estate
//
//  Created by Rion on 13.11.25.
//

import WebKit
import UIKit
import SwiftUI

struct VirtualTourview : UIViewRepresentable{
    let url : URL
    func makeUIView(context: Context) -> WKWebView{
        let webview = WKWebView()
        webview.load(URLRequest(url: url))
        return webview
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}


struct FullScreenImageView: View {
    let imageURL: String
    @Environment(\.dismiss) var dismiss
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()
            ScrollView([.horizontal, .vertical]) {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .gesture(MagnificationGesture()
                            .onChanged { value in scale = value }
                            .onEnded { _ in if scale < 1 { scale = 1 } })
                } placeholder: {
                    ProgressView()
                }
            }
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .padding()
                    .foregroundColor(.white)
            }
        }
    }
}
