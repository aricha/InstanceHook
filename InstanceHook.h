//
//  InstanceHook.h
//  InstanceHook
//
//  Created by Andrew Richardson on 2013-04-02.
//  Copyright (c) 2013 Andrew Richardson. All rights reserved.
//

#import <objc/runtime.h>

typedef struct _instance_hook_s *instance_hook_t;
#define instance_hook_t_block __block instance_hook_t

instance_hook_t instance_hook_create(id self, SEL cmd, id block);
instance_hook_t instance_hook_create_f(id self, SEL cmd, IMP imp);

IMP instance_hook_get_orig(instance_hook_t hook);

void instance_hook_remove(instance_hook_t hook);

instance_hook_t instance_hook_retain(instance_hook_t hook);
void instance_hook_release(instance_hook_t hook);
BOOL instance_hook_is_valid(instance_hook_t hook);

void instance_hook_perform_block(id self, SEL cmd, id blockHook, void (^block)(), instance_hook_t *hook);
