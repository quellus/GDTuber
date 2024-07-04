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

## Road map
The original intention of this project is to be able to integrate with Twitch Rewards. For the [QuellusDev](twitch.tv/quellusdev) livestream. We wanted a way to be able to add and remove accessories to on avatars, change the size of our avatars, and change their color automatically based on reward redeems from viewers.

We intend for this project to be configurable and modular for anyone to use.

Our priorities
1. Add the ability to adjust avatar size and position in the program.
2. Add the ability to save avatar image, microphone threshold, and avatar position and size so it doesn't have to be adjusted every time the program is run.
3. Add the reward redeems listed above.
