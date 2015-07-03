#import <Foundation/Foundation.h>

@interface CEJEFileTypeHolder : NSObject

/**
* @param filename
*
* initializes CFStringRef fileUTI for further usage, which is released by dealloc or by releaseResources
*/
- (id) initWithFilename: (NSString * const) filename;

/**
* releases CFStringRef fileUTI from init
*/
- (void) releaseResources;

/**
* @return true if file is a image
*/
- (bool) isImage;

/**
* @return true if file is a movie
*/
- (bool) isMovie;

/**
* @return true if file is a pdf
*/
- (bool) isPdf;

@end