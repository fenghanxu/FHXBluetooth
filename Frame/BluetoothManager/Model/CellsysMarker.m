//
//  CellsysMarker.m
//  cellsys
//
//  Created by LarryLiu on 2019/10/31.
//  Copyright © 2019 LarryLiu. All rights reserved.
//

#import "CellsysMarker.h"

@implementation CellsysMarker
@synthesize create_time = _create_time;
@synthesize datetime = _datetime;

+(NSDictionary *)mj_replacedKeyFromPropertyName{

    return @{@"Description":@"description",
             @"markerId":@"id"
             
    };

}

- (NSInteger)localMarkerType{
    
    
    if (_localMarkerType) {
        return _localMarkerType;
    }else if ([[CellsysGeometry mj_objectWithKeyValues:self.geometry].type isEqualToString:[GeometryType sharedGeometryType].marker] || [[CellsysGeometry mj_objectWithKeyValues:self.geometry].type isEqualToString:[GeometryType sharedGeometryType].multiPoint]) {
        return 1;
        
    }else if ([[CellsysGeometry mj_objectWithKeyValues:self.geometry].type isEqualToString:[GeometryType sharedGeometryType].line] || [[CellsysGeometry mj_objectWithKeyValues:self.geometry].type isEqualToString:[GeometryType sharedGeometryType].multiLine]){
        return 2;
        
             
    }else if ([[CellsysGeometry mj_objectWithKeyValues:self.geometry].type isEqualToString:[GeometryType sharedGeometryType].multiPolygon] || [[CellsysGeometry mj_objectWithKeyValues:self.geometry].type isEqualToString:[GeometryType sharedGeometryType].polygon]){
        return 3;
        
            
    }else{
        return 0;
    }
    
    
}


- (NSString *)title{
    switch (self.localMarkerType) {
            
        case 1:
        case 2:
        case 3:
        {
            return _name;
        }break;
        case 4:
        {
            return _realname;
        }
            break;
        case 5:
        {
            return _macid;
        }
            break;
        default:{
            return _name;
        }
            break;
    }
}

- (NSString *)buffer_distance{
    if ([NSString isEmptyString:_buffer_distance]) {
        return @"0";
    }else{
        return _buffer_distance;
    }
}

- (NSString *)Description{
    if ([NSString isEmptyString:_Description]) {
        return @"";
    }else{
        return _Description;
    }
}

- (NSString *)update_time{
    
    if ([NSString isEmptyString:_update_time]) {
        _update_time = self.create_time;
    }
    
    if ([_update_time containsString:@"T"]) {
        _update_time = [NSDate getLocalDateFormateUTCDate:_update_time];
    }
    
    return _update_time;
    
}


- (NSString *)datetime{
    if ([_datetime containsString:@"T"]) {
        _datetime = [NSDate getLocalDateFormateUTCDate:_datetime];
    }
    
    if ([NSString isEmptyString:_datetime]) {
        _datetime = self.update_time;
    }
    return _datetime;
}

- (NSString *)create_time{

    if ([_create_time containsString:@"T"]) {
        _create_time = [NSDate getLocalDateFormateUTCDate:_create_time];
    }
    
    return _create_time;
}

- (NSString *)showTime{
    return [NSDate stringDateFromTimestamp:self.update_time];
}

- (NSDictionary *)style{
    return _style.mj_JSONObject;
}

- (NSDictionary *)geometry{
    return _geometry.mj_JSONObject;
}


- (CellsysStyle *)toCellsysStyle{
    CellsysStyle *style = [CellsysStyle mj_objectWithKeyValues:self.style];
    return style;
}

- (CellsysGeometry *)toCellsysGeometry{
    CellsysGeometry *geometry = [CellsysGeometry mj_objectWithKeyValues:self.geometry];
    return geometry;
}

- (id)copyWithZone:(NSZone *)zone {

    id obj = [[[self class] allocWithZone:zone] init];
    Class class = [self class];
    while (class != [NSObject class]) {
        unsigned int count;
        Ivar *ivar = class_copyIvarList(class, &count);
        for (int i = 0; i < count; i++) {
            Ivar iv = ivar[i];
            const char *name = ivar_getName(iv);
            NSString *strName = [NSString stringWithUTF8String:name];
            //利用KVC取值
            id value = [[self valueForKey:strName] copy];//如果还套了模型也要copy呢
            [obj setValue:value forKey:strName];
        }
        free(ivar);

        class = class_getSuperclass(class);//记住还要遍历父类的属性呢
    }
    return obj;
}


- (nonnull id)mutableCopyWithZone:(nullable NSZone *)zone {
    
   id obj = [[[self class] allocWithZone:zone] init];
   Class class = [self class];
   while (class != [NSObject class]) {
       unsigned int count;
       Ivar *ivar = class_copyIvarList(class, &count);
       for (int i = 0; i < count; i++) {
           Ivar iv = ivar[i];
           const char *name = ivar_getName(iv);
           NSString *strName = [NSString stringWithUTF8String:name];
           //利用KVC取值
           id value = [[self valueForKey:strName] mutableCopy];//如果还套了模型也要copy呢
           [obj setValue:value forKey:strName];
       }
       free(ivar);

       class = class_getSuperclass(class);//记住还要遍历父类的属性呢
   }
   return obj;

}




@end
