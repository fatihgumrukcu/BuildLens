import SwiftUI

// Type scale mirrors SF Pro's semantic hierarchy.
// Never call .font(.body) etc. directly in views — always go through these.
// Centralizing here means a single edit to change the entire app's type feel.
extension Font {
    static let appLargeTitle  = Font.largeTitle.weight(.bold)
    static let appTitle       = Font.title.weight(.semibold)
    static let appTitle2      = Font.title2.weight(.semibold)
    static let appTitle3      = Font.title3.weight(.medium)
    static let appHeadline    = Font.headline
    static let appBody        = Font.body
    static let appCallout     = Font.callout
    static let appSubheadline = Font.subheadline
    static let appFootnote    = Font.footnote.weight(.medium)
    static let appCaption     = Font.caption
    static let appMono        = Font.system(.body, design: .monospaced)
    static let appMonoSmall   = Font.system(.caption, design: .monospaced)
}
