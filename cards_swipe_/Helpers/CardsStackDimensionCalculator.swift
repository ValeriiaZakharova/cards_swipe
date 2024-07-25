//
//  CardsStackDimensionCalculator.swift
//  cards_swipe_
//
//  Created by Valeriia Zakharova on 25.07.2024.
//

import SwiftUI
import Dependencies

struct CardsStackDimensionCalculator {
    enum Constant {
        static let screenWidth: CGFloat = UIScreen.main.bounds.size.width
        static let padding: CGFloat = 40
    }

    func getCardWidth(index: Int) -> CGFloat? {
        let cardWidth = Constant.screenWidth - (Constant.padding * 2)
        let offset: CGFloat = CGFloat(index) * (cardWidth * 0.15)
        return cardWidth - offset
    }

    func getCardOffset(index: Int) -> CGFloat {
        CGFloat(index * 20)
    }
}

extension CardsStackDimensionCalculator: DependencyKey {
    static let liveValue = CardsStackDimensionCalculator()
}

extension DependencyValues {
    var cardsStackDimensionCalculator: CardsStackDimensionCalculator {
        get { self[CardsStackDimensionCalculator.self] }
        set { self[CardsStackDimensionCalculator.self] = newValue }
    }
}
