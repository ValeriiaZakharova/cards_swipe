//
//  CardSceneReducer.swift
//  cards_swipe_
//
//  Created by Valeriia Zakharova on 25.07.2024.
//


import ComposableArchitecture
import SwiftUI

@Reducer
struct CardsReducer {

    @Reducer(state: .equatable)
    enum Destination {
        case details(DetailsReducer)
    }

    @ObservableState
    struct State: Equatable {
        var cardsStackState = CardsStackReducer.State()
        var isRecordButtonDisabled: Bool {
            !cardsStackState.isQuestionsLoaded
        }
        @Presents var alert: AlertState<Action.Alert>?
        @Presents var destination: Destination.State?
    }

    enum CancelID {
        case timer
    }

    enum Action: BindableAction {
        case cardsStack(CardsStackReducer.Action)
        case alert(PresentationAction<Alert>)
        case alertCancelRecording
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)

        @CasePathable
        enum Alert {
            case okButtonTapped
        }
    }

    @Dependency(\.dismiss)
    private var dismiss

    var body: some Reducer<State, Action> {
        BindingReducer()
        Scope(state: \.cardsStackState, action: \.cardsStack) {
            CardsStackReducer()
        }
        Reduce { state, action in
            switch action {
            case .alert(.presented(.okButtonTapped)):
                return .none
            case .alert:
                return .none
            case .binding:
                return .none
            case .cardsStack(.showQuestionDetails(let question)):
                state.destination = .details(DetailsReducer.State(question: question))
                return .none
            case .cardsStack:
                return .none
            case .destination:
                return .none
            case .alertCancelRecording:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
        .ifLet(\.$destination, action: \.destination)
    }
}
