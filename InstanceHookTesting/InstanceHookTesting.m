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

- (NSString *)testMethod2
{
	return @"Hello";
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
    TestClass *t = [[TestClass new] autorelease];
	instance_hook_t_block hook = instance_hook_create(t, @selector(testMethod), ^NSUInteger(id self) {
		NSUInteger orig = (NSUInteger)instance_hook_get_orig(hook)(self, @selector(testMethod));
		return 100 + orig;
	});
	instance_hook_t_block innerHook = instance_hook_create(t, @selector(testMethod), ^NSUInteger(id self) {
		NSUInteger innerOrig = (NSUInteger)instance_hook_get_orig(innerHook)(self, @selector(testMethod));
		return 1 + innerOrig;
	});
	STAssertEquals([t class], [TestClass class], @"");
	STAssertEquals([t testMethod], (NSUInteger)151, @"");
	instance_hook_remove(hook);
	STAssertEquals([t testMethod], (NSUInteger)51, @"");
	instance_hook_remove(innerHook);
	STAssertEquals([t testMethod], (NSUInteger)50, @"");
	
	instance_hook_t_block otherHook = instance_hook_create(t, @selector(testMethod2), ^NSString*(id self){
		return @"Goodbye";
	});
	instance_hook_retain(otherHook);
	STAssertEqualObjects([t testMethod2], @"Goodbye", @"");
	STAssertTrue(instance_hook_is_valid(otherHook), @"");
	instance_hook_remove(otherHook);
	STAssertFalse(instance_hook_is_valid(otherHook), @"");
	STAssertEqualObjects([t testMethod2], @"Hello", @"");
	instance_hook_release(otherHook);
}

@end
