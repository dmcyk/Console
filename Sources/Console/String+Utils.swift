//
//  String+Utils.swift
//  Atomics
//
//  Created by Damian Malarczyk on 26/08/2018.
//

import Foundation

extension Character {

    static var newLine: Character {
        return "\n"
    }
}

extension String {

    static var _indent: String {
        return "    "
    }

    static var _newline: String {
        return String(Character.newLine)
    }

    static var indent: String {
        return indent(1)
    }

    static func indent(_ times: Int) -> String {
        return String(repeating: _indent, count: times)
    }

    static var newline: String {
        return newline(1)
    }

    static func newline(_ times: Int) -> String {
        return String(repeating: Character.newLine, count: times)
    }

    static func withIndent(_ times: Int = 1, _ contents: @autoclosure () -> String) -> String {
        return withIndent(times) {
            [contents()]
        }
    }

    static func withIndent(_ times: Int = 1, _ contents: () -> [String]) -> String {
        let text = contents()
        let indentString = indent(times)
        return text
            .map { str -> String in
                str.components(separatedBy: .newlines)
                    .map { indentString + $0 }
                    .joined(separator: ._newline)
            }.joined(separator: ._newline)
    }
}
