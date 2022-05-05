//
//  AboutViewController.swift
//  To-Do App
//
//  Created by Mojtaba Nouri on 05/05/2022.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var mojeetoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mojeetoImageView.layer.cornerRadius = 75
        // Do any additional setup after loading the view.
    }
    
    @IBAction func contactButton(_ sender: UIButton) {
        if let safeTitleLable = sender.titleLabel?.text {
            if safeTitleLable == "E-Mail" {
                guard let url = URL(string: "mailto:mojtaba01nouri@gmail.com") else { return }
                UIApplication.shared.open(url)
            }
            else if safeTitleLable == "Github" {
                guard let url = URL(string: "https://github.com/mojeeto") else { return }
                UIApplication.shared.open(url)
            }
            else {
                guard let url = URL(string: "https://instagram.com/_mojeeto") else { return }
                UIApplication.shared.open(url)
            }
        }
    }
    

}
