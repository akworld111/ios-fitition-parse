//
//  ISCTypeItemView.m
//  F.A.T
//
//  Created by WuYong on 7/2/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCTypeItemView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ISCTypeItemView{
    UIImageView *imgType;
    UILabel *lblType;
    
    UIImageView *imgChecked;
    UIImageView *viewChecked;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
        gesture.numberOfTapsRequired = 1;
        gesture.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:gesture];
        [self setUserInteractionEnabled:YES];
    }
    return self;
}

- (void)handleTap: (UITapGestureRecognizer *)gr {
    [self setImageChecked:!self.bSelected];
    
    if([self.delegate respondsToSelector:@selector(selectedTypeItem:)]){
        [self.delegate selectedTypeItem:self];
    }
    
}

- (void)setImgType:(PFFile *)iType{
    
    if(!imgType){
        CGRect rt = self.bounds;
        rt.size.height -= 25;
        rt.size.width = rt.size.height;
        rt.origin.x = CGRectGetMidX(self.bounds) - CGRectGetMidX(rt);
        rt.origin.y = 2;
        imgType = [[UIImageView alloc]initWithFrame:rt];
        imgType.layer.cornerRadius = rt.size.height / 2;
        imgType.layer.borderColor = [UIColor lightGrayColor].CGColor;
        imgType.layer.borderWidth = 1;
        imgType.layer.masksToBounds = YES;
        [self addSubview:imgType];
    }
    if([lblType.text isEqualToString:@"Other"]){
        [imgType setImage:[UIImage imageNamed:@"imgres.jpg"]];
        return;
    }
    [iType getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if(!error){
            [imgType setImage:[UIImage imageWithData:data]];            
        }
    }];


}
- (void)setLblType:(NSString *)lType{
    if(!lblType){
        CGRect rt = self.bounds;
        rt.origin.y = rt.size.height - 25;
        rt.size.height = 25;
        lblType = [[UILabel alloc]initWithFrame:rt];
        lblType.textAlignment = NSTextAlignmentCenter;
        lblType.textColor = [UIColor colorWithRed:89.0/255.0 green:130.0/255.0 blue:142.0/255.0 alpha:1.0];
        lblType.font = [UIFont systemFontOfSize:10.0f];
        [self addSubview:lblType];
    }
    
    [lblType setText:lType];
}

- (void)setImageChecked:(BOOL)val{
    if(!viewChecked){
        viewChecked = [[UIImageView alloc]initWithFrame:imgType.frame];
//        [viewChecked setBackgroundColor:[UIColor colorWithRed:0.5 green:0 blue:0 alpha:0.3]];
        [viewChecked setImage:[UIImage imageNamed:@"inviteChecked.png"]];
        [self addSubview:viewChecked];
    }
//    if(!imgChecked){
//        imgChecked = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"TypeSelected.png"]];
////        [imgChecked setFrame:imgType.frame];
//        imgChecked.frame = CGRectMake(0, 0, 20, 20);
//        
//        imgChecked.center = imgType.center;
//        [self addSubview:imgChecked];
//    }
    if(val == TRUE){
        self.bSelected = TRUE;
//        [imgChecked setHidden:NO];
        [viewChecked setHidden:NO];
    }else{
        self.bSelected = FALSE;
//        [imgChecked setHidden:YES];
        [viewChecked setHidden:YES];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
