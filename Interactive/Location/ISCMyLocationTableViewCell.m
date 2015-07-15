//
//  ISCMyLocationTableViewCell.m
//  ActLife
//
//  Created by WuYong on 6/16/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCMyLocationTableViewCell.h"
#import <Parse/Parse.h>


@implementation ISCMyLocationTableViewCell

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

- (IBAction)btnInviteClicked:(id)sender {
    if([self.delegate respondsToSelector:@selector(btnInviteClicked:)]){
        [self.delegate btnInviteClicked:self.m_lblUser.text];
    }
}
@end
