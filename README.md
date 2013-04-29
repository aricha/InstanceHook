InstanceHook
============

Hook methods on specific object instances in Objective-C.

Basic Usage:

    NSObject *obj = [[NSObject new] autorelease];
    instance_hook_t_block hook = instance_hook_create(obj, @selector(description), ^NSString *(__typeof(obj) self) {
		NSString *orig = instance_hook_get_orig(hook)(self, @selector(description));
		return [orig stringByAppendingString:@" Hello world!"];
	});
	
	// ...
	
	//This is optional, the hook will be automatically removed when the hooked method is released
	instance_hook_remove(hook);

### The Nitty-Gritty

InstanceHook provides a C-based API for creating method hooks on specific Objective-C objects, using either blocks or functions. Creating a hook using `instance_hook_create` will hook the specified method *only* on the provided object, and only while it has not been deallocated. `instance_hook_remove` returns a reference-counted object representing the hook, of type `instance_hook_t` - which can be used to retrieve the original method implementation, and to remove the hook. The hook remains valid until `instance_hook_remove` is called on the returned `instance_hook_t` hook object, or when the returned `instance_hook_t` object is deallocated.

From within a method hook, the original implementation can be looked up and called using `instance_hook_get_orig`. 

There is also a convenience method `instance_hook_perform_block`, which hooks a method on an object for the duration of the block, and removes the hook afterwards. It can be used like so:

	NSObject *obj = [[NSObject new] autorelease];
	static instance_hook_token_t token;
	id hookBlock = ^NSString *(__typeof(obj) self) {
		instance_hook_t hook = instance_hook_get_hook(&token, hookBlock);
		NSString *origDescription = instance_hook_get_orig(hook)(self, @selector(description));
		return [@"Hello world! Object: " stringByAppendingString:origDescription];
	};	
	instance_hook_perform_block(obj, @selector(description), hookBlock, ^{
		NSString *helloWorld = [obj description]; // "Hello world" is prepended to the description
	}, &token);
	// the hook has now been removed

## instance_hook_get_orig and return types:

instance_hook_get_orig will return an id object (or void * with ARC) which can be normally casted to any objc pointer
When a cast to a non objc type (like primitive C-Types) is required (see all 3 test hooks above) you need to use IHIMPCast:
	<returntype> value = IHIMPCast(instance_hook_get_orig(hook), <returntype>, <arg1type>, <arg2type>, ..., <argNtype>) (self, <selector>, <arg1>, <arg2>, ..., <argN>);
<argNtype> and <argN> stands for the number of args in the method, if there are 0 args then it would simply look like this:
	<returntype> value = IHIMPCast(instance_hook_get_orig(hook), <returntype>) (self, <selector>);


## There are a few caveats to watch out for when using InstanceHook:

• It is **not** compatible with Key-Value Observing (KVO), nor does it account for any method hooks that occur after using `instance_hook_create` if they are not also done using InstanceHook.
• It is not entirely thread-safe - do not share `instance_hook_t` objects across multiple threads.
• When using `instance_hook_create`, if you choose to use a block hook and want to call the original method, you **must** declare the returned `instance_hook_t` object as either being `static` or being of type `instance_hook_t_block`. The latter adds the `__block` qualifier that is necessary to be able to reference the correct value of the `instance_hook_t` object from within the block (when the object is created on the stack).

• InstanceHook is completely compatible with ARC and MRC
