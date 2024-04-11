# Changelog

## 2024-04-11 - v1.0.0(18)

- Integrate Firebase Analytics and Crashlytics

## 2024-04-11 - v1.0.0(17)

- iOS: Set "App Uses Non-Exempt Encryption"=NO flag for App Store Connect

## 2024-04-11 - v1.0.0(16)

- iOS: Supporting opening file via "Share to" also in iOS (works in Files and Mail, not Safari)
- Android: When opening file via "Share to", it's handled by single process Activity so that the UX
  is identical with iOS

## 2024-03-26 - v1.0.0(15)

- iOS: Saving signed documents into app specific directory with file access enabled

## 2024-03-25 - v1.0.0(14)

- iOS: Add missing NSPhotoLibraryUsageDescription for App Store Connect

## 2024-03-25 - v1.0.0(13)

- Add some horizontal padding to Autogram logo
- iOS: First iOS release; where saving to Downloads and opening by Autogram is not yet implemented!
- Sync API client with v0.3.0

## 2024-03-22 - v1.0.0(12)

- Android: Change Application Id to "digital.slovensko.avm"
- iOS: Change Bundle ID to "digital.slovensko.avm"
- Tweak displaying licenses in Settings -> About
- Signature type selection screen - don't displaying app bar when it's loading

## 2024-03-21 - v1.0.0(11)

- After document was signed, displaying success screen even if unable to save file into Downloads
  so that user can at least Share it
- Prepare Terms and Conditions web page - accessible from Setting
- iOS: Update app icon, lock screen orientation

## 2024-03-19 - v1.0.0(10)

- Tweak Autogram logo
- Update core UI elements (Buttons, Radio, AppBar, Loading indicator) based on "AVM" design system
- Storing and using previously selected signing certificate
- Appending timestamp to signed file name

## 2024-03-14 - v1.0.0(9)

- Increase font size to scale 110%
- Android: Using custom Android app icon and logo

## 2024-03-11 - v1.0.0(8)

- Saving signed document into Downloads folder

## 2024-03-11 - v1.0.0(7)

- Supporting opening any file by Autogram
- Using brand Source Sans 3 font
- Displaying license info via Settings -> About
- Tweak button theme

## 2024-03-08 - v1.0.0(6)

- Add share action into preview screen
- Increase primary button height
- Export common theme constants

## 2024-03-08 - v1.0.0(5)

- Implement screen for case when ID card have no QES certificate
- Implement option to select signature type - to add timestamp
- Fix dialog theme

## 2024-03-07 - v1.0.0(4)

- Option to specify PDF container - PAdES / XAdES / CAdES
- Allow to open .sce, .asice, .asics

## 2024-03-07 - v1.0.0(3)

- Android: Custom Android icon and name
- Implement document signing flow with success state where able to share generated file

## 2024-03-06 - v1.0.0(2)

- Fix text (TXT, HTML) visualization encoding
- Displaying QES certificates
- Implement basic document signing flow w/o custom UI

## 2024-03-06 - v1.0.0(1)

- Implement basic app skeleton with navigation and document signing flow
- Implement feature to list certificates from ID card
