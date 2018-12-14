// Copyright 2018-present the Material Components for iOS authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "MDCChipTextFieldScrollView.h"

@interface MDCChipTextFieldScrollView ()

@property (nonatomic, readwrite, strong) NSMutableArray<MDCChipView *> *chipViews;
@property (nonatomic, readwrite, weak) UIView *contentView;
@property (nonatomic, readwrite, weak) NSLayoutConstraint *trailingConstraint;

@end

@implementation MDCChipTextFieldScrollView
@synthesize delegate=_delegate;

- (instancetype)initWithFrame:(CGRect)frame {
  if((self = [super initWithFrame:frame])) {
    [self commonInit];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  if((self = [super initWithCoder:aDecoder])) {
    [self commonInit];
  }
  return self;
}

- (void)commonInit {
  // set up content view
  UIView *contentView = [[UIView alloc] initWithFrame:self.frame];
  [self addSubview:contentView];
  self.contentView = contentView;

  self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
  NSLayoutConstraint *contentConstraintTop = [NSLayoutConstraint constraintWithItem:contentView
                                                                       attribute:NSLayoutAttributeTop
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self
                                                                       attribute:NSLayoutAttributeTop
                                                                      multiplier:1
                                                                        constant:0];
  NSLayoutConstraint *contentConstraintBottom = [NSLayoutConstraint constraintWithItem:contentView
                                                                          attribute:NSLayoutAttributeBottom
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self
                                                                          attribute:NSLayoutAttributeBottom
                                                                         multiplier:1
                                                                           constant:0];
  NSLayoutConstraint *contentConstraintLeading = [NSLayoutConstraint constraintWithItem:contentView
                                                                          attribute:NSLayoutAttributeLeading
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self
                                                                          attribute:NSLayoutAttributeLeading
                                                                         multiplier:1
                                                                           constant:0];
  NSLayoutConstraint *contentConstraintTrailing = [NSLayoutConstraint constraintWithItem:contentView
                                                                              attribute:NSLayoutAttributeTrailing
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self
                                                                              attribute:NSLayoutAttributeTrailing
                                                                             multiplier:1
                                                                               constant:0];
  NSLayoutConstraint *heightContstraint = [NSLayoutConstraint constraintWithItem:contentView
                                                                               attribute:NSLayoutAttributeHeight
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self
                                                                               attribute:NSLayoutAttributeHeight
                                                                              multiplier:1
                                                                                constant:0];
  [self addConstraints:@[contentConstraintTop, contentConstraintBottom, contentConstraintLeading, contentConstraintTrailing, heightContstraint]];
  self.trailingConstraint = contentConstraintTrailing;
  
  [self setShowsVerticalScrollIndicator:NO];
  [self setShowsHorizontalScrollIndicator:NO];

  self.chipViews = [[NSMutableArray alloc] init];
}

- (void)reloadData {
  NSInteger numberOfChipViews = [self.dataSource numberOfChipViewsInScrollView:self];
  NSMutableArray *mutableChipViews = [[NSMutableArray alloc] initWithCapacity:numberOfChipViews];
  for (NSInteger index = 0; index < numberOfChipViews; ++index) {
    mutableChipViews[index] = [self.dataSource scrollView:self chipViewForIndex:index];
  }
  self.chipViews = [mutableChipViews copy];

  // update layout
  CGSize updatedContentViewSize = [self calculateContentSize];
  self.contentView.frame = CGRectMake(0, 0, updatedContentViewSize.width, updatedContentViewSize.height);
  self.contentSize = self.contentView.frame.size;

  // TODO: refactor for performance, right now we reattach everything for every reload
  for (UIView *subview in self.contentView.subviews) {
    [subview removeFromSuperview];
  }
  CGFloat chipOffsetX = 0.0f;
  for (MDCChipView *chipView in self.chipViews) {
    [self.contentView addSubview:chipView];
    chipView.frame = CGRectMake(chipOffsetX, 0, CGRectGetWidth(chipView.frame), CGRectGetHeight(chipView.frame));
    chipOffsetX += self.chipSpacing;
    chipOffsetX += CGRectGetWidth(chipView.frame);
  }
}

- (void)appendChip:(MDCChipView *)chipView {
  [self removeConstraint:self.trailingConstraint];
  [self.contentView addSubview:chipView];
  chipView.translatesAutoresizingMaskIntoConstraints = NO;
  NSLayoutConstraint *contentConstraintTop = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                          attribute:NSLayoutAttributeTop
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:chipView
                                                                          attribute:NSLayoutAttributeTop
                                                                         multiplier:1
                                                                           constant:0];
  NSLayoutConstraint *contentConstraintBottom = [NSLayoutConstraint constraintWithItem: self.contentView
                                                                             attribute:NSLayoutAttributeBottom
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:chipView
                                                                             attribute:NSLayoutAttributeBottom
                                                                            multiplier:1
                                                                              constant:0];
  NSLayoutConstraint *newLeadingConstraint = nil;
  if (self.chipViews.count == 0) {
    newLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                        attribute:NSLayoutAttributeLeading
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:chipView
                                                        attribute:NSLayoutAttributeLeading
                                                       multiplier:1
                                                         constant:0];
  } else {
    newLeadingConstraint = [NSLayoutConstraint constraintWithItem:chipView
                                                        attribute:NSLayoutAttributeLeading
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:[self.chipViews lastObject]
                                                        attribute:NSLayoutAttributeTrailing
                                                       multiplier:1
                                                         constant:0];

  }
  NSLayoutConstraint *newTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                           attribute:NSLayoutAttributeTrailing
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:chipView
                                                                           attribute:NSLayoutAttributeTrailing
                                                                          multiplier:1
                                                                            constant:0];
  [self.contentView addConstraints:@[contentConstraintTop, contentConstraintBottom, newLeadingConstraint, newTrailingConstraint]];
  self.trailingConstraint = newTrailingConstraint;
  [self.chipViews addObject:chipView];
}

- (CGSize)calculateContentSize {
  __block CGFloat widthSum = 0.0f;
  [self.chipViews enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
    MDCChipView *chipView = (MDCChipView *)object;
    widthSum += CGRectGetWidth(chipView.frame);
  }];
  NSInteger numberOfChipViews = self.chipViews.count;
  widthSum += MAX(numberOfChipViews - 1, 0) * self.chipSpacing;
  return CGSizeMake(widthSum, CGRectGetHeight(self.frame));
}

@end
