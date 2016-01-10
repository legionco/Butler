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
    static let GenericRGB = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB)
}

public extension CAMediaTimingFunction {
    @nonobjc static let EaseInEaseOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
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

// MARK: labels and fonts

extension UILabel {
    func addCharactersSpacing(spacing:CGFloat, text:String) {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSKernAttributeName, value: spacing, range: NSMakeRange(0, text.characters.count))
        self.attributedText = attributedString
    }
}

extension UIFont {
    var monospacedDigitFont: UIFont {
        let oldFontDescriptor = fontDescriptor()
        let newFontDescriptor = oldFontDescriptor.monospacedDigitFontDescriptor
        return UIFont(descriptor: newFontDescriptor, size: 0)
    }

}

extension UIFontDescriptor {
    var monospacedDigitFontDescriptor: UIFontDescriptor {
        let fontDescriptorFeatureSettings = [[UIFontFeatureTypeIdentifierKey: kNumberSpacingType, UIFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector]]
        let fontDescriptorAttributes = [UIFontDescriptorFeatureSettingsAttribute: fontDescriptorFeatureSettings]
        let fontDescriptor = self.fontDescriptorByAddingAttributes(fontDescriptorAttributes)
        return fontDescriptor
    }

}

// MARK: Image resizing

// updated for Swift2.0 from here: https://github.com/sudocode/ui-image-extension/blob/master/UIImage%2BResize.swift
public extension UIImage {
    // Returns a copy of this image that is cropped to the given bounds.
    // The bounds will be adjusted using CGRectIntegral.
    // This method ignores the image's imageOrientation setting.
    func croppedImage(bounds: CGRect) -> UIImage {
        let imageRef:CGImageRef = CGImageCreateWithImageInRect(self.CGImage, bounds)!
        return UIImage(CGImage: imageRef)
    }

    // Returns a rescaled copy of the image, taking into account its orientation
    // The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter
    func resizedImage(newSize:CGSize, interpolationQuality quality:CGInterpolationQuality) -> UIImage {
        var drawTransposed:Bool

        switch(self.imageOrientation) {
        case .Left:
            fallthrough
        case .LeftMirrored:
            fallthrough
        case .Right:
            fallthrough
        case .RightMirrored:
            drawTransposed = true
            break
        default:
            drawTransposed = false
            break
        }

        return self.resizedImage(
            newSize,
            transform: self.transformForOrientation(newSize),
            drawTransposed: drawTransposed,
            interpolationQuality: quality
        )
    }

    func resizedImageWithContentMode(contentMode:UIViewContentMode, bounds:CGSize, interpolationQuality quality:CGInterpolationQuality) -> UIImage {
        let horizontalRatio:CGFloat = bounds.width / self.size.width
        let verticalRatio:CGFloat = bounds.height / self.size.height
        var ratio:CGFloat = 1

        switch(contentMode) {
        case .ScaleAspectFill:
            ratio = max(horizontalRatio, verticalRatio)
            break
        case .ScaleAspectFit:
            ratio = min(horizontalRatio, verticalRatio)
            break
        default:
            print("Unsupported content mode \(contentMode)")
        }

        let newSize:CGSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio)
        return self.resizedImage(newSize, interpolationQuality: quality)
    }

    func resizedImage(newSize:CGSize, transform:CGAffineTransform, drawTransposed transpose:Bool, interpolationQuality quality:CGInterpolationQuality) -> UIImage {
        let newRect:CGRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height))
        let transposedRect:CGRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width)
        let imageRef:CGImageRef = self.CGImage!

        // build a context that's the same dimensions as the new size
        let bitmap:CGContextRef = CGBitmapContextCreate(nil,
            Int(newRect.size.width),
            Int(newRect.size.height),
            CGImageGetBitsPerComponent(imageRef),
            0,
            CGImageGetColorSpace(imageRef),
            CGImageAlphaInfo.NoneSkipLast.rawValue//CGImageGetBitmapInfo(imageRef).rawValue
            )!

        // rotate and/or flip the image if required by its orientation
        CGContextConcatCTM(bitmap, transform)

        // set the quality level to use when rescaling
        CGContextSetInterpolationQuality(bitmap, quality)

        // draw into the context; this scales the image
        CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef)

        // get the resized image from the context and a UIImage
        let newImageRef:CGImageRef = CGBitmapContextCreateImage(bitmap)!
        let newImage:UIImage = UIImage(CGImage: newImageRef)

        return newImage
    }

    func transformForOrientation(newSize:CGSize) -> CGAffineTransform {
        var transform:CGAffineTransform = CGAffineTransformIdentity
        switch (self.imageOrientation) {
        case .Down:          // EXIF = 3
            fallthrough
        case .DownMirrored:  // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
            break
        case .Left:          // EXIF = 6
            fallthrough
        case .LeftMirrored:  // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
            break
        case .Right:         // EXIF = 8
            fallthrough
        case .RightMirrored: // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height)
            transform = CGAffineTransformRotate(transform, -CGFloat(M_PI_2))
            break
        default:
            break
        }

        switch(self.imageOrientation) {
        case .UpMirrored:    // EXIF = 2
            fallthrough
        case .DownMirrored:  // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            break
        case .LeftMirrored:  // EXIF = 5
            fallthrough
        case .RightMirrored: // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            break
        default:
            break
        }
        
        return transform
    }
}

// MARK: GCD

// http://bandes-stor.ch/blog/2015/11/28/help-yourself-to-some-swift/
public extension dispatch_queue_t {
//    mySerialQueue.sync {
//        print("I’m on the queue!")
//    }
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
}

// http://bandes-stor.ch/blog/2015/11/28/help-yourself-to-some-swift/
public extension dispatch_group_t {
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
    final func waitForever() {
        dispatch_group_wait(self, DISPATCH_TIME_FOREVER)
    }
}

