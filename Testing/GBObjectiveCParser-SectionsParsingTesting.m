//
//  GBObjectiveCParser-SectionsParsingTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 22.9.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBStore.h"
#import "GBDataObjects.h"
#import "GBObjectiveCParser.h"

// Note that we use class for invoking parsing of methods. Probably not the best option - i.e. we could isolate method parsing code altogether and only parse relevant stuff here, but it seemed not much would be gained by doing this. Separating unit tests does avoid repetition in top-level objects testing code - we only need to test specific data there.

@interface GBObjectiveCParserMethodSectionsParsingTesting : GBObjectsAssertor
@end

@implementation GBObjectiveCParserMethodSectionsParsingTesting

- (void)testParseObjectsFromString_shouldRegisterMethodsToLastSection {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass /** @name Section1 */ /** */ -(id)method1; -(id)method2; @end" sourceFile:@"" toStore:store];
	// verify
	NSArray *sections = [[[[store classes] anyObject] methods] sections];
	assertThatInteger([sections count], equalToInteger(1));
	GBMethodSectionData *section = [sections objectAtIndex:0];
	assertThat(section.sectionName, is(@"Section1"));
	assertThatInteger([[section methods] count], equalToInteger(2));
	[self assertMethod:[[section methods] objectAtIndex:0] matchesInstanceComponents:@"id", @"method1", nil];
	[self assertMethod:[[section methods] objectAtIndex:1] matchesInstanceComponents:@"id", @"method2", nil];
}

- (void)testParseObjectsFromString_shouldRegisterCommentedMethodsToLastSection {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass /** @name Section1 */ /** */ -(id)method1; /** */ -(id)method2; @end" sourceFile:@"" toStore:store];
	// verify
	NSArray *sections = [[[[store classes] anyObject] methods] sections];
	assertThatInteger([sections count], equalToInteger(1));
	GBMethodSectionData *section = [sections objectAtIndex:0];
	assertThat(section.sectionName, is(@"Section1"));
	assertThatInteger([[section methods] count], equalToInteger(2));
	[self assertMethod:[[section methods] objectAtIndex:0] matchesInstanceComponents:@"id", @"method1", nil];
	[self assertMethod:[[section methods] objectAtIndex:1] matchesInstanceComponents:@"id", @"method2", nil];
}

- (void)testParseObjectsFromString_shouldDetectLongSectionNames {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass /** @name Long section name */ /** */ -(id)method1; @end" sourceFile:@"" toStore:store];
	// verify
	NSArray *sections = [[[[store classes] anyObject] methods] sections];
	assertThatInteger([sections count], equalToInteger(1));
	assertThat([[sections objectAtIndex:0] sectionName], is(@"Long section name"));
}

- (void)testParseObjectsFromString_shouldDetectSectionNameRegardlessOfPrefix {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass /** Some prefix @name Section */ /** */ -(id)method1; @end" sourceFile:@"" toStore:store];
	// verify
	NSArray *sections = [[[[store classes] anyObject] methods] sections];
	assertThatInteger([sections count], equalToInteger(1));
	assertThat([[sections objectAtIndex:0] sectionName], is(@"Section"));
}

- (void)testParseObjectsFromString_shouldIgnoreWhitespaceWithinSectionName {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass /** @name\nSection\n\tspanning   multiple\n\n\n\nlines\rwhoa!    */ /** */ -(id)method1; @end" sourceFile:@"" toStore:store];
	// verify
	NSArray *sections = [[[[store classes] anyObject] methods] sections];
	assertThatInteger([sections count], equalToInteger(1));
	assertThat([[sections objectAtIndex:0] sectionName], is(@"Section spanning multiple lines whoa!"));
}

- (void)testParseObjectsFromString_requiresMethodCommentInOrderToDetectSection {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass /** @name Section */ -(id)method1; @end" sourceFile:@"" toStore:store];
	// verify - note that comment is aded to method in such case but default section is created anyway!
	GBClassData *class = [[store classes] anyObject];
	NSArray *methods = [[class methods] methods];
	assertThat([[(GBModelBase *)[methods objectAtIndex:0] comment] stringValue], is(@"@name Section"));
	NSArray *sections = [[class methods] sections];
	assertThatInteger([sections count], equalToInteger(1));
	assertThat([[sections objectAtIndex:0] sectionName], is(nil));
}

@end
