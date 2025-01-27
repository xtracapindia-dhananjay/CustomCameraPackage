// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import UIKit
import Vision
import VisionKit



@available(iOS 13.0, *)
public struct SingleImageDocumentCameraView: UIViewControllerRepresentable {
    @Binding public var scannedImage: UIImage?
    @Binding public var isShowingScanner: Bool
    
    // Add a public initializer
    public init(scannedImage: Binding<UIImage?>, isShowingScanner: Binding<Bool>) {
        self._scannedImage = scannedImage
        self._isShowingScanner = isShowingScanner
        ///
    }
    
    public func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = context.coordinator
        return documentCameraViewController
    }
    
    public func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(scannedImage: $scannedImage, isShowingScanner: $isShowingScanner)
    }
    
    final public class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        @Binding var scannedImage: UIImage?
        @Binding var isShowingScanner: Bool
        
        init(scannedImage: Binding<UIImage?>, isShowingScanner: Binding<Bool>) {
            _scannedImage = scannedImage
            _isShowingScanner = isShowingScanner
        }
        
        public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            // Capture only the first page (single image)
            if scan.pageCount > 0 {
                scannedImage = scan.imageOfPage(at: 0)
            }
            // Dismiss the scanner immediately after capturing one image
            isShowingScanner = false
            controller.dismiss(animated: true, completion: nil)
        }
        
        public func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            isShowingScanner = false
            controller.dismiss(animated: true, completion: nil)
        }
        
        public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("Document scanner error: \(error.localizedDescription)")
            isShowingScanner = false
            controller.dismiss(animated: true, completion: nil)
        }
    }
}


extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
