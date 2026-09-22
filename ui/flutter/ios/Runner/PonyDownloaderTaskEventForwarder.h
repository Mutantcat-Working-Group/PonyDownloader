#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface PonyDownloaderTaskEventForwarder : NSObject

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

FOUNDATION_EXPORT void PonyDownloaderSubscribeTaskEventsWithForwarder(
    int64_t mask,
    PonyDownloaderTaskEventForwarder * _Nullable listener);


typedef void (^PonyDownloaderNativeInvokeCompletion)(
    BOOL success,
    NSString *payload);

FOUNDATION_EXPORT void PonyDownloaderInvokeAsyncNative(
    NSString *method,
    NSString *path,
    NSString *query,
    NSString *body,
    PonyDownloaderNativeInvokeCompletion completion);

FOUNDATION_EXPORT void PonyDownloaderInvokeAsyncWithResult(
    NSString *method,
    NSString *path,
    NSString *query,
    NSString *body,
    int64_t requestID,
    FlutterResult result);

NS_ASSUME_NONNULL_END
