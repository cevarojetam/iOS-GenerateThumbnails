#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#import "CEJEFileUtils.h"
#import "CEJEGuiUtils.h"
#import "CEJEFileTypeHolder.h"

// derived from +/- size of assets thumbnail size
static const CGFloat DEFAULT_THUMBNAIL_SIZE_IN_POINTS = 160.0f;

static CGFloat defaultThumbnailSizeInPixels()
{
    static const CGFloat result = [CEJEGuiUtils pointsToPixels:DEFAULT_THUMBNAIL_SIZE_IN_POINTS];
    return result;
}

@implementation CEJEFileUtils

+ (bool) canGenerateThumbnail: (NSString * const) filename
{
    const CEJEFileTypeHolder * const holder = [[CEJEFileTypeHolder alloc] initWithFilename:filename];

    const bool result =
            ([holder isImage] ||
                    [holder isMovie] ||
                    [holder isPdf]);

    return result;
}

+ (UIImage *) generateThumnailForFileUrl: (NSURL * const) url maxSizeInPixels: (NSNumber * const) pixels;
{
    const CGImageRef refImg = [self generateThumnailForFileUrlCG:url maxSizeInPixels:pixels];
    UIImage * const result = [[UIImage alloc] initWithCGImage:refImg];

    return result;
}

+ (CGImageRef) generateThumnailForFileUrlCG: (NSURL * const) url
{
    return [self generateThumnailForFileUrlCG:url maxSizeInPixels:nil];
}

+ (CGImageRef) generateThumnailForFileUrlCG: (NSURL * const) url maxSizeInPixels: (NSNumber * const) pixels
{
    CGImageRef result = NULL;

    const CEJEFileTypeHolder * const holder = [[CEJEFileTypeHolder alloc] initWithFilename:url.path];

    if ([holder isImage])
        result = [self generateThumnailForImageFileUrlCG: url maxSizeInPixels: pixels];
    else
    if ([holder isMovie])
        result = [self generateThumnailForMovieFileUrlCG:url maxSizeInPixels:pixels];
    else
    if ([holder isPdf])
        result = [self generateThumnailForPdfFileUrlCG:url maxSizeInPixels:pixels];

    return result;
}

/**
* Attempts to generate a tumbnail from the first page of the PDF.
*/
+ (CGImageRef) generateThumnailForPdfFileUrlCG: (NSURL *) url maxSizeInPixels: (NSNumber * const) pixels
{
    UIImage * result;
    const CGPDFDocumentRef pdfDocument = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);

    if (CGPDFDocumentGetNumberOfPages(pdfDocument) > 0)
    {
        const CGFloat maxSizeInPoints = pixels ?
                [CEJEGuiUtils pixelsToPoints:pixels.floatValue] :
                [CEJEGuiUtils pointsToPixels:defaultThumbnailSizeInPixels()];


        // released by document release
        const CGPDFPageRef page = CGPDFDocumentGetPage(pdfDocument, 1);
        const CGRect pageSize = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);

        const CGFloat longestSide = (pageSize.size.width > pageSize.size.height) ?
                pageSize.size.width :
                pageSize.size.height;

        const CGFloat scaleIndex = longestSide / maxSizeInPoints;

        const CGRect thumbnailDim = CGRectMake(0.0f, 0.0f,
                pageSize.size.width / scaleIndex,
                pageSize.size.height / scaleIndex);

        UIGraphicsBeginImageContext(thumbnailDim.size);
        const CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);

        /* ADJUSTMENT START */

        CGContextTranslateCTM(context, 0.0f, thumbnailDim.size.height);
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGContextSetGrayFillColor(context, 1.0f, 1.0f);
        CGContextFillRect(context, thumbnailDim);
        const CGAffineTransform pdfTransform =  CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, thumbnailDim, 0, true);
        CGContextConcatCTM(context, pdfTransform);

        /* ADJUSTMENT END */

        CGContextDrawPDFPage(context, page);

        result = UIGraphicsGetImageFromCurrentImageContext();

        UIGraphicsEndImageContext();
        CGContextRestoreGState(context);
    }

    CGPDFDocumentRelease(pdfDocument);

    return CGImageRetain(result.CGImage);
}

+ (CGImageRef)generateThumnailForMovieFileUrlCG:(NSURL *const)url maxSizeInPixels: (NSNumber * const) pixels
{
    AVAsset * const asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator * const imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];

    const CGFloat sideLengthInPixels = pixels ? pixels.floatValue : defaultThumbnailSizeInPixels();
    imageGenerator.maximumSize = CGSizeMake(sideLengthInPixels, sideLengthInPixels);

    const CMTime time = CMTimeMake(1, 1);
    const CGImageRef result = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];

    return result;
}

+ (CGImageRef) generateThumnailForImageFileUrlCG: (NSURL * const) url maxSizeInPixels: (NSNumber * const) pixels
{
    NSDictionary * const imageOptions = @{(NSString *) kCGImageSourceShouldCache : (id)kCFBooleanTrue};

    const CGImageSourceRef imageSource =
            CGImageSourceCreateWithURL((__bridge CFURLRef)url, (__bridge CFDictionaryRef) imageOptions);

    if (!imageSource)
    {
        NSLog(@"Image source is NULL.");
        return NULL;
    }

    NSMutableDictionary * const thumbnailOptions = [[NSMutableDictionary alloc] init];
    thumbnailOptions[(NSString *) kCGImageSourceCreateThumbnailWithTransform] = (id) kCFBooleanTrue;
    thumbnailOptions[(NSString *) kCGImageSourceCreateThumbnailFromImageIfAbsent] = (id) kCFBooleanTrue;

    thumbnailOptions[(NSString *) kCGImageSourceThumbnailMaxPixelSize] = pixels ?
            pixels :
            @(defaultThumbnailSizeInPixels());

    const CGImageRef result =
            CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef)((NSDictionary*)thumbnailOptions));

    CFRelease(imageSource);

    if (!result)
    {
        NSLog(@"Thumbnail image not created from image source.");
        return NULL;
    }

    return result;
}

@end
