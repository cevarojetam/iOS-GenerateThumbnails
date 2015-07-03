#import <MobileCoreServices/MobileCoreServices.h>
#import "CEJEFileTypeHolder.h"

@interface CEJEFileTypeHolder ()

@property (nonatomic) CFStringRef fileUTI;

@end


@implementation CEJEFileTypeHolder {

}

- (id) initWithFilename: (NSString * const) filename
{
    self = [super init];

    const CFStringRef fileExtension = (__bridge CFStringRef) [filename pathExtension];
    self.fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);

    return self;
}

- (bool) isImage
{
    return UTTypeConformsTo(self.fileUTI, kUTTypeImage);
}

- (bool) isMovie
{
    return UTTypeConformsTo(self.fileUTI, kUTTypeMovie);
}

- (bool) isPdf
{
    return UTTypeConformsTo(self.fileUTI, kUTTypePDF);
}

- (void) releaseResources
{
    if (self.fileUTI)
    {
        CFRelease(self.fileUTI);
        self.fileUTI = NULL;
    }
}

- (void) dealloc
{
    [self releaseResources];
}

@end