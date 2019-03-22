//
//  SidebarItem.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 3/9/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class SidebarItem: NSCollectionViewItem {
    @IBOutlet weak var labelField: NSTextField!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func setLabelText(text: String) {
        self.labelField.stringValue = text;
    }
}
