//
//  SceneDelegate.swift
//  Azimut
//
//  Created by Marcel Mierzejewski on 13/09/2020.
//  Copyright © 2020 Marcel Mierzejewski. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = MapViewController()
        window?.makeKeyAndVisible()
    }
}
