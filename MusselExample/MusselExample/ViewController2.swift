//
//  ViewController2.swift
//  MusselExample
//
//  Created by Renato Gamboa on 12/3/20.
//  Copyright © 2020 Compass. All rights reserved.
//

import SnapKit
import SwiftyGif
import UIKit

class ViewController2: UIViewController {
    let text = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        do {
            let gif = try UIImage(gifName: "link-dancing.gif")
            let imageview = UIImageView(gifImage: gif)
            imageview.contentMode = .scaleAspectFit
            imageview.frame = view.bounds
            view.addSubview(imageview)
            imageview.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.height.width.equalTo(300)
            }

            text.font = .boldSystemFont(ofSize: 26)
            text.text = "Mussel Universal Link Example"
            text.numberOfLines = 0
            text.textAlignment = .center
            text.textColor = .black
            view.addSubview(text)
            text.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(imageview.snp.bottom).offset(24)
            }
        } catch {
            print(error)
        }
    }
}

