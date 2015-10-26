//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Ada Ji on 10/19/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
        
    @IBOutlet weak var memeView: UIView! // Contains image view and text fields
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var bottomBar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var topBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    private let fontNames: [String] = ["Impact", "IMPACTED", "Impacted 2.0", "New", "Thanatos", "Danger Diabolik"]
    private var currentFontIndex: Int!
    private let foregroundColors: [String] = ["white", "red", "blue", "black"]
    private var currentForegroundColorIndex: Int!
    private let strokeColors: [String] = ["black", "white", "red", "blue"]
    private var currentStrokeColorIndex: Int!
    
    // For animated instruction
    private var shouldShowInstructions: Bool?
    private var hasShownInstructionForHorizontalSwipe: Bool?
    private var hasShownInstructionForVerticalSwipe: Bool?
    private let INSTRUCTION_LABEL_TAG: Int = 1
    private let HorizonalSwipeInstruction: String = "← Swipe left or right to change font →"
    private let VerticalSwipeInstruction: String = "Good job.\nNow swipe up ↑ to change text color\nor\nswipe down ↓ to change stroke color"
    private let DEFAULT_DELAY_TIME: Double = 3 // Unit: second
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        setEditorViewToDefault()
        
        addGestureRecognizers()
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
        imagePicker.navigationBar.tintColor = UIColor.orangeColor() // Change image picker's nav bar tint color
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: Swipe to change font or text color
    
    func changeTextAttribute(sender: UISwipeGestureRecognizer) {
        // Dismiss instructions
        
        switch (sender.direction) {
            // Swipe left or right to change font
        case UISwipeGestureRecognizerDirection.Left:
            currentFontIndex = (currentFontIndex + 1) % fontNames.count
            break
        case UISwipeGestureRecognizerDirection.Right:
            currentFontIndex = (currentFontIndex + fontNames.count - 1) % fontNames.count // Add "fontNames.count" to avoid getting negative results
            break
            
            // Swipe up to change foreground color
        case UISwipeGestureRecognizerDirection.Up:
            currentForegroundColorIndex = (currentForegroundColorIndex + 1) % foregroundColors.count
            break
            
            // Swipe down to change stroke color
        case UISwipeGestureRecognizerDirection.Down:
            currentStrokeColorIndex = (currentStrokeColorIndex + 1) % strokeColors.count
            break
            
        default:
            break
        }
        
        setTextAttributes(fontNames[currentFontIndex], foregroundColor: colorForString(foregroundColors[currentForegroundColorIndex]), strokeColor: colorForString(strokeColors[currentStrokeColorIndex]))
        
        // Show instructions at the first launch
        if shouldShowInstructions! {
            if let instructionLabel = view.viewWithTag(INSTRUCTION_LABEL_TAG) as? UILabel {
                showAnimatedInstructionForSwipe(sender.direction, instructionLabel: instructionLabel)
            }
        }
    }
    
    // MARK: Share/save meme
    
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
        presentViewController(activityVC, animated: true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage {
        // Change meme view background color to white
        memeView.backgroundColor = UIColor.whiteColor()
        
        // Render view to an image
        UIGraphicsBeginImageContext(memeView.frame.size)
        memeView.drawViewHierarchyInRect(CGRect(origin: CGPoint(x: 0, y: 0), size: memeView.frame.size), afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Change meme view background color back
        memeView.backgroundColor = UIColor.darkGrayColor()
        
        return memedImage
    }
    
    func saveMeme(memedImage: UIImage) {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, image: imageView.image!, memedImage: memedImage)
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).memes.append(meme)
    }
    
    @IBAction func cancelEditing(sender: UIBarButtonItem) {
        setEditorViewToDefault()
    }
    
    // MARK: Gestures
    
    func addGestureRecognizers() {
        for direction: UISwipeGestureRecognizerDirection in [.Left, .Right, .Up, .Down] {
            addSwipeRecognizer(direction)
        }
        
        // Show instructions at the first launch
        shouldShowInstructions = !NSUserDefaults.standardUserDefaults().boolForKey("HasLaunchedBefore")
        if shouldShowInstructions! {
            showInstructions()
        }
    }
    
    func addSwipeRecognizer(direction: UISwipeGestureRecognizerDirection) {
        // Swipe right or left to change font
        let swipe = UISwipeGestureRecognizer(target: self, action: "changeTextAttribute:")
        swipe.direction = direction
        view.addGestureRecognizer(swipe)
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
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if (string != "") {
            cancelButton.enabled = true
        }
        
        return true
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            
            shareButton.enabled = true
            cancelButton.enabled = true
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Helper methods
    
    // Return to launch state, displaying no image and default text
    func setEditorViewToDefault() {
        shareButton.enabled = false
        cancelButton.enabled = false
        
        currentFontIndex = 0
        currentForegroundColorIndex = 0
        currentStrokeColorIndex = 0
        
        imageView.image = nil
        setTextFieldsToDefault()
    }
    
    // Set text and text attributes to default
    func setTextFieldsToDefault() {
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        
        setTextAttributes(fontNames[currentFontIndex], foregroundColor: colorForString(foregroundColors[currentForegroundColorIndex]), strokeColor: colorForString(strokeColors[currentStrokeColorIndex]))
    }
    
    func setTextAttributes(fontName: String, foregroundColor: UIColor, strokeColor: UIColor) {
        // Set default text attributes
        let memeTextAttributes = [
            NSStrokeColorAttributeName : strokeColor,
            NSForegroundColorAttributeName : foregroundColor,
            NSFontAttributeName : UIFont(name: fontName, size: 40)!,
            NSStrokeWidthAttributeName : -3 // A negative value means both fill and stroke, 0 means only fill, a positive value means only stroke
        ]
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        // Set text alignment after setting default text attributes
        topTextField.textAlignment = .Center
        bottomTextField.textAlignment = .Center
    }
    
    func colorForString(colorName: String) -> UIColor {
        switch colorName {
        case "white":
            return UIColor.whiteColor()
        case "black":
            return UIColor.blackColor()
        case "red":
            return UIColor.redColor()
        case "blue":
            return UIColor.blueColor()
        default:
            return UIColor.clearColor()
        }
    }
    
    // Set label text and adjust label frame to the center
    func updateInstructionLabel(label: UILabel, text: String) {
        label.text = text
        
        // Reset label frame to center
        label.sizeToFit()
        label.center = view.center
    }
    
    func enableSwipes(enabled: Bool, horizontal: Bool) {
        if let gestures = self.view.gestureRecognizers {
            for gesture in gestures {
                if let swipe = gesture as? UISwipeGestureRecognizer {
                    if (horizontal && (swipe.direction == .Left || swipe.direction == .Right)) || (swipe.direction == .Up || swipe.direction == .Down) {
                        swipe.enabled = enabled
                    }
                }
            }
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
        view.frame.origin.y += dist
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
    
    // MARK: Animated instructions
    
    func showInstructions() {
        hasShownInstructionForHorizontalSwipe = false
        hasShownInstructionForVerticalSwipe = false
        
        // Temporarily disable text fields and vertical swipes to make sure users follow instructions
        topTextField.enabled = false
        bottomTextField.enabled = false
        enableSwipes(false, horizontal: false)
        
        // Show instructions for swipe left and right
        let instructionLabel = UILabel()
        instructionLabel.tag = INSTRUCTION_LABEL_TAG
        instructionLabel.numberOfLines = 4
        instructionLabel.textAlignment = .Center
        instructionLabel.textColor = UIColor.orangeColor()
        updateInstructionLabel(instructionLabel, text: HorizonalSwipeInstruction)
        view.addSubview(instructionLabel)
    }
    
    // Show animated instruction for swipe
    func showAnimatedInstructionForSwipe(direction: UISwipeGestureRecognizerDirection, instructionLabel: UILabel) {
        // Show instructions for swiping up and down
        if (direction == .Left || direction == .Right) && !hasShownInstructionForHorizontalSwipe! {
            hasShownInstructionForHorizontalSwipe = true
            
            showNewInstruction(
                instructionLabel,
                newInstruction: VerticalSwipeInstruction,
                completion: {
                    (value: Bool) in
                    // Enable vertical swipes
                    self.enableSwipes(true, horizontal: false)
                }
            )
        }
            // End instructions
        else if (direction == .Up || direction == .Down) && !hasShownInstructionForVerticalSwipe! {
            hasShownInstructionForVerticalSwipe = true
            
            showNewInstruction(
                instructionLabel,
                newInstruction: "You get it. Now go ahead and create your first meme. :)",
                completion: {
                    (value: Bool) in
                    // Enable text fields
                    self.topTextField.enabled = true
                    self.bottomTextField.enabled = true
                    
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(self.DEFAULT_DELAY_TIME * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                        instructionLabel.removeFromSuperview()
                    }
                }
            )
        }
    }
    
    // Clear current instruction for new instruction
    func showNewInstruction(instructionLabel:UILabel, newInstruction: String, completion: ((Bool) -> Void)?) {
        UIView.animateWithDuration(
            0.3,
            animations: {
                instructionLabel.alpha = 0
            }, completion: {
                (value: Bool) in
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(self.DEFAULT_DELAY_TIME * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.updateInstructionLabel(instructionLabel, text: newInstruction)
                    UIView.animateWithDuration(0.3, animations: {
                        instructionLabel.alpha = 1
                        }, completion: completion
                    )
                }
            }
        )
    }
    
}
