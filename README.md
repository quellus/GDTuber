# GDTuber <img src="/Assets/GDTuber.png" width="48">
Made by Quellus and [Code807](https://github.com/code807)

GDTuber is a dynamic PNGTuber software made in Godot. It supports voice-reactive avatars, accessories, and a save/load system for multiple profiles. 

## Features
- Support for voice reactive on-screen objects with visual changes or movement (bouncing)
- Support for several individual on-screen objects
- Support for dynamic position, scale, and rotation of on-screen objects
- Audio threshold/sensitivity settings
- Designed for simple OBS integration using transparency or chroma key

## Instructions
1. Select your microphone from the `Input Device` drop down menu at the top.
3. Press the `+` button to create a new avatar
4. Use the `Change Image` button to set an image for the avatar/object (more information in the **Image Setup** section)
6. Use the bottom row of icons to activate the gizmo
    - left click to move the object on screen
    - right click to rotate the object on screen
    - scroll to scale the object on screen
8. Add additional avatars or accessories with the `+` button

### OBS instructions
1. Create a `Game Capture` source
2. Set `Mode` to "Capture specific window"
3. Set `Window` to the GDTuber window
4. Select `Allow Transparency` at the bottom

## Image Setup
Currently, GDTuber supports single-image avatars. If an avatar has a blinking animation, it should take up the bottom half of the image. If an avatar has a talking animation, it should take up the right half of the image. Below is an example avatar featuring both a talking and blinking animation.

<img src="/Assets/DefaultAvatar.png" width="128">

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

For any questions or additional help, feel free to open an issue or contact us on our [Discord server](https://discord.com/invite/RzaVWjPU8s).

## Attribution
[Contract icon](https://game-icons.net/1x1/delapouite/contract.html) by [Delapouite](https://delapouite.com/) under CC BY 3.0

[Cog icon](https://game-icons.net/1x1/lorc/cog.html) by [Lorc](https://lorcblog.blogspot.com/) under CC BY 3.0
