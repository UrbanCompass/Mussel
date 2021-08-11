//
//  ViewController.swift
//  MusselExample
//
//  Created by Renato Gamboa on 12/3/20.
//  Copyright © 2020 Compass. All rights reserved.
//

import SnapKit
import SwiftyGif
import UIKit

class ViewController: UIViewController {
    let text = UILabel()
    let imageview = UIImageView(image: #imageLiteral(resourceName: "mussel-icon"))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        imageview.contentMode = .scaleAspectFit
        imageview.frame = view.bounds
        view.addSubview(imageview)
        imageview.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(300)
        }

        text.font = .boldSystemFont(ofSize: 26)
        text.text = "Mussel Push Notification Example"
        text.numberOfLines = 0
        text.textAlignment = .center
        text.textColor = .black
        view.addSubview(text)
        text.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(imageview.snp.bottom).offset(24)

            if pushUrl {
                self.navigationController?.pushViewController(ViewController2(), animated: true)
            }
        }
    }
}
