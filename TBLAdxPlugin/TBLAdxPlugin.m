//
//  TBLAdxPlugin.m
//  TaboolaSDK-AdX
//
//  Created by Taboola on 17.09.2025.
//

#import "TBLAdxPlugin.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

NS_ASSUME_NONNULL_BEGIN

// Logging prefix constant
static NSString * const kTBLAdxPluginLogPrefix = @"TaboolaSDK AdX Adapter:";

/// Delegate protocol for handling external URL clicks
@protocol TBLPluginDelegate <NSObject>
- (void)handleUrl:(NSString *)urlString;
@end

@interface TBLAdxPlugin ()
@property (nonatomic, weak, nullable) id<TBLPluginDelegate> delegate;
@end

@implementation TBLAdxPlugin

- (void)registerWebView:(WKWebView *)webView {
    NSLog(@"%@ Registering WebView with Google Mobile Ads", kTBLAdxPluginLogPrefix);
    [[GADMobileAds sharedInstance] registerWebView:webView];
    NSLog(@"%@ WebView registration completed", kTBLAdxPluginLogPrefix);
}

- (WKAudiovisualMediaTypes)mediaTypesRequiringUserActionForPlayback {
    // Allow autoplay for all media types
    return WKAudiovisualMediaTypeNone;
}

- (nullable WKWebView *)webView:(WKWebView *)webView
 createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
   forNavigationAction:(WKNavigationAction *)navigationAction
        windowFeatures:(WKWindowFeatures *)windowFeatures {
    // Extract URL and domain information for click handling
    NSURL *url = navigationAction.request.URL;
    NSString *currentDomain = webView.URL.host;
    NSString *targetDomain = navigationAction.request.URL.host;

    // Determine whether to handle the click URL
    if ([self didHandleClickForURL:url
                     currentDomain:currentDomain
                      targetDomain:targetDomain
                  navigationAction:navigationAction]) {
        NSLog(@"%@ URL handled outside the webview", kTBLAdxPluginLogPrefix);
    }
    // method used only to handle the click, no need to create a new webview
    return nil;
}

#pragma mark WKNavigationDelegate
// Implemented only if extra prop TBLOpenMLUncaughtClicksInSafariCtrl = true

- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    NSString *currentDomain = webView.URL.host;
    NSString *targetDomain = navigationAction.request.URL.host;

    // Determine whether to handle the click URL.
    if ([self didHandleClickForURL: url
                     currentDomain: currentDomain
                      targetDomain: targetDomain
                  navigationAction: navigationAction]) {
        // cancel navigation, because handled outside webview
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    // proceed, click handled by webview
    decisionHandler(WKNavigationActionPolicyAllow);
}

/// Returns whether the URL has to be handled outside of WKWebView.
/// If true, click URL is handled by the SDK's logic.
- (BOOL)didHandleClickForURL:(NSURL *)url
               currentDomain:(NSString *)currentDomain
                targetDomain:(NSString *)targetDomain
            navigationAction:(WKNavigationAction *)navigationAction {
    if (!url || !currentDomain || !targetDomain) {
        return NO;
    }

    // the navigationType is a link with an href attribute
    BOOL navigationLinkActivated = navigationAction.navigationType == WKNavigationTypeLinkActivated;
    // the target of the navigation is a new window
    BOOL openInNewWindow = !navigationAction.targetFrame;
    // the current domain is not equal to the target domain (the assumption is the user is navigating away from the site)
    BOOL isTargetDomainSame = [currentDomain isEqualToString: targetDomain];

    // determine if click should be handled externally
    BOOL shouldHandleClick = (navigationLinkActivated || openInNewWindow) && !isTargetDomainSame;

    if (shouldHandleClick) {
        // pass the click control to the SDK
        NSString *urlString = [url absoluteString];
        if (self.delegate && [self.delegate respondsToSelector:@selector(handleUrl:)]) {
            NSLog(@"%@ Click delegating to SDK for URL: %@", kTBLAdxPluginLogPrefix, urlString);
            [self.delegate handleUrl:urlString];
        } else {
            NSLog(@"%@ Error: No delegate available to handle URL: %@", kTBLAdxPluginLogPrefix, urlString);
        }
    }

    return shouldHandleClick;
}

@end

NS_ASSUME_NONNULL_END
