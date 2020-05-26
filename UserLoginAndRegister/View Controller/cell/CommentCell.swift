//
//  CommentCell.swift
//  intellik
//
//  Created by 江南 on 5/14/20.
//  Copyright © 2020 江南. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var comments: UILabel!
    
    func setComments(comment: Comment) {
        photo.image = comment.image;
        name.text = comment.name;
        comments.text = comment.description;
    }
}
