//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Ada Ji on 10/19/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit

// MARK: - Protocols

protocol MemeEditorViewControllerDelegate {
    func didSendMeme(meme: Meme)
}

// MARK: - Meme Editor View Controller

class MemeEditorViewController: KeyboardHandlingViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var memeView: UIView! // Contains image view and text fields
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var bottomBar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var topBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var delegate: MemeEditorViewControllerDelegate?
    var meme: Meme?

    private var currentFontNameIndex: Int!
    private var currentForegroundColorIndex: Int!
    private var currentStrokeColorIndex: Int!
    
    // For animated instruction
    private var shouldShowInstructions: Bool?
    private var hasShownInstructionForHorizontalSwipe: Bool?
    private var hasShownInstructionForVerticalSwipe: Bool?
    private let INSTRUCTION_LABEL_TAG: Int = 1
    private let HorizonalSwipeInstruction: String = "← Swipe left or right to change font →"
    private let VerticalSwipeInstruction: String = "Good job.\nNow swipe up ↑ to change text color\nor\nswipe down ↓ to change stroke color"
    private let DEFAULT_DELAY_TIME: Double = 3 // Unit: second
    
    var upSwipeRecognizer: UISwipeGestureRecognizer? = nil
    var downSwipeRecognizer: UISwipeGestureRecognizer? = nil
    var leftSwipeRecognizer: UISwipeGestureRecognizer? = nil
    var rightSwipeRecognizer: UISwipeGestureRecognizer? = nil
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        setupEditorView()
        
        setupGestureRecognizers()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        addTextAttributesChangeRecognizers()
        addKeyboardDismissRecognizer()
        
        // Subscribe to the keyboard notifications, to allow the view to adjust frame when necessary
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeTextAttributesChangeRecognizers()
        removeKeyboardDismissRecognizer()
        
        unsubscribeToKeyboardNotifications()
    }
    
    // MARK: Edit Meme Image
    
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
    
    // MARK: Edit Meme Text Attributes
    
    func addTextAttributesChangeRecognizers() {
        for recognizer: UIGestureRecognizer in [upSwipeRecognizer!, downSwipeRecognizer!, leftSwipeRecognizer!, rightSwipeRecognizer!] {
            view.addGestureRecognizer(recognizer)
        }
    }
    
    func removeTextAttributesChangeRecognizers() {
        for recognizer: UIGestureRecognizer in [upSwipeRecognizer!, downSwipeRecognizer!, leftSwipeRecognizer!, rightSwipeRecognizer!] {
            view.removeGestureRecognizer(recognizer)
        }
    }
    
    // Change font or text color by swiping
    //
    // Swipe left or right to change font
    // Swipe up to change foreground color
    // Swipe down to change stroke color
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        
        switch (sender.direction) {
            // Swipe left or right to change font
        case UISwipeGestureRecognizerDirection.Left:
            currentFontNameIndex = (currentFontNameIndex + 1) % FontNames.count
            break
        case UISwipeGestureRecognizerDirection.Right:
            currentFontNameIndex = (currentFontNameIndex + FontNames.count - 1) % FontNames.count // Add "fontNames.count" to avoid getting negative results
            break
            
            // Swipe up to change foreground color
        case UISwipeGestureRecognizerDirection.Up:
            currentForegroundColorIndex = (currentForegroundColorIndex + 1) % ForegroundColors.count
            break
            
            // Swipe down to change stroke color
        case UISwipeGestureRecognizerDirection.Down:
            currentStrokeColorIndex = (currentStrokeColorIndex + 1) % StrokeColors.count
            break
            
        default:
            break
        }
        
        setTextAttributes(FontNames[currentFontNameIndex], foregroundColor: stringToColor(ForegroundColors[currentForegroundColorIndex]), strokeColor: stringToColor(StrokeColors[currentStrokeColorIndex]))
        
        // Show instructions at the first launch
        if shouldShowInstructions! {
            if let instructionLabel = view.viewWithTag(INSTRUCTION_LABEL_TAG) as? UILabel {
                showAnimatedInstructionForSwipe(sender.direction, instructionLabel: instructionLabel)
            }
        }
    }
    
    // MARK: Share/Save Meme
    
    @IBAction func shareMeme(sender: UIBarButtonItem) {
        let memedImage = generateMemedImage()
        let activityVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityVC.completionWithItemsHandler = {
            (activity, success, items, error) in
            if success {
                self.saveMeme(memedImage)
            }
        }
        presentViewController(activityVC, animated: true, completion: nil)
    }
    
    // This method generates memed image by taking snapshot of the image area
    //
    // It handles conditions that the image does not fill the image view vertically
    // so that generated image does not have margins on its top and bottom.
    // However, generated image may still have margins on its left and right.
    //
    // TODO: Remove left and right margins of generated image
    // To do this, you also need to constrain text fields' frames to be in the image area
    // to avoid text being cut off by the edges.
    func generateMemedImage() -> UIImage {
        
        // Change to snapshot settings
        
        topBar.hidden = true
        bottomBar.hidden = true
        
        memeView.backgroundColor = UIColor.whiteColor()
        
        let imageViewSize = imageView.frame.size
        let imageViewWidth = imageViewSize.width
        let imageViewHeight = imageViewSize.height
        let imageViewRatio = imageViewWidth / imageViewHeight
        
        let imageSize = imageView.image!.size
        let imageWidth = imageSize.width
        let imageHeight = imageSize.height
        let imageRatio = imageWidth / imageHeight
        
        let topFrame = topTextField.frame
        let bottomFrame = bottomTextField.frame

        var memedImage: UIImage
        // image display width = image view width
        if imageRatio >= imageViewRatio {
            let imageDisplayWidth = imageViewWidth
            let imageDisplayHeight = imageDisplayWidth / imageWidth * imageHeight - 2.0 // - 2.0 to get rid of the white lines on the top and bottom edges of the generated image
            let imageDisplayY = (imageViewHeight - imageDisplayHeight) / 2.0
            let imageDisplaySize = CGSizeMake(imageDisplayWidth, imageDisplayHeight)
            
            var topFrame_temp = topFrame
            topFrame_temp.origin.y = imageDisplayY + 20
            topTextField.frame = topFrame_temp
            var bottomFrame_temp = bottomFrame
            bottomFrame_temp.origin.y = imageView.frame.size.height - imageDisplayY - bottomFrame_temp.size.height - 20
            bottomTextField.frame = bottomFrame_temp

            // Render view to an image
            UIGraphicsBeginImageContext(imageDisplaySize)
            memeView.drawViewHierarchyInRect(CGRect(origin: CGPoint(x: 0, y: -imageDisplayY), size: memeView.frame.size), afterScreenUpdates: true)
        }
            // image display height = image view height
        else {
            var topFrame_temp = topFrame
            topFrame_temp.origin.y = 20
            topTextField.frame = topFrame_temp
            var bottomFrame_temp = bottomFrame
            bottomFrame_temp.origin.y = imageView.frame.size.height - bottomFrame_temp.size.height - 20
            bottomTextField.frame = bottomFrame_temp
            
            // Render view to an image
            UIGraphicsBeginImageContext(memeView.frame.size)
            memeView.drawViewHierarchyInRect(CGRect(origin: CGPoint(x: 0, y: 0), size: memeView.frame.size), afterScreenUpdates: true)
        }
        memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Change back to editor settings
        
        topBar.hidden = false
        bottomBar.hidden = false

        memeView.backgroundColor = UIColor.darkGrayColor()
        
        topTextField.frame = topFrame
        bottomTextField.frame = bottomFrame
        
        return memedImage
    }
    
    func saveMeme(memedImage: UIImage) {
        let meme = Meme(sentDate: NSDate(), topText: topTextField.text!, bottomText: bottomTextField.text!, textAttributes: topTextField.defaultTextAttributes, originalImage: imageView.image!, memedImage: memedImage)
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).memes.append(meme)
        delegate?.didSendMeme(meme)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelEditing(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Image Picker Controller Delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            
            shareButton.enabled = true
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Text Field Delegate
    
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
    
    // MARK: View Setup
    
    func setupEditorView() {
        // Create new meme
        if meme == nil {
            shareButton.enabled = false
            
            imageView.image = nil
            
            // Set text and text attributes to default
            
            topTextField.text = "TOP"
            bottomTextField.text = "BOTTOM"
            
            currentFontNameIndex = 0
            currentForegroundColorIndex = 0
            currentStrokeColorIndex = 0
            
            setTextAttributes(FontNames[currentFontNameIndex], foregroundColor: stringToColor(ForegroundColors[currentForegroundColorIndex]), strokeColor: stringToColor(StrokeColors[currentStrokeColorIndex]))
        }
            // Edit existing meme
        else {
            shareButton.enabled = true
            
            imageView.image = meme!.originalImage
            
            topTextField.text = meme!.topText
            bottomTextField.text = meme!.bottomText
            
            let textAttributes = meme!.textAttributes
            currentFontNameIndex = FontNames.indexOf(textAttributes[NSFontAttributeName]!.fontName)
            currentForegroundColorIndex = ForegroundColors.indexOf(colorToString(textAttributes[NSForegroundColorAttributeName] as! UIColor))
            currentStrokeColorIndex = StrokeColors.indexOf(colorToString(textAttributes[NSStrokeColorAttributeName] as! UIColor))
            setTextAttributesWithDictionary(textAttributes)
        }
    }
    
    func setupGestureRecognizers() {
        // Swipe right or left to change font
        upSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        upSwipeRecognizer?.direction = .Up
        downSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        downSwipeRecognizer?.direction = .Down
        leftSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        leftSwipeRecognizer?.direction = .Left
        rightSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        rightSwipeRecognizer?.direction = .Right
        
        // Show instructions at the first launch
        shouldShowInstructions = !NSUserDefaults.standardUserDefaults().boolForKey("HasLaunchedBefore")
        if shouldShowInstructions! {
            showInstructions()
        }
        
    }
    
    // MARK: Show/Hide Keyboard
    
    override func keyboardWillShow(notification: NSNotification) {
        if !keyboardAdjusted && bottomTextField.isFirstResponder() {
            lastKeyboardOffset = getKeyboardHeight(notification)
            view.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    // Dismiss keyboard and adjust view frame when screen rotates
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if (bottomTextField.isFirstResponder()) {
            bottomTextField.resignFirstResponder()
        }
    }
    
    // MARK: Animated Instructions
    
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
    
    // MARK: Helper Functions
    
    func setTextAttributes(fontName: String, foregroundColor: UIColor, strokeColor: UIColor) {
        let textAttributes = [
            NSStrokeColorAttributeName : strokeColor,
            NSForegroundColorAttributeName : foregroundColor,
            NSFontAttributeName : UIFont(name: fontName, size: 40)!,
            NSStrokeWidthAttributeName : -4 // A negative value means both fill and stroke, 0 means only fill, a positive value means only stroke
        ]
        
        setTextAttributesWithDictionary(textAttributes)
    }
    
    func setTextAttributesWithDictionary(textAttributes: [String: AnyObject]) {
        topTextField.defaultTextAttributes = textAttributes
        bottomTextField.defaultTextAttributes = textAttributes
        
        // Set text alignment after setting default text attributes
        topTextField.textAlignment = .Center
        bottomTextField.textAlignment = .Center
    }
    
}
