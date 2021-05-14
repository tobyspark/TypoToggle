# TypoToggle
_a contemporary caps lock_

Caps Lock toggles between two modes. For my usage, the wrong modes. Switching between programming and prose, I want straight quotes or curly quotes and all the other smart typographic substitutions. A contemporary caps lock key would do that, toggling that typography on and off.

## How might this be done on macOS?

### Getting the state

The `Caps Lock` key is a special case. Its state and effect are handled at the keyboard driver level, so any upstream (e.g. CGEventTap, NSEvent) detection is moot, as the keyboard is or isn’t sending capitals already. See e.g. https://stackoverflow.com/a/3085481

macOS can assign no action to the key, however. With the keyboard driver’s _alpha shift_ functionality disabled, detecting the keypress somehow would then be useful. Again, the higher level methods fail as e.g. it no longer registers in an event’s modifier flags. However keypress events can still be detected at the USB level. e.g. Here’s a contemporary keylogger https://github.com/SkrewEverything/Swift-Keylogger

Answer: `IOKit`’s `HID` functionality, which neatly is also how you would control the Caps Lock key’s status light.

Implementation:

- `CapsLock.swift` uses an `IOHIDManager` to register for keyboard events, filters for Caps Lock key down, and when found toggles an internal state and calls a handler passed to it.
- LED reflecting that state: to do.

### Setting the state

The AppKit functionality for the typographic goodness is exposed through `Edit` → `Substitutions` → `Smart Copy/Paste`, `Smart Quotes`, ..., `Text Replacements`. These menu items are stateful, with checkmarks. These states are per-application. Sometimes the `Substitutions` submenu is nested further.

Non-AppKit apps would have to be case-by-case. Sublime Text doesn't even seem to have a smart quotes package.

Answer: nothing yet satisfactory. Most pragmatic so far: set global hotkeys in `System Preferences` and send these keystrokes on press of Caps Lock.

#### To investigate

Either there is some way of hooking into this state behind the scenes, or some kind of UI automation is required.

- Control front-most application only? Or control a white-list?
- Sublime Text: perhaps the LaTeX smart quote package could be modified to do curly quotes for Markdown documents?

Behind the scenes:

- The substitution functionality doesn’t seem to be exposed in scripting dictionaries.
- Access the settings through the AppKit preferences system, e.g. `defaults write`?

UI automation:

- The state of the menu items would have to be set (rather than toggled blindly). Manipulating menus seems fragile, with voodoo `delay` and so on.
	- https://stackoverflow.com/questions/69030/in-applescript-how-can-i-find-out-if-a-menu-item-is-selected-focused
- Global hotkeys for named menu items can be set in `System Preferences` → `Keyboard` → `Shortcuts` → `App Shortcuts`. These are fast acting and sending keystrokes is straightforward, but the action is to toggle blindly. 
	- Stored as `NSUserKeyEquivalents`
- The global hotkey system acts on the menu item name alone. Whereas scripting seems to require traversing the menu system. How does that work and/or might it be exposed anywhere, because that’s better.
