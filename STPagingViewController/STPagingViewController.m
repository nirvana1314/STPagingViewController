//
//  STPagingViewController.m
//  testAutoHomeDetail
//
//  Created by lisongtao on 16/11/25.
//  Copyright © 2016年 lst. All rights reserved.
//

#import "STPagingViewController.h"
#import "UIView+Frame.h"
#import "Masonry.h"
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)

@interface STSubView : UIView
@property (nonatomic, weak) UIWebView *webView;
@property (nonatomic, assign) CGFloat coverPercent;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, weak) UILabel *tipsLabel;
@property (nonatomic, weak) UIView *coverView;
@end

@implementation STSubView

- (void)setup {
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    [self coverView];
    [self tipsLabel];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (UIWebView *)webView {
    if (_webView == nil) {
        UIWebView *webView = [UIWebView new];
        _webView = webView;
        webView.scrollView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
        webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
        webView.frame = self.bounds;
        [self addSubview:webView];
    }
    return _webView;
}

- (UIView *)coverView {
    if (_coverView == nil) {
        UIView *coverView = [[UIView alloc] init];
        coverView.userInteractionEnabled = NO;
        coverView.backgroundColor = [UIColor colorWithRed:0x00 green:0x00 blue:0x00 alpha:0];
        coverView.frame = self.bounds;
        
        _coverView = coverView;
        [self addSubview:coverView];
    }
    return _coverView;
}

- (UILabel *)tipsLabel {
    if (_tipsLabel == nil) {
        UILabel *tipsLabel = [[UILabel alloc] init];
        _tipsLabel = tipsLabel;
        tipsLabel.textColor = [UIColor whiteColor];
        tipsLabel.alpha = 0;
        [self addSubview:tipsLabel];
        
        [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(self).offset(-50);
        }];
        
    }
    return _tipsLabel;
}

- (void)setCoverPercent:(CGFloat)coverPercent {
    _coverPercent = coverPercent;
    
    self.coverView.backgroundColor = [UIColor colorWithRed:0x00 green:0x00 blue:0x00 alpha:coverPercent];
}

- (void)setUrl:(NSString *)url {
    _url = url;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
}

@end



@interface STPagingViewController ()<UIWebViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) UIView *rootView;
@property (nonatomic, weak) STSubView *topView;
@property (nonatomic, weak) STSubView *midView;
@property (nonatomic, weak) STSubView *bottomView;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, weak) UILabel *indexLabel;
@property (nonatomic, weak) UITableView *pageNumTableView;
@property (nonatomic, strong) UIPanGestureRecognizer *pullDownPan;
@property (nonatomic, strong) UIPanGestureRecognizer *pullUpPan;
/** 是否应该翻页 */
@property (nonatomic, assign) BOOL needPaging;
@property (nonatomic, strong) NSArray *dataSourceArr;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) UITapGestureRecognizer *titleViewGR;
/** 弹出选择页面号码的cover */
@property (nonatomic, weak) UIView *coverView;
@end

static CGFloat pagingValue = 100;
@implementation STPagingViewController

- (void)setDataSourceArr:(NSArray *)dsArr CurrentIndex:(NSInteger)currentIndex {
    self.dataSourceArr = dsArr;
    self.currentIndex = currentIndex;
    if (currentIndex + 1 >= 0 && currentIndex + 1 < dsArr.count) {
        self.bottomView.url = dsArr[currentIndex + 1];
    }
    if (currentIndex >= 0 && currentIndex < dsArr.count) {
        self.midView.url = dsArr[currentIndex];
    }
    if (currentIndex - 1 >= 0 && currentIndex - 1 < dsArr.count) {
        self.topView.url = dsArr[currentIndex - 1];
    }
    
    self.indexLabel.text = [NSString stringWithFormat:@"%tu/%tu", self.currentIndex + 1, self.dataSourceArr.count];
    
    [self coverView];
    if (dsArr.count > 6) {
        self.pageNumTableView.height = 35 * 6;
    }else {
        self.pageNumTableView.height = 35 * dsArr.count;
    }
    self.pageNumTableView.bottom = 0;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.titleView = self.titleView;
    
}

- (void)titleViewDidClick:(UITapGestureRecognizer *)gr {
    if (gr.view.tag == 0) {
        gr.view.tag = 1;
    }else {
        gr.view.tag = 0;
    }
    
    if (gr.view.tag == 1) {
        [UIView animateWithDuration:0.2 animations:^{
            self.pageNumTableView.y = 64;
            self.coverView.alpha = 1;
        }];
    }else {
        [UIView animateWithDuration:0.2 animations:^{
            self.pageNumTableView.bottom = 0;
            self.coverView.alpha = 0;
        }];
    }
}

- (void)coverViewClick {
    [self titleViewDidClick:self.titleViewGR];
}

- (void)pullDownPan:(UIPanGestureRecognizer *)rec {
    CGPoint point = [rec translationInView:self.view];
    if (self.midView.webView.scrollView.contentOffset.y <= 0 && self.needPaging == YES) {
        NSLog(@"下拉!!!");
        NSLog(@"下拉!!!");
        NSLog(@"下拉!!!");
        if (point.y > 0) {
            self.midView.webView.scrollView.scrollEnabled = NO;
        }
        if (self.currentIndex - 1 >= 0) {
            self.midView.tipsLabel.text = [NSString stringWithFormat:@"下翻至第%tu页", self.currentIndex];
        }
    }else {
        return;
    }
    switch (rec.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"UIGestureRecognizerStateBegan");
            
            break;
        case UIGestureRecognizerStateChanged:
            NSLog(@"UIGestureRecognizerStateChanged");
            
            self.topView.bottom = self.topView.bottom + point.y;
            self.midView.coverPercent = self.topView.bottom / kScreenHeight;
            if (self.currentIndex - 1 >= 0) {
                self.midView.tipsLabel.alpha = 1;
            }
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"UIGestureRecognizerStateEnded");
            if (self.topView.bottom > pagingValue) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.topView.y = 0;
                } completion:^(BOOL finished) {
                    [self resetStatusWithPullDown];
                }];
            }else {
                [UIView animateWithDuration:0.3 animations:^{
                    self.topView.bottom = 0;
                } completion:^(BOOL finished) {
                    [self resetStatus];
                }];
            }
            
            self.midView.webView.scrollView.scrollEnabled = YES;
            break;
            
        default:
            NSLog(@"default");
            break;
    }
    [rec setTranslation:CGPointMake(0, 0) inView:self.view];
}

- (void)pullUpPan:(UIPanGestureRecognizer *)rec {
    CGPoint point = [rec translationInView:self.view];
    NSLog(@"pullUpPan==%f",point.y);
    if (self.midView.webView.scrollView.contentOffset.y + kScreenHeight >= self.midView.webView.scrollView.contentSize.height && self.needPaging == YES) {
        NSLog(@"上拉!!!");
        NSLog(@"上拉!!!");
        NSLog(@"上拉!!!");
        if (point.y < 0) {
            self.midView.webView.scrollView.scrollEnabled = NO;
        }
        if (self.currentIndex < self.dataSourceArr.count - 1) {
            self.bottomView.tipsLabel.text = [NSString stringWithFormat:@"上翻至第%tu页", self.currentIndex + 2];
        }
    }else {
        return;
    }
    switch (rec.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"UIGestureRecognizerStateBegan");
            
            break;
        case UIGestureRecognizerStateChanged:
            NSLog(@"UIGestureRecognizerStateChanged");
            
            self.midView.bottom = self.midView.bottom + point.y;
            self.bottomView.coverPercent = self.midView.bottom / kScreenHeight;
            if (self.currentIndex < self.dataSourceArr.count - 1) {
                self.bottomView.tipsLabel.alpha = 1;
            }
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"UIGestureRecognizerStateEnded");
            if (self.midView.bottom > kScreenHeight - pagingValue) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.midView.bottom = kScreenHeight;
                } completion:^(BOOL finished) {
                    [self resetStatus];
                }];;
            }else {
                [UIView animateWithDuration:0.3 animations:^{
                    self.midView.bottom = 0;
                } completion:^(BOOL finished) {
                    [self resetStatusWithPullUp];
                }];
            }
            self.midView.webView.scrollView.scrollEnabled = YES;
            break;
            
        default:
            NSLog(@"default");
            break;
    }
    [rec setTranslation:CGPointMake(0, 0) inView:self.view];
}

- (void)resetStatusWithPullDown {
    STSubView *temp;
    temp = self.bottomView;
    self.bottomView = self.midView;
    self.midView = temp;
    
    STSubView *temp2;
    temp2 = self.topView;
    self.topView = self.midView;
    self.midView = temp2;
    
    self.topView.bottom = 0;
    [self.rootView bringSubviewToFront:self.topView];
    self.currentIndex -= 1;
    
    // 重置状态
    [self resetStatus];
    
    if (self.currentIndex < 1) {
        return;
    }
    self.topView.url = self.dataSourceArr[self.currentIndex - 1];
    
}

- (void)resetStatusWithPullUp {
    STSubView *temp;
    temp = self.bottomView;
    self.bottomView = self.midView;
    self.midView = temp;
    
    STSubView *temp2;
    temp2 = self.topView;
    self.topView = self.bottomView;
    self.bottomView = temp2;
    
    self.bottomView.y = 0;
    [self.rootView sendSubviewToBack:self.bottomView];
    self.currentIndex += 1;
    // 重置状态
    [self resetStatus];
    
    if (self.currentIndex + 1 > self.dataSourceArr.count - 1) {
        return;
    }
    self.bottomView.url = self.dataSourceArr[self.currentIndex + 1];
}

- (void)resetStatus {
    [UIView animateWithDuration:0.2 animations:^{
        self.midView.coverPercent = 0;
        self.topView.coverPercent = 0;
        self.bottomView.coverPercent = 0;
    }];
    
    self.topView.tipsLabel.alpha = 0;
    self.midView.tipsLabel.alpha = 0;
    self.bottomView.tipsLabel.alpha = 0;
    
    /** 重置代理 */
    self.topView.webView.scrollView.delegate = nil;
    self.bottomView.webView.scrollView.delegate = nil;
    self.midView.webView.scrollView.delegate = self;
    
    
    self.topView.webView.scrollView.scrollsToTop = NO;
    self.midView.webView.scrollView.scrollsToTop = YES;
    self.bottomView.webView.scrollView.scrollsToTop = NO;
    
    
    /** resetContentLocation */
    //    window.scrollTo(0,999999)
    //    window.scrollTo(0,document.body.scrollHeight)
    NSString *scrollToBottom = @"window.scrollTo(0,document.body.scrollHeight)";
    NSString *scrollToTop = @"window.scrollTo(0,0)";
    [self.topView.webView stringByEvaluatingJavaScriptFromString:scrollToBottom];
    [self.bottomView.webView stringByEvaluatingJavaScriptFromString:scrollToTop];
    
    self.indexLabel.text = [NSString stringWithFormat:@"%tu/%tu", self.currentIndex + 1, self.dataSourceArr.count];
    [self.pageNumTableView reloadData];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"scrollViewWillBeginDragging");
    if (scrollView.contentOffset.y + kScreenHeight >= scrollView.contentSize.height && self.currentIndex == self.dataSourceArr.count - 1) {
        [UIView animateWithDuration:0.2 animations:^{
            self.midView.tipsLabel.alpha = 1;
        }];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidEndScrollingAnimation");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSLog(@"scrollViewDidEndDragging");
    if (self.currentIndex == self.dataSourceArr.count - 1) {
        [UIView animateWithDuration:0.2 animations:^{
            self.midView.tipsLabel.alpha = 0;
        }];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidEndDecelerating-%f", scrollView.contentSize.height - scrollView.contentOffset.y - kScreenHeight);
    
    if (scrollView.contentOffset.y <= 0 || scrollView.contentOffset.y + kScreenHeight >= scrollView.contentSize.height) {
        self.needPaging = YES;
        if (scrollView.contentOffset.y <= 0) {
            if (self.currentIndex == 0) {
                [self.midView removeGestureRecognizer:self.pullDownPan];
                [self.midView removeGestureRecognizer:self.pullUpPan];
            }else {
                [self.midView addGestureRecognizer:self.pullDownPan];
            }
            
        }else if (scrollView.contentOffset.y + kScreenHeight >= scrollView.contentSize.height){
            if (self.currentIndex == self.dataSourceArr.count - 1) {
                [self.midView removeGestureRecognizer:self.pullDownPan];
                [self.midView removeGestureRecognizer:self.pullUpPan];
                
                self.midView.tipsLabel.text = @"已经到最后一页啦";
                self.midView.tipsLabel.alpha = 0;
            }else {
                [self.midView addGestureRecognizer:self.pullUpPan];
            }
        }
    }else {
        self.needPaging = NO;
    }
    
    [self resetStatus];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (webView == self.topView.webView || webView == self.bottomView.webView) {
        [self resetStatus];
    }
    
    NSLog(@"self.midView.webView.scrollView.contentInset.top==%f", self.midView.webView.scrollView.contentInset.top);
    NSLog(@"self.topView.webView.scrollView.contentInset.top==%f", self.topView.webView.scrollView.contentInset.top);
    NSLog(@"self.bottomView.webView.scrollView.contentInset.top==%f", self.bottomView.webView.scrollView.contentInset.top);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:reuseID];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"第%tu页", indexPath.row + 1];
    if (indexPath.row == self.currentIndex) {
        cell.textLabel.textColor = [UIColor blueColor];
    }else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self selectIndex:indexPath.row];
}

- (void)selectIndex:(NSInteger)index {
    self.currentIndex = index;
    [self resetStatus];
    if (self.currentIndex + 1 >= 0 && self.currentIndex + 1 < self.dataSourceArr.count) {
        self.bottomView.url = self.dataSourceArr[self.currentIndex + 1];
    }
    if (self.currentIndex >= 0 && self.currentIndex < self.dataSourceArr.count) {
        self.midView.url = self.dataSourceArr[self.currentIndex];
    }
    if (self.currentIndex - 1 >= 0 && self.currentIndex - 1 < self.dataSourceArr.count) {
        self.topView.url = self.dataSourceArr[self.currentIndex - 1];
    }
    
    if (self.currentIndex == 0) {
        [self.midView addGestureRecognizer:self.pullUpPan];
    }else if (self.currentIndex == self.dataSourceArr.count - 1) {
        [self.midView addGestureRecognizer:self.pullDownPan];
    }
    [self coverViewClick];
}

#pragma mark - lazy
- (UIPanGestureRecognizer *)pullDownPan {
    if (_pullDownPan == nil) {
        _pullDownPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pullDownPan:)];
        _pullDownPan.delegate = self;
        
    }
    return _pullDownPan;
}

- (UIPanGestureRecognizer *)pullUpPan {
    if (_pullUpPan == nil) {
        _pullUpPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pullUpPan:)];
        _pullUpPan.delegate = self;
    }
    return _pullUpPan;
}

- (NSArray *)dataSourceArrAtIndexes:(NSIndexSet *)indexes {
    if (_dataSourceArr == nil) {
        _dataSourceArr = [[NSArray alloc] init];
        
    }
    return _dataSourceArr;
}

- (UIView *)rootView {
    if (_rootView == nil) {
        UIView *rootView = [[UIView alloc] init];
        _rootView = rootView;
        rootView.backgroundColor = [UIColor blackColor];
        rootView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        [self.view addSubview:rootView];
    }
    return _rootView;
}

- (STSubView *)bottomView {
    if (_bottomView == nil) {
        STSubView *bottomView = [[STSubView alloc] initWithFrame:self.rootView.bounds];
        _bottomView = bottomView;
        bottomView.webView.delegate = self;
        bottomView.coverPercent = 0;
        [self.rootView addSubview:bottomView];
    }
    return _bottomView;
}

- (STSubView *)midView {
    if (_midView == nil) {
        STSubView *midView = [[STSubView alloc] initWithFrame:self.rootView.bounds];
        _midView = midView;
        midView.webView.scrollView.delegate = self;
        midView.webView.delegate = self;
        [midView addGestureRecognizer:self.pullDownPan];
        midView.coverPercent = 0;
        [self.rootView addSubview:midView];
    }
    return _midView;
}

- (STSubView *)topView {
    if (_topView == nil) {
        STSubView *topView = [[STSubView alloc] initWithFrame:self.rootView.bounds];
        topView.bottom = 0;
        _topView = topView;
        topView.webView.delegate = self;
        topView.coverPercent = 0;
        [self.rootView addSubview:topView];
    }
    return _topView;
}

- (UIView *)titleView {
    if (_titleView == nil) {
        _titleView = [[UIView alloc] init];
        _titleView.width = 50;
        _titleView.height = 44;
        UITapGestureRecognizer *titleViewGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleViewDidClick:)];
        self.titleViewGR = titleViewGR;
        [_titleView addGestureRecognizer:titleViewGR];
        
        UILabel *indexLabel = [UILabel new];
        self.indexLabel = indexLabel;
        [_titleView addSubview:indexLabel];
        
        [indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_titleView);
            make.left.equalTo(_titleView).offset(10);
        }];
        
    }
    return _titleView;
}

- (UITableView *)pageNumTableView {
    if (_pageNumTableView == nil) {
        UITableView *pageNumTableView = [[UITableView alloc] init];
        pageNumTableView.delegate = self;
        pageNumTableView.dataSource = self;
        _pageNumTableView = pageNumTableView;
        pageNumTableView.width = kScreenWidth;
        pageNumTableView.height = 100;
        pageNumTableView.bottom = 0;
        [self.view addSubview:pageNumTableView];
    }
    return _pageNumTableView;
}

- (UIView *)coverView {
    if (_coverView == nil) {
        UIView *coverView = [[UIView alloc] init];
        _coverView = coverView;
        coverView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        coverView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        coverView.alpha = 0;
        [coverView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverViewClick)]];
        [self.view addSubview:coverView];
    }
    return _coverView;
}

@end
