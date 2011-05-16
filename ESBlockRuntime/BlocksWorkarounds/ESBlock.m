/*
 * Copyright 2008 - 2009 Apple, Inc.
 * Copyright 2009 - 2010 Plausible Labs Cooperative, Inc.
 *
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge,
 * to any person obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to permit
 * persons to whom the Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import "ESBlock.h"

#import <objc/objc-auto.h>
#import <objc/runtime.h>

/**
 * @ingroup private_api
 * @{
 */

#define BLOCK(id) ((struct Block_layout *)id)

// Weak import Apple's stack and global block classes.

extern void *_ESBlock_copy(const void *arg);
extern void _ESBlock_release(const void *arg);

BOOL has_native_blocks_runtime_ = NO;

/**
 * Abstract Block Superclass.
 */
@implementation ESBlock

- (id)copyWithZone: (NSZone *) zone {
#ifdef __OBJC_GC__
   /* If garbage collection is enabled, make a collectable copy. */
   if (objc_collectingEnabled())
      return _Block_copy_gc((void *) self);
   else
      return _Block_copy((void *) self);
#else
   return has_native_blocks_runtime_ ? _Block_copy((void *) self) : _ESBlock_copy((void *) self);
#endif /* __OBJC_GC__ */
}

- (id) copy {
   return [self copyWithZone: nil];
}

- (void) dealloc {
   /* Quiesce [super dealloc] warnings */
   if (NO) [super dealloc];
}

@end

/**
 * A malloc-allocated block.
 */
@implementation _ESMallocBlock

-(id)retain {
   return [ self copyWithZone: nil ];
}

- (void) release {
   if ( has_native_blocks_runtime_ )
   {
      _Block_release((void *) self);
   }
   else
   {
      _ESBlock_release((void *) self);
   }
}

- (NSUInteger) retainCount {
   return BLOCK(self)->flags & BLOCK_REFCOUNT_MASK;
}

@end


/**
 * A stack allocated block.
 */
@implementation _ESStackBlock

// Force early class initialization to ensure that this class is valid when
// referenced by a block
+ (void) load
{
}

- (id) retain {
   /* Allocated on stack */
   return self;
}

- (void) release {
   /* Allocated on stack */
}

- (id) autorelease {
   /* Allocated on stack */
   return self;
}

- (NSUInteger) retainCount {
   return 1;
}

@end

/**
 * A global block.
 */
@implementation _ESGlobalBlock

// Force early class initialization to ensure that this class is valid when
// referenced by a block
+ (void) load {}

- (id) copyWithZone: (NSZone *) zone {
   return self; 
}

- (id) copy {
   return self;
}

- (id) retain {
   return self;
}

- (void) release {
}

- (id) autorelease {
   /* Allocated on stack */
   return self;
}

- (NSUInteger) retainCount {
   return 1;
}

@end

/**
 * A GC-collectable block.
 */
@implementation _ESAutoBlock

- (id) copyWithZone: (NSZone *) zone {
   return self; 
}

- (id) copy { 
   return self;
}

- (id) retain { 
   return self; 
}

- (void) release {
}

- (NSUInteger) retainCount { 
   return UINT_MAX; 
}

@end

/**
 * A GC-collectable block that will call the block's finalizer.
 */
@implementation _ESFinalizingBlock

- (void) finalize {
   /* Call the block dispose handler */
   struct Block_layout *aBlock = (struct Block_layout *) self;
   if (aBlock->flags & BLOCK_HAS_COPY_DISPOSE)
      (*aBlock->descriptor->dispose)(aBlock);

   [super finalize];
}

@end

/**
 * Provides an object-equivalent to Block_byref structure, with a __weak reference instance variable for the byref
 * value. This provides support for __block __weak value references.
 */
@implementation _ESWeakBlockVariable
@end

/**
 * @}
 */
