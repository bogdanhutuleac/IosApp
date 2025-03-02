# Delivery Calculator iOS

This is an iOS version of the Delivery Calculator app, designed to help delivery drivers track their deliveries and calculate earnings. The app provides a simple interface for parsing delivery receipts and calculating daily statistics.

## Project Structure

The project follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Models**: Data structures representing the core entities of the application

  - `ClipboardEntry.swift`: Represents a parsed delivery receipt

- **Views**: SwiftUI views for the user interface

  - `ReportScreen.swift`: Main screen showing delivery statistics and list of entries
  - `ContentView.swift`: Root view that sets up the environment

- **ViewModels**: Business logic and state management

  - `ReportViewModel.swift`: Manages the application state and business logic

- **Utils**: Utility classes and helpers

  - `SimpleDate.swift`: Date handling utilities for consistent date representation
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
- Detailed breakdown of morning and evening deliveries
- Support for multiple receipt formats

## Building the Project

This project is designed to be built with Xcode. To open the project:

1. Clone or download the repository
2. Open the project folder in Xcode
3. Build and run the project on a simulator or device

### Setting up in Xcode

1. Create a new SwiftUI App project in Xcode
2. Make sure to set the minimum deployment target to iOS 14.0+
3. Ensure the main app file (`DeliveryCalculatoriOSApp.swift`) has the `@main` attribute
4. Copy all the files from this repository into their respective folders in your Xcode project
5. No third-party dependencies are required - the app uses only native iOS frameworks:
   - SwiftUI for the user interface
   - Foundation for basic functionality
   - Combine for reactive programming

## Recent Updates

- Fixed Date optional binding issues in ReportViewModel and ReportScreen
- Improved clipboard monitoring for better receipt detection
- Enhanced UI for better readability and user experience

## Development Notes

This is a manual recreation of the project structure for development on non-macOS platforms. To properly build and run the app, you'll need to:

1. Transfer these files to a Mac with Xcode
2. Create a new SwiftUI project in Xcode
3. Copy these files into the appropriate locations in the Xcode project
4. Add any required configurations

## Requirements

- iOS 14.0+
- Xcode 12.0+
- Swift 5.3+

## Receipt Format Examples

The app currently supports parsing JustEats receipts in the following format:

```
Delivery 133803766

JustEats

Due: 2025-02-26 21:50

Delivery Station 2

Qty

1

1

Item

Price

Taco Chips

€7.99

Doner Kebab

€8.99

- Extra Meat

€2.00

Order Price

€18.98

Service Charges

€0.99

Delivery Charges

€3.90

Net Price

€23.87

Paid Amount

€23.87

Outstanding

€0.00

Customer Details

Monika Warchala

01 483 2993 (masking

code) 303844006

84 Weston Park Dublin 14 Dublin 14 D14 WD28

Order Paid

Additional receipt formats can be supported by implementing new parser classes that conform to the `ReceiptParser` protocol.
```

```SAN MARINO

Dundrum

Placed: 20.02.2025, 17:31:26

Accepted: 20.02.2025, 17:31:40

11 Grange Wood

Rathfarnha

+353879188373

1x Chicken Burger Chips and Sauce

: 8.50.

Mayonaise

1x 12" Margherita & Drink Fanta (can)

€ 10.70

1x Garlic Chips & Cheese

€ 6.40

1x Chicken Wings

6.90

1x 4 Chicken Tenders

€ 4.50

1x Sausage Meal Diet Coke (Can)

€ 9.00

1x Oreo Milkshake

€ 4.20

1x Vanila Milkshake

€ 3.90

2x Cans

€ 4.00

Type: Diet Coke

Subtotal:

€ 58.10

Delivery:

€ 3.00

Total:

€ 61.10

Payment: Paid

Signed By
```
