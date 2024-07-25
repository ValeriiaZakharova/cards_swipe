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

    var body: some View {
        ZStack {
            ForEach(store.displayedQuestions) { question in
                let cardWidth = cardsStackDimensionCalculator.getCardWidth(
                    index: question.index)
                CardView(question: question,
                         color: question.color,
                         onSwipe: { question in
                            store.send(.swipeQuestion(question), animation: .default)},
                         onTap: { question in
                    store.send(.showQuestionDetails(question))
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
    }
}

 #Preview {
    CardsStackView(store: Store(initialState: CardsStackReducer.State(),
                                reducer: { CardsStackReducer() }))
 }
