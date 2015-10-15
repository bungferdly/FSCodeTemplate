//
//  FSAPIParserManager.h
//  Pods
//
//  Created by Ferdly Sethio on 9/12/15.
//
//

#import "FSManager.h"
#import <JSONModel/JSONModel.h>

@interface FSJSONParserManager : FSManager

/// Register an MTLModel<MTLJSONSerializing> class.
/// If the key exist somewhere in JSON, it will automatically converted to this class.
/// If primaryKey registered too, the object will be merged with cached object with a same
/// primaryKey and returned the cache instead of the object, so the pointer is still same.
/// Convenient if you need only 1 object in every API response.
- (void)registerClass:(Class)cls forJSONKey:(NSString *)key withPrimaryKey:(NSString *)primaryKey;

/// Convert JSON to hierarchical MTLModel<MTLJSONSerializing>.
/// You must register the object class first.
- (id)parseJSON:(id)JSON;

/// convert hierarchical MTLModel<MTLJSONSerializing> to JSON.
- (id)parseHierarchicalObject:(id)object;

/// Clear cached objects.
- (void)clearCache;

@end

@interface FSModel : JSONModel

@end
