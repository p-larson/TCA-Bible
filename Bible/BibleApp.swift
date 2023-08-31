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
import AppFeature

final class AppDelegate: NSObject, UIApplicationDelegate {
    let store = StoreOf<AppReducer>(
        initialState: AppReducer.State(
            reader: Reader.State(),
            appDelegate: AppDelegateReducer.State()
        )
    ) {
        AppReducer()
            ._printChanges()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        store.send(.appDelegate(action: .didFinishLaunching))
        return true
    }
}

@main
struct BibleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    
    var body: some Scene {
        WindowGroup {
<<<<<<< Updated upstream
            #if os(macOS)
                DesktopReaderView(store: Store(initialState: DesktopReader.State.init()) {
                    DesktopReader()
                })
            #elseif os(iOS)
                MobileReaderView(store: Store(initialState: MobileReader.State.init()) {
                    MobileReader()
                })
            #else
                fatalError("Unsupported OS")
            #endif
            
=======
            AppView(store: delegate.store)
>>>>>>> Stashed changes
        }
        #if os(macOS)
            .defaultPosition(.center)
            .windowResizability(.contentMinSize)
            .windowStyle(.titleBar)
            .windowToolbarStyle(.unified(showsTitle: false))
        #endif
    }
}
