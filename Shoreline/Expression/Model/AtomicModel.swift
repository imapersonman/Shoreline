//
//  AtomicModel.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 3/23/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class AtomicModel: ExpressionModel {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    override func orphanCopy() -> ExpressionModel {
        return AtomicModel(self.text)
    }
    
    override func matchesExpression(_ expression: ExpressionModel) -> Bool {
        if let castExpression = expression as? AtomicModel {
            return self.text == castExpression.text
        } else {
            return false
        }
    }
    
    override func toSelectionTree() -> ExpressionModel {
        return AtomicModel(self.text)
    }
    
    override func findMatchingSubtree(_ pattern: ExpressionModel?) -> ExpressionModel? {
        // yeah I'll clean this up later stop yelling at me, please
        if pattern == nil {
            return nil
        } else if self.matchesExpression(pattern!) {
            return self
        } else {
            return nil
        }
    }
    
    override func replaceWithPatternMap(_ map: [Int: ExpressionModel]) -> ExpressionModel? {
        return self.orphanCopy()
    }
    
    override func asView() -> ExpressionView {
        return AtomicView(self.text)
    }
}
