//
//  CardsStackReducer.swift
//  cards_swipe_
//
//  Created by Valeriia Zakharova on 25.07.2024.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct CardsStackReducer {

    @ObservableState
    struct State: Equatable {
        var questions: [Question] = [
            Question(id: "0", text: "Do you like pizza?"),
            Question(id: "2", text: "Do you like ocean?"),
            Question(id: "3", text: "Do you like surfing?"),
            Question(id: "4", text: "Do you like climbing?"),
            Question(id: "5", text: "Do you like strange people?"),
            Question(id: "6", text: "Do you like sleeping?"),
            Question(id: "7", text: "Do you like reading?"),
            Question(id: "8", text: "Do you like running?"),
            Question(id: "9", text: "Do you like volleyball?")
        ]
        var displayedQuestions: [QuestionViewModel] = []
        let cardColors: [Color] = [.blue, .yellow, .brown, .pink]
        let cardColorsRecording: [Color] = [.green, .orange, .gray, .cyan]
        var isQuestionsLoaded = false
        @Presents var alert: AlertState<Action.Alert>?
    }

    enum Action: BindableAction {
        case fetchQuestions
        case updateQuestions([Question])
        case loadDisplayedQuestions
        case swipeQuestion(QuestionViewModel)
        case setIsQuestionsLoaded
        case showErrorAlert(String)
        case notifyParentAboutError
        case showQuestionDetails(QuestionViewModel)
//        case failed(QuestionsNetworkError)
        case alert(PresentationAction<Alert>)
        case binding(BindingAction<State>)

        @CasePathable
        enum Alert {
            case tryAgainButtonTapped
            case okButtonTapped
        }
    }

    @Dependency(\.uuid)
    private var uuid

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .fetchQuestions:
                return .send(.updateQuestions(state.questions))
            case .updateQuestions(let questions):
                state.questions = questions
                return .send(.loadDisplayedQuestions)
            case .loadDisplayedQuestions:
                state.displayedQuestions = loadDisplayedQuestions(state: state)
                return .send(.setIsQuestionsLoaded)
            case .setIsQuestionsLoaded:
                state.isQuestionsLoaded = true
                return .none
            case .swipeQuestion(let question):
                if let index = state.questions.firstIndex(where: { $0.id == question.id }) {
                    state.questions.remove(at: index)
                    let questionToAdd = Question(id: question.id, text: question.text)
                    state.questions.append(questionToAdd)
                }
                return .send(.loadDisplayedQuestions)
            case .showErrorAlert(let message):
                state.alert = AlertState {
                    TextState("Oops, something went wrong")
                } actions: {
                    ButtonState(action: .tryAgainButtonTapped) {
                        TextState("Try Again")
                    }
                    ButtonState(action: .okButtonTapped) {
                        TextState("OK")
                    }
                } message: {
                    TextState(message)
                }
                return .none
            case .alert(.presented(.tryAgainButtonTapped)):
                return .send(.fetchQuestions)
            case .alert(.presented(.okButtonTapped)):
                return .none
            case .notifyParentAboutError:
                return .none
            case .showQuestionDetails(let question):
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

private extension CardsStackReducer {
// TODO: Implement API
//    func fetchQuestionsTask() -> Effect<Action> {
//        .run { send in
//            do {

//            } catch {

//            }
//        }
//    }

//    func handleErrorTask(_ error: QuestionsNetworkError) -> Effect<Action> {
//        if error == .unauthenticated || error == .unauthorised {
//            return .send(.notifyParentAboutError)
//        }
//
//        guard let error = error.errorDescription else {
//            return .none
//        }
//        return .send(.showErrorAlert(error))
//    }

    func loadDisplayedQuestions(state: State) -> [QuestionViewModel] {
        var updatedDisplayedQuestions: [QuestionViewModel] = []
        let displayedQuestionsCount = 4

        for index in 0..<displayedQuestionsCount {
            let question = state.questions[index]
            let color = state.cardColors[index]
            let questionViewModel = QuestionViewModel(question: question, color: color, index: index)
            updatedDisplayedQuestions.append(questionViewModel)
        }

        return updatedDisplayedQuestions.reversed()
    }
}

