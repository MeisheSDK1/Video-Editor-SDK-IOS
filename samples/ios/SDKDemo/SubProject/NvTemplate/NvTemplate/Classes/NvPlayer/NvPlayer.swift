//
//  NvPlayer.swift
//  MYVideo
//
//  Created by meicam on 2020/11/3.
//  Copyright © 2020 MEISHE. All rights reserved.
//

import AVFoundation

public func nv_convertURL(urlPath: String) -> URL? {
    var url: URL?
    if urlPath.lowercased().hasPrefix("file://") || urlPath.hasPrefix("/") {
        url = URL(fileURLWithPath: urlPath)
    } else {
        url = URL(string: urlPath)
    }
    return url
}

protocol NvPlayerDelegate: AnyObject {
    func player(player: NvPlayer?, currentTimeValue value: Double)
    func playerEOF(player: NvPlayer?)
}

public class NvPlayer: NSObject {
    let player = AVPlayer()
    var urlPath: URL? {
        didSet {
            if let path = urlPath {
                if observer != nil {
                    player.removeTimeObserver(observer as Any)
                }
                NotificationCenter.default.removeObserver(self)
                palyerItem = nil
                palyerItem = AVPlayerItem(url: path)
                player.replaceCurrentItem(with: palyerItem)
                weak var weakSelf = self
                observer = player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 10), queue: DispatchQueue.main) { (time) in
                    weakSelf?.delegate?.player(player: weakSelf, currentTimeValue: time.seconds)
                }
                NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            }else {
                if observer != nil {
                    player.removeTimeObserver(observer as Any)
                    observer = nil
                }
                NotificationCenter.default.removeObserver(self)
                palyerItem = nil
                player.replaceCurrentItem(with: palyerItem)
            }
        }
    }
    var observer: Any?
    var boundaryObserver: Any?
    weak var delegate: NvPlayerDelegate?
    deinit {
        if observer != nil {
            player.removeTimeObserver(observer as Any)
            observer = nil
        }
        NotificationCenter.default.removeObserver(self)
    }
    var palyerItem: AVPlayerItem?
    init(urlPath: URL) {
        super.init()
        self.urlPath = urlPath
        palyerItem = AVPlayerItem(url: urlPath)
        player.replaceCurrentItem(with: palyerItem)
        weak var weakSelf = self
        
        observer = player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 10), queue: DispatchQueue.main) { (time) in
            weakSelf?.delegate?.player(player: weakSelf, currentTimeValue: time.seconds)
        }
 
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
    }
    
    @objc func playerItemDidPlayEnd() {
        if Thread.isMainThread {
            delegate?.playerEOF(player: self)
        } else {
            weak var weakSelf = self
            DispatchQueue.main.async {
                weakSelf?.delegate?.playerEOF(player: weakSelf)
            }
        }
    }
    
    public func setUrlPath(urlPath: URL) {
        self.urlPath = urlPath
        if player.currentItem != nil {
            if observer != nil {
                player.removeTimeObserver(observer as Any)
            }
            NotificationCenter.default.removeObserver(self)
        }
        palyerItem = AVPlayerItem(url: urlPath)
        player.replaceCurrentItem(with: palyerItem)
        weak var weakSelf = self
        observer = player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 10), queue: DispatchQueue.main) { (time) in
            weakSelf?.delegate?.player(player: weakSelf, currentTimeValue: time.seconds)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    public func play() {
        player.play()
    }
    
    public func pause() {
        player.pause()
    }
    
    public func seek(time: Double) {
        player.seek(to: CMTime(seconds: time * 25.0, preferredTimescale: CMTimeScale(25)))
    }
}
