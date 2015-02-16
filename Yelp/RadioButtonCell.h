//
//  RadioButtonCell.h
//  Yelp
//
//  Created by Charlie Hu on 2/15/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RadioButtonCell;

@protocol RadioButtonCellDelegate <NSObject>

- (void)radioButtonCell:(RadioButtonCell *)cell didUpdateValue:(BOOL)value;

@end

@interface RadioButtonCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *radioButtonTitle;
@property (nonatomic, assign) BOOL checkBoxChecked;
@property (weak, nonatomic) IBOutlet UIButton *radioButton;

@property (nonatomic, weak) id<RadioButtonCellDelegate> delegate;

- (void)setCheckBoxChecked:(BOOL)checkBoxChecked;

@end
