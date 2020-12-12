//
//  SceneDelegate.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 11.12.2020.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }


            let rootViewController = ViewController()
            window?.rootViewController = rootViewController
    }
}
