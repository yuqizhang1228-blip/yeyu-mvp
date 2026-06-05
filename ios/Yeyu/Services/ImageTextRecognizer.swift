import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(Vision)
import Vision
#endif

/// 本地图片文字识别（Vision OCR）。
/// 图片**只在本机处理**，不外传——契合夜屿隐私基调，也绕开后端纯文本模型的限制。
/// 适用「聊天截图 / 消息截图」这类图片上下文；纯风景/人物照识别不出文字属正常。
enum ImageTextRecognizer {
    static func recognize(in image: UIImage) async -> String {
        #if canImport(Vision)
        guard let cg = image.cgImage else { return "" }
        return await withCheckedContinuation { (cont: CheckedContinuation<String, Never>) in
            let request = VNRecognizeTextRequest { req, _ in
                let lines = (req.results as? [VNRecognizedTextObservation])?
                    .compactMap { $0.topCandidates(1).first?.string } ?? []
                cont.resume(returning: lines.joined(separator: "\n"))
            }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["zh-Hans", "en-US"]
            let handler = VNImageRequestHandler(cgImage: cg, options: [:])
            DispatchQueue.global(qos: .userInitiated).async {
                do { try handler.perform([request]) }
                catch { cont.resume(returning: "") }
            }
        }
        #else
        return ""
        #endif
    }
}
