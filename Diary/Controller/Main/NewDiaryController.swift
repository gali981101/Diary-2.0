//
//  NewDiaryController.swift
//  Diary
//
//  Created by Terry Jason on 2023/12/24.
//

import UIKit
import CoreData

class NewDiaryController: UITableViewController {
    
    var diary: Diary!
    
    let imagePicker = UIImagePickerController()
    
    // MARK: - @IBOulet
    
    @IBOutlet var photoImageView: UIImageView! {
        didSet {
            photoImageView.layer.cornerRadius = 10.0
            photoImageView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var titleTextField: RoundedTextField! {
        didSet {
            titleTextField.tag = 1
            titleTextField.becomeFirstResponder()
            titleTextField.delegate = self
        }
    }
    
    @IBOutlet var weatherTextField: RoundedTextField! {
        didSet {
            weatherTextField.tag = 2
            weatherTextField.delegate = self
        }
    }
    
    @IBOutlet var locationTextField: RoundedTextField! {
        didSet {
            locationTextField.tag = 3
            locationTextField.delegate = self
        }
    }
    
    @IBOutlet var dateTextField: RoundedTextField! {
        didSet {
            dateTextField.tag = 4
            dateTextField.delegate = self
        }
    }
    
    @IBOutlet var descriptionTextView: UITextView! {
        didSet {
            descriptionTextView.tag = 5
            descriptionTextView.layer.cornerRadius = 10.0
            descriptionTextView.layer.masksToBounds = true
            
            descriptionTextView.text = NSLocalizedString("Write something about this story...", comment: "Write something about this story...")
            descriptionTextView.textColor = UIColor.lightGray
        }
    }
    
    @IBOutlet var allTextFields: [RoundedTextField]!
    
}

// MARK: - Life Cycle

extension NewDiaryController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        descriptionTextView.delegate = self
        
        guard let appearance = navigationController?.navigationBar.standardAppearance else { fatalError() }
        guard let customFont = UIFont(name: "RubikDoodleShadow-Regular", size: 35.0) else { fatalError() }
        
        appearance.titleTextAttributes = [.foregroundColor: UIColor.systemMint]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.systemMint, .font: customFont]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
}

// MARK: - @IBAction

extension NewDiaryController {
    
    @IBAction func saveButtonTapped() {
        for textField in allTextFields {
            if textField.text!.isEmpty || descriptionTextView.text.isEmpty {
                makeAlert(
                    NSLocalizedString(
                        "We can't procceed because one of the fields is blank. Please note that all fields are required",
                        comment: "We can't procceed because one of the fields is blank. Please note that all fields are required"
                    )
                )
                return
            }
        }
        
        guard let appDelegate = (UIApplication.shared.delegate as? AppDelegate) else { fatalError() }
        
        diary = Diary(context: appDelegate.persistentContainer.viewContext)
        
        diary.title = titleTextField.text!
        diary.weather = weatherTextField.text!
        diary.location = locationTextField.text!
        diary.date = dateTextField.text!
        diary.summary = descriptionTextView.text!
        diary.isFavorite = false
        
        if let imageData = photoImageView.image?.pngData() {
            diary.image = imageData
        }
        
        print(NSLocalizedString("Saving data to context", comment: "Saving data to context"))
        appDelegate.saveContext()
        
        dismiss(animated: true)
    }
    
}

// MARK: - UIAlertController

extension NewDiaryController {
    
    private func makeAlert(_ message: String) {
        let alert = UIAlertController(title: NSLocalizedString("Wait!", comment: "Wait!"), message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel)
        
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
}

// MARK: - UIAlertAction

extension NewDiaryController {
    
    private func cameraAction() -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("Camera", comment: "Camera"), style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true)
            }
        }
    }
    
    private func photoLibraryAction() -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("Photo library", comment: "Photo library"), style: .default) { _ in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true)
        }
    }
    
}

// MARK: - UITableViewDelegate

extension NewDiaryController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row == 0 else { return }
        
        let photoSourceRequestController = UIAlertController(
            title: "",
            message: NSLocalizedString("Choose your photo source", comment: "Choose your photo source"),
            preferredStyle: .alert
        )
        
        photoSourceRequestController.addAction(cameraAction())
        photoSourceRequestController.addAction(photoLibraryAction())
        
        if let popoverController = photoSourceRequestController.popoverPresentationController {
            guard let cell = tableView.cellForRow(at: indexPath) else { return }
            
            popoverController.sourceView = cell
            popoverController.sourceRect = cell.bounds
        }
        
        present(photoSourceRequestController, animated: true)
    }
    
}

// MARK: - UITextFieldDelegate

extension NewDiaryController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        
        return true
    }
    
}

// MARK: - UITextViewDelegate

extension NewDiaryController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = NSLocalizedString("Write something about this story...", comment: "Write something about this story...")
            textView.textColor = UIColor.lightGray
        }
    }
    
}

// MARK: - UIImagePickerController

extension NewDiaryController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        
        photoImageView.image = selectedImage
        photoImageView.contentMode = .scaleAspectFit
        photoImageView.clipsToBounds = true
        
        dismiss(animated: true)
    }
    
}




