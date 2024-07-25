//
//  DetailsReducer.swift
//  cards_swipe_
//
//  Created by Valeriia Zakharova on 25.07.2024.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct DetailsReducer {

    @ObservableState
    struct State: Equatable {
        var question: QuestionViewModel
        @Presents var alert: AlertState<Action.Alert>?
    }

    enum Action: BindableAction {
        case displayQuestion
        case alert(PresentationAction<Alert>)
        case binding(BindingAction<State>)

        @CasePathable
        enum Alert {
            case tryAgainButtonTapped
            case okButtonTapped
        }
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .displayQuestion:
                return .none
            case .alert:
                return .none
            case .binding:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
