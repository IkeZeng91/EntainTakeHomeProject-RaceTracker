//
//  ContentView.swift
//  RaceTracker
//
//  Created by Ike Zeng on 14/12/2024.
//

import SwiftUI

/// RacesListView is the main view that displays a list of races with filtering options and loading state.
struct RacesListView: View {

    /// The view model that handles the data and logic for the races list.
    @StateObject private var viewModel = RacesListViewModel(apiManager: DefaultAPIManager())

    /// A boolean to control whether to show the alert.
    @State private var showingAlert = false

    var body: some View {
        NavigationView {
            VStack {
                topFilterView
                if viewModel.isLoading {
                    Spacer()
                    ProgressView(Strings.RacesListView.loadingMessage)
                        .progressViewStyle(CircularProgressViewStyle())
                        .accessibilityLabel(Strings.RacesListView.accessibilityLoadingRaces)
                        .accessibilityValue(Strings.RacesListView.loadingMessage)
                    Spacer()
                } else {
                    racesList
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .background(Color(UIColor.systemBackground))
            .navigationTitle(Strings.RacesListView.title)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Load races data when the view appears and start the refresh timer.
                Task {
                    await viewModel.loadRacesData(categoryIDs: Array(viewModel.selectedCategories))
                    viewModel.startRefreshTimer()
                }
            }
            .onDisappear {
                // Stop the refresh timer when the view disappears.
                viewModel.stopRefreshTimer()
            }
            .onChange(of: viewModel.errorMessage) { errorMessage in
                if let errorMessage = errorMessage, !errorMessage.isEmpty {
                    if !showingAlert {
                            showingAlert = true
                        }
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text(Strings.RacesListView.errorTitle),
                    message: Text(viewModel.errorMessage ?? Strings.RacesListView.unknownError),
                    primaryButton: .destructive(Text(Strings.RacesListView.errorRetryButton)) {
                        Task {
                            viewModel.errorMessage = nil
                            await viewModel.loadRacesData(categoryIDs: Array(viewModel.selectedCategories))
                        }
                    },
                    secondaryButton: .cancel(Text(Strings.RacesListView.errorCancelButton))
                )
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Refresh button
                    Button(action: {
                        Task {
                            await viewModel.loadRacesData(categoryIDs: Array(viewModel.selectedCategories))
                        }
                    }, label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.primary)
                            .accessibilityLabel(Strings.RacesListView.accessibilityRefreshButton)
                            .accessibilityHint(Strings.RacesListView.accessibilityRefreshButtonHint)
                    })
                }
            }
        }
    }

    // MARK: - Subviews

    /// The top filter view that contains filter buttons for selecting race categories.
    private var topFilterView: some View {
        HStack {
            FilterButton(
                isSelected: viewModel.selectedCategories.contains(RaceCategories.horseRacing),
                iconName: "hare.fill",
                title: Strings.RacesListView.filterButtonHorseRacing
            ) {
                Task {
                    await viewModel.toggleCategory(RaceCategories.horseRacing)
                }
            }
            .accessibilityLabel(Strings.RacesListView.accessibilityHorseRacingFilter)

            FilterButton(
                isSelected: viewModel.selectedCategories.contains(RaceCategories.harnessRacing),
                iconName: "car.2",
                title: Strings.RacesListView.filterButtonHarnessRacing
            ) {
                Task {
                    await viewModel.toggleCategory(RaceCategories.harnessRacing)
                }
            }
            .accessibilityLabel(Strings.RacesListView.accessibilityHarnessRacingFilter)

            FilterButton(
                isSelected: viewModel.selectedCategories.contains(RaceCategories.greyhoundRacing),
                iconName: "dog.fill",
                title: Strings.RacesListView.filterButtonGreyhoundRacing
            ) {
                Task {
                    await viewModel.toggleCategory(RaceCategories.greyhoundRacing)
                }
            }
            .accessibilityLabel(Strings.RacesListView.accessibilityGreyhoundRacingFilter)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 8)
        .padding(.leading, 16)
    }

    /// The list view that displays the race details.
    private var racesList: some View {
        List(viewModel.races, id: \.raceID) { race in
            RaceDetailsRow(race: race)
        }
        .listStyle(PlainListStyle())
    }
}

#Preview {
    RacesListView()
}
