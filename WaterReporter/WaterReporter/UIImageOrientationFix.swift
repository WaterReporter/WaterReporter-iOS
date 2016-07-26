//
//  UIImageOrientationFix.swift
//  WaterReporter
//
//  Created by Viable Industries on 7/25/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

import UIKit

extension UIImage {
    
    func fixOrientation() -> UIImage {
        
        print("ImageLoaded")
        print(imageOrientation)
        print("Up")
        print(imageOrientation == UIImageOrientation.Up)
        print("UpMirrored")
        print(imageOrientation == UIImageOrientation.UpMirrored)
        print("Down")
        print(imageOrientation == UIImageOrientation.Down)
        print("DownMirrored")
        print(imageOrientation == UIImageOrientation.DownMirrored)
        print("Left")
        print(imageOrientation == UIImageOrientation.Left)
        print("LeftMirrored")
        print(imageOrientation == UIImageOrientation.LeftMirrored)
        print("Right")
        print(imageOrientation == UIImageOrientation.Right)
        print("RightMirrored")
        print(imageOrientation == UIImageOrientation.RightMirrored)
        
        if imageOrientation == UIImageOrientation.Up {
            return self
        }
        
        print("image returned false, we need to do more")
        
        var transform: CGAffineTransform = CGAffineTransformIdentity
        
        switch imageOrientation {
            case UIImageOrientation.Down, UIImageOrientation.DownMirrored:
                transform = CGAffineTransformTranslate(transform, size.width, size.height)
                transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
                break
            case UIImageOrientation.Left, UIImageOrientation.LeftMirrored:
                transform = CGAffineTransformTranslate(transform, size.width, 0)
                transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
                break
            case UIImageOrientation.Right, UIImageOrientation.RightMirrored:
                transform = CGAffineTransformTranslate(transform, 0, size.height)
                transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
                break
            case UIImageOrientation.Up, UIImageOrientation.UpMirrored:
                break
        }
        
        switch imageOrientation {
            case UIImageOrientation.UpMirrored, UIImageOrientation.DownMirrored:
                CGAffineTransformTranslate(transform, size.width, 0)
                CGAffineTransformScale(transform, -1, 1)
                break
            case UIImageOrientation.LeftMirrored, UIImageOrientation.RightMirrored:
                CGAffineTransformTranslate(transform, size.height, 0)
                CGAffineTransformScale(transform, -1, 1)
            case UIImageOrientation.Up, UIImageOrientation.Down, UIImageOrientation.Left, UIImageOrientation.Right:
                break
        }
        
        let ctx: CGContextRef = CGBitmapContextCreate(nil, Int(size.width), Int(size.height), CGImageGetBitsPerComponent(CGImage), 0, CGImageGetColorSpace(CGImage), CGImageAlphaInfo.PremultipliedLast.rawValue)!
        
        CGContextConcatCTM(ctx, transform)
        
        switch imageOrientation {
            case UIImageOrientation.Left, UIImageOrientation.LeftMirrored, UIImageOrientation.Right, UIImageOrientation.RightMirrored:
                CGContextDrawImage(ctx, CGRectMake(0, 0, size.height, size.width), CGImage)
                break
            default:
                CGContextDrawImage(ctx, CGRectMake(0, 0, size.width, size.height), CGImage)
                break
        }
        
        let cgImage: CGImageRef = CGBitmapContextCreateImage(ctx)!
        
        return UIImage(CGImage: cgImage)
    }
}