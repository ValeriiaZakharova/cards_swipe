//
//  CardSceneView.swift
//  cards_swipe_
//
//  Created by Valeriia Zakharova on 25.07.2024.
//

import SwiftUI
import ComposableArchitecture

struct CardSceneView: View {

    @Bindable var store: StoreOf<CardSceneReducer>

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                Image(store.isRecording ? .logoWhiteSmall : .logoBlack)
                    .frame(width: 38, height: 38)
                    .tint(store.isRecording ? .white : .black)
                Text("Connection")
                    .font(.medium20)
                    .foregroundColor(store.isRecording ? .white : .black)
            }
            .padding(.top, 115)
            Spacer()
            CardsStackView(
                store: store.scope(state: \.cardsStackState, action: \.cardsStack),
                isRecording: $store.isRecording)
            if store.isRecording {
                HStack {
                    Image(.microphoneGreen)
                        .padding(.trailing, 12)
                    Text(store.timeProgress.formatTime())
                        .font(.regular14)
                        .foregroundColor(.stackQuestion3)
                }
                .padding(.horizontal, 30)
                .frame(height: 72)
                .background(.stackRecord1)
                .cornerRadius(100)
            }
            Spacer()
            if !store.isRecording {
                PlayButton(isDisabled: store.isRecordButtonDisabled, action: {
                    store.send(.checkPermission)
                })
            } else {
                StopButton {
                    store.send(.pauseRecording(isAppInBackground: false))
                }
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                if store.isRecording {
                    store.send(.pauseRecording(isAppInBackground: true))
                }
            }
        }
        .onAppear {
            store.send(.checkForExistingRecordings)
        }
        .alert($store.scope(state: \.alert, action: \.alert))
        .navigationDestination(
            item: $store.scope(state: \.destination?.recordingsList, action: \.destination.recordingsList)
        ) { store in
            RecordingsListView(store: store)
        }
        .fullScreenCover(
            item: $store.scope(state: \.destination?.login, action: \.destination.login),
            onDismiss: {
                store.send(.cardsStack(.fetchQuestions))
            },
            content: { store in
                SinginWithAppleView(store: store)
            })
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity)
        .background(store.isRecording ? .black : .white)
        .toolbarRole(.editor)
        .toolbar {
            if !store.isRecording {
                if store.hasRecordings {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            store.send(.dismiss)
                        }, label: {
                            Image(.backButtonBlack)
                                .padding(.leading, 23)
                        })
                    }
                }
            } else {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        store.send(.alertCancelRecording)
                    }, label: {
                        Image(.cancelButtonWhite)
                            .padding(.trailing, 23)
                    })
                }
            }
        }
        .toolbarBackground(store.isRecording ? .blackBackground : .whiteBackground, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    RecordView(store: Store(initialState: RecordReducer.State()) {
        RecordReducer()
    })
}

