//
//  LMURLRecordDetailCell.m
//  LMCommonModule
//
//  Created by Arclin on 2019/8/5.
//

#import "ALURLRecordDetailCell.h"

#import "Masonry.h"

@interface ALURLRecordDetailCell()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *resposneLabel;

@end

@implementation ALURLRecordDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}
        
- (void)setup
{
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 , 15, 50, 20)];
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(15);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(20);
    }];
    
    self.resposneLabel = [[UILabel alloc] init];
    self.resposneLabel.font = [UIFont systemFontOfSize:15];
    self.resposneLabel.numberOfLines = 0;
    [self.contentView addSubview:self.resposneLabel];
    [self.resposneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_right).offset(5);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(15);
        make.height.greaterThanOrEqualTo(@20);
        make.bottom.mas_equalTo(-10);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
