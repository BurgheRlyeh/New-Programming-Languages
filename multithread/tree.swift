import Foundation

class TreeNode<T: Comparable> {
    var value: T
    var left: TreeNode?
    var right: TreeNode?
    private let lock = NSLock()

    init(value: T) {
        self.value = value
        self.left = nil
        self.right = nil
    }

    func insert(value: T) {
        lock.lock()
        defer {
            lock.unlock()
        }

        if value < self.value {
            if let left = left {
                left.insert(value: value)
            } else {
                left = TreeNode(value: value)
            }
        } else {
            if let right = right {
                right.insert(value: value)
            } else {
                right = TreeNode(value: value)
            }
        }
    }

    func contains(value: T) -> Bool {
        lock.lock()
        defer {
            lock.unlock()
        }

        if value == self.value {
            return true
        } else if value < self.value {
            return left?.contains(value: value) ?? false
        } else {
            return right?.contains(value: value) ?? false
        }
    }

    func printTree() {
        lock.lock()
        defer {
            lock.unlock()
        }
        print("Tree: ", terminator: "")
        printInOrderTraversal(self)
    }

    private func printInOrderTraversal(_ node: TreeNode?) {
        guard let node = node else { return }

        printInOrderTraversal(node.left)
        print("\(node.value) ", terminator: "")
        printInOrderTraversal(node.right)
    }
}

// Example demonstrating tree working correctly in parallel from two threads
let tree = TreeNode<Int>(value: 10)

let queue = DispatchQueue(label: "example.tree", attributes: .concurrent)

queue.async {
    for i in 0..<10 {
        if !tree.contains(value: i) {
            tree.insert(value: i)
            print("Inserted \(i) from Thread 1")
        }
    }
}

queue.async {
    for i in 0..<10 {
        if !tree.contains(value: i) {
            tree.insert(value: i)
            print("Inserted \(i) from Thread 2")
        }
    }
}

do {
    try await Task.sleep(nanoseconds: UInt64(3000))
} catch {}
tree.printTree()
print(" ", terminator: "\n")
