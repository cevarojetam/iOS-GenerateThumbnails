#import <Foundation/Foundation.h>

@interface CEJEFileUtils : NSObject

/**
* @param url - of a file which name should be true on canGenerateThumbnail:
* @param pixels - size in pixels of the longest side of the thumbnail
*               - if nil, defaultThumbnailSizeInPixels() is used
*
* @result managed image result from generateThumnailForFileUrlCG:maxSizeInPixels:
*/
+ (UIImage *) generateThumnailForFileUrl: (NSURL * const) url maxSizeInPixels: (NSNumber * const) pixels;

/**
* @param url - of a file which name should be true on canGenerateThumbnail:
*
* @return
*   result of generateThumnailForFileUrlCG:maxSizeInPixels: using nil for maxSizeInPixels;
*/
+ (CGImageRef) generateThumnailForFileUrlCG: (NSURL * const) url;

/**
* @param url - of a file which name should be true on canGenerateThumbnail:
* @param pixels - size in pixels of the longest side of the thumbnail
*               - if nil, defaultThumbnailSizeInPixels() is used
*
* @return
*   CGImageRef on success that needs to be released by the caller
*   nil otherwise
*/
+ (CGImageRef) generateThumnailForFileUrlCG: (NSURL * const) url maxSizeInPixels: (NSNumber * const) pixels;

/**
* Uses CEJEFileTypeHolder for defining type of a file according to provided filename
*
* @param filename - name of a file with extension
*
* @return
*   true if the filename is for image, movie or pdf
*   false otherwise
*/
+ (bool) canGenerateThumbnail: (NSString * const) filename;

@end
