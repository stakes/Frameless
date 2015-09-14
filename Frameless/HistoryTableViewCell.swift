//
//  HistoryTableViewCell.swift
//  Frameless
//
//  Created by Jay Stakelon on 8/3/15.
//  Copyright (c) 2015 Jay Stakelon. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    var entry: HistoryEntry? {
        willSet(entry) {
            self.textLabel?.text = entry!.title
            self.detailTextLabel?.text = entry!.urlString
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.textLabel?.textColor = UIColorFromHex(0x1E1E25)
        self.textLabel?.font = UIFont.systemFontOfSize(16)
        self.detailTextLabel?.textColor = UIColorFromHex(0xA5A6A9)
        self.detailTextLabel?.font = UIFont.systemFontOfSize(12)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
