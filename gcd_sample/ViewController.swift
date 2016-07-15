//
//  ViewController.swift
//  gcd_sample
//
//  Created by NAGAMINE HIROMASA on 2016/07/15.
//  Copyright © 2016年 NAGAMINE HIROMASA. All rights reserved.
//

import UIKit



class DispatchClassA: Dispatchable {
    var queue: dispatch_queue_t? = nil

    internal func closure(group: dispatch_group_t) {
        print("Sync A (no thread)")
    }
}


class DispatchClassB: Dispatchable {
    var queue: dispatch_queue_t? = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

    internal func closure(group: dispatch_group_t) {
        dispatch_group_enter(group)

        // Background Queue
        dispatch_group_async(group, queue!) {
            print("Async B (background thread)")
            dispatch_group_leave(group)
        }
    }
}

class DispatchClassC: Dispatchable {
    var queue: dispatch_queue_t? = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    var group2 = dispatch_group_create()
    internal func closure(group: dispatch_group_t) {
        dispatch_group_async(group, self.queue!) {
            print("Async C (background thread)")

            dispatch_group_async(group, dispatch_get_main_queue(), {
                print("Async C (main thread)")
            })

            print("dispatched main queue")
        }
    }
}

protocol DispatchableGroup {
    var group: dispatch_group_t {get}
    var dispatchables: [Dispatchable] {get set}
}

extension DispatchableGroup {
    mutating func addDispatchable(dispatchable: Dispatchable) {
        dispatchables.append(dispatchable)
    }

    func execute(completion:() -> ()) {
        print("start....")
        dispatchables.forEach { $0.closure(group) }

//        dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            print("end...")
            completion()
        }
    }
}

protocol Dispatchable {
    var queue: dispatch_queue_t? {get}
    func closure(group: dispatch_group_t)
}

class DGroup: DispatchableGroup {
    var group: dispatch_group_t = dispatch_group_create()
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