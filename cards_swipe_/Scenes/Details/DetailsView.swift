//
//  DetailsView.swift
//  cards_swipe_
//
//  Created by Valeriia Zakharova on 25.07.2024.
//

import SwiftUI
import ComposableArchitecture

struct DetailsView: View {

    @Bindable var store: StoreOf<DetailsReducer>

    var body: some View {
        VStack {
            Text(store.question.text)
                .font(.largeTitle)
                .foregroundColor(.red)
            Text("What do you wanna learn today?")
                .font(.subheadline)
                .foregroundColor(.red)
        }
        .alert($store.scope(state: \.alert, action: \.alert))
        .onAppear {
            store.send(.displayQuestion)
        }
    }
}

 #Preview {
     DetailsView(store: Store(initialState: DetailsReducer.State(question: QuestionViewModel(question: Question(id: "1", text: "bla"), color: .accentColor, index: 1)),
                                reducer: { DetailsReducer() }))
 }

