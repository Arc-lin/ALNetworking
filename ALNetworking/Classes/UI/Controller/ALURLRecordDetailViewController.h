//
//  LMURLRecordDetailViewController.h
//  LMCommonModule
//
//  Created by Arclin on 2019/8/5.
//

#import <UIKit/UIKit.h>

@class ALURLRequestRecord;

NS_ASSUME_NONNULL_BEGIN

@interface ALURLRecordDetailViewController : UITableViewController

@property (nonatomic, strong) ALURLRequestRecord *record;

@end

NS_ASSUME_NONNULL_END
