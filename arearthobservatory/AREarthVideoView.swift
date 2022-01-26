//
//  AREarthVideoView.swift
//  arearthobservatory
//
//  Created by Yasuhito NAGATOMO on 2022/01/26.
//

import SwiftUI
import RealityKit
import ARKit

struct AREarthVideoView: UIViewControllerRepresentable {
    typealias UIViewControllerType = ARViewController

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> ARViewController {
        let viewController = ARViewController()
        return viewController
    }

    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {
    }

    class Coordinator: NSObject {
        var parent: AREarthVideoView
        init(_ parent: AREarthVideoView) {
            self.parent = parent
        }
    }
}

class ARViewController: UIViewController {
    let videoName = "CERES_NETFLUX_M-MOP_CO_M"
    let videoType = "mov"
    let panelName = "arEarthObservatory.usdz"
    let position = SIMD3<Float>(0.0, 0.0, -0.5) // position of the virtual object [meters]

    var playerLooper: AVPlayerLooper!

    override func viewDidAppear(_ animated: Bool) {
        let arView = ARView(frame: .zero)
        view = arView

        let anchorEntity = AnchorEntity(world: position)
        arView.scene.addAnchor(anchorEntity)

        if let url = Bundle.main.url(forResource: videoName, withExtension: videoType) {
            let playerItem = AVPlayerItem(url: url)
            let player = AVQueuePlayer()
            // The AVPlayerLooper instance should be kept.
            playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)

            let material = VideoMaterial(avPlayer: player)
            do {
                let panelModelEntity = try Entity.loadModel(named: panelName)
                panelModelEntity.model?.materials = [material]
                anchorEntity.addChild(panelModelEntity)
            } catch {
                assertionFailure("Could not load the panel asset.")
            }

            player.play()

        } else {
            assertionFailure("Could not load the video asset.")
        }

        let config = ARWorldTrackingConfiguration()
        arView.session.run(config)
    }
}
