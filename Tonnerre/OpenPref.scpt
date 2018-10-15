tell application "System Preferences"
      set securityPane to pane id "com.apple.preference.security"
      tell securityPane to reveal anchor "Privacy_Accessibility"
      activate
end tell
