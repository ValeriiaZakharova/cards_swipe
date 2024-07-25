//
//  CardSView.swift
//  cards_swipe_
//
//  Created by Valeriia Zakharova on 25.07.2024.
//

import SwiftUI
import ComposableArchitecture

struct CardsView: View {

    @Bindable var store: StoreOf<CardsReducer>

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    Text("Hey Hey Hey")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text("What do you wanna learn today?")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                .padding(.top, 115)
                Spacer()
                CardsStackView(
                    store: store.scope(state: \.cardsStackState, action: \.cardsStack))
                Spacer()
                Spacer()
            }
            .onAppear {
                // TODO: implement fetching date
            }
            .alert($store.scope(state: \.alert, action: \.alert))
            .navigationDestination(
                item: $store.scope(state: \.destination?.details, action: \.destination.details)
            ) { store in
                DetailsView(store: store)
            }
            .padding(.horizontal, 40)
            .frame(maxWidth: .infinity)
            .background(.white)
            .toolbarRole(.editor)
            .toolbar {
                // TODO: Add correct buttons
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        //store.send(.dismiss)
                    }, label: {
                        Image(uiImage: .checkmark)
                            .padding(.leading, 23)
                    })
                }
            }
        }
    }
}

#Preview {
    CardsView(store: Store(initialState: CardsReducer.State()) {
        CardsReducer()
    })
}

