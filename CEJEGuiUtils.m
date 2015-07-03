#import <UIKit/UIKit.h>

#import "CEJEGuiUtils.h"

@implementation CEJEGuiUtils {

}

+ (CGFloat)pointsToPixels: (const CGFloat) points
{
    const CGFloat screenScale = [[UIScreen mainScreen] scale];
    return points * screenScale;
}

+ (CGFloat)pixelsToPoints: (const CGFloat) pixels
{
    const CGFloat screenScale = [[UIScreen mainScreen] scale];
    return pixels / screenScale;
}

@end