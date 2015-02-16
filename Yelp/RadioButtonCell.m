//
//  RadioButtonCell.m
//  Yelp
//
//  Created by Charlie Hu on 2/15/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "RadioButtonCell.h"

@interface RadioButtonCell ()
- (IBAction)onButtonTouched:(UIButton *)sender;

@end

@implementation RadioButtonCell

- (void)awakeFromNib {
    // Initialization code
  _checkBoxChecked = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setCheckBoxChecked:(BOOL)checkBoxChecked {
  _checkBoxChecked = checkBoxChecked;
  if (checkBoxChecked) {
    [self.radioButton setImage:[UIImage imageNamed:@"checkbox-checked-24.png"] forState:UIControlStateNormal];
  } else {
    [self.radioButton setImage:[UIImage imageNamed:@"checkbox-24.png"] forState:UIControlStateNormal];
  }
}

- (IBAction)onButtonTouched:(UIButton *)sender {
  [self setCheckBoxChecked:YES];
  [self.delegate radioButtonCell:self didUpdateValue:YES];
}
@end
