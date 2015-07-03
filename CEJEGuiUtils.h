#import <Foundation/Foundation.h>

@interface CEJEGuiUtils : NSObject

/**
* @return
*   amount of points converted using [[UIScreen mainScreen] scale]
*/
+ (CGFloat)pointsToPixels: (const CGFloat) points;

/**
* @return
*    amount in pixels converted using [[UIScreen mainScreen] scale]
*/
+ (CGFloat)pixelsToPoints: (const CGFloat) pixels;

@end