#import "ESBlocksRuntimeInitializer.h"

#import <UIKit/UIDevice.h>

#import "Block_private.h"

#include <objc/runtime.h>

// see doc - http://clang.llvm.org/docs/Block-ABI-Apple.txt

extern void *_NSConcreteGlobalBlock[32];//_ESGlobalBlock
extern void *_NSConcreteStackBlock[32];//_ESStackBlock
extern void *_NSConcreteMallocBlock[32];//_ESMallocBlock
extern void *_NSConcreteWeakBlockVariable[32];//_ESWeakBlockVariable

extern BOOL has_native_blocks_runtime_;

typedef void (*retain)(const void *);

@implementation ESBlocksRuntimeInitializer

+(void)load
{
   NSAutoreleasePool* pool_ = [ [ NSAutoreleasePool alloc ] init ];

   float ios_version_ = [ [ [ UIDevice currentDevice ] systemVersion ] floatValue ];
   if ( ios_version_ >= 4.f )
      has_native_blocks_runtime_ = YES;

   _Block_use_RR( (retain)&CFRetain, &CFRelease );

   Class class_ = objc_getClass( "_ESGlobalBlock" );
   memmove( _NSConcreteGlobalBlock, class_, sizeof( _NSConcreteGlobalBlock ) );
   class_ = objc_getClass( "_ESStackBlock" );
   memmove( _NSConcreteStackBlock, class_, sizeof( _NSConcreteStackBlock ) );
   class_ = objc_getClass( "_ESMallocBlock" );
   memmove( _NSConcreteMallocBlock, class_, sizeof( _NSConcreteMallocBlock ) );
   class_ = objc_getClass( "_ESWeakBlockVariable" );
   memmove( _NSConcreteWeakBlockVariable, class_, sizeof( _NSConcreteWeakBlockVariable ) );

   //_NSConcreteFinalizingBlock
   //_NSConcreteAutoBlock
   [ pool_ release ];
}

@end
