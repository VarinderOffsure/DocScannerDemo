//
//  Extention.swift
//  WeScanSampleProject
//
//  Created by Offsureit Solutions on 21/02/24.
//  Copyright © 2024 WeTransfer. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
 
extension UIImage {

    /// Data structure to easily express rotation options.
    struct RotationOptions: OptionSet {
        let rawValue: Int

        static let flipOnVerticalAxis = RotationOptions(rawValue: 1)
        static let flipOnHorizontalAxis = RotationOptions(rawValue: 2)
    }

    /// Returns the same image with a portrait orientation.
    func applyingPortraitOrientation() -> UIImage {
        switch imageOrientation {
        case .up:
            return rotated(by: Measurement(value: Double.pi, unit: .radians), options: []) ?? self
        case .down:
            return rotated(by: Measurement(value: Double.pi, unit: .radians), options: [.flipOnVerticalAxis, .flipOnHorizontalAxis]) ?? self
        case .left:
            return self
        case .right:
            return rotated(by: Measurement(value: Double.pi / 2.0, unit: .radians), options: []) ?? self
        default:
            return self
        }
    }

    /// Rotate the image by the given angle, and perform other transformations based on the passed in options.
    ///
    /// - Parameters:
    ///   - rotationAngle: The angle to rotate the image by.
    ///   - options: Options to apply to the image.
    /// - Returns: The new image rotated and optionally flipped (@see options).
    func rotated(by rotationAngle: Measurement<UnitAngle>, options: RotationOptions = []) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }

        let rotationInRadians = CGFloat(rotationAngle.converted(to: .radians).value)
        let transform = CGAffineTransform(rotationAngle: rotationInRadians)
        let cgImageSize = CGSize(width: cgImage.width, height: cgImage.height)
        var rect = CGRect(origin: .zero, size: cgImageSize).applying(transform)
        rect.origin = .zero

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        let renderer = UIGraphicsImageRenderer(size: rect.size, format: format)

        let image = renderer.image { renderContext in
            renderContext.cgContext.translateBy(x: rect.midX, y: rect.midY)
            renderContext.cgContext.rotate(by: rotationInRadians)

            let x = options.contains(.flipOnVerticalAxis) ? -1.0 : 1.0
            let y = options.contains(.flipOnHorizontalAxis) ? 1.0 : -1.0
            renderContext.cgContext.scaleBy(x: CGFloat(x), y: CGFloat(y))

            let drawRect = CGRect(origin: CGPoint(x: -cgImageSize.width / 2.0, y: -cgImageSize.height / 2.0), size: cgImageSize)
            renderContext.cgContext.draw(cgImage, in: drawRect)
        }

        return image
    }

    /// Rotates the image based on the information collected by the accelerometer
    func withFixedOrientation() -> UIImage {
        var imageAngle: Double = 0.0

        var shouldRotate = true
        switch CaptureSession.current.editImageOrientation {
        case .up:
            shouldRotate = false
        case .left:
            imageAngle = Double.pi / 2
        case .right:
            imageAngle = -(Double.pi / 2)
        case .down:
            imageAngle = Double.pi
        default:
            shouldRotate = false
        }

        if shouldRotate,
            let finalImage = rotated(by: Measurement(value: imageAngle, unit: .radians)) {
            return finalImage
        } else {
            return self
        }
    }

}
final class CaptureSession {

    static let current = CaptureSession()

    /// The AVCaptureDevice used for the flash and focus setting
    var device: CaptureDevice?

    /// Whether the user is past the scanning screen or not (needed to disable auto scan on other screens)
    var isEditing: Bool

    /// The status of auto scan. Auto scan tries to automatically scan a detected rectangle if it has a high enough accuracy.
    var isAutoScanEnabled: Bool

    /// The orientation of the captured image
    var editImageOrientation: CGImagePropertyOrientation

    private init(isAutoScanEnabled: Bool = true, editImageOrientation: CGImagePropertyOrientation = .up) {
        self.device = AVCaptureDevice.default(for: .video)

        self.isEditing = false
        self.isAutoScanEnabled = isAutoScanEnabled
        self.editImageOrientation = editImageOrientation
    }

}

protocol CaptureDevice: AnyObject {
    var torchMode: AVCaptureDevice.TorchMode { get set }
    var isTorchAvailable: Bool { get }

    var focusMode: AVCaptureDevice.FocusMode { get set }
    var focusPointOfInterest: CGPoint { get set }
    var isFocusPointOfInterestSupported: Bool { get }

    var exposureMode: AVCaptureDevice.ExposureMode { get set }
    var exposurePointOfInterest: CGPoint { get set }
    var isExposurePointOfInterestSupported: Bool { get }

    var isSubjectAreaChangeMonitoringEnabled: Bool { get set }

    func isFocusModeSupported(_ focusMode: AVCaptureDevice.FocusMode) -> Bool
    func isExposureModeSupported(_ exposureMode: AVCaptureDevice.ExposureMode) -> Bool
    func unlockForConfiguration()
    func lockForConfiguration() throws
}

extension AVCaptureDevice: CaptureDevice { }

final class MockCaptureDevice: CaptureDevice {
    var torchMode: AVCaptureDevice.TorchMode = .off
    var isTorchAvailable = true

    var focusMode: AVCaptureDevice.FocusMode = .continuousAutoFocus
    var focusPointOfInterest: CGPoint = .zero
    var isFocusPointOfInterestSupported = true

    var exposureMode: AVCaptureDevice.ExposureMode = .continuousAutoExposure
    var exposurePointOfInterest: CGPoint = .zero
    var isExposurePointOfInterestSupported = true
    var isSubjectAreaChangeMonitoringEnabled = false

    func unlockForConfiguration() {
        return
    }

    func lockForConfiguration() throws {
        return
    }

    func isFocusModeSupported(_ focusMode: AVCaptureDevice.FocusMode) -> Bool {
        return true
    }

    func isExposureModeSupported(_ exposureMode: AVCaptureDevice.ExposureMode) -> Bool {
        return true
    }
}
