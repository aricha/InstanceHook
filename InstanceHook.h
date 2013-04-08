//
//  InstanceHook.h
//  InstanceHook
//
//  Created by Andrew Richardson on 2013-04-02.
//  Copyright (c) 2013 Andrew Richardson. All rights reserved.
//

#import <objc/runtime.h>

#ifdef __clang__
	#if __has_feature(objc_arc)
		#define IHUseARC
	#endif
#endif

#ifdef __cplusplus
	#define IHExtern extern "C"
#else
	#define IHExtern extern
#endif

typedef struct _instance_hook_s *instance_hook_t;
#define instance_hook_t_block __block instance_hook_t

// to support non-id return types in ARC, IMP must be redefined to
// avoid ARC attempting to retain the returned value
#ifdef IHUseARC
typedef void *(*IHIMP)(id, SEL, ...);
#else
typedef id (*IHIMP)(id, SEL, ...);
#endif

IHExtern instance_hook_t instance_hook_create(id self, SEL cmd, id block);
IHExtern instance_hook_t instance_hook_create_f(id self, SEL cmd, IMP imp);

IHExtern IHIMP instance_hook_get_orig(instance_hook_t hook);

IHExtern void instance_hook_remove(instance_hook_t hook);

IHExtern instance_hook_t instance_hook_retain(instance_hook_t hook);
IHExtern void instance_hook_release(instance_hook_t hook);
IHExtern BOOL instance_hook_is_valid(instance_hook_t hook);

IHExtern void instance_hook_perform_block(id self, SEL cmd, id blockHook, void (^block)(), instance_hook_t *hook);
