# Quick Setup

 1. Upon first time Opening GDTube you should see a window with a Transparent Background and an menu bar on the left side of the window. The menu bar contains the following items from top to bottom: 
    </br>
    <img src="./Pictures/FirstTimeWindow.png" alt="image" width="500" height="auto">
    - Scene Title: Editable textbox for giving your scene a name.
    - Input device options drop down: Button will show a drop down of available input devices. 
    - Threshold: Volume Visual and Slider: Will show your threshold for activation of animation, and slider for adjusting tolerance of threshold
    - Loudness: Slider for adjusting input gain
    - \+  (Create New Screen Object): Adds new visual element to scene 
    - System Settings: Opens System Settings menu 
    - Hide Menu: Hides side bar from visibility, pressing any key in the window will make it return. 

2. Press the `+` button to create a new avatar/scene element, system default will appear automatically in the center of the screen and in the menu bar a `Screen Object Element` menu will appear. Keep pressing the + to add more to the scene. The `Screen Object Element` has the following menu options from right to left.
    </br>   
    <img src="./Pictures/ScreenObjectElementMenu.png" alt="image" width="200" height="auto"> 
    - Up and Down toggle for Scenes Z order. 
    - Element Name label for naming visual element.
    - Gear Icon: Image source configurations and options as well as color minuplation settings. 
    - Eyeball Icon: Toggle for making element visible and non-visible
    - Copy Icon: Creates new duplicate of current Screen Object Element.
    - Gizmo Icon: Allows for transform, resize and rotation of Screen Object Element. 
    - Trash: Deletes Screen Object Element.  

3. Select your microphone by clicking the `Input Device` and selecting your preferred device from the drop down menu choices 
    </br>   
    <img src="./Pictures/InputMenu.png" alt="image" width="400" height="auto"> 

4. Click the Gear Icon to open the image Screen Object Element settings pop up menu to upload your own custom avatar or images (for more information see the **[Image Setup](#image-setup)** section)
    </br>   
    <img src="./Pictures/ImageOptions.png" alt="image" width="300" height="auto"> 
5. Clicking the Gizmo Icon allows for `Screen Object Element` transformations of the image as follows: 
    - left click to move the object on screen
    - right click to rotate the object on screen
    - scroll wheel to scale the selected object on screen


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
