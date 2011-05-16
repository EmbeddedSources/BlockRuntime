#import <Foundation/Foundation.h>

#include <objc/runtime.h>

typedef void (^EnumerateArrayObjects) ( id obj_, NSUInteger index_, BOOL* stop_ );
typedef BOOL (^ArraObjectPredicate) ( id obj_, NSUInteger index_, BOOL* stop_ );

static NSInteger compareObjectsWithBlock( id obj1_, id obj2_, void* block_context_ )
{
   NSComparator block_ = block_context_;
   return block_( obj1_, obj2_ );
}

@interface ESArrrayBlockWorkarounds : NSObject

+(void)addMethodIfNeedWithSelector:( SEL )selector_
                           toClass:( Class )class_;

@end

@implementation ESArrrayBlockWorkarounds

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

-(void)enumerateObjectsUsingBlock:( EnumerateArrayObjects )block_
{
   BOOL stop_ = NO;
   NSUInteger index_ = 0;
   for ( id obj_ in self )
   {
      block_( obj_, index_, &stop_ );
      if ( stop_ )
         break;
      ++index_;
   }
}

-(NSUInteger)indexOfObjectPassingTest:( ArraObjectPredicate )block_
{
   BOOL stop_ = NO;
   NSUInteger index_ = 0;
   for ( id obj_ in self )
   {
      if ( block_( obj_, index_, &stop_ ) )
         return index_;
      if ( stop_ )
         break;
      ++index_;
   }
   return NSNotFound;
}

-(NSIndexSet*)indexesOfObjectsPassingTest:( ArraObjectPredicate )block_
{
   NSMutableIndexSet* indexes_ = [ NSMutableIndexSet indexSet ];
   [ self enumerateObjectsUsingBlock: ^( id obj_, NSUInteger index_, BOOL* stop_ )
   {
      if ( block_( obj_, index_, stop_ ) )
         [ indexes_ addIndex: index_ ];
   } ];
   return indexes_;
}

-(NSArray*)sortedArrayUsingFunction:(NSInteger (*)(id, id, void *))comparator_ context:( void* )context_
{
   [ self doesNotRecognizeSelector: _cmd ];
   return nil;
}

-(NSArray*)sortedArrayUsingComparator:( NSComparator )block_
{
   return [ self sortedArrayUsingFunction: compareObjectsWithBlock context: block_ ];
}

+(void)load
{
   [ ESArrrayBlockWorkarounds addMethodIfNeedWithSelector: @selector( enumerateObjectsUsingBlock: )
                                                  toClass: [ NSArray class ] ];
   [ ESArrrayBlockWorkarounds addMethodIfNeedWithSelector: @selector( indexOfObjectPassingTest: )
                                                  toClass: [ NSArray class ] ];
   [ ESArrrayBlockWorkarounds addMethodIfNeedWithSelector: @selector( indexesOfObjectsPassingTest: )
                                                  toClass: [ NSArray class ] ];
   [ ESArrrayBlockWorkarounds addMethodIfNeedWithSelector: @selector( sortedArrayUsingComparator: )
                                                  toClass: [ NSArray class ] ];      
}

@end
