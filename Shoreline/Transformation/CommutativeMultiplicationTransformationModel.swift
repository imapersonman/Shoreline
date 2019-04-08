//
//  CommutativeMultiplicationTransformationModel.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 4/7/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

class CommutativeMultiplicationTransformationModel: CommutativeNAryTransformationModel {
    init() {
        super.init(
            top: MultiplicationModel([PatternModel(0), PatternModel(1)] as [ExpressionModel]),
            bottom: MultiplicationModel([PatternModel(1), PatternModel(0)] as [ExpressionModel]))
    }
}
