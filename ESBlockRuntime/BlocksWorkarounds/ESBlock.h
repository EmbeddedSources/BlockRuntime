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

//#include "Block.h"
#include "Block_private.h"

#import <Foundation/Foundation.h>

#ifndef _ESBLOCK_H_
#define _ESBLOCK_H_

@interface ESBlock : NSObject
@end

@interface _ESStackBlock : ESBlock
@end

@interface _ESMallocBlock : ESBlock
@end

@interface _ESAutoBlock : ESBlock
@end

@interface _ESFinalizingBlock : ESBlock
@end

@interface _ESGlobalBlock : ESBlock
@end

@interface _ESWeakBlockVariable : NSObject {
@public
   /* WARNING: This layout MUST match the Block_byref structure layout */
   struct Block_byref *forwarding;
   int flags;
   int size;
   void (*byref_keep)(struct Block_byref *dst, struct Block_byref *src);
   void (*byref_destroy)(struct Block_byref *);

   /* The weak object reference */
   __weak id obj;
}

@end

#endif /* _NSBLOCK_H_ */
