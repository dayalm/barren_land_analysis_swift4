//
//  BarrenLandAnalyzer.swift
//
//  Created by Dayal Murukutla on 2/18/18.
//  Copyright © 2018 Dayal Murukutla. All rights reserved.
//

import Foundation

protocol Queue {
    associatedtype Element
    func enqueue(_ element:Element)
    func dequeue()->Element?
    var isEmpty:Bool {get}
}

class SimpleQueue<T>:Queue{
    var elements:[T] = []
    typealias Element = T
    func enqueue(_ element:T){
        elements.append(element)
    }
    func dequeue()->T? {
        
        guard !self.isEmpty else {
            return nil
        }
        
        return elements.removeFirst()
    }
    
    var isEmpty:Bool {
        return elements.isEmpty
    }
}

class DoublyLinkedList<T>:Queue {
    var head:Node<T>?
    var tail:Node<T>?
    
    typealias Element = T
    
    func enqueue(_ element:T) {
        let node = Node(element)
        
        if head == nil { // head is not set
            self.head = node
        } else if tail == nil { // head is set but tail is not
            self.head?.nextNode = node
            self.tail = node
            node.previousNode = self.head
            
        } else { // both head and tail are set
            node.previousNode = self.tail
            self.tail?.nextNode = node
            self.tail = node
        }
        
    }
    
    func dequeue()->T? {
        if self.head == nil {
            return nil
        }
        let nodeForDequeue = self.head
        let nextHead = self.head?.nextNode
        self.head = nextHead
        
        if self.head == nil || self.head?.nextNode == nil {
            self.tail = nil
        }
        
        return nodeForDequeue?.value
    }
    
    var isEmpty:Bool {
        return self.head == nil
    }
    
}

class SinglyLinkedList<T>:Queue {
    var head:SinglyLinkedNode<T>?
    var tail:SinglyLinkedNode<T>?
    
    typealias Element = T
    
    func enqueue(_ element:T) {
        let node = SinglyLinkedNode(element)
        
        if head == nil { // head is not set
            self.head = node
        } else if tail == nil { // head is set but tail is not set
            self.head?.nextNode = node
            self.tail = node
        } else { // head is set tail is set
            self.tail?.nextNode = node
            self.tail = node
        }
    }
    
    func dequeue()->T? {
        
        guard let head = self.head else {
            return nil
        }
        
        let value = head.value
        
        let nextHead = head.nextNode
        
        self.head = nextHead
        
        if self.head == nil {
            self.tail = nil
        }
        
        return value
    }
    
    var isEmpty:Bool {
        return self.head == nil
    }
}


class SinglyLinkedNode<T> {
    let value:T
    var nextNode:SinglyLinkedNode<T>?
    init(_ value:T) {
        self.value = value
    }
    deinit {
        //print("SinglyLinkedNode with value \(self.value) will be deinitialized")
    }
}

class Node<T>{
    let value:T
    weak var previousNode:Node<T>?
    var nextNode:Node<T>?
    init(_ value:T) {
        self.value = value
    }
    
    deinit {
        //print("Node with value \(self.value) will be deinitialized")
    }
}

class BarrenLandAnalyzer {
    final let WIDTH = 400
    final let HEIGHT = 600
    
    var coordinates = "48 192 351 207, 48 392 351 407,120 52 135 547,260 52 275 547" //"0 292 399 307"
    
    func process() {
        let start = Date()
        let parsedCoordinateString = parseCoordinateStringFromCommandLineArgs()
        
        if !parsedCoordinateString.isEmpty {
                self.coordinates = parsedCoordinateString
        }
        
        print("processing with coordinates: \(self.coordinates)")
        
        defer {
            print("time taken: \(Date().timeIntervalSince(start)) seconds")
        }
        
        guard let fertileAreas = try? fertileAreas() else {
            print("Input Error")
            return
        }
        
        print(fertileAreas.sorted().map{"\($0)"}.joined(separator:" "))
        
    }
    
    func parseCoordinateStringFromCommandLineArgs()->String {
        var arguments = CommandLine.arguments
        arguments.removeFirst()
        
        return arguments.joined(separator:" ").trimmingCharacters(in:.whitespacesAndNewlines)
    }
    
    func fertileAreas()throws ->[Int] {
        var farm:[[Int]]
        do {
            farm = try buildFarmWithBarrenLand()
        } catch {
            throw error
        }
        var x = 0
        var y = 0
        var currentSection = 0
        
        //Best performance is with a SinglyLinkedList, followed by the Array backed SimpleQueue and then followed closely with a DoublyLinkedList
        //let queue = SimpleQueue<Location>()
        //let queue = DoublyLinkedList<Location>()
        let queue = SinglyLinkedList<Location>()
        
        var parcelMap:[Int:Int] = [:]
        while x < WIDTH && y < HEIGHT {
            if queue.isEmpty {
                if !isVisited(location: Location(x:x,y:y), farm: farm) {
                    currentSection += 1
                    parcelMap[currentSection] = 0
                    queue.enqueue(Location(x: x, y: y))
                }
                
                if x == WIDTH - 1{
                    x = 0
                    y += 1
                } else {
                    x += 1
                }
            }
            
            if !queue.isEmpty {
                let location = queue.dequeue()!
                
                if !isVisited(location: location, farm: farm) {
                    parcelMap[currentSection] = parcelMap[currentSection]! + 1
                    farm[location.x][location.y] = currentSection
                    
                    let immediateNeighbors = neighbors(forLocation:location)
                    
                    for neighbor in immediateNeighbors {
                        if !isVisited(location:neighbor,farm:farm) {
                            queue.enqueue(neighbor)
                        }
                    }
                }
            }
        }
        print("processed farm")
        return parcelMap.map{$1}
        
    }
    
    func isVisited(location:Location, farm:[[Int]])->Bool {
        return farm[location.x][location.y] != 0
    }
    
    func neighbors(forLocation location:Location)->[Location] {
        var neighbors:[Location] = []
        let x = location.x
        let y = location.y
        
        if x+1 < WIDTH {
            neighbors.append(Location(x:x+1,y:y))
        }
        
        if x-1 >= 0 {
            neighbors.append(Location(x:x-1,y:y))
        }
        
        if y+1 < HEIGHT {
            neighbors.append(Location(x:x,y:y+1))
        }
        
        if y-1 >= 0 {
            neighbors.append(Location(x:x,y:y-1))
        }
        
        return neighbors
    }
    
    func buildFarmWithBarrenLand()throws->[[Int]] {
        var farm = self.buildFarm()
        let rectangles:[Rectangle]
        
        do {
            rectangles = try self.parseInput(coordinates)
        } catch {
            throw error
        }
        
        for rectangle in rectangles {
            for x in rectangle.bottomLeftX...rectangle.topRightX {
                for y in rectangle.bottomLeftY...rectangle.topRightY {
                    farm[x][y] = -1
                }
            }
        }
        
        print("marked barren land in farm model")
        return farm
    }
    func printUsage() {
        print("Input Error!")
    }
    func parseInput(_ barrenLandString:String)throws ->[Rectangle] {
        var rectangles:[Rectangle] = []
        let rectanglesAsStrings = coordinates.split(separator: ",")
        for rectangleAsString in rectanglesAsStrings {
            let coordinates = rectangleAsString.split(separator: " ")
            guard let leftBottomX = Int(coordinates[0]) else {
                printUsage()
                throw InputError.invalidInput
            }
            guard let leftBottomY = Int(coordinates[1]) else {
                printUsage()
                throw InputError.invalidInput
            }
            guard let topRightX = Int(coordinates[2]) else {
                printUsage()
                throw InputError.invalidInput
            }
            guard let topRightY = Int(coordinates[3]) else {
                printUsage()
                throw InputError.invalidInput
            }
            
            let rectangle = Rectangle(bottomLeftX: leftBottomX, bottomLeftY: leftBottomY, topRightX: topRightX, topRightY: topRightY)
            
            rectangles.append(rectangle)
        }
        
        return rectangles
    }
    func buildFarm()->[[Int]]{
        //var farm = [[Int]]()
        let farm = Array(repeating:Array(repeating:0,count:600),count:400)
       
        /*for _ in 0..<WIDTH {
            var rows:[Int] = []
            for _ in 0..<HEIGHT {
                rows.append(0)
            }
            farm.append(rows)
        }*/
        
        print("created farm model")
        return farm
        
    }
}

extension BarrenLandAnalyzer {
    struct Rectangle {
        let bottomLeftX:Int
        let bottomLeftY:Int
        let topRightX:Int
        let topRightY:Int
    }
    struct Location {
        let x:Int
        let y:Int
    }
    enum InputError:Error {
        case invalidInput
    }
    
}

let analyzer = BarrenLandAnalyzer()
analyzer.process()

