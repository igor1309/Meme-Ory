//
//  UILaunchTests.swift
//  Meme-OryUITests
//
//  Created by Igor Malyarov on 09.12.2020.
//

import XCTest

class UILaunchTests: XCTestCase {
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
