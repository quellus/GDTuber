# Setup

1. Select your microphone from the `Input Device` drop down menu at the top.
3. Press the `+` button to create a new avatar
4. Use the `Change Image` button to set an image for the avatar/object (more information in the **Image Setup** section)
6. Use the bottom row of icons to activate the gizmo
    - left click to move the object on screen
    - right click to rotate the object on screen
    - scroll to scale the object on screen
8. Add additional avatars or accessories with the `+` button

## Image Setup

### Single Image

You must check the Single Image to true to use single image. One image must contain the separate avatar visual states either side by side and/or on the top and bottom halves of the image. If an avatar has a blinking animation, it should take up the bottom half of the image. If an avatar has a talking animation, it should take up the right half of the image.

### Multiple Images

You must uncheck the Single Image checkbox, it will be multimage by default. For each seprate avatar visual state it would be an image.

### Pixel Art

If you have pixel art or a low res image as your avatar go under the sprite settings and image then uncheck linear filter, the linear filter makes that fuss in the pixel art.

## Setup in OBS

1. Create a Game Capture source
2. Set Mode to "Capture specific window"
3. Set Window to the GDTuber window
4. Select Allow Transparency at the bottom
