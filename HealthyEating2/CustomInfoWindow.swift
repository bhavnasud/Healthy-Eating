//
//  CustomInfoWindow.swift
//  HealthyEating2
//
//  Created by Bhavna Sud on 1/2/19.
//  Copyright © 2019 Bhavna Sud. All rights reserved.
//

import UIKit

class CustomInfoWindow: UIView {

    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var body_label: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func loadView() -> CustomInfoWindow{
        let customInfoWindow = Bundle.main.loadNibNamed("CustomInfoWindow", owner: self, options: nil)?[0] as! CustomInfoWindow
        return customInfoWindow
    }

}
