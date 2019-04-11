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
    @IBOutlet weak var historyView: HistoryView!
    
    var selectionStart: NSPoint = NSPoint.zero
    var selectionEnd: NSPoint = NSPoint.zero
    
    var lastIntersectedModels = Set<ExpressionModel>()
    var intersectedModels = Set<ExpressionModel>()
    
    var currentExpressionIndex = 0  // might cause problems
    var allExpressionHistories = [ExpressionModel]()
    
    var allExpressions = [
        SourceModel(EqualsModel(
            AtomicModel("y"),
            PlusModel([
                MultiplicationModel([AtomicModel("m"), AtomicModel("x")]),
                AtomicModel("b")]))),
        SourceModel(EqualsModel(
            AtomicModel("x"),
            RationalModel(
                PlusModel([NegativeModel(AtomicModel("b")), AtomicModel("y")]),
                AtomicModel("m")))),
        SourceModel(PlusModel([AtomicModel("a"), AtomicModel("b"), AtomicModel("c"), AtomicModel("d"), AtomicModel("e")]))
    ]
    
    var currentExpressionHistory = [ExpressionModel]()
    var currentExpressionView = ExpressionView()
    var currentExpression = SourceModel(ExpressionModel())
    var viewToModel = [ExpressionView: ExpressionModel]()
    var modelToView = [ExpressionModel: ExpressionView]()
    var nextSelectionIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.addNotificationObserver(selector: #selector(expressionSelected(_:)), name: "expressionSelected")
        self.addNotificationObserver(selector: #selector(transformationPressed(_:)), name: "transformationPressed")
        self.historyView.setFontSize(20)
    }
    
    // I hate what I'm doing with the next two functions but I need to get things done quickly
    var count = 0
    func updateCurrentExpressionView() {
        self.currentExpressionView.removeFromSuperview()
        self.currentExpressionView = self.currentExpression.asView()
        self.currentExpressionView.setFontSize(size: 72)
        self.currentExpressionView.frame.origin = NSPoint.zero
        self.view.addSubview(self.currentExpressionView)
        
        // building view-model map
        self.viewToModel = [ExpressionView: ExpressionModel]()
        var queue = [(ExpressionView, ExpressionModel)]()
        queue.append((self.currentExpressionView, self.currentExpression))
        while !queue.isEmpty {
            let current = queue.remove(at: 0)
            self.viewToModel[current.0] = current.1
            self.modelToView[current.1] = current.0
            if let viewSubs = current.0.getExpressionSubviews() {
                // trees should be the same, so this should be okay to do
                let modelSubs = current.1.getSubExpressions()!
                for pair in zip(viewSubs, modelSubs) {
                    queue.append(pair)
                }
            }
        }
        self.currentExpressionView.frame.origin = NSPoint(
            x: self.view.frame.size.width / 2 - self.currentExpressionView.frame.size.width / 2,
            y: self.view.frame.size.height / 2 - self.currentExpressionView.frame.size.height / 2)
    }
    
    func addNotificationObserver(selector: Selector, name: String) {
        NotificationCenter.default.addObserver(self, selector: selector, name: NSNotification.Name(name), object: nil)
    }
    
    @objc func expressionSelected(_ notification: NSNotification) {
        if let expression = notification.userInfo?["expression"] as? SourceModel,
            let index = notification.userInfo?["index"] as? Int,
            let history = notification.userInfo?["history"] as? [ExpressionModel] {
            self.currentExpression = expression
            self.currentExpressionIndex = index
            self.currentExpressionHistory = history
            self.historyView.setExpressions(history.map({ expression in expression.asView() }))
            self.sendExpressionModelToBottomBar(self.currentExpression)
            self.updateCurrentExpressionView()
        } else {
            print("MainViewController wanted expression, got burned")
        }
    }
    
    @objc func transformationPressed(_ notification: NSNotification) {
        if let expression = notification.userInfo?["transformedModel"] as? SourceModel {
            self.currentExpression.clearSelectedRanges()
            self.currentExpressionHistory.append(self.currentExpression)
            self.historyView.addExpression(self.currentExpression.asView())
            self.currentExpression = expression
            //self.currentExpression.clearSelectedRanges()
            self.sendExpressionModelToSidebar(self.currentExpression, self.currentExpressionIndex, self.currentExpressionHistory)
            self.updateCurrentExpressionView()
        } else {
            print("MainViewController wanted transformedModel, got burned")
            exit(-1)
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
            self.currentExpression.clearSelectedRanges()
            self.lastIntersectedModels.removeAll()
            self.updateCurrentExpressionView()
            self.nextSelectionIndex = 0
        }
        //self.sendExpressionModelToBottomBar(self.currentExpression)
    }
    
    override func mouseDragged(with event: NSEvent) {
        let pos = self.view.convert(event.locationInWindow, from: nil)
        self.selectionEnd = pos
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
        
        self.selectionBox.frame = frame
        self.checkAndMakeExpressionSelection(self.currentExpressionView, self.selectionBox.frame)
    }
    
    override func mouseUp(with event: NSEvent) {
        self.endSelectionBox()
        self.sendExpressionModelToBottomBar(self.currentExpression)  // for now but ahhh no
        
        let difference = self.lastIntersectedModels.symmetricDifference(self.intersectedModels)
        if difference.isEmpty {
            return
        }
        //self.sendExpressionModelToSidebar(self.currentExpression, self.currentExpressionIndex, self.currentExpressionHistory)
        // where should this go???
        self.lastIntersectedModels = intersectedModels
    }
    
    /**
     * getIntersectedViews: ExpressionView, NSRect -> [ExpressionView]
     *
     * Returns a list of the expressions that are being intersected by the given rect.  Lowest level
     * of selection process.
     */
    func getIntersectedViews(_ expression: ExpressionView, _ rect: NSRect) -> Set<ExpressionView> {
        let transformedRect = expression.superview!.convert(rect, to: expression)
        return expression.getIntersectedViews(transformedRect)
        
        /*
        var intersectedViews = Set<ExpressionView>()
        let transformedRect = expression.superview!.convert(rect, to: expression)
        
        if transformedRect.intersects(NSRect(origin: NSPoint.zero, size: expression.frame.size)) {
            if let subs = expression.getExpressionSubviews() {
                for sub in subs {
                    let intersectedSubSubs = self.getIntersectedViews(sub, transformedRect)
                    intersectedViews.formUnion(intersectedSubSubs)
                }
            } else {
                intersectedViews.insert(expression)
            }
        }
        
        return intersectedViews
 */
    }
    
    func intersectedModelsDidChange(_ newIntersectedModels: [ExpressionModel]) -> Bool {
        if self.lastIntersectedModels.count != newIntersectedModels.count {
            return true
        } else {
            for (last, new) in zip(self.lastIntersectedModels, newIntersectedModels) {
                if last != new {
                    return true
                }
            }
        }
        return false
    }
    
    func getSelectionRange(_ parent: ExpressionModel, _ subModels: Set<ExpressionModel>) -> (Int, Int) {
        var lowest = Int.max
        var highest = Int.min
        for model in subModels {
            var current = Optional(model)
            while (current?.getParent() != parent && current?.getParent() != nil) {
                current = current!.getParent()
            }
            if current?.getParent() == parent {
                if current!.getChildIndex() < lowest {
                    lowest = current!.getChildIndex()
                }
                if current!.getChildIndex() > highest {
                    highest = current!.getChildIndex()
                }
            }
        }
        return (lowest, highest)
    }
    
    func checkAndMakeExpressionSelection(_ expression: ExpressionView, _ rect: NSRect) {
        let intersectedViews = self.getIntersectedViews(expression, rect)
        self.intersectedModels = Set<ExpressionModel>(
            intersectedViews.map({ (view) -> ExpressionModel in self.viewToModel[view]! }))
        let difference = self.lastIntersectedModels.symmetricDifference(self.intersectedModels)
        if difference.isEmpty {
            return
        }
        
        if let lca = ExpressionModel.lowestCommonAncestor(self.intersectedModels) {
            var toSelect = lca
            // messy, but for a cleaner cause
            if self.intersectedModels.count == 1 {
                // i know it exists because a SourceModel can't be selected
                toSelect = toSelect.getParent()!
            }
            // update the model
            let range = self.getSelectionRange(toSelect, intersectedModels)
            toSelect.selectRange(self.nextSelectionIndex, range)
            // update the view based on the model
            self.lastIntersectedModels = intersectedModels
            self.updateCurrentExpressionView()
        }
    }
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        let dictionary = ["index": self.currentExpressionIndex]
        NotificationCenter.default.post(name: NSNotification.Name("resetRequested"), object: self, userInfo: dictionary)
    }
    
    func sendExpressionModelToBottomBar(_ expression: ExpressionModel) {
        let dictionary = ["selection": expression]
        NotificationCenter.default.post(name: NSNotification.Name("filterTransformations"), object: self, userInfo: dictionary)
    }
    
    func sendExpressionModelToSidebar(_ expression: ExpressionModel, _ index: Int, _ history: [ExpressionModel]) {
        let dictionary = [
            "expression": expression,
            "index": index,
            "history": history
            ] as [String: Any]
        NotificationCenter.default.post(name: NSNotification.Name("expressionUpdated"), object: self, userInfo: dictionary)
    }
}
