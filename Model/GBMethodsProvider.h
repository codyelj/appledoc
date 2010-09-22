//
//  GBMethodsProvider.h
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GBMethodData;
@class GBMethodSectionData;

/** A helper class that unifies methods handling.
 
 Dividing implementation of methods provider to a separate class allows us to abstract the logic and reuse it within any object that needs to handle methods using composition. This breaks down the code into simpler and more managable chunks. It also simplifies methods parsing and handling. To use the class, simply "plug" it to the class that needs to handle methods and provide access through public interface.
 
 The downside is that querrying code becomes a bit more verbose as another method or property needs to be sent before getting access to actual methods data.
 */
@interface GBMethodsProvider : NSObject {
	@private
	NSMutableArray *_sections;
	NSMutableArray *_methods;
	NSMutableDictionary *_methodsBySelectors;
	id _parent;
}

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Initializes methods provider with the given parent object.
 
 The given parent object is set to each `GBMethodData` registered through `registerMethod:`. This is the designated initializer.
 
 @param parent The parent object to be used for all registered methods.
 @return Returns initialized object.
 @exception NSException Thrown if the given parent is `nil`.
 */
- (id)initWithParentObject:(id)parent;

///---------------------------------------------------------------------------------------
/// @name Sections handling
///---------------------------------------------------------------------------------------

/** Registers a new section with the given name.
 
 This creates a new `GBMethodSectionData` object with empty array of methods and the given name. Any method registered from now on is added to this section until another section is registered. Registering a section with the same name as one of the existing sections logs a warning but adds the section anyway!
 
 @warning *Important:* If no section is registered when registering first method, default, no-name section (i.e. `[GBMethodSectionData sectionName]` value is `nil`) is created automatically. However registering a second (and all subsequent) section would yield a warning in log! This aids creating simple objects which have no section. Note that only a log warning is issued, but all additional sections are added anyway.
 
 @param name The name of the section.
 @return Returns created `GBMethodSectionData` object.
 @see registerSectionIfNameIsValid:
 @see sections
 */
- (GBMethodSectionData *)registerSectionWithName:(NSString *)name;

/** Registers a new section if the given name is valid section name.
 
 The method validates the name string to have at least one char in it. If so, it sends the receiver `registerSectionWithName:` message, passing it the given name and returns generated `GBMethodSectionData` object.. If the name is `nil` or empty string, no section is registered and `nil` is returned. This is provided only to simplify client code - i.e. no need for testing in each place where section should be registered, while on the other hand, validation tests are nicely encapsulated within the class itself, so no functionality is exposed.
 
 @param name The name of the section.
 @return Returns created `GBMethodSectionData` object or `nil` if name is not valid.
 @see registerSectionWithName:
 @see sections
 */
- (GBMethodSectionData *)registerSectionIfNameIsValid:(NSString *)name;

/** The array of all registered sections in the order of registration.
 
 Each section is represented as `GBMethodSectionData` object containing the name of the section and the list of all methods registered for that section.
 
 @see registerSectionWithName:
 @see registerMethod:
 @see methods
 */
@property (readonly) NSArray *sections;

///---------------------------------------------------------------------------------------
/// @name Methods handling
///---------------------------------------------------------------------------------------

/** Registers the given method to the providers data.
 
 If provider doesn't yet have the given method instance registered, the object is added to `methods` list. If the same object is already registered, nothing happens. The method is also registered to the end of the list of methods for last registered section. If no section is registered a default section is created. However if another section is registered in such case, a warning is issued!
 
 @warning *Note:* If another instance of the method with the same selector is registered, an exception is thrown.
 
 @param method The method to register.
 @exception NSException Thrown if a method with the same selector is already registered.
 @see registerSectionWithName:
 @see registerSectionIfNameIsValid:
 @see methods
 */
- (void)registerMethod:(GBMethodData *)method;

/** Returns the method that matches the given selector.
 
 If no method matches the given selector, `nil` is returned. If `nil` or empty string is passed for selector, `nil` is returned also.
 
 @param selector Selector for which to return the method.
 @return Returns method data or `nil` if no method matches the given selector.
 @see methods
 @see sections
 */
- (GBMethodData *)methodBySelector:(NSString *)selector;

/** The array of all registered methods as `GBMethodData` instances in the order of registration. */
@property (readonly) NSArray *methods;

///---------------------------------------------------------------------------------------
/// @name Helper methods
///---------------------------------------------------------------------------------------

/** Merges data from the given methods provider.
 
 This copies all unknown methods from the given source to receiver and invokes merging of data for receivers methods also found in source. It leaves source data intact.
 
 @param source `GBMethodsProvider` to merge from.
 */
- (void)mergeDataFromMethodsProvider:(GBMethodsProvider *)source;

@end
