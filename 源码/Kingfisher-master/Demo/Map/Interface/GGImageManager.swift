//
//  GGImageManager.swift
//  Kingfisher
//
//  Created by admin on 2026/5/8.
//
//  Copyright (c) 2026 Wei Wang <onevcat@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Cocoa

class GGImageManager: @unchecked Sendable {

    public static let shared = GGImageManager()

    func getImage(
        _ url: URL?,
        completionHandler: (@MainActor @Sendable (Result<NSImage, GGImageError>) -> Void)? = nil
    ) {
        GGImageManager.shared.retrieveImage(url,completionHandler: completionHandler)
    }
    
    func retrieveImage(
        _ url: URL?,
        completionHandler: (@MainActor @Sendable (Result<NSImage, GGImageError>) -> Void)? = nil)
    {
        // 缓存命中
        if retrieveImageFromCache(url, completionHandler: completionHandler) == true{
            
        }else{
            // 下载并保存
            
        }
    }
    
    func retrieveImageFromCache(
        _ url: URL?,
        completionHandler: (@Sendable (Result<NSImage, GGImageError>) -> Void)?) -> Bool
    {
        
    }
}
