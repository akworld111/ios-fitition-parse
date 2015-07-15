//
//  ISCPostResultTableViewCell.m
//  ActLife
//
//  Created by WuYong on 6/18/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCPostResultTableViewCell.h"
#import <Parse/Parse.h>

@implementation ISCPostResultTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setInitialInfo:(NSMutableDictionary *)initialInfo{
    
    NSString *username = [initialInfo objectForKey:@"Username"];
    PFQuery *query = [PFUser query];
//    [query whereKey:@"username" equalTo:username];
    [query getObjectInBackgroundWithId:username block:^(PFObject *object, NSError *error) {
        if(!error){
            [self.m_lblUsername setText:object[@"username"]];
            PFFile *file = [object objectForKey:@"Photo"];
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                self.m_imgUser.image = [UIImage imageWithData:data];
            }];
        }
    }];
//    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        if(!error){
//            PFFile *file = [object objectForKey:@"Photo"];
//            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//                self.m_imgUser.image = [UIImage imageWithData:data];
//            }];
//        }
//    }];
    
//    [self.m_lblUsername setText:[initialInfo objectForKey:@"Username"]];
    if([[initialInfo objectForKey:@"Winner"]isEqualToString:@"YES"]){
        [self.m_btnWinner setSelected:YES];
    }else{
        [self.m_btnWinner setSelected:NO];
    }
    
    NSUInteger rate = [[initialInfo objectForKey:@"Rate"]integerValue];
    [self setRate:rate];
    
    [self.m_txtDescription setText:[initialInfo objectForKey:@"Description"]];
    
//    if(self.delegate == nil){
//        [self.m_btnRate1 setUserInteractionEnabled:NO];
//        [self.m_btnRate2 setUserInteractionEnabled:NO];
//        [self.m_btnRate3 setUserInteractionEnabled:NO];
//        [self.m_btnRate4 setUserInteractionEnabled:NO];
//        [self.m_btnRate5 setUserInteractionEnabled:NO];
//        [self.m_btnWinner setUserInteractionEnabled:NO];
//    }
    
}
- (void)setRate:(NSUInteger )rate{
    if(rate>0){
        [self.m_btnRate1 setSelected:YES];
    }else{
        [self.m_btnRate1 setSelected:NO];
    }
    if(rate>1){
        [self.m_btnRate2 setSelected:YES];
    }else{
        [self.m_btnRate2 setSelected:NO];
    }
    if(rate>2){
        [self.m_btnRate3 setSelected:YES];
    }else{
        [self.m_btnRate3 setSelected:NO];
    }
    if(rate>3){
        [self.m_btnRate4 setSelected:YES];
    }else{
        [self.m_btnRate4 setSelected:NO];
    }
    if(rate>4){
        [self.m_btnRate5 setSelected:YES];
    }else{
        [self.m_btnRate5 setSelected:NO];
    }
}

- (IBAction)btnWinnerClicked:(id)sender {
    [self.m_btnWinner setSelected:![self.m_btnWinner isSelected]];
    if([self.delegate respondsToSelector:@selector(setWinner:IndexPath:)]){
        [self.delegate setWinner:[self.m_btnWinner isSelected] IndexPath:self.indexPath];
    }
}

- (IBAction)btnRate1Clicked:(id)sender {
    [self setRate:1];
    
    if([self.delegate respondsToSelector:@selector(setRate:IndexPath:)]){
        [self.delegate setRate:1 IndexPath:self.indexPath];
    }
}
- (IBAction)btnRate2Clicked:(id)sender {
    
    [self setRate:2];
    
    if([self.delegate respondsToSelector:@selector(setRate:IndexPath:)]){
        [self.delegate setRate:2 IndexPath:self.indexPath];
    }
}
- (IBAction)btnRate3Clicked:(id)sender {
    [self setRate:3];
    
    if([self.delegate respondsToSelector:@selector(setRate:IndexPath:)]){
        [self.delegate setRate:3 IndexPath:self.indexPath];
    }
}

- (IBAction)btnRate4Clicked:(id)sender {
    
    [self setRate:4];
    
    if([self.delegate respondsToSelector:@selector(setRate:IndexPath:)]){
        [self.delegate setRate:4 IndexPath:self.indexPath];
    }
}

- (IBAction)btnRate5Clicked:(id)sender {
    
    [self setRate:5];
    
    if([self.delegate respondsToSelector:@selector(setRate:IndexPath:)]){
        [self.delegate setRate:5 IndexPath:self.indexPath];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if([self.delegate respondsToSelector:@selector(setDescription:IndexPath:)]){
        [self.delegate setDescription:textView.text IndexPath:self.indexPath];
    }
}
@end
