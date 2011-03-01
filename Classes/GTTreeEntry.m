//
//  GTTreeEntry.m
//  ObjectiveGitFramework
//
//  Created by Timothy Clem on 2/22/11.
//
//  The MIT License
//
//  Copyright (c) 2011 Tim Clem
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "GTTreeEntry.h"
#import "GTObject.h"
#import "GTTree.h"
#import "NSString+Git.h"
#import "NSError+Git.h"

@implementation GTTreeEntry

@synthesize entry;
@synthesize name;
@synthesize attributes;
@synthesize sha;
@synthesize tree;

- (NSString *)name {
	
	return [NSString stringForUTF8String:git_tree_entry_name(self.entry)];
}
- (void)setName:(NSString *)n {
	
	git_tree_entry_set_name(self.entry, [NSString utf8StringForString:n]);
}

- (NSInteger)attributes {
	
	return git_tree_entry_attributes(self.entry);
}
- (void)setAttributes:(NSInteger)attr {
	
	git_tree_entry_set_attributes(self.entry, attr);
}

- (NSString *)sha {
	
	char hex[41];
	git_oid_fmt(hex, git_tree_entry_id(self.entry));
	hex[40] = 0;
	return [NSString stringForUTF8String:hex];
}
- (void)setSha:(NSString *)s {
	
	git_oid oid;
	int gitError = git_oid_mkstr(&oid, [NSString utf8StringForString:s]);
	if(gitError == GIT_SUCCESS){
		git_tree_entry_set_id(self.entry, &oid);
	}
}

- (GTObject *)toObjectAndReturnError:(NSError **)error {
	
	git_object *obj;
	int gitError = git_tree_entry_2object(&obj, self.entry);
	if(gitError != GIT_SUCCESS){
		if(error != NULL)
			*error = [NSError gitErrorForTreeEntryToObject:gitError];
		return nil;
	}
	
	return [GTObject objectInRepo:self.tree.repo withObject:obj];
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	
	self.name = nil;
	self.sha = nil;
	self.tree = nil;
	[super dealloc];
}

@end
