//
//  CardStackView.swift
//  cards_swipe_
//
//  Created by Valeriia Zakharova on 25.07.2024.
//

import SwiftUI
import ComposableArchitecture

struct CardsStackView: View {

    @Dependency(\.cardsStackDimensionCalculator)
    private var cardsStackDimensionCalculator

    @Bindable var store: StoreOf<CardsStackReducer>
    @Binding var isRecording: Bool

    var body: some View {
        ZStack {
            ForEach(store.displayedQuestions) { question in
                let cardWidth = cardsStackDimensionCalculator.getCardWidth(
                    index: question.index)
                CardView(question: question,
                         color: question.color,
                         onSwipe: { question in
                            store.send(.swipeQuestion(question), animation: .default)
                        })
                .frame(width: cardWidth, height: 170)
                .offset(x: 0, y: -cardsStackDimensionCalculator.getCardOffset(
                    index: question.index)
                )
            }
        }
        .overlay {
            if !store.isQuestionsLoaded {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
        .onAppear {
            store.send(.fetchQuestions)
        }
        .onChange(of: isRecording) {
            store.send(.setIsRecording(isRecording))
        }
    }
}

 #Preview {
    CardsStackView(store: Store(initialState: CardsStackReducer.State(),
                                reducer: { CardsStackReducer() }),
                   isRecording: Binding.constant(true))
 }
