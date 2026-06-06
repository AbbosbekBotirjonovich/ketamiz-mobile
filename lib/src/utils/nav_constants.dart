// Height of the floating nav bar content (balance row ~60px + divider 1px + tabs row ~80px).
const double kNavBarHeight = 148.0;
// Gap between nav bar bottom edge and screen bottom edge.
const double kNavBarBottomMargin = 12.0;
// Extra breathing room above the nav bar for fixed buttons and content.
const double kNavBarGap = 16.0;
// Safe scroll-content bottom padding — covers nav bar height + margin + gap on all devices
// (adds enough headroom for iOS safe area without needing MediaQuery in const contexts).
const double kNavBarTotalPadding = 220.0;
