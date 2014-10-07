//
//  UIImagePickerController+oritation.m
//  MIApp
//
//  Created by Gursimran Singh on 12/31/2013.
//  Copyright (c) 2013 BCHydro. All rights reserved.
//

#import "UIImagePickerController+oritation.h"

@implementation UIImagePickerController (oritation)

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

@end