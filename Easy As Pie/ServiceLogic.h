//
//  ServiceLogic.h
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 8/16/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceLogic : NSObject

+ (ServiceLogic *)getObject;

-(void)getVersionNumberWithCompleteionBlock:(void(^)(id response))successBlock andFailureBlock:(void(^)(NSError*))failureBlock;

@end
