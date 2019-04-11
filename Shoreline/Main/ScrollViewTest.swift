//
//  ScrollViewTest.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 4/8/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class ScrollViewTest: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let scrollView = NSScrollView(frame: self.view.frame)
        scrollView.hasVerticalScroller = true
        scrollView.borderType = NSBorderType.noBorder
        
        scrollView.documentView = HistoryView(
            list: [
                SourceModel(EqualsModel(
                    AtomicModel("y"),
                    PlusModel([
                        MultiplicationModel([AtomicModel("m"), AtomicModel("x")]),
                        AtomicModel("b")]))).asView(),
                SourceModel(EqualsModel(
                    AtomicModel("x"),
                    RationalModel(
                        PlusModel([NegativeModel(AtomicModel("b")), AtomicModel("y")]),
                        AtomicModel("m")))).asView(),
                SourceModel(PlusModel(
                    [AtomicModel("a"), AtomicModel("b"), AtomicModel("c"), AtomicModel("d") ,AtomicModel("e")])).asView()])
        self.view.addSubview(scrollView)
    }
}
