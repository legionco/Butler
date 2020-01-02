//
//  Extensions.swift
//  Butler
//
//  Created by Nick O'Neill on 12/11/15.
//  Copyright © 2015 922am Burrito. All rights reserved.
//

import Foundation

// MARK: Graphics and animation

// http://bandes-stor.ch/blog/2015/11/28/help-yourself-to-some-swift/
public extension CGContext {
    static func currentContext() -> CGContext? {
        return UIGraphicsGetCurrentContext()
    }
}

public extension CGColorSpace {
    @available(iOS 9.0, *)
    static let GenericRGB = CGColorSpace(name: CGColorSpace.sRGB)
}

public extension CAMediaTimingFunction {
    @nonobjc static let EaseInEaseOut = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
}

public extension UIColor {
    convenience init(hex: NSInteger) {
        let red = CGFloat((hex >> 16) & 0xFF) / CGFloat(0xFF)
        let green = CGFloat((hex >> 8) & 0xFF) / CGFloat(0xFF)
        let blue = CGFloat((hex >> 0) & 0xFF) / CGFloat(0xFF)
        let alpha = hex > 0xFFFFFF ? CGFloat((hex >> 24) & 0xFF) / CGFloat(0xFF) : 1
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

// MARK: views

public extension UIView {
    // requires downcasting to specified type
    func copyView() -> AnyObject {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self))! as AnyObject
    }
}

// MARK: labels and fonts

extension UILabel {
    func addCharactersSpacing(spacing:CGFloat, text:String) {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: spacing, range: NSMakeRange(0, text.count))
        self.attributedText = attributedString
    }
}

extension UIFont {
    var monospacedDigitFont: UIFont {
        let oldFontDescriptor = fontDescriptor
        let newFontDescriptor = oldFontDescriptor.monospacedDigitFontDescriptor
        return UIFont(descriptor: newFontDescriptor, size: 0)
    }
}

extension UIFontDescriptor {
    var monospacedDigitFontDescriptor: UIFontDescriptor {
        let fontDescriptorFeatureSettings = [[UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType, UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector]]
        let fontDescriptorAttributes = [UIFontDescriptor.AttributeName.featureSettings: fontDescriptorFeatureSettings]
        let fontDescriptor = self.addingAttributes(fontDescriptorAttributes)
        return fontDescriptor
    }
}

public extension UITextField {
    func configureForEmail() {
        InputCoordinator.configureEmail(textField: self)
    }

    func configureForPass() {
        InputCoordinator.configurePassword(textField: self)
    }

    func configureForPhone() {
        InputCoordinator.configurePhone(textField: self)
    }

    func isValidEmail() -> Bool {
        return Butler.emailValid(email: self.text ?? "")
    }
}

// MARK: Strings

extension String {
    static func random(length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""

        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
}

// MARK: Image resizing

// updated for Swift2.0 from here: https://github.com/sudocode/ui-image-extension/blob/master/UIImage%2BResize.swift
public extension UIImage {
    func squaredImage(dim: CGFloat? = nil) -> UIImage {
        let side = min(self.size.height, self.size.width)

        let crop = croppedImage(bounds: CGRect(x: (self.size.width - side) / 2, y: (self.size.height - side) / 2, width: side, height: side))

        if let dim = dim {
            return crop.resizedImage(newSize: CGSize(width: dim, height: dim), interpolationQuality: .default)
        } else {
            return crop
        }
    }

    // Returns a copy of this image that is cropped to the given bounds.
    // The bounds will be adjusted using CGRectIntegral.
    // This method ignores the image's imageOrientation setting.
    func croppedImage(bounds: CGRect) -> UIImage {
        let imageRef:CGImage = self.cgImage!.cropping(to: bounds)!
        return UIImage(cgImage: imageRef)
    }

    // Returns a rescaled copy of the image, taking into account its orientation
    // The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter
    func resizedImage(newSize:CGSize, interpolationQuality quality:CGInterpolationQuality) -> UIImage {
        var drawTransposed:Bool

        switch(self.imageOrientation) {
        case .left:
            fallthrough
        case .leftMirrored:
            fallthrough
        case .right:
            fallthrough
        case .rightMirrored:
            drawTransposed = true
            break
        default:
            drawTransposed = false
            break
        }
        
        return self.resizedImage(newSize: newSize,
                                 transform: self.transformForOrientation(newSize: newSize),
                                 drawTransposed: drawTransposed,
                                 interpolationQuality: quality)
    }

    func resizedImageWithContentMode(contentMode:UIView.ContentMode, bounds:CGSize, interpolationQuality quality:CGInterpolationQuality) -> UIImage {
        let horizontalRatio:CGFloat = bounds.width / self.size.width
        let verticalRatio:CGFloat = bounds.height / self.size.height
        var ratio:CGFloat = 1

        switch(contentMode) {
        case .scaleAspectFill:
            ratio = max(horizontalRatio, verticalRatio)
            break
        case .scaleAspectFit:
            ratio = min(horizontalRatio, verticalRatio)
            break
        default:
            print("Unsupported content mode \(contentMode)")
        }

        let newSize:CGSize = CGSize(width: self.size.width * ratio, height: self.size.height * ratio)//CGSizeMake(self.size.width * ratio, self.size.height * ratio)
        return self.resizedImage(newSize: newSize, interpolationQuality: quality)
    }

    func resizedImage(newSize:CGSize, transform:CGAffineTransform, drawTransposed transpose:Bool, interpolationQuality quality:CGInterpolationQuality) -> UIImage {
        let newRect:CGRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        let transposedRect:CGRect = CGRect(x: 0, y: 0, width: newRect.size.height, height: newRect.size.width)
        let imageRef:CGImage = self.cgImage!

        // build a context that's the same dimensions as the new size
        
        
        let bitmap:CGContext = CGContext.init(data: nil,
                                              width: Int(newRect.size.width),
                                              height: Int(newRect.size.height),
                                              bitsPerComponent: imageRef.bitsPerComponent,
                                              bytesPerRow: 0,
                                              space: imageRef.colorSpace!,
                                              bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!

        // rotate and/or flip the image if required by its orientation
        bitmap.concatenate(transform)

        // set the quality level to use when rescaling
        bitmap.interpolationQuality = quality

        // draw into the context; this scales the image
        bitmap.draw(imageRef, in:  transpose ? transposedRect : newRect)

        // get the resized image from the context and a UIImage
        let newImageRef:CGImage = bitmap.makeImage()!
        let newImage:UIImage = UIImage(cgImage: newImageRef)

        return newImage
    }

    func transformForOrientation(newSize:CGSize) -> CGAffineTransform {
        var transform:CGAffineTransform = .identity
        switch (self.imageOrientation) {
        case .down:          // EXIF = 3
            fallthrough
        case .downMirrored:  // EXIF = 4
            transform = transform.translatedBy(x: newSize.width, y: newSize.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            break
        case .left:          // EXIF = 6
            fallthrough
        case .leftMirrored:  // EXIF = 5
            transform = transform.translatedBy(x: newSize.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2)) //CGAffineTransformRotate(transform, CGFloat(M_PI_2))
            break
        case .right:         // EXIF = 8
            fallthrough
        case .rightMirrored: // EXIF = 7
            transform = transform.translatedBy(x: 0, y: newSize.height)
            transform = transform.rotated(by: -CGFloat(Double.pi / 2))
            break
        default:
            break
        }

        switch(self.imageOrientation) {
        case .upMirrored:    // EXIF = 2
            fallthrough
        case .downMirrored:  // EXIF = 4
            transform = transform.translatedBy(x: newSize.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored:  // EXIF = 5
            fallthrough
        case .rightMirrored: // EXIF = 7
            transform = transform.translatedBy(x: newSize.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        default:
            break
        }
        
        return transform
    }
}

// MARK: GCD

// http://bandes-stor.ch/blog/2015/11/28/help-yourself-to-some-swift/
public extension DispatchQueue {
//    mySerialQueue.sync {
//        print("I’m on the queue!")
//    }
    /*
    
     final func async(block: dispatch_block_t) {
        dispatch_async(self, block)
    }

    final func async(group: dispatch_group_t, _ block: dispatch_block_t) {
        dispatch_group_async(group, self, block)
    }

    // `block` should be @noescape here, but can't be <http://openradar.me/19770770>
    final func sync(block: dispatch_block_t) {
        dispatch_sync(self, block)
    }
     
     */
}

// http://bandes-stor.ch/blog/2015/11/28/help-yourself-to-some-swift/
public extension DispatchGroup {
//    let group = dispatch_group_create()
//
//    concurrentQueue.async(group) {
//        print("I’m part of the group")
//    }
//
//    concurrentQueue.async(group) {
//        print("I’m independent, but part of the same group")
//    }
//    
//    group.waitForever()
    /*
    final func waitForever() {
        dispatch_group_wait(self, DISPATCH_TIME_FOREVER)
    }
 */
}

