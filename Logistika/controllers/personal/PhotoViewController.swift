//
//  PhotoViewController.swift
//  Logistika
//
//  Created by BoHuang on 5/5/18.
//  Copyright © 2018 BoHuang. All rights reserved.
//

import UIKit
import AVFoundation

class PhotoViewController: UIViewController {

    @IBOutlet weak var segControl:UISegmentedControl!
    @IBOutlet weak var stackImageCells:UIStackView!
    @IBOutlet weak var viewPreview:UIView!
    @IBOutlet weak var imgSample: UIImageView!
    
    public var limit:Int = 0
    
    
    
    
    var session: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        // Setup your camera here...
        
        
        
        session = AVCaptureSession()
        session!.sessionPreset = AVCaptureSessionPresetPhoto
        
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
            print(error!.localizedDescription)
        }
        
        if error == nil && session!.canAddInput(input) {
            session!.addInput(input)
            // ...
            // The remainder of the session setup will go here...
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            
            if session!.canAddOutput(stillImageOutput) {
                session!.addOutput(stillImageOutput)
                // ...
                // Configure the Live Preview here...
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
                videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                videoPreviewLayer!.connection?.videoOrientation = .portrait
                viewPreview.layer.addSublayer(videoPreviewLayer!)
                session!.startRunning()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let videoPreviewLayer = self.videoPreviewLayer {
            videoPreviewLayer!.frame = self.calcRect()
        }
        
    }
    
    func calcRect()->CGRect{
        let rect = UIScreen.main.bounds
        var height = rect.size.height - 175
        if let vc = self.navigationController {
            if vc.navigationBar.isHidden == false {
                height = height - vc.navigationBar.frame.size.height
            }
        }
        height = height - UIApplication.shared.statusBarFrame.size.height
        let viewRect = CGRect.init(x: 0, y: 0, width: rect.size.width, height: height)
        
        return viewRect
        
    }
    
    @IBAction func captureNow(_ sender: Any) {
        if let videoConnection = stillImageOutput!.connection(withMediaType: AVMediaTypeVideo) {
            // ...
            // Code for photo capture goes here...
            
            
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (sampleBuffer, error) in
                // ...
                // Process the image data (sampleBuffer) here to get an image file we can put in our captureImageView
                if sampleBuffer != nil {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    if let dataProvider = CGDataProvider(data: imageData as! CFData){
                        if let cgImageRef = CGImage.init(jpegDataProviderSource: dataProvider, decode: nil, shouldInterpolate: true, intent: .defaultIntent){
                            let image = UIImage.init(cgImage: cgImageRef, scale: 1.0, orientation: .right)
                            // ...
                            // Add the image to captureImageView here...
                            self.imgSample.image = image
                        }
                    }
                    
                }
                
            })
        }else{
            print("if let videoConnection = stillImageOutput!.connection(withMediaType: AVMediaTypeVideo)")
        }
    }
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
