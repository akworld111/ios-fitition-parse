//
//  ISCTypeItemView.h
//  F.A.T
//
//  Created by WuYong on 7/2/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol TypeSelectionDelegate <NSObject>

@optional
- (void)selectedTypeItem:(id)selectedItem;

@end

@interface ISCTypeItemView : UIView

- (void)setImgType:(PFFile *)iType;
- (void)setLblType:(NSString *)lType;
- (void)setImageChecked:(BOOL)val;

@property (nonatomic, assign) BOOL bSelected;
@property (nonatomic, retain) id<TypeSelectionDelegate> delegate;
@end
