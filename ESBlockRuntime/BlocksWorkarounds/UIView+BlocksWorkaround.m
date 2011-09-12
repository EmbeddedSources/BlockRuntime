#import <UIKit/UIKit.h>

#include <objc/runtime.h>
#include <math.h>

typedef void (^DidFinishAnimation) ( BOOL finished_ );

@interface ESAnimationDelegate : NSObject

@property ( nonatomic, copy ) DidFinishAnimation block;

@end

@implementation ESAnimationDelegate

@synthesize block = _block;

-(void)dealloc
{
   [ _block release ];

   [ super dealloc ];
}

-(id)initWithBlock:( DidFinishAnimation )block_
{
   self = [ super init ];

   self.block = block_;

   return self;
}

+(id)animationDelegateWithBlock:( DidFinishAnimation )block_
{
   return [ [ [ self alloc ] initWithBlock: block_ ] autorelease ];
}

-(void)animationDidStop:( NSString* )animation_id_ finished:( NSNumber* )finished_ context:( void* )context_
{
   self.block( [ finished_ boolValue ] );
}

@end

@interface UIView (BlocksWorkaround)
@end

@implementation UIView (BlocksWorkaround)

//not implemented options
//enum {
//   UIViewAnimationOptionLayoutSubviews            = 1 <<  0,
//   UIViewAnimationOptionAllowUserInteraction      = 1 <<  1, // turn on user interaction while animating
//   UIViewAnimationOptionOverrideInheritedDuration = 1 <<  5, // ignore nested duration
//   UIViewAnimationOptionOverrideInheritedCurve    = 1 <<  6, // ignore nested duration
//   UIViewAnimationOptionAllowAnimatedContent      = 1 <<  7, // animate contents (applies to transitions only)
//   UIViewAnimationOptionShowHideTransitionViews   = 1 <<  8, // flip to/from hidden state instead of adding/removing
//   
//   UIViewAnimationOptionTransitionNone            = 0 << 20, // default
//   UIViewAnimationOptionTransitionFlipFromLeft    = 1 << 20,
//   UIViewAnimationOptionTransitionFlipFromRight   = 2 << 20,
//   UIViewAnimationOptionTransitionCurlUp          = 3 << 20,
//   UIViewAnimationOptionTransitionCurlDown        = 4 << 20,
//};
//typedef NSUInteger UIViewAnimationOptions;

+(void)animateWithDuration:( NSTimeInterval )duration_
                     delay:( NSTimeInterval )delay_
                   options:( UIViewAnimationOptions )options_
                animations:( void (^)( void ) )animations_
                completion:( void (^)( BOOL finished ) )completion_
{
   [ self beginAnimations: nil context: nil ];
   [ self setAnimationDuration: duration_ ];
   [ self setAnimationDelay: delay_ ];

   NSAssert( !( options_ & 1 ), @"unsupported UIViewAnimationOptionLayoutSubviews option" );
   NSAssert( !( options_ & 2 ), @"unsupported UIViewAnimationOptionAllowUserInteraction option" );
   NSAssert( !( options_ & 32 ), @"unsupported UIViewAnimationOptionOverrideInheritedDuration option" );
   NSAssert( !( options_ & 64 ), @"unsupported UIViewAnimationOptionOverrideInheritedCurve option" );
   NSAssert( !( options_ & 128 ), @"unsupported UIViewAnimationOptionAllowAnimatedContent option" );
   NSAssert( !( options_ & 256 ), @"unsupported UIViewAnimationOptionShowHideTransitionViews option" );
   NSAssert( !( options_ >> 20 ), @"unsupported UIViewAnimationOptionTransition* options" );

   [ self setAnimationRepeatCount: ( ( options_ >> 3 ) & 1 ) ? MAXFLOAT : 0.f ];//UIViewAnimationOptionRepeat
   [ self setAnimationBeginsFromCurrentState: ( options_ >> 2 ) & 1 ]; //UIViewAnimationOptionBeginFromCurrentState
   [ self setAnimationRepeatAutoreverses: ( options_ >> 4 ) & 1 ];//UIViewAnimationOptionAutoreverse

   [ self setAnimationCurve: ( options_ >> 16 ) & 3 ]; //UIViewAnimationOptionCurve

   if ( completion_ )
   {
      [ self setAnimationDelegate: [ ESAnimationDelegate animationDelegateWithBlock: completion_ ] ];
      [ self setAnimationDidStopSelector: @selector( animationDidStop:finished:context: ) ];
   }

   animations_();

   [ self commitAnimations ];
}

+(void)animateWithDuration:( NSTimeInterval )duration_
                animations:( void (^)( void ) )animations_
                completion:( void (^)( BOOL finished_ ) )completion_
{
   [ self animateWithDuration: duration_
                        delay: 0.
                      options: UIViewAnimationOptionCurveEaseInOut
                   animations: animations_
                   completion: completion_ ];
}

+(void)animateWithDuration:( NSTimeInterval )duration_ animations:( void (^)(void) )animations_
{
   [ self animateWithDuration: duration_ animations: animations_ completion: nil ];
}

@end
