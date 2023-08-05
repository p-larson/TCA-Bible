//
//  BibleApp.swift
//  Bible
//
//  Created by Peter Larson on 7/19/23.
//

import SwiftUI
import ReaderCore
import ComposableArchitecture

@main
struct BibleApp: App {
    var body: some Scene {
        WindowGroup {
            ReaderView(
                store: Store(initialState: Reader.State()) {
                    Reader()
                        ._printChanges()
                }
            )
        }
        
    }
}
