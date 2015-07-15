//
//  ISCSwipingControl.m
//  Fitition
//
//  Created by WuYong on 7/20/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCSwipingControl.h"
#import <Parse/Parse.h>

static CGFloat const PhotoRotationOffsetDefault = 4.0f;

@interface ISCSwipingControl(){
    UIImageView *imgUser;
    UILabel *lblAccept;
    UILabel *lblDecline;
}

@end

@implementation ISCSwipingControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}
- (void)reloadData{
    NSString *userId = [self.dataSource GetUserId:self];
    
    if(userId == nil){
        [self setHidden:YES];
        return;
    }else{
        [self setHidden:NO];
    }
    
    if(!imgUser){
        imgUser = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
        [self addSubview:imgUser];
        lblAccept = [[UILabel alloc]init];
        lblAccept.text = @"ACCEPT";
        lblAccept.textColor = [UIColor redColor];
        lblAccept.font = [UIFont boldSystemFontOfSize:24];
        lblAccept.alpha = 0;
        lblAccept.frame = CGRectMake(50, 20, 150, 50);
        lblAccept.textAlignment = NSTextAlignmentLeft;
        
        lblDecline = [[UILabel alloc]init];
        lblDecline.text = @"DECLINE";
        lblDecline.textColor = [UIColor blueColor];
        lblDecline.font = [UIFont boldSystemFontOfSize:24];
        lblDecline.alpha = 0;
        lblDecline.frame = CGRectMake(0, 20, 150, 50);
        lblDecline.textAlignment = NSTextAlignmentRight;
        
        [self addSubview:lblAccept];
        [self addSubview:lblDecline];
        
    }
    imgUser.image = [UIImage imageNamed:@"images-1.jpg"];
    imgUser.layer.borderColor = [UIColor whiteColor].CGColor;
    imgUser.layer.borderWidth = 4.0f;
    imgUser.layer.cornerRadius = imgUser.frame.size.width/2;
    imgUser.layer.masksToBounds = YES;
    imgUser.alpha = 0.1;
    
    PFQuery *query = [PFUser query];
    [query getObjectInBackgroundWithId:userId block:^(PFObject *object, NSError *error) {
        //                self.m_lblUser.text = object[@"username"];
        [self.delegate didGetUsername:object[@"username"]];
        PFFile *file = object[@"Photo"];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            UIImage *image = [UIImage imageWithData:data];
            [UIView animateWithDuration:1.0f
                             animations:^{
                                 imgUser.alpha = 1.0f;
                             }];
//            if(!imgUser){
//                imgUser = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
//                [self addSubview:imgUser];
//            }
            [self.delegate imageLoaded:image];
            imgUser.image = image;
            imgUser.layer.borderColor = [UIColor whiteColor].CGColor;
            imgUser.layer.borderWidth = 4.0f;
            imgUser.layer.cornerRadius = imgUser.frame.size.width/2;
            imgUser.layer.masksToBounds = YES;
        }];
    }];
    
//    PFQuery *queryForRates = [[PFQuery alloc]initWithClassName:@"Rates"];
//    [queryForRates whereKey:@"Username" equalTo:userId];
//    [queryForRates findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        NSUInteger totalScore = 0;
//        for(PFObject *tmpObj in objects){
//            totalScore += [tmpObj[@"Rate"]integerValue];
//        }
//        [self setScore:totalScore :[objects count]];
//    }];
}
- (void)setup{
    
    self.rotationOffset = PhotoRotationOffsetDefault;
    
    // Add Pan Gesture
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(photoPanned:)];
    [panGesture setMaximumNumberOfTouches:1];
    panGesture.delegate = self;
    [self addGestureRecognizer:panGesture];
    
    // Add Tap Gesture
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapped:)];
    [tapGesture setNumberOfTapsRequired:1];
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
}


#pragma mark -
#pragma mark Gesture Handlers

-(void)photoPanned:(UIPanGestureRecognizer *)gesture {
    
    UIView *topPhoto = self;
    CGPoint velocity = [gesture velocityInView:self];
    CGPoint translation = [gesture translationInView:self];
    NSLog(@"%f,%f", gesture.view.center.x, gesture.view.center.y);
    
//        NSLog(@"%f,%f",velocity.x, velocity.y);
//    self.transform = CGAffineTransformMakeRotation(<#CGFloat angle#>)
    
    CGFloat tWidth = CGRectGetWidth(self.superview.bounds)/2;
    
    CGFloat angle = 0.57*(gesture.view.center.x - tWidth)/tWidth;
    self.transform = CGAffineTransformMakeRotation(angle);
    
    CGFloat lblAlpha = fabs(gesture.view.center.x - tWidth)/tWidth;
    if (gesture.view.center.x > tWidth){
        lblDecline.alpha = 0;
        lblAccept.alpha = lblAlpha;
    }else{
        lblAccept.alpha = 0;
        lblDecline.alpha = lblAlpha;
    }
    
    if(gesture.state == UIGestureRecognizerStateBegan) {
        
        [self sendActionsForControlEvents:UIControlEventTouchCancel];
        
        if ([self.delegate respondsToSelector:@selector(willStartMoving:)]) {
            [self.delegate willStartMoving:self];
        }
        
    }
    
    if(gesture.state == UIGestureRecognizerStateChanged) {
        
        CGFloat xPos = topPhoto.center.x + translation.x;
//        CGFloat yPos = topPhoto.center.y + translation.y;
        
        topPhoto.center = CGPointMake(xPos, topPhoto.center.y);
        [gesture setTranslation:CGPointMake(0, 0) inView:self];
        
        
    } else if(gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        
        if(abs(velocity.x) > 200) {
            [self flickAway:topPhoto withVelocity:velocity];
            
        } else {
            [self returnToCenter:topPhoto];
        }
        
    }
    
}

-(void)photoTapped:(UITapGestureRecognizer *)gesture {
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    if ([self.delegate respondsToSelector:@selector(didSelectPhoto:)]) {
        [self.delegate didSelectPhoto:self];
    }
}
- (void)resetToCenter{
    self.center = CGPointMake(CGRectGetMidX(self.superview.bounds), CGRectGetMidY(self.superview.bounds));
    self.transform = CGAffineTransformMakeRotation(0);
}
-(void)returnToCenter:(UIView *)photo {
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         photo.center = CGPointMake(CGRectGetMidX(self.superview.bounds), CGRectGetMidY(self.superview.bounds));
                         self.transform = CGAffineTransformMakeRotation(0);
                         lblAccept.alpha = 0;
                         lblDecline.alpha = 0;
                     }];
}

-(void)flickAway:(UIView *)photo withVelocity:(CGPoint)velocity {
    
    if ([self.delegate respondsToSelector:@selector(willFlickAway:withVelocity:)]) {
        [self.delegate willFlickAway:self withVelocity:velocity];
    }

    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat xPos = (velocity.x < 0) ? -width/2 : self.superview.bounds.size.width + width/2;
    CGFloat yPos = CGRectGetHeight(self.superview.bounds);
    CGFloat rVal = (velocity.x < 0) ? -1.57 : 1.57;
    
    if(rVal < 0){
        lblAccept.alpha = 0;
    }else{
        lblDecline.alpha = 0;
    }
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         photo.center = CGPointMake(xPos, yPos);
                         self.transform = CGAffineTransformMakeRotation(rVal);
                         if(rVal>0){
                             lblAccept.alpha = 1;
                         }else{
                             lblDecline.alpha = 1;
                         }
                     }
                     completion:^(BOOL finished){
                         [self setHidden:YES];
                         lblAccept.alpha = 0;
                         lblDecline.alpha = 0;
//                         [self makeCrooked:photo animated:YES];
//                         [self makeStraight:photo animated:YES];
//                         [self returnToCenter:photo];
                         [self resetToCenter];
                         if(velocity.x < 0){
                             if ([self.delegate respondsToSelector:@selector(didDeclineUser:)]) {
                                 [self.delegate didDeclineUser:self];
                             }
                         }else{
                             if ([self.delegate respondsToSelector:@selector(didAcceptUser:)]){
                                 [self.delegate didAcceptUser:self];
                             }
                         }
                     }];
    
}

-(void)makeCrooked:(UIView *)photo animated:(BOOL)animated {
    
    NSInteger min = -(self.rotationOffset);
    NSInteger max = self.rotationOffset;
    
    NSInteger degrees = (arc4random_uniform(max-min+1)) + min;
    [self rotatePhoto:photo degrees:degrees animated:animated];
    
}

-(void)makeStraight:(UIView *)photo animated:(BOOL)animated {
    [self rotatePhoto:photo degrees:0 animated:animated];
}

-(void)rotatePhoto:(UIView *)photo degrees:(NSInteger)degrees animated:(BOOL)animated {
    
    CGFloat radians = M_PI * degrees / 180.0;
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(radians);
    
    if(animated) {
        
        [UIView animateWithDuration:0.2
                         animations:^{
                             photo.transform = transform;
                         }];
        
    } else {
        photo.transform = transform;
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
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [super touchesBegan:touches withEvent:event];
//    
//    if ([self.delegate respondsToSelector:@selector(didSelectPhoto:)]) {
//        // No need to highlight the photo if delegate does not implement a
//        // selection handler (ie. nothing happens when they tap it)
//        [self sendActionsForControlEvents:UIControlStateHighlighted];
//    }
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    [super touchesMoved:touches withEvent:event];
//    [self sendActionsForControlEvents:UIControlEventTouchDragInside];
//}
//
//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    [super touchesEnded:touches withEvent:event];
//    [self sendActionsForControlEvents:UIControlEventTouchCancel];
//}
@end
