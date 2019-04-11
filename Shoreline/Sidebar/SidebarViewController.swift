//
//  SidebarViewController.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 3/11/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class SidebarViewController: NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource {
    @IBOutlet weak var collectionView: NSCollectionView!
    var fakeList = [String]()
    var allExpressions = [
        SourceModel(EqualsModel(AtomicModel("b"), AtomicModel("a"))),
        SourceModel(PlusModel([AtomicModel("3"), AtomicModel("1"), AtomicModel("4"), AtomicModel("2"), AtomicModel("5")])),
        SourceModel(MultiplicationModel([AtomicModel("4"), AtomicModel("3"), AtomicModel("1"), AtomicModel("2"), AtomicModel("5")])),
        SourceModel(EqualsModel(AtomicModel("2"),
                                PlusModel([NegativeModel(AtomicModel("1")), AtomicModel("3")]))),
        SourceModel(EqualsModel(RationalModel(AtomicModel("a"), AtomicModel("c")),
                                RationalModel(AtomicModel("d"), AtomicModel("b")))),
        SourceModel(EqualsModel(
            AtomicModel("y"),
            PlusModel([
                MultiplicationModel([AtomicModel("m"), AtomicModel("x")]),
                AtomicModel("b")])))
    ]
    var allExpressionHistories = [[ExpressionModel]]()
    var allExpressionsCopy = [SourceModel]()
    
    static let ARBITRARY_ITEM_HEIGHT = 50.0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NotificationCenter.default.addObserver(self, selector: #selector(expressionUpdated(_:)),
                                               name: NSNotification.Name("expressionUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resetRequested(_:)),
                                               name: NSNotification.Name("resetRequested"), object: nil)
        self.collectionView.register(SidebarItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("reuseId"))
        self.allExpressionsCopy = self.allExpressions
        self.allExpressionHistories = [[ExpressionModel]](repeating: [ExpressionModel](), count: self.allExpressions.count)
        self.sendExpressionToMain(0)
    }
    
    @objc func expressionUpdated(_ notification: NSNotification) {
        if let expression = notification.userInfo?["expression"] as? SourceModel,
            let index = notification.userInfo?["index"] as? Int,
            let history = notification.userInfo?["history"] as? [ExpressionModel] {
            // fu no bounds checking
            self.allExpressions[index] = expression
            self.allExpressionHistories[index] = history
            self.collectionView.reloadData()
        } else {
            print("SidebarViewController wanted expression and index, got burned")
        }
    }
    
    @objc func resetRequested(_ notification: NSNotification) {
        if let index = notification.userInfo?["index"] as? Int {
            self.allExpressions[index] = self.allExpressionsCopy[index]
            self.allExpressionHistories[index] = [ExpressionModel]()
            self.sendExpressionToMain(index)
            self.collectionView.reloadData()
        } else {
            print("SidebarViewController expected index, got burned")
        }
    }
    
    @IBAction func plusButtonPressed(_ sender: Any) {
        self.allExpressions.append(SourceModel(AtomicModel(String(self.allExpressions.count))))
        self.allExpressionHistories.append([ExpressionModel]())
        self.allExpressionsCopy.append(self.allExpressions.last!)
        self.collectionView.reloadData()
    }
    
    func sendExpressionToMain(_ index: Int) {
        let dictionary = [
            "expression": self.allExpressions[index].orphanCopy(),
            "index": index,
            "history": self.allExpressionHistories[index]
        ] as [String: Any]
        NotificationCenter.default.post(name: NSNotification.Name("expressionSelected"), object: self, userInfo: dictionary)
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.allExpressions.count;
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = self.collectionView.makeItem(
            withIdentifier:NSUserInterfaceItemIdentifier(rawValue: "reuseId"),
            for: indexPath) as! SidebarItem;
        item.setExpression(self.allExpressions[indexPath.item])
        return item;
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        // I like to live dangerously...
        self.sendExpressionToMain(indexPaths.first!.item)
    }
}
