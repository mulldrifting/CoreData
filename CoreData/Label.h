//
//  Label.h
//  CoreData
//
//  Created by Lauren Lee on 5/7/14.
//  Copyright (c) 2014 Lauren Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Label : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *artists;
@end

@interface Label (CoreDataGeneratedAccessors)

- (void)addArtistsObject:(NSManagedObject *)value;
- (void)removeArtistsObject:(NSManagedObject *)value;
- (void)addArtists:(NSSet *)values;
- (void)removeArtists:(NSSet *)values;

@end
