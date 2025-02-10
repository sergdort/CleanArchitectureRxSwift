import SwiftUI
import UIKit
import WebKit

public struct WebView: UIViewRepresentable {
  let url: URL
  
  public init(url: URL) {
    self.url = url
  }
  
  public func makeUIView(context: Context) -> WKWebView {
    WKWebView(frame: .zero, configuration: .init())
  }
  
  public func updateUIView(_ uiView: WKWebView, context: Context) {
    uiView.load(URLRequest(url: url))
  }
}
