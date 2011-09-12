#import <Foundation/Foundation.h>

#include <objc/runtime.h>

typedef void (^EnumerateDictionaryObjectsAndKeys) ( id key_, id obj_, BOOL* stop_ );

@interface ESDictionaryBlockWorkarounds : NSObject

+(void)addMethodIfNeedWithSelector:( SEL )selector_
                           toClass:( Class )class_;

@end

@implementation ESDictionaryBlockWorkarounds

+(void)addMethodIfNeedWithSelector:( SEL )selector_
                           toClass:( Class )class_
{
   if ( ![ class_ instancesRespondToSelector: selector_ ] )
   {
      Method prototype_method_ = class_getInstanceMethod( self, selector_ );
      const char* type_encoding_ = method_getTypeEncoding( prototype_method_ );
      BOOL result_ = class_addMethod( class_
                                     , selector_
                                     , method_getImplementation( prototype_method_ )
                                     , type_encoding_ );
      NSAssert( result_, @"should be added" );
   }
}

-(NSUInteger)countByEnumeratingWithState:( NSFastEnumerationState* )state_ objects:( id* )stackbuf_ count:( NSUInteger )len_
{
   [ self doesNotRecognizeSelector: _cmd ];
   return 0;
}

-(id)objectForKey:( id )key_
{
   [ self doesNotRecognizeSelector: _cmd ];
   return nil;
}

-(void)enumerateKeysAndObjectsUsingBlock:( EnumerateDictionaryObjectsAndKeys )block_
{
   BOOL stop_ = NO;
   for ( id key_ in self )
   {
      block_( key_, [ self objectForKey: key_ ], &stop_ );
      if ( stop_ )
         break;
   }
}

+(void)load
{
   [ self addMethodIfNeedWithSelector: @selector( enumerateKeysAndObjectsUsingBlock: )
                              toClass: [ NSDictionary class ] ];      
}

@end
