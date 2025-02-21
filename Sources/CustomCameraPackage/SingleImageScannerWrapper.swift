//
//  CaptureDocScanner.swift
//  CustomCameraPackage
//
//  Created by Dhananjay on 20/02/25.
//

import SwiftUI
import Vision
import VisionKit

@available(iOS 15.0, *)
struct SingleImageScannerWrapper: View {
    @State private var scannedImage: UIImage? = nil
    @State private var isShowingScanner = false
    var scanType: String  // Accept scanType

    var onScanComplete: (String?) -> Void  // Callback to return scanned image

    var body: some View {
        SingleImageDocumentCameraView(
            scannedImage: $scannedImage,
            isShowingScanner: $isShowingScanner
        )
        .onChange(of: scannedImage) { newImage in
            if let image = newImage {
                print("scanType (scanType)1")
                print(scanType)
                returnScannedImage(image,scanType: scanType)
                //onScanComplete(image)  // Return scanned image
            }
        }
    }
    
    private func returnScannedImage(_ image: UIImage?,scanType: String) {
        //guard let resultCallback = self.resultCallback else { return }

        if let image = image {
            if let imageData = image.pngData() {
            print("imageData (imageData)")
           self.recognizeText(from: image,scanType: scanType)
            print(imageData)
                print("imageData after")
                let imagePath = saveImageToDocuments(imageData: imageData)  // Save and return file path
                onScanComplete(imagePath)
            } else {
                //onScanComplete(nil)
            }
        } else {
            //onScanComplete(nil)
        }
    }

    func recognizeText(from image: UIImage,scanType: String) {
        guard let cgImage = image.cgImage else { return }

        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
           
            // Check if text is exactly "PAN"
              if scanType.caseInsensitiveCompare("PAN") == .orderedSame {
                //print("✅ Found the word 'PAN'")
                //print("✅  'PAN' $(isValidPAN)")
                  let isValidPAN = self.checkPanImage(observations)
                  print("✅  'PAN' $(isValidPAN)")
                  print(isValidPAN)
//                  if !isValidPAN {
//                                  // Delay alert to avoid UIKit hierarchy issue
//                                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                                      showInvalidPANAlert = true
//                                  }
//                              }
                } else if scanType.caseInsensitiveCompare("AADHAAR") == .orderedSame {
                    print("✅ Found the word 'AADHAAR'")
                    let isValidAadhar = self.processAadhaarOCR(observations)
                    
                } else if scanType.caseInsensitiveCompare("CHEQUE") == .orderedSame {
                    print("✅ Found the word 'CHEQUE'")
                } else {
                    print("❌ Unrecognized document type")
                }
  //          for observation in observations {
  //              if let topCandidate = observation.topCandidates(1).first {
  //
  //                  print(topCandidate.string)
  //              }
  //          }
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? requestHandler.perform([request])
    }
      
      private func checkPanImage(_ observations: [VNRecognizedTextObservation]) -> Bool {
              let panRegex = "^[A-Z]{5}[0-9]{4}[A-Z]$"
              let panTest = NSPredicate(format: "SELF MATCHES %@", panRegex)
              var isPanRegexMatch = false
              var isMatchedIncomeTax = false

              for observation in observations {
                  if let topCandidate = observation.topCandidates(1).first {
                      let detectedText = topCandidate.string.trimmingCharacters(in: .whitespacesAndNewlines)
                      print("Detected Text: \(detectedText)")

                      // Check if the text matches a PAN card number format
                      if panTest.evaluate(with: detectedText) {
                          print("✅ Valid PAN Card Detected: \(detectedText)")
                          //return true
                          isPanRegexMatch = true
                      } else if detectedText.uppercased().contains("INCOME TAX DEPARTMENT") {
                          print("✅ 'INCOME TAX DEPARTMENT' Detected!")
                          isMatchedIncomeTax = true // Exit loop if this phrase is found
                      }
                      else {
                          print("❌ Not a PAN Card Number")
                      }
                      
                      // If both conditions are met, exit early
                      if isPanRegexMatch && isMatchedIncomeTax {
                      print("✅ Both PAN number and 'INCOME TAX DEPARTMENT' detected!")
                          return true
                      }
                      
                      
                  }
              }
          
          return false
      }
    
    /// Process Aadhaar OCR
            func processAadhaarOCR(_ observations: [VNRecognizedTextObservation]) -> Bool  {
               // guard let cgImage = image.cgImage else { return }
                
                    let textArray = observations.compactMap { $0.topCandidates(1).first?.string }
                    let extractedText = textArray.joined(separator: " ")

                    /// ✅ Check if it's a valid Aadhaar Card
                    let notValid = self.isValidAadhaarDocument(extractedText)
                if notValid {
                    print("✅ valid Aadhaar card! 'Government of India' found.")
                }else{
                    print("❌ Not a valid Aadhaar card! 'Government of India' not found.")
                }
                    /// Extract Aadhaar Details
                    let aadhaarNumber = self.extractAadhaarFromText(extractedText)
                    //let name = self.extractNameFromText(extractedText)
                    let dob = self.extractDOBFromText(extractedText)
                    //let address = self.extractAddressFromText(textArray)

                    print("🔹 Aadhaar Number: \(aadhaarNumber ?? "Not Found")")
                    //print("🔹 Name: \(name ?? "Not Found")")
                    print("🔹 DOB: \(dob ?? "Not Found")")
                    //print("🔹 Address: \(address ?? "Not Found")")
            

//                request.recognitionLevel = .accurate
//                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//                try? handler.perform([request])
                
                return true
            }
    
    /// ✅ Check if "Government of India" or "भारत सरकार" exists in OCR text
            func isValidAadhaarDocument(_ text: String) -> Bool {
                return text.localizedCaseInsensitiveContains("Government of India") || text.localizedCaseInsensitiveContains("भारत सरकार")
            }
    
    /// Extract Aadhaar Number (XXXX XXXX XXXX)
            func extractAadhaarFromText(_ text: String) -> String? {
                let pattern = "\\b\\d{4}\\s\\d{4}\\s\\d{4}\\b"
                let regex = try? NSRegularExpression(pattern: pattern)
                let matches = regex?.matches(in: text, range: NSRange(text.startIndex..., in: text))
                
                if let match = matches?.first, let range = Range(match.range, in: text) {
                    return String(text[range])
                }
                return nil
            }
    
    /// Extract Date of Birth (DD/MM/YYYY or YYYY)
            func extractDOBFromText(_ text: String) -> String? {
                let pattern = "\\b(\\d{2}/\\d{2}/\\d{4}|\\d{4})\\b"
                let regex = try? NSRegularExpression(pattern: pattern)
                let matches = regex?.matches(in: text, range: NSRange(text.startIndex..., in: text))

                if let match = matches?.first, let range = Range(match.range, in: text) {
                    return String(text[range])
                }
                return nil
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

