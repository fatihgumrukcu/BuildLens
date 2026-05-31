import CoreGraphics

// 4pt base grid. Every padding, gap, and radius comes from here.
// Adding new values is fine; improvising raw CGFloat literals in views is not.
enum AppSpacing {
    static let xxs:  CGFloat =  4
    static let xs:   CGFloat =  8
    static let sm:   CGFloat = 12
    static let md:   CGFloat = 16
    static let lg:   CGFloat = 20
    static let xl:   CGFloat = 24
    static let xxl:  CGFloat = 32
    static let xxxl: CGFloat = 48

    // Structural
    static let sidebarMinWidth:  CGFloat = 210
    static let contentPadding:   CGFloat = 28
    static let cardCornerRadius: CGFloat = 12
    static let cardPadding:      CGFloat = 14
}
