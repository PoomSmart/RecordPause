#import "../../PS.h"
#import <dlfcn.h>
#import "../Common.h"

%ctor {
    if (isiOS9Up)
        dlopen("/Library/MobileSubstrate/DynamicLibraries/RecordPause/RecordPauseiOS910.dylib", RTLD_LAZY);
    else
        dlopen("/Library/MobileSubstrate/DynamicLibraries/RecordPause/RecordPauseiOS8.dylib", RTLD_LAZY);
}
