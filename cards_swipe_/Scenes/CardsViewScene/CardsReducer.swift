//
//  CardSceneReducer.swift
//  cards_swipe_
//
//  Created by Valeriia Zakharova on 25.07.2024.
//


import ComposableArchitecture
import SwiftUI

// swiftlint:disable type_body_length
@Reducer
struct CardSceneReducer {

//    @Reducer(state: .equatable)
//    enum Destination {
//        case recordingsList(RecordingsListReducer)
//        case login(SinginWithAppleViewReducer)
//    }

    @ObservableState
    struct State: Equatable {
        var cardsStackState = CardsStackReducer.State()
        var isPermissionGranted: Bool = false
        var isRecording: Bool = false
        var isRecordingPaused: Bool = false
        var timeProgress: Double = 0.0
        var urlToUploadString = ""
        var isRecordButtonDisabled: Bool {
            !cardsStackState.isQuestionsLoaded
        }
        var hasRecordings: Bool = false
        @Presents var alert: AlertState<Action.Alert>?
//        @Presents var destination: Destination.State?
    }

    enum CancelID {
        case timer
    }

    enum Action: BindableAction {
        case cardsStack(CardsStackReducer.Action)
        case alert(PresentationAction<Alert>)
        case showErrorAlert(isUploadAlert: Bool, String)
        case alertRecording(isAppInBackground: Bool)
        case showTokenExpiredAlert
        case alertPermissionNotGranted
        case alertCancelRecording
        case binding(BindingAction<State>)
//        case destination(PresentationAction<Destination.Action>)

        @CasePathable
        enum Alert {
            case stopButtonTapped
            case continueRecordingButtonTapped
            case openSettingsTapped
            case cancelPermissionButtonTapped
            case tryAgainButtonTapped
            case tryAgainToUpload
            case okButtonTapped
            case cancelRecordingButtonTapped
            case loginButtonTapped
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
            case .alertCancelRecording:
//                recordingService.pause()
//                state.isRecordingPaused.toggle()
                state.alert = AlertState {
                    TextState("")
                } actions: {
                    ButtonState(action: .continueRecordingButtonTapped) {
                        TextState("Continue")
                    }
                    ButtonState(action: .cancelRecordingButtonTapped) {
                        TextState("Cancel Recording")
                    }
                } message: {
                    TextState("Are you sure you want to cancel recording?")
                }
                return .cancel(id: CancelID.timer)
            case .cancelRecording:
                recordingService.cancelRecording()
                state.destination = .recordingsList(RecordingsListReducer.State())
                return .none
            case .failed(let error):
                return handleErrorTask(error)
            case .showErrorAlert(let isUploadAlert, let message):
                state.alert = AlertState {
                    TextState("Oops, something went wrong")
                } actions: {
                    if isUploadAlert {
                        ButtonState(action: .tryAgainToUpload) {
                            TextState("Try Again")
                        }
                    } else {
                        ButtonState(action: .tryAgainButtonTapped) {
                            TextState("Try Again")
                        }
                        ButtonState(action: .okButtonTapped) {
                            TextState("OK")
                        }
                    }
                } message: {
                    TextState(message)
                }
                return .none
            case .alert(.presented(.tryAgainButtonTapped)):
                return getUrlToUpload()
            case .alert(.presented(.okButtonTapped)):
                return .none
            case .alert(.presented(.tryAgainToUpload)):
                return uploadRecording(to: state.urlToUploadString)
            case .alertRecording(let isAppInBackground):
                state.alert = AlertState {
                    TextState("")
                } actions: {
                    ButtonState(action: .continueRecordingButtonTapped) {
                        TextState("Continue")
                    }
                    ButtonState(action: .stopButtonTapped) {
                        TextState("Stop")
                    }
                } message: {
                    if isAppInBackground {
                        TextState("Recording was stopped. Do you want to continue?")
                    } else {
                        TextState("Are you sure you want to stop recording?")
                    }
                }
                return .cancel(id: CancelID.timer)
            case .alert(.presented(.stopButtonTapped)):
                return .send(.stopRecording)
            case .alert(.presented(.continueRecordingButtonTapped)):
                recordingService.resume()
                state.isRecordingPaused.toggle()
                return .send(.startTimer)
            case .alert(.presented(.cancelRecordingButtonTapped)):
                return .send(.cancelRecording)
            case .alertPermissionNotGranted:
                state.alert = AlertState {
                    TextState("")
                } actions: {
                    ButtonState(action: .cancelPermissionButtonTapped) {
                        TextState("Cancel")
                    }
                    ButtonState(action: .openSettingsTapped) {
                        TextState("Open Settings")
                    }
                } message: {
                    TextState("You don't have permission to record audio. You can change that in settings")
                }
                return .none
            case .alert(.presented(.openSettingsTapped)):
                openSettingsHelper.openSettings()
                return .send(.stopRecording)
            case .alert(.presented(.cancelPermissionButtonTapped)):
                return .none
            case .presentRecordingsListView:
                state.isRecording.toggle()
                state.destination = .recordingsList(RecordingsListReducer.State())
                return .none
            case .dismiss:
                return .run { _ in
                    await dismiss()
                }
            case .showTokenExpiredAlert:
                state.alert = AlertState {
                    TextState("Your session has expired, please Sign In again")
                } actions: {
                    ButtonState(action: .loginButtonTapped) {
                        TextState("Sign In")
                    }
                } message: {
                    TextState("")
                }
                return .none
            case .alert(.presented(.loginButtonTapped)):
                removeAuthenticationManager.resetToken()
                state.destination = .login(SinginWithAppleViewReducer.State())
                return .none
            case .alert:
                return .none
            case .binding:
                return .none
            case .cardsStack(.notifyParentAboutError):
                return .send(.showTokenExpiredAlert)
            case .cardsStack:
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
        .ifLet(\.$destination, action: \.destination)
    }
}

private extension RecordReducer {
    func getUrlToUpload() -> Effect<Action> {
        .run { send in
            do {
                let urlResponse = try await recordingSessionService.getUrlToUploadRecording(
                    recordingLength: recordingService.getAudioFileDuration())
                await send(.createNewRecording(urlResponse))
            } catch {
                await send(.failed(error))
            }
        }
    }

    func uploadRecording(to url: String) -> Effect<Action> {
        .run { send in
            do {
                try await uploadAudioFileService.uploadAudioFile(presignedURL: url)
                await send(.presentRecordingsListView)
            } catch {
                await send(.failed(error))
                AdastraLogger.network.log("\(error.localizedDescription)")
            }
        }
    }

    func handleErrorTask(_ error: Error) -> Effect<Action> {
        if let uploadError = error as? UploadNetworkError,
           let errorDescription = uploadError.errorDescription {
            return .send(.showErrorAlert(isUploadAlert: true, errorDescription))
        } else if let recordingError = error as? RecordingSessionError,
                  let errorDescription = recordingError.errorDescription {
            if recordingError == .unauthenticated || recordingError == .unauthorised {
                return .send(.showTokenExpiredAlert)
            }
            return .send(.showErrorAlert(isUploadAlert: false, errorDescription))
        } else {
            return .none
        }
    }
}
// swiftlint:enable type_body_length

