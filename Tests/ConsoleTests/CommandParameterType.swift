//
//  CommandParameterType.swift
//  ConsoleTests
//
//  Created by Damian Malarczyk on 27/06/2018.
//

import XCTest
@testable import Console

class CommandParameterTypeTests: XCTestCase {

    let exp_e_opt = Option("exp", default: 0, shortForm: "e")
    let exp_e_arg = Argument("exp", default: 0, shortForm: "e")
    let exp_e_1_arg = Argument("exp", default: 1, shortForm: "e")
    let exp_nil_arg = Argument("exp", default: 0, shortForm: nil)
    let exp_nil_opt = Option("exp", default: 0, shortForm: nil)

    func testEquality() {
        let pairs: [(CommandParameter, CommandParameter, Bool)] = [
            (exp_e_opt, exp_e_arg, false),
            (exp_e_arg, exp_e_arg, true),
            (exp_e_opt, exp_e_opt, true),
            (exp_e_1_arg, exp_e_arg, true),
            (exp_nil_opt, exp_nil_arg, false),
            (exp_nil_arg, exp_e_arg, false),
            (exp_nil_opt, exp_e_opt, false)
        ]

        pairs.forEach {
            let lhsType = $0.parameterType
            let rhsType = $1.parameterType
            XCTAssertEqual(lhsType == rhsType, $2)
            XCTAssertEqual(lhsType.hashValue == rhsType.hashValue, $2)
        }
    }
}
