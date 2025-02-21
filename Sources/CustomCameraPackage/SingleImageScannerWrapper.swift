//
//  CaptureDocScanner.swift
//  CustomCameraPackage
//
//  Created by Dhananjay on 20/02/25.
//

import SwiftUI
import Vision
import VisionKit

class CaptureDocScanner {
    var resultCallback: ((String?) -> Void)?
    
    func presentScanner(scanType: String, completion: @escaping (String?) -> Void) {
        print("scanType: \(scanType)")
        
        guard let topController = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        
        print("presentScanner called...")
        self.resultCallback = completion
        
        let scannerView = SingleImageScannerWrapper { scannedImage in
            self.returnScannedImage(scannedImage)
        }
        
        let hostingController = UIHostingController(rootView: scannerView)
        hostingController.modalPresentationStyle = .fullScreen
        topController.present(hostingController, animated: true, completion: nil)
    }
    
    private func returnScannedImage(_ image: UIImage?) {
        guard let resultCallback = self.resultCallback else { return }
        
        if let image = image, let imageData = image.pngData() {
            print("Processing scanned image...")
            self.recognizeText(from: image)
            let imagePath = saveImageToDocuments(imageData: imageData)
            resultCallback(imagePath)
        } else {
            resultCallback(nil)
        }
        
        self.resultCallback = nil
    }
    
    func recognizeText(from image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            for observation in observations {
                if let topCandidate = observation.topCandidates(1).first {
                    print(topCandidate.string)
                }
            }
        }
        
        request.recognitionLevel = .accurate
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? requestHandler.perform([request])
    }
    
    private func saveImageToDocuments(imageData: Data) -> String? {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let fileName = "scanned_image_\(UUID().uuidString).jpeg"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: fileURL)
            return fileURL.path  // Return the saved image path
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
}

