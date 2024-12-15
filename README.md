# EntainTakeHomeProject-RaceTracker
RaceTracker is an application designed to display and track horse racing, harness racing, and greyhound racing events. Users can filter events by category, view upcoming races, and refresh the data every 30 seconds. The app provides an intuitive interface to see race data, with automatic periodic refresh to keep the data up-to-date.

## Features
- **Race List Display**: Shows upcoming horse racing, harness racing, and greyhound racing events.
- **Category Filtering**: Allows users to filter races by horse racing, harness racing, or greyhound racing.
- **Automatic Refresh**: Refreshes race data every 30 seconds to keep the information up-to-date.
- **Error Handling and Alerts**: Displays error messages if race data fails to load, with the option for users to retry or cancel.
- **Accessibility Support**: Provides accessibility support, including voice prompts for interactive controls.

## Additional Details
- The race list always displays 5 events after filtering by category. However, due to the API endpoint's limitation of fetching only the next 10 races, there may be cases where the selected category has fewer than 5 races. A potential solution is to increase the fetch count in the API request until 5 races are available. This feature is not currently implemented in the app.
- To reduce frequent backend access, the app refreshes the race list every 30 seconds, and the network timeout is set to 15 seconds.

## Project Structure
- **Views**: Contains all the SwiftUI views, including the main race list view and filtering options.
- **ViewModels**: Handles the business logic for loading race data, filtering categories, and refreshing race data.
- **Models**: Defines the data structures used in the app, such as `RacesResponse` and `RaceData`.
- **Network**: Includes the API manager (`DefaultAPIManager`) for handling network requests and error handling.
- **Tests**: Unit tests for validating functionality, including the mock API manager for simulating API responses.

## Dependencies
- **SwiftUI**: For building the user interface.
- **XCTest**: For unit testing.

## How to Run
1. Clone the repository:
   ```bash
   git clone https://github.com/IkeZeng91/EntainTakeHomeProject-RaceTracker
2. Open the project in Xcode.
3. Build and run the app on a simulator or physical device.

## Testing
The app includes unit tests for the RacesListViewModel to ensure that race data loads correctly and filtering works as expected. The mock API manager is used to simulate API responses for testing purposes.

To run the tests:

Open the project in Xcode.
Go to Product -> Test or press Cmd + U to run the tests.
License
This project is licensed under the MIT License - see the LICENSE file for details.
