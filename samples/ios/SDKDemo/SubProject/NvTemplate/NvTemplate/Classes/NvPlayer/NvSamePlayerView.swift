//
//  NvSamePlayerView.swift
//  MYVideo
//
//  Created by meicam on 2020/11/3.
//  Copyright © 2020 MEISHE. All rights reserved.
//

import UIKit
import AVFoundation

public class NvSamePlayerView: UIView {

    let playerLayer = AVPlayerLayer()
    weak var player: NvPlayer?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.playerLayer.frame = frame
        playerLayer.backgroundColor = UIColor.black.cgColor
        self.layer.addSublayer(playerLayer)
    }
    
    init(player: NvPlayer) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.playerLayer.frame = CGRect(x: 0, y: 0, width: SCREENWIDTH, height: SCREENWIDTH)
        layer.addSublayer(playerLayer)
        playerLayer.backgroundColor = UIColor.black.cgColor
        setPlayer(player: player)
    }
    
    public func setPlayer(player: NvPlayer) {
        self.player = player
        self.playerLayer.videoGravity = .resizeAspect
        playerLayer.player = self.player?.player
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = self.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
