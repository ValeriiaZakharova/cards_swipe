//
//  QuestionViewModel.swift
//  cards_swipe_
//
//  Created by Valeriia Zakharova on 25.07.2024.
//

import SwiftUI

struct QuestionViewModel: Identifiable, Equatable {
    let id: String
    let text: String
    let color: Color
    let index: Int

    init(question: Question, color: Color, index: Int) {
        self.id = question.id
        self.text = question.text
        self.color = color
        self.index = index
    }
}

struct Question: Identifiable, Equatable, Decodable {
    let id: String
    let text: String
}

struct QuestionResponse: Decodable {
    let questions: [Question]
}
