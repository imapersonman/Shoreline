//
//  CommutativeAdditionTransformationModel.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 4/7/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

class CommutativeAdditionTransformationModel: CommutativeNAryTransformationModel {
    init() {
        super.init(
            top: PlusModel([PatternModel(0), PatternModel(1)] as [ExpressionModel]),
            bottom: PlusModel([PatternModel(1), PatternModel(0)] as [ExpressionModel]))
    }
}
