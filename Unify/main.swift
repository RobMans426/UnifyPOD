//
//  main.swift
//  UnifyPOD
//
//  Created by Shawn Henck on 1/25/16.
//  Copyright © 2015 DragonArmy. All rights reserved.
//

import Foundation
import UIKit

//UIApplicationMain(CommandLine.argc,UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(to: UnsafeMutableRawPointer<Int8>.self, capacity: Int(CommandLine.argc), NSStringFromClass(KioskApplication),
//    NSStringFromClass(AppDelegate.self))

    UIApplicationMain(CommandLine.argc, UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(to: UnsafeMutablePointer<Int8>.self,capacity: Int(CommandLine.argc)),NSStringFromClass(KioskApplication.self),
        NSStringFromClass(AppDelegate.self)
)
