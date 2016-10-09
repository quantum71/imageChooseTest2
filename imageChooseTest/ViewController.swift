//
//  ViewController.swift
//  imageChooseTest
//
//  Created by Eduardo Simpson on 5/18/16.
//  Copyright © 2016 Eduardo Simpson. All rights reserved.
//

import Foundation
import UIKit

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    var memedImage: UIImage!
    @IBOutlet weak var myToolbar: UIToolbar!
    @IBOutlet weak var topToolbar: UIImageView!
    @IBOutlet weak var topField: UITextField!
    @IBOutlet weak var bottomField: UITextField!
    @IBOutlet weak var myShareButton: UIBarButtonItem!
    
    @IBAction func mySharingButton(sender: AnyObject) {
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
    
    //This code sets the attributes of the text in the text fields.
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -4.0
    ]

    //Structure definition for Meme instances
    struct Meme {
        var text1: String?
        var text2: String?
        var image: UIImage?
        var memedImage: UIImage
    }
    
    //Getting ready for initial view. Note that the share button is not enabled yet.
    override func viewDidLoad() {
        super.viewDidLoad()
        imageChooser.delegate = self
       // topField.text = "TOP"
       // bottomField.text = "BOTTOM"
        myShareButton.enabled = false
        textCharacter(topField)
        textCharacter(bottomField)
      }
    
    // This function was created to remove redundant code per the code review.
    func textCharacter(textField: UITextField) {
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .Center
    }
    
    //Tests whether device has a camera source and starts notification process.
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

    //This function is like a mirror of the above and starts when viewWillDisappear is loaded
    func unsubscribeFromKeyboardNotifications() {
        let listener: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        listener.removeObserver(self, name: "keyboardWillShow", object: nil)
        listener.removeObserver(self, name: "keyboardWillHide", object: nil)
            }
    
    //This shifts the current view up by the size of the keyboard if the bottom field is chosen.
    func keyboardWillShow(notification: NSNotification) {
        if bottomField.isFirstResponder(){
        self.view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }

    //This is to move the keyboard back down.
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    //Provided code, to get height of keyboard
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        imageChooser.sourceType = .PhotoLibrary
        imagecamFeed(imageChooser)
    }
    
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        imageChooser.sourceType = .Camera
        imagecamFeed(imageChooser)
    }
   
    //I added this function per a suggestion on my project review to remove extra code but couldn't call it above in pickAnImageFromAlbum or pickAnImageFromCamera.
    func imagecamFeed (picker: UIImagePickerController){
        imageChooser.allowsEditing = false
        myShareButton.enabled = true
        presentViewController(imageChooser, animated: true, completion: nil)
    }
    
    /*This is part of the built in functionality for text fields. It tells the
    text field that is chosen to clear when chosen and to become the first 
    responder.
    */
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text=""
        textField.becomeFirstResponder()
    }
    
    //If the user hits the return key, the view shifts back down.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        view.frame.origin.y = 0
        return true;
    }
    
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]){
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
        imageView.contentMode = .ScaleAspectFit
        imageView.image = pickedImage
        myShareButton.enabled = true
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
        navigationController?.navigationBarHidden=false
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
