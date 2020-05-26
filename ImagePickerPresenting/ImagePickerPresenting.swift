//
//  ImagePickerPresenting.swift
//  O-Fit
//
//  Created by william on 2020/5/19.
//  Copyright © 2020 O-Fit. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Photos

enum SOURCE_TYPE {
    case ALL
    case CAMERA
    case PHOTO_LIBRARY
}

protocol ImagePickerControllerDelegate: class {
    func imagePickerControllerDidFinish(image: UIImage?, _: ImagePickerController)
}

final class ImagePickerController: UIImagePickerController {
    weak var imagePickerDelegate: ImagePickerControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
}

extension ImagePickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerDelegate?.imagePickerControllerDidFinish(image: selectedImage, self)
        } else {
            imagePickerDelegate?.imagePickerControllerDidFinish(image: nil, self)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePickerDelegate?.imagePickerControllerDidFinish(image: nil, self)
    }
}

var completionBlock: ((UIImage?) -> Void)?

protocol ImagePickerPresenting: ImagePickerControllerDelegate {
    func showCameraAlert(type: SOURCE_TYPE, completion: @escaping (UIImage?) -> Void)
}

extension ImagePickerPresenting where Self: UIViewController {
    
    func showCameraAlert(type: SOURCE_TYPE, completion: @escaping (UIImage?) -> Void) {
        completionBlock = completion
        let imagePickerController = ImagePickerController()
        imagePickerController.imagePickerDelegate = self
        let alertController = UIAlertController.init(title: "請選擇相片來源", message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction.init(title: "從相機", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.allowsEditing = true
                imagePickerController.sourceType = .camera
                self.accessCameraWithReminderPrompt { (accessGranted) in
                    DispatchQueue.main.async {
                        self.present(imagePickerController, animated: true, completion: nil)
                    }
                }
            } else {
                self.alertCameraAccessNeeded()
            }
        }
        
        let library = UIAlertAction.init(title: "從相簿", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                imagePickerController.allowsEditing = true
                imagePickerController.sourceType = .photoLibrary
                self.remindToGiveGalleryWithReminderPrompt { (accessGranted) in
                    DispatchQueue.main.async {
                        self.present(imagePickerController, animated: true, completion: nil)
                    }
                }
            } else {
                self.alertPhotosAccessNeeded()
            }
        }
        
        let cancel = UIAlertAction.init(title: "取消", style: .cancel) { (action) in
            completionBlock = nil
        }
        cancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        switch type {
        case .ALL:
            alertController.addAction(camera)
            alertController.addAction(library)
        case .CAMERA:
            alertController.addAction(camera)
        case .PHOTO_LIBRARY:
            alertController.addAction(library)
        }
        
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidFinish(image: UIImage?, _ viewController: ImagePickerController) {
        completionBlock?(image)
        completionBlock = nil
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func accessCameraWithReminderPrompt(completion:@escaping (_ accessGranted: Bool)->()) {
        let accessRight = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch accessRight {
        case .authorized:
            completion(true)
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if granted == true  {
                    completion(true)
                    return
                }
                self.alertCameraAccessNeeded()
            })
        case .denied, .restricted:
            self.alertCameraAccessNeeded()
            
            break
        @unknown default:
            fatalError()
        }
    }
    
    func remindToGiveGalleryWithReminderPrompt(completion:@escaping (_ accessGranted: Bool)->()) {
        
        let accessRight = PHPhotoLibrary.authorizationStatus()
        
        switch accessRight {
        case .authorized:
            completion(true)
            break
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized {
                    completion(true)
                    return
                }
                self.alertPhotosAccessNeeded()
            }
        case .denied, .restricted:
            alertPhotosAccessNeeded()
            break
        @unknown default:
            fatalError()
        }
    }
    
    func alertCameraAccessNeeded() {
        let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
        
        let alert = UIAlertController(
            title: "隱私權錯誤",
            message: "請至設定打開您的相機隱私權，方能繼續使用相機。",
            preferredStyle: UIAlertController.Style.alert
        )
        
        alert.addAction(UIAlertAction(title: "好", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "去設定", style: .cancel, handler: { (alert) -> Void in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(settingsAppURL)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func alertPhotosAccessNeeded() {
        let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
        
        let alert = UIAlertController(
            title: "隱私權錯誤",
            message: "請至設定打開您的相簿隱私權，方能繼續使用相機。",
            preferredStyle: UIAlertController.Style.alert
        )
        
        alert.addAction(UIAlertAction(title: "好", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "去設定", style: .cancel, handler: { (alert) -> Void in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(settingsAppURL)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
