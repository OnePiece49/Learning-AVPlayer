//
//  ViewController.swift
//  MergeImageAndAudio
//
//  Created by Tiến Việt Trịnh on 10/07/2023.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    //MARK: - Properties
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    //MARK: - Helpers
    func configureUI() {
        let imageName: [String] = ["naruto", "bp", "see", "op", "op2", "op3"]
        
        var pixelBuffers: [CVPixelBuffer?] = []
        //create a CIImage
        
        imageName.forEach { name in
            var pixelBuffer: CVPixelBuffer?
            guard let uikitImage = UIImage(named: name), let staticImage = CIImage(image: uikitImage) else {
                return
            }

            let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                 kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary

            let width:Int = Int(staticImage.extent.size.width)
            let height:Int = Int(staticImage.extent.size.height)

            CVPixelBufferCreate(kCFAllocatorDefault,
                                width,
                                height,
                                kCVPixelFormatType_32BGRA,
                                attrs,
                                &pixelBuffer)
            //create a CIContext
            let context = CIContext()
            context.render(staticImage, to: pixelBuffer!)
            pixelBuffers.append(pixelBuffer)
        }
        
        guard let imageNameRoot = imageName.split(separator: ".").first, let outputMovieURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(imageNameRoot).mov") else {
          return
        }
        //delete any old file
        do {
          try FileManager.default.removeItem(at: outputMovieURL)
        } catch {
          print("Could not remove file \(error.localizedDescription)")
        }

        guard let assetwriter = try? AVAssetWriter(outputURL: outputMovieURL, fileType: .mov) else {
          abort()
        }

        let settingsAssistant = AVOutputSettingsAssistant(preset: .preset1920x1080)?.videoSettings
        //create a single video input
        let assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: settingsAssistant)
        //create an adaptor for the pixel buffer
        let assetWriterAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput, sourcePixelBufferAttributes: nil)
        assetwriter.add(assetWriterInput)
        //begin the session
        assetwriter.startWriting()
        assetwriter.startSession(atSourceTime: CMTime.zero)
        //determine how many frames we need to generate
        let framesPerSecond = 30
        //duration is the number of seconds for the final video
        let totalFrames = 30 * framesPerSecond
        var frameCount = 0
        var count = 0
        
        print("DEBUG: \(totalFrames)")
        while frameCount < totalFrames {
          if assetWriterInput.isReadyForMoreMediaData {
            let frameTime = CMTimeMake(value: Int64(frameCount), timescale: Int32(framesPerSecond))
            //append the contents of the pixelBuffer at the correct time
            assetWriterAdaptor.append(pixelBuffers[count]!, withPresentationTime: frameTime)
            frameCount+=1
              print("DEBUG: \(frameCount) siuuuuuu")
              if frameCount % (totalFrames / pixelBuffers.count) == 0 {
                  count += 1
                  print("DEBUG: \(totalFrames / pixelBuffers.count) và \(totalFrames % (totalFrames / pixelBuffers.count))")
              }
          }
        }
        //close everything
        assetWriterInput.markAsFinished()
        assetwriter.finishWriting {
            for i in 0..<pixelBuffers.count {
                pixelBuffers[i] = nil
            }
        }
        

    }
    
    //MARK: - Selectors
    
}
//MARK: - delegate
