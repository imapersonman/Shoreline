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
    var plus: ExpressionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.sidebarLabel.stringValue = ""
        self.bottomLabel.stringValue = ""
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(expressionSelected(_:)),
            name: NSNotification.Name("expressionSelected"),
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(transformationPressed(_:)),
            name: NSNotification.Name("transformationPressed"),
            object: nil)
        self.selectionBox.isHidden = true;
        self.plus = PlusView(
            origin: NSPoint(x: 100.0, y: 100.0),
            list: [
                RationalView(
                    numerator: AtomicView(text: "x"),
                    denominator: PlusView(
                        origin: NSPoint.zero,
                        list: [
                            AtomicView(text: "3"),
                            AtomicView(text: "x"),
                            RationalView(
                                numerator: PlusView(origin: NSPoint.zero, list: [AtomicView(text: "everything"), AtomicView(text: "9")]),
                                denominator: AtomicView(text: "y"))
                        ]))
            ]);
        /*
        self.plus = PlusView(
            origin: NSPoint(x: 100.0, y: 100.0),
            list: [AtomicView(text: "a"), AtomicView(text: "b"), AtomicView(text: "c"), AtomicView(text: "d")]);
         */
        self.plus?.setFontSize(size: 72)
        self.view.addSubview(self.plus!)
        //plus.frame.origin.x = self.view.frame.width / 2 - plus.frame.width / 2
        //plus.frame.origin.y = self.view.frame.height / 2 - plus.frame.height / 2
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
    
    override func mouseDown(with event: NSEvent) {
        self.clearExpressionIntersection(expression: self.plus!)
        let pos = self.view.convert(event.locationInWindow, from: nil)
        self.selectionStart = pos
        self.selectionEnd = pos
        self.selectionBox.frame = NSRect(x: pos.x, y: pos.y, width: 0.0, height: 0.0)
        self.selectionBox.isHidden = false
    }
    
    override func mouseUp(with event: NSEvent) {
        self.selectionStart = NSPoint.zero
        self.selectionEnd = NSPoint.zero
        self.selectionBox.isHidden = true
    }
    
    func clearExpressionIntersection(expression: ExpressionView) {
        // Uhhhggg I need to do this better
        expression.setSelected(false)
        if let subs = expression.getExpressionSubviews() {
            for sub in subs {
                self.clearExpressionIntersection(expression: sub)
            }
        }
    }
    
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
    
    func actuallySelectSelectedViewsImSeriousThisTime(_ expressions: [ExpressionView]) -> ExpressionView? {
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
        
        let intersectedViews = self.getIntersectedViews(self.plus!, frame)
        if let toSelect = self.actuallySelectSelectedViewsImSeriousThisTime(intersectedViews) {
            // Clear children, then select toSelect
            self.clearExpressionIntersection(expression: self.plus!)
            toSelect.setSelected(true)
        }
        self.selectionBox.frame = frame;
    }
}
