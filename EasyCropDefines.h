//
//  EasyCropDefines.h
//  Pods
//
//  Created by Leo Ni on 1/31/18.
//

#ifndef EasyCropDefines_h
#define EasyCropDefines_h

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif

#endif /* EasyCropDefines_h */
