//
//  MainViewController.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 3/13/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {
    @IBOutlet weak var sidebarLabel: NSTextField!
    @IBOutlet weak var bottomLabel: NSTextField!
    @IBOutlet weak var selectionBox: NSBox!
    
    var selectionStart: NSPoint = NSPoint.zero
    var selectionEnd: NSPoint = NSPoint.zero
    
    var currentExpressionView = ExpressionView()
    var currentExpression = ExpressionModel()
    var viewToModel = [ExpressionView: ExpressionModel]()
    var nextSelectionIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.addNotificationObserver(selector: #selector(expressionSelected(_:)), name: "expressionSelected")
        self.addNotificationObserver(selector: #selector(transformationPressed(_:)), name: "transformationPressed")
        
        self.currentExpression = RationalModel(
            PlusModel([AtomicModel("a"), AtomicModel("b"), AtomicModel("c"), AtomicModel("d"), AtomicModel("e")]),
            PlusModel([AtomicModel("g"), AtomicModel("h"), AtomicModel("i"), AtomicModel("j"), AtomicModel("k")]))
        self.updateCurrentExpressionView()
    }
    
    // I hate what I'm doing with the next two functions but I need to get things done quickly
    func updateCurrentExpressionView() {
        self.currentExpressionView.removeFromSuperview()
        self.currentExpressionView = self.currentExpression.asView()
        self.currentExpressionView.setFontSize(size: 72)
        self.currentExpressionView.frame.origin = NSPoint(x: 100, y: 100)
        self.view.addSubview(self.currentExpressionView)
        
        // building view-model map
        self.viewToModel = [ExpressionView: ExpressionModel]()
        var queue = [(ExpressionView, ExpressionModel)]()
        queue.append((self.currentExpressionView, self.currentExpression))
        while !queue.isEmpty {
            let current = queue.remove(at: 0)
            self.viewToModel[current.0] = current.1
            if let viewSubs = current.0.getExpressionSubviews() {
                // trees should be the same, so this should be okay to do
                let modelSubs = current.1.getSubExpressions()!
                for pair in zip(viewSubs, modelSubs) {
                    queue.append(pair)
                }
            }
        }
    }
    
    func updateCurrentExpressionModel() {
        self.currentExpression = self.currentExpressionView.asModel()
        self.sendCurrentExpressionModelToBottomBar()
    }
    
    func addNotificationObserver(selector: Selector, name: String) {
        NotificationCenter.default.addObserver(self, selector: selector, name: NSNotification.Name(name), object: nil)
    }
    
    @objc func expressionSelected(_ notification: NSNotification) {
        if let text = notification.userInfo?["text"] as? String {
            self.sidebarLabel.stringValue = text
        } else {
            print("MainViewController wanted text, got burned")
        }
    }
    
    @objc func transformationPressed(_ notification: NSNotification) {
        if let text = notification.userInfo?["text"] as? String {
            self.bottomLabel.stringValue = text
        } else {
            print("MainViewController wanted text, got burned")
        }
    }
    
    func startSelectionBox(_ pos: NSPoint) {
        self.selectionStart = pos
        self.selectionEnd = pos
        self.selectionBox.frame = NSRect(x: pos.x, y: pos.y, width: 0.0, height: 0.0)
        self.selectionBox.isHidden = false
    }
    
    func endSelectionBox() {
        self.selectionStart = NSPoint.zero
        self.selectionEnd = NSPoint.zero
        self.selectionBox.isHidden = true
    }
    
    override func mouseDown(with event: NSEvent) {
        let pos = self.view.convert(event.locationInWindow, from: nil)
        self.startSelectionBox(pos)
        self.nextSelectionIndex += 1
        
        if !event.modifierFlags.contains(NSEvent.ModifierFlags.command) {
            self.clearExpressionIntersection(expression: self.currentExpressionView)
            self.nextSelectionIndex = 0
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        let pos = self.view.convert(event.locationInWindow, from: nil)
        self.selectionEnd = pos;
        var frame = NSRect(x: 0.0, y: 0.0,
                           width: abs(self.selectionStart.x - self.selectionEnd.x),
                           height: abs(self.selectionStart.y - self.selectionEnd.y))
        
        if (self.selectionEnd.x < self.selectionStart.x) {
            frame.origin.x = self.selectionEnd.x
        } else {
            frame.origin.x = self.selectionStart.x
        }
        
        if (self.selectionEnd.y < self.selectionStart.y) {
            frame.origin.y = self.selectionEnd.y
        } else {
            frame.origin.y = self.selectionStart.y
        }
        
        self.selectionBox.frame = frame;
        self.checkAndMakeExpressionSelection(self.currentExpressionView, self.selectionBox.frame);
    }
    
    override func mouseUp(with event: NSEvent) {
        self.endSelectionBox()
    }
    
    func clearExpressionIntersection(expression: ExpressionView) {
        // Uhhhggg I need to do this better
        expression.setSelectionIndex(-1)
        if let subs = expression.getExpressionSubviews() {
            for sub in subs {
                self.clearExpressionIntersection(expression: sub)
            }
        }
    }
    
    /**
     * getIntersectedViews: ExpressionView, NSRect -> [ExpressionView]
     *
     * Returns a list of the expressions that are being intersected by the given rect.  Lowest level
     * of selection process.
     */
    func getIntersectedViews(_ expression: ExpressionView, _ rect: NSRect) -> [ExpressionView] {
        var intersectedViews = [ExpressionView]()
        let transformedRect = expression.superview!.convert(rect, to: expression)
        
        if transformedRect.intersects(NSRect(origin: NSPoint.zero, size: expression.frame.size)) {
            if let subs = expression.getExpressionSubviews() {
                for sub in subs {
                    let intersectedSubSubs = self.getIntersectedViews(sub, transformedRect)
                    intersectedViews.append(contentsOf: intersectedSubSubs)
                }
            } else {
                intersectedViews.append(expression)
            }
        }
        
        return intersectedViews
    }
    
    /**
     * lowestCommonAncestor: [ExpressionView] -> ExpressionView?
     *
     * Returns the lowest common ancestor of all the ExpressionView's in the given list.
     */
    func lowestCommonAncestor(_ expressions: [ExpressionView]) -> ExpressionView? {
        var visitedNodeCount = [ExpressionView : Int]()
        
        for expression in expressions {
            var current = Optional(expression)
            while current != nil {
                if visitedNodeCount[current!] == nil {
                    visitedNodeCount[current!] = 1
                } else {
                    visitedNodeCount.updateValue(visitedNodeCount[current!]! + 1, forKey: current!)
                }
                if visitedNodeCount[current!] == expressions.count {
                    return current!
                }
                current = current?.getParent()
            }
        }
        
        return nil
    }
    
    var lastIntersectedViews = [ExpressionView]()
    
    func intersectedViewListDidChange(_ newIntersectedViews: [ExpressionView]) -> Bool {
        if self.lastIntersectedViews.count != newIntersectedViews.count {
            return true
        } else {
            for (last, new) in zip(self.lastIntersectedViews, newIntersectedViews) {
                if last != new {
                    return true
                }
            }
        }
        return false
    }
    
    func checkAndMakeExpressionSelection(_ expression: ExpressionView, _ rect: NSRect) {
        let intersectedViews = self.getIntersectedViews(expression, rect)
        // Another early out is required since the same selection might have this called more than once
        if !self.intersectedViewListDidChange(intersectedViews) {
            return
        }
        
        self.lastIntersectedViews = intersectedViews
        if let toSelect = self.lowestCommonAncestor(intersectedViews) {
            // Clear children, then select toSelect
            self.clearExpressionIntersection(expression: expression)
            
            var intersectedAsChildren = Set<ExpressionView>()
            var lowest = Int.max
            var highest = Int.min
            for view in intersectedViews {
                var current = Optional(view)
                while current?.getParent() != toSelect && current?.getParent() != nil {
                    current = current!.getParent()
                }
                if current?.getParent() == toSelect {
                    intersectedAsChildren.insert(current!)
                    if current!.getChildIndex() < lowest {
                        lowest = current!.getChildIndex()
                    }
                    if current!.getChildIndex() > highest {
                        highest = current!.getChildIndex()
                    }
                }
            }
            
            toSelect.setSelectionIndex(self.nextSelectionIndex, rangeSelected: (lowest, highest))
            self.viewToModel[toSelect]?.setSelectionIndex(self.nextSelectionIndex, rangeSelected: (lowest, highest))
            
            self.updateCurrentExpressionModel()
        }
    }
    
    func sendCurrentExpressionModelToBottomBar() {
        let dictionary = ["selection": self.currentExpression]
        NotificationCenter.default.post(name: NSNotification.Name("filterTransformations"), object: self, userInfo: dictionary)
    }
}
