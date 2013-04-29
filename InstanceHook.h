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

#ifdef IHUseARC
	#define IHBridgeCast(type, obj) ((__bridge type)obj)
#else
	#define IHBridgeCast(type, obj) ((type)obj)
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

#define IHIMPCast(imp, returnType, argTypes...) ((returnType(*)(id, SEL, ##argTypes))imp)

/* IHIMPCast explained:
 * instance_hook_get_orig will return an id object (or void * with ARC) which can be normally casted to any objc pointer.
 * When a cast to a non objc type (like primitive C-Types) is required (see all 3 test hooks above) you need to use IHIMPCast:
 * <returntype> value = IHIMPCast(instance_hook_get_orig(hook), <returntype>, <arg1type>, <arg2type>, ..., <argNtype>) (self, <selector>, <arg1>, <arg2>, ..., <argN>);
 * <argNtype> and <argN> stands for the number of args in the method, if there are 0 args then it would simply look like this:
 * <returntype> value = IHIMPCast(instance_hook_get_orig(hook), <returntype>) (self, <selector>);
 */

IHExtern instance_hook_t instance_hook_create(id self, SEL cmd, id block);
IHExtern instance_hook_t instance_hook_create_f(id self, SEL cmd, IMP imp);

IHExtern IHIMP instance_hook_get_orig(instance_hook_t hook);

IHExtern void instance_hook_remove(instance_hook_t hook);

IHExtern instance_hook_t instance_hook_retain(instance_hook_t hook);
IHExtern void instance_hook_release(instance_hook_t hook);
IHExtern BOOL instance_hook_is_valid(instance_hook_t hook);

typedef char instance_hook_token_t;
IHExtern instance_hook_t instance_hook_get_hook(instance_hook_token_t *token, id self);

IHExtern void instance_hook_perform_block(id self, SEL cmd, id blockHook, void (^block)(), instance_hook_token_t *token);
