# Intention

Every morning, I write down a to-do list, along with a few themes I want
to keep in mind for the day (e.g. "be patient").

Often I'd forget my goals during the day and have to go back to my list
to check what I needed to do.

With the Intention app, you can jot down up to 6 goals for the day and
see them right on your lock or home screen, in a widget of your choice
of size.

Stay reminded of your daily Intention.

## Features

- Add, edit, and remove up to 6 goals for the day from the main app
- Check goals off directly, right from the home or lock screen widget —
  no need to open the app
- Widget adapts to the space it's given: full goal list when there's
  room, a compact view when there isn't
- Available in multiple widget sizes:
  - Home screen: medium, large
  - Lock screen: rectangular, circular, inline

## Built with

- SwiftUI
- WidgetKit
- AppIntents (for tap-to-complete directly from the widget)
- iOS 17+

## Setup

1. Clone the repo and open `Intention.xcodeproj` in Xcode
2. Select your own Team under **Signing & Capabilities** for both the
   `Intention` and `IntentionWidgetExtension` targets
3. Update the App Group identifier (`group.com.lev.Intention`) to one
   registered under your own Apple ID, on both targets, so they match
4. Build and run on a simulator or your own device (iOS 17+)

## Notes

- Built for personal use with a free Apple Developer account, so an
  install expires after 7 days and needs to be rebuilt from Xcode to
  keep working. A paid Apple Developer Program membership removes this
  limit.
