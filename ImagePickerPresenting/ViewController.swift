//
//  ViewController.swift
//  ImagePickerPresenting
//
//  Created by william on 2020/5/19.
//  Copyright © 2020 william. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ImagePickerPresenting {

    lazy var myImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("點擊選擇", for: .normal)
        button.backgroundColor = .darkGray
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup()
        setupConstraint()
        
        
    }

    func setup() -> Void {
        view.addSubview(myImageView)
        view.addSubview(button)
        
        button.addTarget(self, action: #selector(showMyCamera), for: .touchUpInside)
    }
    
    @objc func showMyCamera() -> Void {
        showCameraAlert(type: .ALL) { (image) in
            self.myImageView.image = image
        }
    }
    
    func setupConstraint() -> Void {
        NSLayoutConstraint.activate(myImageView.edgeConstraints(top: 0, left: 0, bottom: 0, right: 0))
        NSLayoutConstraint.activate([button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
                                     button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0),
                                     button.heightAnchor.constraint(equalToConstant: 100),
                                     button.widthAnchor.constraint(equalToConstant: 100)])
    }
    
    
}

extension UIView {
    public func edgeConstraints(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> [NSLayoutConstraint] {
        return [
            self.leftAnchor.constraint(equalTo: self.superview!.leftAnchor, constant: left),
            self.rightAnchor.constraint(equalTo: self.superview!.rightAnchor, constant: -right),
            self.topAnchor.constraint(equalTo: self.superview!.topAnchor, constant: top),
            self.bottomAnchor.constraint(equalTo: self.superview!.bottomAnchor, constant: -bottom)
        ]
    }
}
