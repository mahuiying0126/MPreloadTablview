//
//  TestTableViewCell.m
//  MLoadMoreService
//
//  Created by yizhilu on 2017/9/12.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import "TestTableViewCell.h"
#import <YYKit.h>
@implementation TestTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLB = [[UILabel alloc]init];
        self.textLB.left = 10;
        self.textLB.top = 10;
        self.textLB.width = [UIScreen mainScreen].bounds.size.width-20;
        self.textLB.height = self.contentView.height;
        self.textLB.numberOfLines = 0;
        
        [self.contentView addSubview:self.textLB];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
