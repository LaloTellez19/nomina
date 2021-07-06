//
//  ViewController.swift
//  Adelanto de Nomina
//
//  Created by Miguel Eduardo  Valdez Tellez  on 18/06/21.
//

import UIKit
import Lottie

class SplashViewController: UIViewController {

    @IBOutlet weak var nominaAnimation: AnimationView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        animationInit()
    }

    func animationInit() {
        let animation: Animation? = Animation.named("nomina")
        nominaAnimation.animation = animation
        nominaAnimation.animationSpeed = 3
        nominaAnimation.play { _ in
            let storyboard = UIStoryboard(name: "Login", bundle: Bundle.main)
            let controller = storyboard.instantiateViewController(identifier: "Login")
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true)
        }
    }
}
