//
//  MultiplicativeIdentityTransformationModel.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 4/7/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

class MultiplicativeIdentityTransformationModel: IdentityTransformationModel {
    init() {
        // i shouldn't need the identity and top/bottom stuff, but time and abstraction and sleep
        // and whatever it's fine i promise it's just a little bit huffey to say people really is
        // the way they say they is or generally speaking not at all for the least of which even.
        super.init(
            nAryOperator: MultiplicationModel(),
            identity: AtomicModel("1"),
            top: MultiplicationModel([PatternModel(0), AtomicModel("1")]),
            bottom: PatternModel(0))
    }
}
