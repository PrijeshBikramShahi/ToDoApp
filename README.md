# Flutter To-Do App

A comprehensive mobile task management application built with Flutter, demonstrating modern mobile development practices with clean architecture, REST API integration, and offline-first functionality.


## ✨ Features

### Core Functionality
- **Complete CRUD Operations**: Create, read, update, and delete tasks
- **REST API Integration**: Full network communication with error handling
- **Offline-First Architecture**: Works seamlessly without internet connection
- **Real-time Synchronization**: Automatic sync between local and remote data
- **Task Statistics**: Visual progress tracking and completion analytics

### User Experience
- **Modern Material Design**: Clean, intuitive interface with dark/light themes
- **Smooth Animations**: Beautiful transitions and loading states
- **Pull-to-Refresh**: Intuitive gesture-based data refresh
- **Optimistic Updates**: Immediate UI feedback with rollback on failure
- **Contextual Notifications**: Smart error messages and success feedback

### Technical Features
- **Reactive State Management**: GetX for efficient state handling
- **Network Resilience**: Automatic retry mechanisms and offline handling
- **Clean Architecture**: MVC pattern with proper separation of concerns
- **Dependency Injection**: Modular and testable code structure

## 🏗️ Architecture

The application follows clean architecture principles with clear separation of concerns:

```
lib/
├── controllers/          # GetX controllers for state management
├── models/              # Data models and entities
├── services/            # API services and business logic
├── views/               # UI components and screens
├── widgets/             # Reusable UI components
└── bindings/            # Dependency injection setup
```

## 🛠️ Technologies Used

- **Flutter**: Cross-platform mobile development framework
- **Dart**: Programming language
- **GetX**: State management, routing, and dependency injection
- **Dio**: HTTP client for REST API communication
- **GetStorage**: Local storage for offline functionality
- **Material Design**: UI/UX design system

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Android/iOS emulator or physical device

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/flutter-todo-app.git
   cd flutter-todo-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### API Configuration

The app uses JSONPlaceholder as a demo API. To use your own API:

1. Update the `baseUrl` in `lib/services/api_service.dart`
2. Modify JSON mapping methods if your API structure differs
3. Add authentication headers in Dio interceptors if required

## 📊 Project Structure

### Key Components

- **TaskController**: Manages task state and business logic
- **ApiService**: Handles all REST API communications
- **TaskModel**: Data model for task entities
- **HomePage**: Main task list with statistics
- **AddEditTaskPage**: Form for creating/updating tasks
- **TaskCard**: Individual task display component

### State Management Flow

1. User interactions trigger controller methods
2. Controllers update reactive variables
3. UI automatically rebuilds using `Obx` widgets
4. Network requests sync with remote API
5. Local storage maintains offline functionality

## 🔧 Configuration

### Dependencies

Key dependencies used in this project:

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6
  dio: ^5.3.2
  get_storage: ^2.1.1
  flutter_spinkit: ^5.2.0
```

### API Endpoints

Current configuration uses JSONPlaceholder:

- **Base URL**: `https://jsonplaceholder.typicode.com`
- **Tasks Endpoint**: `/todos`
- **Individual Task**: `/todos/{id}`

## 📱 Screenshots

*Add your app screenshots here*

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- GetX community for the powerful state management solution
- JSONPlaceholder for providing the demo API
- Material Design for the design system

## 📞 Contact

Your Name - [@yourusername](https://twitter.com/yourusername) - your.email@example.com

Project Link: [https://github.com/yourusername/flutter-todo-app](https://github.com/yourusername/flutter-todo-app)

---

**Built with ❤️ using Flutter**