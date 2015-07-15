//
//  ISCSwipingControl.h
//  Fitition
//
//  Created by WuYong on 7/20/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ISCSwipingControl;

@protocol SwipingControlDataSource <NSObject>

@required

- (NSString *)GetUserId:(ISCSwipingControl *)swipingControl;

@end


@protocol SwipingControlDelegate <NSObject>

@optional
-(void) willStartMoving:(ISCSwipingControl *)swipingControl;
-(void)willFlickAway:(ISCSwipingControl *)swipingControl withVelocity:(CGPoint )velocity;
-(void)didAcceptUser:(ISCSwipingControl *)swipingControl;
-(void)didDeclineUser:(ISCSwipingControl *)swipingControl;
-(void)didSelectPhoto:(ISCSwipingControl *)swipingControl;
-(void)imageLoaded:(UIImage *)img;
-(void)didGetUsername:(NSString *)uName;

@end
@interface ISCSwipingControl : UIControl<UIGestureRecognizerDelegate>
@property (weak, nonatomic) id <SwipingControlDataSource> dataSource;
@property (weak, nonatomic) id <SwipingControlDelegate> delegate;

@property (nonatomic) CGFloat rotationOffset;

- (void)reloadData;
-(void)flickAway:(UIView *)photo withVelocity:(CGPoint)velocity;
@end
