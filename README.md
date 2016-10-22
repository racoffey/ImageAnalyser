# ImageAnalyser

The Image Analyser app is an experimental app that explores the capabilites of the Google Vision API.

The app provides the possibility for a user to perform different types of analyses on an image of their selection and receive various types for information back depending on the type of analysis performed.

The intial view controller provides the user the option to select an image from their photo album or camera.  The user can also choose to see the history of their analysis results.

When an image has been selected the user is presented with the option to choose from 4 different types of analysis:

1. "General" analysis makes a general analysis of the image and provides keywords related to the image content.

2. "Face" analysis performs both general and face analyses of the image, providing keywords related to the content as well as  emotional information any faces found in the image.

3. "Landmark" returns the name, country and a Wikipedia link presented as an annotated pin on a map for any recognisable landmark found in the image.

4. "Text" returns the textual content of the image. If the language of the textual content is not English it is automatically translated to English using Google's Transation API.

The analysis results are stored and are available as a collection view. Earlier results can be updated with new analyses if wished by the user.

SETUP

App has been converted to Swift 2.3, so is compatible with Xcode8.0 and iOS10.  It can be run stand alone and does not require 3rd party components.

The Google API key has not been included as the app is not commericalised.  If needed the key can be requested from racoffey@gmail.com.
