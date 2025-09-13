# BantayBaha Mobile Application

## Project Overview

**BantayBaha** is a comprehensive flood monitoring and disaster management mobile application designed specifically for the City of Bogo, Cebu, Philippines. The application serves as a critical tool for residents to monitor real-time flood conditions, access emergency services, and navigate to safe evacuation centers during flood emergencies.

### Project Information
- **Project Name**: BantayBaha Mobile Application
- **Target Location**: Bogo City, Cebu, Philippines
- **Platform**: Cross-platform (Android, iOS, Web)
- **Framework**: Flutter
- **Backend**: Firebase (Firestore, Realtime Database, Storage)
- **Version**: 1.0.0+1

## Table of Contents
1. [Features](#features)
2. [System Architecture](#system-architecture)
3. [Technical Implementation](#technical-implementation)
4. [Installation & Setup](#installation--setup)
5. [Usage Guide](#usage-guide)
6. [API Integration](#api-integration)
7. [Database Structure](#database-structure)
8. [Security & Privacy](#security--privacy)
9. [Testing](#testing)
10. [Future Enhancements](#future-enhancements)
11. [Contributors](#contributors)

## Features

### Core Functionalities

#### 1. Real-Time Flood Monitoring
- **Live Sensor Data**: Displays real-time water level, precipitation, and water pressure readings from IoT sensors deployed across Bogo City
- **Status Indicators**: Color-coded status system (LOW/MEDIUM/HIGH) for quick flood risk assessment
- **Nearest Sensor Detection**: Automatically identifies and displays the closest sensor to user's location
- **Flood Alerts**: Push notifications for critical flood conditions

#### 2. Weather Integration
- **Current Weather**: Real-time weather data for Bogo City using OpenWeatherMap API
- **7-Day Forecast**: Extended weather predictions with rainfall probability
- **Weather Alerts**: Integration with meteorological data for early warning systems

#### 3. Emergency Services
- **Emergency Hotlines**: Quick access to critical emergency contacts including:
  - CBDRRMO (City of Bogo Disaster Risk Reduction)
  - Command Center
  - Police Department
  - Fire Department
- **One-Tap Calling**: Direct phone call functionality for emergency numbers
- **Emergency Information**: Comprehensive contact details with multiple communication channels

#### 4. Evacuation Management
- **Evacuation Centers Database**: Complete list of designated evacuation centers in Bogo City
- **Interactive Maps**: Real-time mapping with evacuation center locations
- **Route Navigation**: Turn-by-turn directions to nearest evacuation centers
- **Distance Calculation**: Automatic distance and travel time estimation
- **Evacuation Guidelines**: Safety precautions and preparation checklists

#### 5. Location Services
- **GPS Integration**: Precise location tracking for personalized services
- **Permission Management**: Secure location permission handling
- **Distance Calculations**: Haversine formula implementation for accurate distance measurements
- **Location-Based Alerts**: Contextual notifications based on user proximity to flood zones

#### 6. User Authentication
- **Phone Number Verification**: Secure OTP-based authentication system
- **User Session Management**: Persistent login sessions
- **Privacy Protection**: Minimal data collection with user consent

## System Architecture

### Frontend Architecture
```
lib/
├── main.dart                 # Application entry point
├── login_page.dart          # Authentication interface
├── firebase_options.dart    # Firebase configuration
├── components/              # UI Components
│   ├── home_page.dart       # Main dashboard
│   ├── sensor_details_page.dart
│   ├── emergency_hotlines_modal.dart
│   ├── evacuation_centers_modal.dart
│   ├── evacuation_route_map.dart
│   ├── location_permission_widget.dart
│   ├── sensor_card.dart
│   └── weather_forecast_card.dart
└── services/                # Business Logic
    ├── location_service.dart
    └── routing_service.dart
```

### Backend Architecture
- **Firebase Realtime Database**: Real-time sensor data and evacuation center information
- **Firebase Storage**: Image storage for evacuation centers
- **OpenWeatherMap API**: Weather data integration
- **OSRM Routing API**: Navigation and route calculation

## Technical Implementation

### Dependencies
```yaml
dependencies:
  flutter: sdk
  cupertino_icons: ^1.0.8
  google_fonts: ^6.2.1
  cloud_firestore: ^4.15.8
  firebase_core: ^2.32.0
  firebase_database: ^10.5.7
  firebase_storage: ^11.7.7
  http: ^1.1.0
  url_launcher: ^6.2.5
  flutter_map: ^6.1.0
  latlong2: ^0.9.0
  geolocator: ^10.1.1
```

### Key Technical Features

#### 1. Real-Time Data Synchronization
- **Firebase Realtime Database**: Continuous data streaming for sensor readings
- **State Management**: Reactive UI updates based on data changes
- **Error Handling**: Robust error management for network connectivity issues

#### 2. Map Integration
- **Flutter Map**: OpenStreetMap integration for navigation
- **Custom Markers**: User location and destination markers
- **Route Visualization**: Polyline rendering for navigation paths
- **Interactive Controls**: Zoom, pan, and location tracking

#### 3. Location Services
- **Geolocator Package**: High-accuracy GPS positioning
- **Permission Management**: Runtime permission requests
- **Distance Calculations**: Haversine formula for precise measurements
- **Location Updates**: Continuous location tracking for navigation

#### 4. UI/UX Design
- **Material Design**: Modern, intuitive interface
- **Responsive Layout**: Adaptive design for various screen sizes
- **Color-Coded Status**: Visual indicators for flood risk levels
- **Accessibility**: Screen reader support and high contrast options

## Installation & Setup

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Firebase project setup
- OpenWeatherMap API key

### Installation Steps

1. **Clone the Repository**
   ```bash
   git clone [repository-url]
   cd BantayBaha-Mobile-Application-v8
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - Create a Firebase project
   - Enable Realtime Database, Firestore, and Storage
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place configuration files in appropriate directories

4. **API Configuration**
   - Obtain OpenWeatherMap API key
   - Update API key in `lib/components/home_page.dart` (line 591)

5. **Run the Application**
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### Android
- Minimum SDK: 21
- Target SDK: 34
- Permissions: Location, Internet, Phone

#### iOS
- Minimum iOS: 11.0
- Permissions: Location When In Use, Phone

## Usage Guide

### Initial Setup
1. **Launch Application**: Open BantayBaha app
2. **Phone Verification**: Enter phone number and verify with OTP (use 123456 for testing)
3. **Location Permission**: Grant location access for personalized services

### Main Features Usage

#### Monitoring Flood Conditions
1. **Dashboard View**: Check real-time sensor readings on home screen
2. **Sensor Details**: Tap on sensor cards for detailed information
3. **Status Indicators**: Monitor color-coded flood risk levels
4. **Weather Information**: View current conditions and 7-day forecast

#### Emergency Response
1. **Emergency Hotlines**: Access via bottom navigation
2. **Direct Calling**: Tap phone numbers to initiate calls
3. **Evacuation Centers**: View available evacuation centers
4. **Route Navigation**: Get turn-by-turn directions to safety

#### Location-Based Services
1. **Nearest Sensor**: Automatically displays closest sensor to your location
2. **Evacuation Routes**: Personalized navigation to nearest evacuation centers
3. **Distance Information**: Real-time distance and travel time calculations

## API Integration

### OpenWeatherMap API
- **Endpoint**: `https://api.openweathermap.org/data/2.5/weather`
- **Parameters**: Latitude, Longitude, API Key
- **Data Retrieved**: Temperature, humidity, rainfall, weather conditions
- **Update Frequency**: Real-time with manual refresh capability

### OSRM Routing API
- **Endpoint**: `https://router.project-osrm.org/route/v1/driving`
- **Parameters**: Start coordinates, destination coordinates
- **Data Retrieved**: Route geometry, distance, duration, turn-by-turn instructions
- **Usage**: Navigation to evacuation centers

### Firebase APIs
- **Realtime Database**: Sensor data, evacuation center information
- **Storage**: Evacuation center images
- **Authentication**: User session management

## Database Structure

### Firebase Realtime Database Schema

#### Sensors Collection
```json
{
  "sensors": {
    "sensor_id": {
      "sensorLocation": "Location Name",
      "sensorlat": 11.0519,
      "sensorlong": 124.0043,
      "waterlevel": 1.5,
      "rainprecipitation": 25.0,
      "waterpressure": 101.3,
      "status": "MEDIUM"
    }
  }
}
```

#### Evacuation Centers Collection
```json
{
  "evacuationCenter": {
    "center_id": {
      "location": "Center Name",
      "lat": 11.0519,
      "long": 124.0043,
      "imageUrl": "gs://bucket/path/image.jpg",
      "date": "2024-01-01"
    }
  }
}
```

## Security & Privacy

### Data Protection
- **Minimal Data Collection**: Only essential location and phone number data
- **Secure Authentication**: OTP-based verification system
- **Firebase Security Rules**: Database access control
- **API Key Protection**: Secure storage of sensitive credentials

### Privacy Compliance
- **Location Permissions**: Explicit user consent for location access
- **Data Retention**: Temporary storage with automatic cleanup
- **User Control**: Option to disable location services
- **Transparent Usage**: Clear indication of data usage purposes

## Testing

### Test Coverage
- **Unit Tests**: Core business logic testing
- **Widget Tests**: UI component testing
- **Integration Tests**: End-to-end functionality testing
- **Manual Testing**: User experience validation

### Test Scenarios
1. **Authentication Flow**: Phone verification and login
2. **Location Services**: GPS accuracy and permission handling
3. **Real-Time Data**: Sensor data synchronization
4. **Navigation**: Route calculation and map rendering
5. **Emergency Features**: Hotline access and evacuation guidance

## Future Enhancements

### Planned Features
1. **Push Notifications**: Real-time flood alerts and emergency notifications
2. **Offline Mode**: Basic functionality without internet connection
3. **Multi-Language Support**: Cebuano and English language options
4. **Community Reports**: User-generated flood reports and photos
5. **Historical Data**: Flood history and trend analysis
6. **Social Integration**: Community alerts and information sharing

### Technical Improvements
1. **Performance Optimization**: Reduced battery consumption and faster loading
2. **Enhanced Security**: Biometric authentication and encrypted data storage
3. **Advanced Analytics**: Flood prediction algorithms and risk assessment
4. **IoT Integration**: Direct sensor communication and control
5. **Machine Learning**: Predictive flood modeling and early warning systems

## Contributors

### Development Team
- **Project Lead**: [Your Name]
- **Backend Development**: Firebase integration and API management
- **Frontend Development**: Flutter UI/UX implementation
- **Testing & QA**: Application testing and quality assurance

### Acknowledgments
- **City Government of Bogo**: Project support and data provision
- **CBDRRMO**: Emergency services integration and validation
- **OpenWeatherMap**: Weather data API services
- **Firebase**: Backend infrastructure and real-time database services

---

## Academic Context

This project represents a comprehensive study in mobile application development for disaster management, focusing on the integration of real-time data, location services, and emergency response systems. The application demonstrates practical implementation of modern mobile development frameworks, cloud services, and user-centered design principles in addressing real-world challenges faced by communities in flood-prone areas.

The BantayBaha application serves as both a functional tool for the residents of Bogo City and a case study in developing technology solutions for disaster preparedness and response in developing regions.

---

**Note**: This application is developed for academic and research purposes as part of a study project on mobile application development for disaster management systems.
