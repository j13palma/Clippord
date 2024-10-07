//
//  WindowManager.swift
//  Clippord
//
//  Created by Julio Palma on 10/7/24.
//


import SwiftUI

class WindowManager: ObservableObject {
    var windowController: ClippordWindowController?

    func showMainWindow() {
        if windowController == nil {
            windowController = createWindowController()
        }
        windowController?.showWindow()
    }

    private func createWindowController() -> ClippordWindowController {
        let controller = ClippordWindowController()
        controller.onClose = { [weak self] in
            self?.windowController = nil
        }
        return controller
    }
}
