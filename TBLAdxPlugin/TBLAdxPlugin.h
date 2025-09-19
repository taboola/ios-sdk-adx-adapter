//
//  TBLAdxPlugin.h
//  TaboolaSDK-AdX
//
//  Created by Taboola on 17.09.2025.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

/// TBLAdxPlugin - A plugin for integrating Taboola SDK with Google AdX
@interface TBLAdxPlugin : NSObject <WKUIDelegate, WKNavigationDelegate>

/// Registers a WebView with Google Mobile Ads for AdX integration
/// @param webView The WKWebView instance to register
- (void)registerWebView:(WKWebView *)webView;

/// Specifies which media types require user action for playback
/// return WKAudiovisualMediaTypeNone to allow autoplay
- (WKAudiovisualMediaTypes)mediaTypesRequiringUserActionForPlayback;

@end

NS_ASSUME_NONNULL_END
