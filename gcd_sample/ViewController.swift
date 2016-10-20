//
//  ViewController.swift
//  gcd_sample
//
//  Created by NAGAMINE HIROMASA on 2016/07/15.
//  Copyright © 2016年 NAGAMINE HIROMASA. All rights reserved.
//

import UIKit



class DispatchClassA: Dispatchable {
    var queue: DispatchQueue? = nil

    internal func closure(_ group: DispatchGroup) {
        print("Sync A (no thread)")
    }
}


class DispatchClassB: Dispatchable {
    var queue: DispatchQueue? = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)

    internal func closure(_ group: DispatchGroup) {
        group.enter()

        // Background Queue
        queue!.async(group: group) {
            print("Async B (background thread)")
            group.leave()
        }
    }
}

class DispatchClassC: Dispatchable {
    var queue: DispatchQueue? = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
    var group2 = DispatchGroup()
    internal func closure(_ group: DispatchGroup) {
        self.queue!.async(group: group) {
            print("Async C (background thread)")

            DispatchQueue.main.async(group: group, execute: {
                print("Async C (main thread)")
            })

            print("dispatched main queue")
        }
    }
}

protocol DispatchableGroup {
    var group: DispatchGroup {get}
    var dispatchables: [Dispatchable] {get set}
}

extension DispatchableGroup {
    mutating func addDispatchable(_ dispatchable: Dispatchable) {
        dispatchables.append(dispatchable)
    }

    func execute(_ completion:@escaping () -> ()) {
        print("start....")
        dispatchables.forEach { $0.closure(group) }

//        dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
        group.notify(queue: DispatchQueue.main) {
            print("end...")
            completion()
        }
    }
}

protocol Dispatchable {
    var queue: DispatchQueue? {get}
    func closure(_ group: DispatchGroup)
}

class DGroup: DispatchableGroup {
    var group: DispatchGroup = DispatchGroup()
    var dispatchables: [Dispatchable] = []
}


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        var groupB = DGroup()
        groupB.addDispatchable(DispatchClassC())
        groupB.addDispatchable(DispatchClassC())
        groupB.addDispatchable(DispatchClassC())
        groupB.execute {
            print("Finished groupB\n")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
