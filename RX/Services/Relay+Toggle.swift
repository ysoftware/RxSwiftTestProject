//
//  ToggleRelay.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 27.12.2020.
//

import RxRelay

extension BehaviorRelay where Element == Bool {
    func toggleValue() {
        accept(!value)
    }
}
