//
//  cards_swipe_App.swift
//  cards_swipe_
//
//  Created by Valeriia Zakharova on 25.07.2024.
//

import SwiftUI
import ComposableArchitecture

@main
struct cards_swipe_App: App {
    var body: some Scene {
        WindowGroup {
            CardsView(store: Store(initialState: CardsReducer.State()) {
                CardsReducer()
            })
        }
    }
}
