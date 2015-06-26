//
//  ViewController.swift
//  Camera3
//
//  Created by Farrukh Khan on 25/06/2015.
//  Copyright (c) 2015 Farrukh. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{

    @IBOutlet var ActivityIndicatorButton: UIActivityIndicatorView!
    
    @IBOutlet var myImageView: UIImageView!
    
    
    @IBAction func AddPhotoButton(sender: AnyObject) {
        var myPickerController = UIImagePickerController()
        myPickerController.delegate = self
        myPickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(myPickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        myImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }

    @IBAction func UploadPhotoButton(sender: AnyObject) {
        myImageUploadRequest()
    }
    
    func myImageUploadRequest() {
        let myUrl = NSURL(string: hostURL + "TEST/hello.php")
        let request = NSMutableURLRequest(URL: myUrl!)
        request.HTTPMethod = "POST"
        
        let param = [
            "firstName": "Farrukh",
            "lastName": "Khan",
            "userId": "21"
        ]
        println("Param: \(param)")
        
        let boundary = generateBoundaryString()
        
        println("Boundary: \(boundary)")

        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let imageData = UIImageJPEGRepresentation(myImageView.image, 1)
        
        if(imageData == nil) {return}
        
        request.HTTPBody = createBodyWithParameters(param, filePathKey: "file", imageDataKey: imageData, boundary: boundary)
        
        ActivityIndicatorButton.startAnimating()
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if(error != nil) {
                println("Error = \(error)")
                return
            }
            
            println("Response = \(response)")
            
            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
            
            println("Response Data = \(responseString!)")
            
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &err) as? NSDictionary
            
            dispatch_async(dispatch_get_main_queue(),{
                self.ActivityIndicatorButton.stopAnimating()
                self.myImageView.image = nil
            })
        }
        
        
        
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }

    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) ->NSData {
        var body = NSMutableData()

        if(parameters != nil) {
            for(key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        let filename = "user-profile.jpg"
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n)")
        body.appendString("Content-Disposition: form-data; name\"\(filePathKey!)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.appendData(imageDataKey)
        body.appendString("\r\n")
        
        body.appendString("--\(boundary)--\r\n")
        
        return body
    }
}

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}



