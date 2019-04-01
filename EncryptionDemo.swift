//
//  EncryptionDemo.swift
//  
//
//  Created by Yi Zhang on 2019/4/2.
//

extension StringProtocol {
    
    var string: String { return String(self) }
    
    subscript(offset: Int) -> Element {
        return self[index(startIndex, offsetBy: offset)]
    }
    
    subscript(_ range: CountableRange<Int>) -> SubSequence {
        return prefix(range.lowerBound + range.count)
            .suffix(range.count)
    }
    subscript(range: CountableClosedRange<Int>) -> SubSequence {
        return prefix(range.lowerBound + range.count)
            .suffix(range.count)
    }
    
    subscript(range: PartialRangeThrough<Int>) -> SubSequence {
        return prefix(range.upperBound.advanced(by: 1))
    }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence {
        return prefix(range.upperBound)
    }
    subscript(range: PartialRangeFrom<Int>) -> SubSequence {
        return suffix(Swift.max(0, count - range.lowerBound))
    }
}

extension Substring {
    var string: String { return String(self) }
}

import Foundation

let keys = "EV9QkI36KxWmlagbRq2sc47uHSPOAtC"
let values = "rJypdFUhvXoBiLfTDweY58Z0nNzGj1M"

var table = [String:String]()

// 初始化密码表
for i in 0...(keys.count-1) {
    table[String(keys[i])] = String(values[i])
    table[String(values[i])] = String(keys[i])
}

// 解密加密为同一方法
func handle(string:String)
{
    var result = ""
    for s in string {
        result += table[String(s)] ?? String(s)
    }
    print(result)
}

handle(string: "www.baidu.com")
handle(string: "qqq.TLlk0.5WB")
