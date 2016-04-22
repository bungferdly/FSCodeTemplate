//
//  FSAPIParserManager.m
//  Pods
//
//  Created by Ferdly Sethio on 9/12/15.
//
//

#import "FSJSONParserManager.h"
#import "FSCodeTemplate.h"
#import <JSONModel/JSONModel.h>

@interface FSJSONParserManager() <FSAccountManagerDelegate>

@property (strong, nonatomic) NSMutableArray *models;
@property (strong, nonatomic) NSMutableDictionary *modelCaches;

@end

@implementation FSJSONParserManager

- (void)didLoad
{
    self.models = [NSMutableArray array];
    self.modelCaches = [NSMutableDictionary dictionary];
    [[FSAccountManager sharedManager] addDelegate:self];
}

- (void)registerClass:(Class)cls forJSONKey:(NSString *)key withPrimaryKey:(NSString *)primaryKey
{
    [self.models addObject:@[cls, key, primaryKey ?: @""]];
}

- (id)parseJSON:(id)data
{
    id mData = data;
    if ([data isKindOfClass:[NSArray class]]) {
        mData = [@[] mutableCopy];
        for (id subData in data) {
            [mData addObject:[self parseJSON:subData]];
        }
    } else if ([data isKindOfClass:[NSDictionary class]]) {
        mData = [self parseDictionary:data];
    }
    return mData;
}

- (id)parseDictionary:(NSDictionary *)data
{
    NSMutableDictionary *mData = [@{} mutableCopy];
    for (NSString *key in data.allKeys) {
        [mData setObject:[self parseJSON:data[key]] forKey:key];
    }
    for (NSArray *model in self.models) {
        NSString *key = model[1];
        if ([data objectForKey:key]) {
            Class cls = model[0];
            
            NSObject<FSAbstractModelProtocol> *modelObject = [[cls alloc] initWithDictionary:mData];
            if (!modelObject) {
                FSLog(@"Failed to create object model %@.", cls);
                return mData;
            } else if ([model[2] length] && [modelObject valueForKey:model[2]]) {
                return [self cacheWithAppendModel:modelObject];
            } else {
                return modelObject;
            }
        }
    }
    return mData;
}

- (id)cacheForObject:(id)object
{
    for (NSArray *model in self.models) {
        Class cls = model[0];
        
        if ([object isKindOfClass:cls]) {
            NSString *primaryKey = model[2];
            NSString *clsString = NSStringFromClass(cls);
            if (!primaryKey.length) {
                return object;
            }
            NSMutableDictionary *modelCache = self.modelCaches[clsString];
            if (!modelCache) {
                modelCache = [NSMutableDictionary dictionary];
                [self.modelCaches setObject:modelCache forKey:clsString];
            }
            id key = [object valueForKey:primaryKey];
            JSONModel *cache = [modelCache objectForKey:key];
            if (!cache) {
                [modelCache setObject:object forKey:key];
                cache = object;
            }
            return cache;
        }
    }
    return object;
}

- (id)cacheWithAppendModel:(id)object
{
    NSObject<FSAbstractModelProtocol> *cache = [self cacheForObject:object];
    if (cache != object) {
        [cache mergeWithModel:object];
    }
    return cache;
}

- (void)clearCache
{
    [self.modelCaches removeAllObjects];
}

- (id)parseHierarchicalObject:(id)data
{
    id mData = data;
    if ([data isKindOfClass:[NSArray class]]) {
        mData = [@[] mutableCopy];
        for (id subData in data) {
            [mData addObject:[self parseHierarchicalObject:subData]];
        }
    } else if ([data respondsToSelector:@selector(toDictionary)]) {
        mData = [self parseModel:[data toDictionary]];
    } else if ([data respondsToSelector:@selector(dictionaryValue)]) {
        mData = [self parseModel:[data dictionaryValue]];
    } else if ([data isKindOfClass:[NSDictionary class]]) {
        mData = [self parseModel:data];
    }
    return mData;
}

- (id)parseModel:(id)data
{
    NSMutableDictionary *mData = [data mutableCopy];
    for (NSString *key in mData.allKeys) {
        [mData setObject:[self parseHierarchicalObject:[mData valueForKey:key]] forKey:key];
    }
    return mData;
}

- (void)accountManagerDidLoggedOut:(id)userInfo
{
    [self clearCache];
}

@end

@implementation FSModel

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    return [self initWithDictionary:[decoder decodeObjectForKey:@"json"] error:nil];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:[self toDictionary] forKey:@"json"];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    return [self initWithDictionary:dictionary error:nil];
}

- (NSDictionary *)dictionaryValue
{
    return [self toDictionary];
}

- (void)mergeWithModel:(id)model
{
    [self mergeFromDictionary:[model dictionaryValue] useKeyMapping:NO];
}

+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end
