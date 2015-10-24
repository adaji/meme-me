//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Ada Ji on 10/19/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var fontNames: NSArray!
    var currentFontIndex: Int!
    var textColors: NSArray!
    var currentColorIndex: Int!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var topBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var fontButton: UIButton!
    
    @IBOutlet weak var bottomBar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fontNames = ["Impact", "Legrand", "Cowboy Movie"]
        textColors = [UIColor.whiteColor(), UIColor.redColor(), UIColor.blueColor(), UIColor.blackColor()]
        
        setupEditorView()
    }
    
    func setupEditorView() {
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        // Set default text and text attributes
        setTextFieldsToDefault()
        
        // Swipe right or left to change font
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: "changeFont:")
        leftSwipe.direction = .Left
        self.view.addGestureRecognizer(leftSwipe)
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: "changeFont:")
        rightSwipe.direction = .Right
        self.view.addGestureRecognizer(rightSwipe)
        
        // Swipe up or down to change text color
        let swipeUp = UISwipeGestureRecognizer(target: self, action: "changeTextColor:")
        swipeUp.direction = .Up
        self.view.addGestureRecognizer(swipeUp)
        let swipeDown = UISwipeGestureRecognizer(target: self, action: "changeTextColor:")
        swipeDown.direction = .Down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        // Subscribe to the keyboard notifications, to allow the view to adjust frame when necessary
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeToKeyboardNotifications()
    }
    
    // MARK: Edit meme image
    
    @IBAction func pickImageFromAlbum(sender: UIBarButtonItem) {
        presentImagePicker(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    
    @IBAction func takeImage(sender: UIBarButtonItem) {
        presentImagePicker(UIImagePickerControllerSourceType.Camera)
    }
    
    func presentImagePicker(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: Swipe to change font or text color
    
    func changeFont(sender: UISwipeGestureRecognizer) {
        if (sender.direction == .Left) {
            currentFontIndex = (currentFontIndex+1) % fontNames.count
        }
        else if (sender.direction == .Right) {
            currentFontIndex = (currentFontIndex+fontNames.count-1) % fontNames.count
        }
        setTextAttributes(fontNames[currentFontIndex] as! String, textColor: textColors[currentColorIndex] as! UIColor)
    }
    
    func changeTextColor(sender: UISwipeGestureRecognizer) {
        if (sender.direction == .Up) {
            currentColorIndex = (currentColorIndex+1) % textColors.count
        }
        else if (sender.direction == .Down) {
            currentColorIndex = (currentColorIndex+textColors.count-1) % textColors.count
        }
        setTextAttributes(fontNames[currentFontIndex] as! String, textColor: textColors[currentColorIndex] as! UIColor)
    }
    
    // MARK: Share / save meme
    
    @IBAction func shareMeme(sender: UIBarButtonItem) {
        let memedImage = generateMemedImage()
        let activityVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityVC.completionWithItemsHandler = {
            (activity, success, items, error) in
            if success {
                self.saveMeme(memedImage)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage {
        // hide top/bottom bar
        topBar.hidden = true
        bottomBar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // show top/bottom bar
        topBar.hidden = false
        bottomBar.hidden = false
        
        return memedImage
    }
    
    func saveMeme(memedImage: UIImage) {
        let meme = Meme(originalImage: imageView.image!, topText: topTextField.text!, bottomText: bottomTextField.text!, memedImage: memedImage)
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).memes.append(meme)
    }
    
    // MARK: Cancel editing meme
    
    @IBAction func cancelEditing(sender: UIBarButtonItem) {
        resetEditorView()
    }
    
    // Return to launch state, displaying no image and default text
    func resetEditorView() {
        imageView.image = nil
        setTextFieldsToDefault()
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField.text == "TOP" || textField.text == "BOTTOM") {
            textField.text = ""
        }
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        // Show default text if textField is empty
        if (textField.text == "") {
            if (textField == topTextField) {
                textField.text = "TOP"
            }
            else if (textField == bottomTextField) {
                textField.text = "BOTTOM"
            }
        }
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            
            shareButton.enabled = true
            cancelButton.enabled = true
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Helper methods
    
    func setTextFieldsToDefault() {
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"

        currentFontIndex = 0
        currentColorIndex = 0
        setTextAttributes(fontNames[currentFontIndex] as! String, textColor: textColors[currentColorIndex] as! UIColor)
    }
    
    func setTextAttributes(fontName: String, textColor: UIColor) {
        // Set default text attributes
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : textColor,
            NSFontAttributeName : UIFont(name: fontName, size: 40)!,
            NSStrokeWidthAttributeName : -3 // A negative value means both fill and stroke, 0 means only fill, a positive value means only stroke
        ]
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        // Set text alignment after setting default text attributes
        topTextField.textAlignment = .Center
        bottomTextField.textAlignment = .Center
    }
    
    // MARK: Adjust view frame when keyboard shows/hides

    func keyboardWillShow(notification: NSNotification) {
        if (bottomTextField.isFirstResponder()) {
            moveViewVertically(getKeyboardHeight(notification), up: true)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if (bottomTextField.isFirstResponder()) {
            moveViewVertically(getKeyboardHeight(notification), up: false)
        }
    }
    
    func moveViewVertically(distance: CGFloat, up: Bool) {
        let dist = distance * (up ? -1 : 1)
        self.view.frame.origin.y += dist
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    // Dismiss keyboard and adjust view frame when screen rotates
    func screenDidRotate() {
        if (bottomTextField.isFirstResponder()) {
            bottomTextField.resignFirstResponder()
        }
    }
    
    // MARK: Notifications
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "screenDidRotate", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

