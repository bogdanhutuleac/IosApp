# Delivery Calculator iOS

This is an iOS version of the Delivery Calculator app, designed to help delivery drivers track their deliveries and calculate earnings.

## Project Structure

The project follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Models**: Data structures representing the core entities of the application

  - `ClipboardEntry.swift`: Represents a parsed delivery receipt

- **Views**: SwiftUI views for the user interface

  - `ReportScreen.swift`: Main screen showing delivery statistics and list of entries

- **ViewModels**: Business logic and state management

  - `ReportViewModel.swift`: Manages the application state and business logic

- **Utils**: Utility classes and helpers

  - `SimpleDate.swift`: Date handling utilities
  - `TimeEntry.swift`: Time representation and formatting

- **Parsers**: Receipt parsing logic
  - `ReceiptParser.swift`: Protocol defining the interface for receipt parsers
  - `JustEats2Parser.swift`: Parser for JustEats receipts

## Features

- Parse delivery receipts from clipboard text
- Categorize deliveries as morning or evening based on time
- Track paid and unpaid orders
- View daily statistics including total deliveries and earnings
- Navigate between different dates

## Building the Project

This project is designed to be built with Xcode. To open the project:

1. Clone or download the repository
2. Open the project folder in Xcode
3. Build and run the project on a simulator or device

## Development Notes

This is a manual recreation of the project structure for development on non-macOS platforms. To properly build and run the app, you'll need to:

1. Transfer these files to a Mac with Xcode
2. Create a new SwiftUI project in Xcode
3. Copy these files into the appropriate locations in the Xcode project
4. Add any required dependencies and configurations

## Requirements

- iOS 14.0+
- Xcode 12.0+
- Swift 5.3+
