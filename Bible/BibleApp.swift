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
import UIKit
import AppFeature

final public class AppDelegate: NSObject, UIApplicationDelegate {
    let store = Store(
        initialState: AppReducer.State(
            appDelegate: AppDelegateReducer.State()
        )
    ) {
        AppReducer()
    }
    
    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        store.send(.appDelegate(.didFinishOpening))
        return true
    }
}

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
            .windowToolbarStyle(.unified(showsTitle: false))
        #endif
    }
}
