//
//  ViewController.swift
//  imageChooseTest
//
//  Created by Eduardo Simpson on 5/18/16.
//  Copyright © 2016 Eduardo Simpson. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    var memedImage: UIImage!
    @IBOutlet weak var myToolbar: UIToolbar!
    @IBOutlet weak var myNavbar: UINavigationItem!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var topField: UITextField!
    @IBOutlet weak var bottomField: UITextField!
    
    @IBAction func sharingFunction(sender: AnyObject) {
        let sharedImage = generateMemedImage()
        let instanceActivity = UIActivityViewController(activityItems: [sharedImage], applicationActivities: nil)
        presentViewController(instanceActivity, animated: true, completion:nil)
        instanceActivity.completionWithItemsHandler = {
            (activity,success,items,error) in
            
            self.save()
            instanceActivity.dismissViewControllerAnimated(true, completion: nil)
    }
    
    }
    
    let imageChooser = UIImagePickerController()
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : 5.0
    ]

    //Structure definition for Meme instances
    struct Meme {
        var text1: String?
        var text2: String?
        var image: UIImage?
        var memedImage: UIImage
    }
    
    //Getting ready for initial view
    override func viewDidLoad() {
        super.viewDidLoad()
        imageChooser.delegate = self
        topField.text = "TOP"
        bottomField.text = "BOTTOM"
        topField.textAlignment = .Center
        bottomField.textAlignment = .Center
        self.topField.delegate = self
        self.bottomField.delegate = self
        topField.defaultTextAttributes = memeTextAttributes
        bottomField.defaultTextAttributes = memeTextAttributes
        shareButton.enabled = false
        
    }
    
    //Tests whether device has a camera source and starts notification process
    //Adding the listener through the subscribeToKeyboardNotification
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }
    
    //Removing the listener through the unsubscribeFromKeyboardNotification
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    
    //This function starts when viewWillAppear is loaded
    func subscribeToKeyboardNotifications() {
        let listener: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        listener.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        listener.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)

    }

    func unsubscribeFromKeyboardNotifications() {
        let listener: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        listener.removeObserver(self, name: "keyboardWillShow", object: nil)
        listener.removeObserver(self, name: "keyboardWillHide", object: nil)
            }
    
    //This shifts the current view up by the size of the keyboard
    func keyboardWillShow(notification: NSNotification) {
        print("testing keyboard will show")
        if bottomField.isFirstResponder(){
        view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }

    //
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y += getKeyboardHeight(notification)
    }
    
    //Provided code, to get height of keyboard
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        print ("album")
        imageChooser.allowsEditing = false
        imageChooser.sourceType = .PhotoLibrary
        shareButton.enabled = true
        presentViewController(imageChooser, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        print ("test")
        
     imageChooser.allowsEditing = false
     imageChooser.sourceType = .Camera
     shareButton.enabled = true
        presentViewController(imageChooser, animated: true, completion: nil)
     
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        view.frame.origin.y = 0
        return true;
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text=""
        textField.becomeFirstResponder()
    }
    
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]){
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                imageView.contentMode = .ScaleAspectFit
                imageView.image = pickedImage
                shareButton.enabled = true
            }
            dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage
    {
        // Render view to an image
        myToolbar.hidden=true
        self.navigationController?.navigationBarHidden=true
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        myToolbar.hidden = false
        self.navigationController?.navigationBarHidden=false
        return memedImage
    }
    
    func save() {
        //Create the meme
        let topText = topField.text
        let bottomText = bottomField.text
        let memedImage = generateMemedImage()
        
        let meme = Meme(text1: topText, text2: bottomText, image:
            imageView.image, memedImage: memedImage)
        
    }
    
}
