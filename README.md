# Safety Inspection App 🔒📱

[![Flutter](https://img.shields.io/badge/Flutter-3.13-blue)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-9.23-orange)](https://firebase.google.com)
[![Hive](https://img.shields.io/badge/Hive-2.2-lightgrey)](https://pub.dev/packages/hive)

A Flutter application designed to streamline safety inspections and form submissions with customizable and dynamic templates and offline capability.

## Features ✨
- ✅ **Custom Template Creation**  
- 📋 Multiple field types: text, checkboxes, dropdowns, radio buttons, date pickers  
- 📁 **Predefined Templates** for common safety inspections  
- 📴 **Offline Functionality** with automatic sync  
- 🕰️ **Submission History** with easy access  
- ✏️ **Form Editing** capabilities  
- ☁️ **Cloud Synchronization** with Firebase Firestore  

## Tech Stack 🛠️
| Component              | Technology       |
|------------------------|------------------|
| Cross-platform UI      | Flutter          |
| Local Storage          | Hive             |
| Cloud Database         | Firebase Firestore |
| Network Detection      | Connectivity Plus|

## Project Structure 📂

```
assets/predefined_template.json
|
lib/
├── models/
│   ├── template_model.dart
│   └── form_submission_model.dart
├── services/
│   ├── storage_service.dart
│   └── sync_service.dart
├── views/
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── create_template_screen.dart
│   │   └── fill_form_screen.dart
│   └── widgets/
│       ├── template_card.dart
│       ├── submission_card.dart
│       ├── dynamic_form.dart
│       └── field_editor.dart
└── main.dart
```

## Future Enhancements 🔮
- 🔐 User authentication
- 📸 Image attachments
- 📊 Advanced analytics
- 🗺️ GPS location tagging
- 📄 PDF export
