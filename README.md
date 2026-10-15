# notes_app

# Flutter Developer Test Task

- This application is a test task for the Middle Flutter Developer position.

## How to Run the Application

- Make sure you have Flutter installed. You can follow the [official Flutter installation guide](https://docs.flutter.dev/get-started/install).
- Clone the repository:
   ```bash
   git clone https://github.com/NersisVah/notes_app
   ```
- Navigate to the project directory:
   ```bash
   cd notes_app
   ```
- Install dependencies:
   ```bash
   flutter pub get
   ```
- Run the application on an available emulator or connected device:
   ```bash
   flutter run
   ```


# State Management

- I chose BLoC (Business Logic Component) for state management because it allows business logic to be separated from the UI, making the code more maintainable, testable, and easier to scale.

- I also use Hydrated BLoC, an extension of the BLoC library that automatically persists and restores BLoC state using local storage. This allows the application to load the relevant state between app launches.

# UX Improvements

### **Screen 01:**
- Add a missing screen, bottom sheet, or dialog that displays information about how to use the app. It will be shown when the user taps the information ( i ) button.

### **Screen 02:**
- Using colored cards with text is not the best approach because text can become unreadable on certain background colors. Instead, use colors that correspond to the app's background, add some elevation, and include a `chevron_right` icon to help users understand that the cards are tappable.

### **Buttons:**
- Use the primary color for all buttons, especially the floating action button used to add a new note.

### **Screens 05–06:**
- Choose Screen 06 instead of Screen 05. Because when users have many favorite notes, they can find their other notes by long scrolling or searching. Also, when a note is added to or removed from Favorites, its position or visibility may change, which can head to confusing UI change at that moment.

### **Screen 06:**
- The meaning of Recent is unclear because it doesn't specify whether notes were recently viewed, created, or updated. Add sorting options based on creation and update dates.

### **Swipe interaction:**
- Add a simple animation to the first note to show users that it is draggable, since they may not understand this interaction at first glance.

### **Loading state:**
- Add a loading animation for notes. Depending on the application needs, developers may use different local data holders, and notes may be loaded asynchronously, requiring a loading state.

### **Screen 07:**
- The `X` button should clear the text in the search field. Show it only when the field is not empty. Add a Back button on the left side of the search field. When the search field is empty, display all notes.

### **Screen 08:**
- Change the informational text displayed on this screen.

### **Screens 09–11:**
- Based on the eye button, introduce two modes: View Mode and Edit Mode. Create a switcher button that allows users to switch between these modes. Use the same switcher button on Screen 11 instead of the button that only indicates whether the note is a favorite.

### **Screen 14:**
- Add two icon buttons: one to delete the note and another to add or remove it from Favorites.

### **Confirmation dialog:**
- Add a confirmation dialog for deleting a note.