Made by Quellus and [Code807](https://github.com/code807)

A dynamic PNG Tuber software. It will be highly configurable to fit anyone's avatar needs as well as connect to Twitch API to react to reward redeems or chat commands.

## Current state
GDTuber supports uploading your own sprite sheet for your avatar, choosing the microphone, and adjusting the threshold to ensure your model reacts at the correctly to your voice.

GDTuber opens in a transparent full screen window with no visible UIs to make it as easy to integrate with OBS as possible.

## Instructions
1. When GDTuber opens, press any key to open the settings menu.
From here, you can:
    1. Select your microphone from the `Input Device` drop down menu.
    2. Adjust the slider to change your microphone's threshold.
    3. Press `Change Texture` to upload your own avatar's sprite sheet.
2. Press `Close` to hide the menu. You can open the menu again at any time by focusing the window and pressing any key
3. **To setup OBS**
    1. Create a `Game Capture` source
    2. Set `Mode` to "Capture specific window"
    3. Set `Window` to the GDTuber window
    4. Select `Allow Transparency` at the bottom

---

## Road map
The original intention of this project is to be able to integrate with Twitch Rewards. For the [QuellusDev](twitch.tv/quellusdev) livestream. We wanted a way to be able to add and remove accessories to on avatars, change the size of our avatars, and change their color automatically based on reward redeems from viewers.

We intend for this project to be configurable and modular for anyone to use.

Our priorities
1. Add the ability to adjust avatar size and position in the program.
2. Add the ability to save avatar image, microphone threshold, and avatar position and size so it doesn't have to be adjusted every time the program is run.
3. Add the reward redeems listed above.

---

## Contributing

Thank you for considering contributing to our project! We appreciate your interest and support. To make the process as smooth as possible, please follow the guidelines below.

### Prerequisites

- Ensure you have Godot version **4.2.2** installed. You can download it from the [official Godot website](https://godotengine.org/download).

### Getting Started

1. **Fork the repository**: Click the 'Fork' button at the top right corner of the repository page.
2. **Clone your forked repository**: 
    ```sh
    git clone https://github.com/quellus/GDTuber.git
    ```
3. **Navigate to the project directory**:
    ```sh
    cd REPO_NAME
    ```
4. **Create a new branch** for your feature or bugfix:
    ```sh
    git checkout -b feature-or-bugfix-name
    ```

### Making Changes

1. Open the project in Godot (version 4.2.2).
2. Make your changes or additions in the Godot editor.
3. Test your changes thoroughly to ensure they work as expected.

### Committing Your Changes

1. **Add your changes**:
    ```sh
    git add .
    ```
2. **Commit your changes** with a descriptive commit message:
    ```sh
    git commit -m "Description of changes"
    ```

### Pushing Your Changes

1. **Push to your forked repository**:
    ```sh
    git push origin feature-or-bugfix-name
    ```
2. **Create a Pull Request**:
    - Go to the [GDTuber repository](https://github.com/quellus/GDTuber).
    - Click on the 'Pull requests' tab.
    - Click the 'New pull request' button.
    - Select the branch you pushed your changes to in your forked repository.
    - Click 'Create pull request' and fill out the required information.


### Code Review

Your pull request will be reviewed by one of our team members. We may ask for changes or clarifications. Please be responsive and address any feedback as soon as possible.

### Additional Notes

- Adhere to the existing code style and conventions.
- Write clear, concise commit messages.
- Include comments and documentation as necessary.
- Ensure your changes do not break existing functionality.

### Community Guidelines

- Be respectful and considerate of others.
- Provide constructive feedback.
- Keep discussions focused and on topic.

Thank you for your contributions!

For any questions or additional help, feel free to open an issue or contact the maintainers.
