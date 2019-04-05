//
//  PatternModel.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 3/24/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class PatternModel: ExpressionModel {
    let patternId: Int
    
    init(_ patternId: Int) {
        self.patternId = patternId
    }
    
    override func orphanCopy() -> ExpressionModel {
        return PatternModel(self.patternId)
    }
    
    override func matchesExpression(_ expression: ExpressionModel) -> Bool {
        return true // i don't think this case matters.  let's find out
    }
    
    override func applyPatternMap(_ map: [Int : [ExpressionModel]]) {
        if let replacements = map[self.patternId] {
            // awesome cool this is completely wrong i'll just cry about it later
            let parent = ExpressionModel.lowestCommonAncestor(Set(replacements))
            let replacementParent = parent!.orphanCopy()  // performance is a non-issue haha jk sarcasm sucks
            for replacement in replacements {
                replacementParent.replaceChildAt(replacement.getChildIndex(), with: replacement)
            }
            self.getParent()?.replaceChildAt(self.getChildIndex(), with: replacementParent)
        }
    }
    
    override func replaceWithPatternMap(_ map: [Int: ExpressionModel]) -> ExpressionModel? {
        if let replacement = map[self.patternId]?.orphanCopy() {
            return replacement
        } else {
            print("patternId not found is pattern map.  panic!")
            return nil
        }
    }
    
    override func findMatchingSubtree(_ pattern: ExpressionModel?) -> ExpressionModel? {
        return self  // i don't think this case matters.  let's find out.
    }
    
    override func asView() -> ExpressionView {
        return PatternView(patternId: self.patternId)
    }
}
