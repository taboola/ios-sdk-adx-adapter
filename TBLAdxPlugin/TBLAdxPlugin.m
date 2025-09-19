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
@property (nonatomic, strong) NSMapTable<WKWebView *, id<TBLPluginDelegate>> *delegates; // weak→weak
@end

@implementation TBLAdxPlugin

- (instancetype)init {
    if ((self = [super init])) {
        _delegates = [NSMapTable weakToWeakObjectsMapTable];
    }
    return self;
}

#pragma mark - Handling delegates

/// Set or clear delegate for a specific webView (weakly stored)
- (void)setDelegate:(nullable id<TBLPluginDelegate>)delegate
         forWebView:(WKWebView *)webView {
    if (!webView)
        return;
    if (delegate) {
        [self.delegates setObject:delegate forKey:webView];
    } else {
        [self.delegates removeObjectForKey:webView];
    }
}

/// Get delegate for given webview
- (nullable id<TBLPluginDelegate>)delegateForWebView:(WKWebView *)webView {
    return [self.delegates objectForKey:webView];
}

#pragma mark - Public methods

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
                         inWebView:webView
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

/// Returns whether the URL has to be handled outside of WKWebView. If true, click URL
/// is opened in SFSafariViewController by webViewManager's logic.
- (BOOL)didHandleClickForURL:(NSURL *)url
                   inWebView:(WKWebView *)webView
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
        // use delegate specifically for this webview
        id<TBLPluginDelegate> delegate = [self delegateForWebView:webView];
        if (delegate && [delegate respondsToSelector:@selector(handleUrl:)]) {
            NSLog(@"%@ Click delegating to SDK for URL: %@", kTBLAdxPluginLogPrefix, urlString);
            [delegate handleUrl:urlString];
        } else {
            NSLog(@"%@ Error: No delegate available to handle URL: %@", kTBLAdxPluginLogPrefix, urlString);
        }
    }

    return shouldHandleClick;
}

@end

NS_ASSUME_NONNULL_END
