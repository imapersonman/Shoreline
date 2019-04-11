//
//  BottombarItem.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 3/11/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class BottombarItem: NSCollectionViewItem {
    static let DEFAULT_COLOR = NSColor.windowBackgroundColor
    static let LOCKOUT_COLOR = NSColor.disabledControlTextColor
    
    @IBOutlet weak var backgroundBox: NSBox!
    var topExpression: ExpressionView?
    var bottomExpression: ExpressionView?
    var foregroundBox = NSBox()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.lockTransformation(true)
        self.foregroundBox.frame = NSRect(origin: NSPoint.zero, size: self.view.frame.size)
        self.foregroundBox.boxType = NSBox.BoxType.custom
        self.foregroundBox.titlePosition = NSBox.TitlePosition.noTitle
        self.foregroundBox.fillColor = NSColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        self.foregroundBox.borderColor = NSColor.clear
    }
    
    func setExpressions(top: ExpressionModel, bottom: ExpressionModel) {
        let fontSize: CGFloat = 16
        
        self.topExpression?.removeFromSuperview()
        self.topExpression = top.asView()
        self.topExpression?.setFontSize(size: fontSize)
        self.topExpression!.frame.origin.y = self.view.frame.height * 3 / 4.0 - self.topExpression!.frame.height / 2
        self.topExpression!.frame.origin.x = self.view.frame.width / 2 - self.topExpression!.frame.width / 2
        self.topExpression?.layoutCustom()
        self.view.addSubview(self.topExpression!)
        
        self.bottomExpression?.removeFromSuperview()
        self.bottomExpression = bottom.asView()
        self.bottomExpression?.setFontSize(size: fontSize)
        self.bottomExpression!.frame.origin.y = self.view.frame.height / 4.0 - self.bottomExpression!.frame.height / 2
        self.bottomExpression!.frame.origin.x = self.view.frame.width / 2 - self.bottomExpression!.frame.width / 2
        self.bottomExpression?.layoutCustom()
        self.view.addSubview(self.bottomExpression!)
    }
    
    func lockTransformation(_ shouldLock: Bool) {
        if shouldLock {
            //self.backgroundBox.fillColor = BottombarItem.LOCKOUT_COLOR
            self.view.addSubview(self.foregroundBox)
        } else {
            //self.backgroundBox.fillColor = BottombarItem.DEFAULT_COLOR
            if self.foregroundBox.superview != nil {
                self.foregroundBox.removeFromSuperview()
            }
        }
    }
}
