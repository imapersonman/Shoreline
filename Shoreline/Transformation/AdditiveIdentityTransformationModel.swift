//
//  AdditiveIdentityTransformationModel.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 4/7/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

class AdditiveIdentityTransformationModel: IdentityTransformationModel {
    init() {
        super.init(
            nAryOperator: PlusModel(),
            identity: AtomicModel("0"),
            top: PlusModel([PatternModel(0), AtomicModel("0")]),
            bottom: PatternModel(0))
    }
}
