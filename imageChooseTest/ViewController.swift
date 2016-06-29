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
    @IBOutlet weak var TextFieldOne: UITextField!
    @IBOutlet weak var TextFieldTwo: UITextField!
    var memedImage: UIImage!
    
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
        TextFieldOne.text = "TOP"
        TextFieldTwo.text = "BOTTOM"
        TextFieldOne.textAlignment = .Center
        TextFieldTwo.textAlignment = .Center
        self.TextFieldOne.delegate = self
        self.TextFieldTwo.delegate = self
        TextFieldOne.defaultTextAttributes = memeTextAttributes
        TextFieldTwo.defaultTextAttributes = memeTextAttributes
        
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //This shifts the current view up by the size of the keyboard
    func keyboardWillShow(notification: NSNotification) {
        view.frame.origin.y -= getKeyboardHeight(notification)
    }

    //I wrote this with the intent of shifting the view back down
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
        presentViewController(imageChooser, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        print ("test")
        
     imageChooser.allowsEditing = false
     imageChooser.sourceType = .Camera
     presentViewController(imageChooser, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        view.frame.origin.y = 0
    //    generateMemedImage()
        return true;
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text=""
    }
    
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]){
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                imageView.contentMode = .ScaleAspectFit
                imageView.image = pickedImage
            }
            dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
  //  @IBOutlet weak var navBar: UINavigationBar!
  //  @IBOutlet weak var toolBar: UIToolbar!
    
    func generateMemedImage() -> UIImage
    {
        // Render view to an image
    self.toolbar.hidden=true
        
        //    toolbar.hidden = true
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
     //   toolbar.hidden = false
        
        return memedImage
    }
    
    func save() {
        //Create the meme
        let text1 = TextFieldOne.text
        let text2 = TextFieldTwo.text
        let memedImage = generateMemedImage()
        let meme = Meme(text1: text1, text2: text2, image:
            imageView.image, memedImage: memedImage)
        
    }
    
}
