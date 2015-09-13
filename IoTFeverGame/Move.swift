//
//  Move.swift
//  IoTFeverGame
//
//  Created by Alexander Edelmann on 13/9/15.
//  Copyright (c) 2015 Foitzik Andreas. All rights reserved.
//

import Foundation

protocol Move {
    
    func getImage() -> String
    
    func isSuccessful() -> Bool
}