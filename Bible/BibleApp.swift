//
//  BibleApp.swift
//  Bible
//
//  Created by Peter Larson on 7/19/23.
//

import SwiftUI
import DirectoryCore
import ReaderCore
import ComposableArchitecture

@main
struct BibleApp: App {
    var body: some Scene {
        WindowGroup {
            
            #if os(macOS)
                DesktopReaderView(store: Store(initialState: DesktopReader.State.init()) {
                    DesktopReader()
                })
            #elseif os(iOS)
                ReaderView(store: Store(initialState: Reader.State.init()) {
                    Reader()
                })
            #else
                fatalError("Unsupported OS")
            #endif
            
        }
        #if os(macOS)
            .defaultPosition(.center)
            .windowResizability(.contentMinSize)
            .windowStyle(.titleBar)
            .windowToolbarStyle(.unified)
        #endif
    }
}
