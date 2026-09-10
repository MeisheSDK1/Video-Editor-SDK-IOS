//
//  NvGCDGroup.swift
//  NvMeicam
//
//  Created by chengww on 2022/8/29.
//

import UIKit

extension NvGCDGroup {
    class NvGroupItem {
        var handle: ((_ group: DispatchGroup) -> Void)
        var needAsync: Bool = false
        init(callback: @escaping (_ group: DispatchGroup) -> Void) {
            self.handle = callback
        }
    }
}

public class NvGCDGroup: NSObject {
    public func addSubWoekItem(callback: @escaping (_ group: DispatchGroup) -> Void) {
        let item = NvGroupItem.init(callback: callback)
        self.workList.append(item)
    }
    
    public func start(completion: @escaping () -> Void) {
        if workList.isEmpty {
            DispatchQueue.main.async(execute: { completion() })
        }else {
            let group = DispatchGroup.init()
            while !self.workList.isEmpty {
                let item = self.workList.removeFirst()
                group.enter()
                item.handle(group)
            }
            group.notify(queue: .main, execute: {
                completion()
            })
        }
    }
    private var workList: [NvGroupItem] = []
}
