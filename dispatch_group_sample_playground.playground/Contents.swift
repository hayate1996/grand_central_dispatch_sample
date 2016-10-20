//: Playground - noun: a place where people can play

import Foundation
import PlaygroundSupport

typealias DispatchCancelableBlock = (_ cancel: Bool) -> ()
let queue = DispatchQueue(label: "concurrent queue", attributes: .concurrent) //DispatchQueue(label: "sample queue")
let group = DispatchGroup()

var cancel = false

let blockA = DispatchWorkItem {
    while(!cancel) {
        sleep(1)
        print("A")
    }
}

let blockB = DispatchWorkItem {
    while(!cancel) {
        sleep(2)
        print("B")
    }
}

let blockC = DispatchWorkItem {
    while(!cancel) {
        sleep(3)
        print("C")
    }
}

//queue.async(group: group, execute: blockA)
//queue.async(group: group, execute: blockB)
//queue.async(group: group, execute: blockC)

//
//group.notify(queue: DispatchQueue.main) {
//    if cancel {
//        print("Canceled")
//    }
//    else {
//        print("Completed")
//    }
//}

//queue.async {
//    sleep(6)
//    print("will resume")
////    queue.resume() // why stop?
//}



class SampleOperationQueue: OperationQueue {
    func cancel() {
        self.isSuspended = true
        self.cancelAllOperations()
    }
}
let oQueue = SampleOperationQueue()
let operation = BlockOperation()
operation.addExecutionBlock {
    for i in 0...10 {
        sleep(1)
        let innerOperation = BlockOperation()
        innerOperation.addExecutionBlock {
            print(operation.isCancelled)
//            while(true) {
            while(!operation.isCancelled) {
                sleep(1)
                print("operation - \(i)")
            }
        }
        oQueue.addOperation(innerOperation)
    }
}

oQueue.addOperation(operation)

let operationC = BlockOperation {
    sleep(5)
    print("operation count = \(oQueue.operationCount)")
    oQueue.cancel()
}

oQueue.addOperation(operationC)

PlaygroundPage.current.needsIndefiniteExecution = true
