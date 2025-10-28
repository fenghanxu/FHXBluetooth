//
//  CellsysStyle.m
//  cellsys
//
//  Created by 刘磊 on 2019/11/15.
//  Copyright © 2019 LarryLiu. All rights reserved.
//

#import "CellsysStyle.h"

@implementation CellsysStyle


- (NSString *)strokeOpacity{
    if (_strokeOpacity == nil) {
        _strokeOpacity = @"1";
    }
    return _strokeOpacity;
}

- (NSString *)fillOpacity{
    if (_fillOpacity == nil) {
        _fillOpacity = @"1";
    }
    return _fillOpacity;
}

- (NSString *)fillColor{
    if (_fillColor == nil) {
        _fillColor = @"#2D8CF0";
    }
    return _fillColor;
}


- (NSString *)strokeColor{
    if (_strokeColor == nil) {
        _strokeColor = self.fillColor;
    }
    return _strokeColor;
}

- (NSString *)weight{
    if (_weight == nil) {
        _weight = @"2";
    }
    return _weight;
}

@end
