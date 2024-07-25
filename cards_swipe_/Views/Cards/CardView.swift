//
//  CardView.swift
//  cards_swipe_
//
//  Created by Valeriia Zakharova on 25.07.2024.
//

import SwiftUI

struct CardView: View {
    enum Constants {
        static let swipeThresholdPercentage: CGFloat = 0.3
    }

    let question: QuestionViewModel
    let color: Color
    let onSwipe: (_ question: QuestionViewModel) -> Void

    private var isTopCard: Bool {
        question.index == 0
    }

    @State private var offset = CGSize.zero

    var body: some View {
        ZStack {
            Rectangle()
                .fill(color)
                .cornerRadius(10)
            VStack(spacing: 5) {
                Text("Question")
                    .foregroundStyle(.white)
                    .font(.headline)
                    .padding()
                Text(isTopCard ? question.text : "")
                    .foregroundStyle(.white)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 45)
                    .padding(.bottom, 20)
                    .animation(.easeIn(duration: 0.5), value: isTopCard)
            }
        }
        .offset(x: offset.width)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { _ in
                    withAnimation {
                        swipeCard(width: offset.width, cardWidth: UIScreen.main.bounds.size.width)
                    }
                }
        )
    }

    private func swipeCard(width: CGFloat, cardWidth: CGFloat) {
        let threshold = cardWidth * Constants.swipeThresholdPercentage
        if width < -threshold {
            offset.width = -cardWidth
            onSwipe(question)
        } else {
            offset = .zero
        }
    }
}

#Preview {
    CardView(question: QuestionViewModel(question: Question(
        id: "1",
        text: "When did you feel excited and inspired while working?"),
                                         color: .black,
                                         index: 1),
             color: .black) { _ in }
}
