//
//  InstanceHookTesting.m
//  InstanceHookTesting
//
//  Created by Andrew Richardson on 2013-04-02.
//  Copyright (c) 2013 Andrew Richardson. All rights reserved.
//

#import "InstanceHookTesting.h"
#import "InstanceHook.h"

@interface TestClass : NSObject
@end

@implementation TestClass

- (NSUInteger)testMethod
{
	return 50;
}

- (float)testMethod1:(NSUInteger)arg {
    return (float)arg/2.0f;
}

- (NSString *)testMethod2
{
	return @"Hello";
}

- (void)dealloc
{
	NSLog(@"deallocating!");
#ifndef IHUseARC
	[super dealloc];
#endif
}

@end

@implementation InstanceHookTesting

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testBasicFunctionality
{
	TestClass *t = [TestClass new];
	instance_hook_t_block hook = instance_hook_create(t, @selector(testMethod), ^NSUInteger(__typeof(t) self) {
        //proper casting using IHIMPCast
		NSUInteger orig = IHIMPCast(instance_hook_get_orig(hook), NSUInteger)(self, @selector(testMethod));
		return 100 + orig;
	});
    
    instance_hook_t_block floatHook = instance_hook_create(t, @selector(testMethod1:), ^float(__typeof(t) self, NSUInteger arg1) {
        //proper casting using IHIMPCast
		float orig = IHIMPCast(instance_hook_get_orig(floatHook), float, NSUInteger)(self, @selector(testMethod), arg1);
        float result = orig/2.0;
		return result;
	});
    
	instance_hook_t_block innerHook = instance_hook_create(t, @selector(testMethod), ^NSUInteger(__typeof(t) self) {
        //proper casting using IHIMPCast
		NSUInteger innerOrig = IHIMPCast(instance_hook_get_orig(innerHook), NSUInteger)(self, @selector(testMethod));
		return 1 + innerOrig;
	});
    
	STAssertEquals([t class], [TestClass class], @"");
    
	STAssertEquals([t testMethod], (NSUInteger)151, @"");
	instance_hook_remove(hook);
    STAssertEquals([t testMethod], (NSUInteger)51, @"");
    
    STAssertEquals([t testMethod1:20], 5.0f, @"");
	instance_hook_remove(floatHook);
    STAssertEquals([t testMethod1:20], 10.0f, @"");
    
	instance_hook_remove(innerHook);
	STAssertEquals([t testMethod], (NSUInteger)50, @"");
	
	instance_hook_t_block otherHook = instance_hook_create(t, @selector(testMethod2), ^NSString*(__typeof(t) self){
		return @"Goodbye";
	});
	instance_hook_retain(otherHook);
	STAssertEqualObjects([t testMethod2], @"Goodbye", @"");
	STAssertTrue(instance_hook_is_valid(otherHook), @"");
	instance_hook_remove(otherHook);
	STAssertFalse(instance_hook_is_valid(otherHook), @"");
	STAssertEqualObjects([t testMethod2], @"Hello", @"");
	instance_hook_release(otherHook);
	
	static instance_hook_token_t token;
	instance_hook_perform_block(t, @selector(testMethod2), ^(__typeof(t) self){
		instance_hook_t blockHook = instance_hook_get_hook(&token, self);
		IHIMP origImpl = instance_hook_get_orig(blockHook);
		NSString *orig = IHBridgeCast(id, origImpl(self, @selector(testMethod2)));
		return [orig stringByAppendingString:@" in a block!"];
	}, ^{
		STAssertEqualObjects([t testMethod2], @"Hello in a block!", @"");
	}, &token);
	STAssertEqualObjects([t testMethod2], @"Hello", @"");
	
#ifndef IHUseARC
	[t release];
#endif
}

@end
