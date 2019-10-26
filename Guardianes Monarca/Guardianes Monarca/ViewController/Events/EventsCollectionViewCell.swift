//
//  EventsCollectionViewCell.swift
//  Guardianes Monarca
//
//  Created by Juan David Torres on 10/15/19.
//  Copyright © 2019 Juan David Torres. All rights reserved.
//

import UIKit

class EventsCollectionViewCell: UITableViewCell {
    @IBOutlet weak var backgroundImageEvents: UIImageView!
    @IBOutlet weak var labelNombre: UILabel!
    @IBOutlet weak var labelLugar: UILabel!
    @IBOutlet weak var labelFecha: UILabel!
    @IBOutlet weak var labelDescripcion: UILabel!
    @IBOutlet weak var calendarIcon: UIImageView!
    
    @IBOutlet weak var viewEvents: UIView!
}
