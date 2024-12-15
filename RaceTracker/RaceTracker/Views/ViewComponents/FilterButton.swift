//
//  FilterButton.swift
//  RaceTracker
//
//  Created by Ike Zeng on 14/12/2024.
//

import Foundation
import SwiftUI

/// A button for filtering races by category. It displays an icon, title, and a selection indicator.
struct FilterButton: View {

    /// A boolean whether the button is selected or not. It changes the appearance of the button.
    let isSelected: Bool

    /// The name of the system icon to display inside the button.
    let iconName: String

    /// The title of the button.
    let title: String

    /// The action to perform when the button is pressed.
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(isSelected ? .blue : .secondary)

                VStack {
                    // Icon and title
                    Image(systemName: iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(isSelected ? .primary : .secondary)
                    Text(title)
                        .font(.caption)
                        .foregroundColor(isSelected ? .primary : .secondary)
                }
                Spacer()
            }
            .padding(8)
            .frame(maxWidth: .infinity)
            .cornerRadius(8)
        }
        .accessibilityLabel(Strings.FilterButton.accessibilityFilterButtonTitle(title))
        .accessibilityHint(Strings.FilterButton.accessibilityFilterButtonHint(isSelected: isSelected))
    }
}
