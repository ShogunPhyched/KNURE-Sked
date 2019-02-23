//
//  PFNavigationDropdownMenu.h
//  PFNavigationDropdownMenu
//
//  Created by Cee on 02/08/2015.
//  Copyright (c) 2015 Cee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFTableView.h"

@protocol PFNavigationDropdownMenuDelegate <NSObject>

@required
- (void)didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface PFNavigationDropdownMenu : UIView

@property (weak, nonatomic) id <PFNavigationDropdownMenuDelegate> delegate;

@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, strong) UIColor *cellBackgroundColor;
@property (nonatomic, strong) UIColor *cellTextLabelColor;
@property (nonatomic, strong) UIFont *cellTextLabelFont;
@property (nonatomic, strong) UIColor *cellSelectionColor;
@property (nonatomic, strong) UIImage *checkMarkImage;
@property (nonatomic, strong) UIImage *arrowImage;
@property (nonatomic, assign) CGFloat arrowPadding;
@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, strong) UIColor *maskBackgroundColor;
@property (nonatomic, assign) CGFloat maskBackgroundOpacity;
@property (nonatomic, strong) PFTableView *tableView;
@property (nonatomic, copy) void(^didSelectItemAtIndexHandler)(NSUInteger indexPath);
@property (nonatomic, assign) BOOL isShown;

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title items:(NSArray *)items containerView:(UIView *)containerView;

- (void)hideMenu;

@end
