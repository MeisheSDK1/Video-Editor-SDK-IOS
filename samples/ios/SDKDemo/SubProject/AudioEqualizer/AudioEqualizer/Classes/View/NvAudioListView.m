//
//  NvAudioListView.m
//  AudioEqualizer
//
//  Created by ms on 2022/1/7.
//

#import "NvAudioListView.h"
#import <Masonry/Masonry.h>
#import <NvBaseCommon/NVDefineConfig.h>
#import <NvBaseCommon/NvBaseUtils.h>
#import <NvBaseCommon/UIColor+NvColor.h>
#import "NvAudioListModel.h"

@interface NvAudioListCell: UITableViewCell

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NvAudioListModel *model;
@end

@implementation NvAudioListCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor nv_colorWithHexString:@"3C3C3C"];
        [self addSubviews];
    }
    return self ;
}

-(void)addSubviews{
    self.iconImageView = [[UIImageView alloc]init];
    self.iconImageView.image = NvImageNamed(@"NvAudioListSelect");
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.iconImageView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KScale6s(10));
        make.centerY.equalTo(self.contentView);
        make.width.offset(9.0 * SCREENSCALE);
        make.height.offset(19.0 / 2 * SCREENSCALE);
    }];
    
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.textColor = [UIColor nv_colorWithHexRGB:@"#DDDDDD"];
    self.titleLabel.font = [NvBaseUtils fontWithSize:11];
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconImageView).offset(15.0f * SCREENSCALE);
        make.centerY.equalTo(self.contentView);
        make.height.mas_equalTo(15.0f);
        make.right.mas_equalTo(self.contentView).offset(-5.0f * SCREENSCALE);
    }];
}

-(void)setModel:(NvAudioListModel *)model{
    _model = model;
    self.iconImageView.hidden = !model.isSelected;
    self.titleLabel.text = model.name;
}

@end

@interface NvAudioListView()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

static NSString *const NvAudioListCellID = @"NvAudioListCell";
@implementation NvAudioListView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        [self initSubviews];
 
    }
    return self;
}


-(void)initData{
    self.dataSource = [NSMutableArray array];
    NSArray *data = @[NvLocalStringFromTable([self class],@"Popular", @"流行"),
                      NvLocalStringFromTable([self class],@"Dance music", @"舞曲"),
                      NvLocalStringFromTable([self class],@"Blues", @"蓝调"),
                      NvLocalStringFromTable([self class],@"Classical", @"古典"),
                      NvLocalStringFromTable([self class],@"Jazz", @"爵士"),
                      NvLocalStringFromTable([self class],@"Slow song", @"慢歌"),
                      NvLocalStringFromTable([self class],@"Electronic music", @"电子乐"),
                      NvLocalStringFromTable([self class],@"Rock", @"摇滚"),
                      NvLocalStringFromTable([self class],@"Rural", @"乡村"),
                      NvLocalStringFromTable([self class],@"voice", @"人声"),
                      NvLocalStringFromTable([self class],@"Custom", @"自定义"),
                      NvLocalStringFromTable([self class],@"30 segment equalizer", @"30段均衡器")];
    for (NSString *name in data) {
        NvAudioListModel *model = [[NvAudioListModel alloc] init];
        model.name = name;
        model.isSelected = NO;
        if ([name isEqualToString:NvLocalStringFromTable([self class],@"Custom", @"自定义")]) {
            model.isSelected = YES;
        }
        [self.dataSource addObject:model];
    }
        
}

-(void)initSubviews{
    self.listTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.listTableView.backgroundColor = [UIColor nv_colorWithHexString:@"#3C3C3C"];
    self.listTableView.dataSource = self;
    self.listTableView.delegate = self;
    [self.listTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self addSubview:self.listTableView];
    [self.listTableView registerClass:[NvAudioListCell class] forCellReuseIdentifier:NvAudioListCellID];
    [self.listTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-25.0 *SCREENSCALE);
        make.top.mas_equalTo(self);
        make.width.mas_equalTo(100.0 *SCREENSCALE);
        make.bottom.mas_equalTo(self).offset(-50.0);
    }];
    [self.listTableView reloadData];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bagTap)];
    recognizer.delegate = self;
    [self addGestureRecognizer:recognizer];
}

-(void)bagTap{
    self.hidden = !self.hidden;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:self.listTableView]) {
        return NO;
    }
    return YES;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 25.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NvAudioListCell *cell = [self.listTableView dequeueReusableCellWithIdentifier:NvAudioListCellID forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.model = self.dataSource[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    for (NvAudioListModel *model in self.dataSource) {
        model.isSelected = NO;
    }
    NvAudioListModel *model = self.dataSource[indexPath.row];
    model.isSelected = YES;
    [tableView reloadData];
    if (self.selectBlock) {
        self.selectBlock(model.name, indexPath.row);
    }
}
@end
