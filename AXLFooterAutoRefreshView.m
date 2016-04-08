
#import "AXLFooterAutoRefreshView.h"

static const CGFloat kRefreshFooterHeight = 44.f;
static const CGFloat kActivityIndicatorViewSize = 20.0f;

static NSString *const kScrollViewContentOffsetIdentifier = @"contentOffset";
static NSString *const kScrollViewContentSizeIdentifier = @"contentSize";

@implementation AXLFooterAutoRefreshView
{
    UIActivityIndicatorView * _footerActivity;
    BOOL _isRefreshing;
}
- (void)dealloc{
    [_scrollView removeObserver:self forKeyPath:kScrollViewContentOffsetIdentifier];
    [_scrollView removeObserver:self forKeyPath:kScrollViewContentSizeIdentifier];
}

#pragma mark---Init
- (instancetype)init 
{
    self = [super init];
    if (self) {
        
        _autoRefreshEnable = YES;
        _isRefreshing = NO;
        _refreshDistance = 100.f;
        _state = RefreshStateStop;
        self.backgroundColor = [UIColor clearColor];
        self.frame = CGRectMake(0, self.scrollView.contentSize.height, UIScreen_W, 0);
        
        [self __setFooterAnimationView];
        
    }
    return self;
}

- (void)__setFooterAnimationView{
    
    _footerActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _footerActivity.color = [UIColor grayColor];
    _footerActivity.frame = CGRectMake((UIScreen_W - kActivityIndicatorViewSize)/2.0, (kRefreshFooterHeight - kActivityIndicatorViewSize)/2.0, kActivityIndicatorViewSize, kActivityIndicatorViewSize);
    [self addSubview:_footerActivity];
}

#pragma mark--Public
- (void)setFooterAutoRefreshWithScrollView:(UIScrollView *)scrollView andCallBack:(RefreshCallBack)block{
    
    self.callBackBlock = block;
    self.scrollView = scrollView;
    
}

- (void)startRefresh{
    
    _isRefreshing = YES;
    self.state = RefreshStateAnimating;
    
}

- (void)endRefresh{
    
    _isRefreshing = NO;
    self.state = RefreshStateStop;
    
}



#pragma mark---KVO Observe
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    if(_isRefreshing || !_autoRefreshEnable) return;
    
    if([keyPath isEqualToString:kScrollViewContentOffsetIdentifier]){
        [self __scrollViewContentOffsetDidChange:change];
    }
    
    if([keyPath isEqualToString:kScrollViewContentSizeIdentifier]){
        [self __scrollViewContentSizeDidChange:change];
    }

}

// observe the content offset
- (void)__scrollViewContentOffsetDidChange:(NSDictionary *)change{
    
    if(self.state != RefreshStateStop) return;
    
    CGFloat diff = CGRectGetHeight(_scrollView.frame) + _scrollView.contentOffset.y - _scrollView.contentSize.height;
    if(fabs(diff) <= _refreshDistance){
        if(self.callBackBlock){
            
            CGPoint old = [change[@"old"] CGPointValue];
            CGPoint new = [change[@"new"] CGPointValue];
            if (new.y <= old.y) return;
            
            [self startRefresh];
            
            if(self.callBackBlock){
                self.callBackBlock();
            }
            
        }
    }
   
}

// observe the content size
- (void)__scrollViewContentSizeDidChange:(NSDictionary *)change{
  
    CGRect rect = self.frame;
    rect.origin.y = self.scrollView.contentSize.height;
    self.frame = rect;
    
}

- (void)__resetFooterHeight:(CGFloat)height{
  
    CGRect rect = self.frame;
    rect.size.height = height;
    self.frame = rect;

}

- (void)__resetBottomInset:(CGFloat)bottom{
  
    UIEdgeInsets inset = _scrollView.contentInset;
    inset.bottom = bottom;
    _scrollView.contentInset = inset;

}


#pragma mark--Setter
- (void)setScrollView:(UIScrollView *)scrollView{
    
    NSAssert(scrollView != nil, @"Axl scrollView can't be nil");
    
    if(_scrollView){
        _scrollView = nil;
        [_scrollView removeObserver:self forKeyPath:kScrollViewContentOffsetIdentifier];
        [_scrollView removeObserver:self forKeyPath:kScrollViewContentSizeIdentifier];
    }
    _scrollView = scrollView;
    [_scrollView addSubview:self];
    [_scrollView addObserver:self forKeyPath:kScrollViewContentOffsetIdentifier options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [_scrollView addObserver:self forKeyPath:kScrollViewContentSizeIdentifier options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
}

- (void)setState:(RefreshState)state{
  
    if(_state == state) return;
    
    _state = state;
    switch (_state) {
        case RefreshStateAnimating:
        {
            if(!_footerActivity.isAnimating){
                [_footerActivity startAnimating];
            }
            [self __resetFooterHeight:kRefreshFooterHeight];
            [UIView animateWithDuration:.2f animations:^{
                [self __resetBottomInset:kRefreshFooterHeight];
            }];
            
        }
            break;
        case RefreshStateStop:
        {
            // excute this code when the table reload completed
            dispatch_async(dispatch_get_main_queue(), ^{
                [_footerActivity stopAnimating];
                [UIView animateWithDuration:.2f animations:^{

                    [self __resetFooterHeight:0];
                    [self __resetBottomInset:0];
        
                }];
            });
            
        }
            break;
        default:
            break;
    }
 
}

@end
