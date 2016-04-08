
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RefreshState) {
    RefreshStateAnimating,
    RefreshStateStop
};

typedef void(^RefreshCallBack)(void);

@interface AXLFooterAutoRefreshView : UIView

@property (nonatomic,assign) CGFloat refreshDistance; //defeault is 100.f

@property (nonatomic,strong) UIScrollView *scrollView;

@property (nonatomic,  copy) RefreshCallBack callBackBlock;

@property (nonatomic,assign) RefreshState state;

@property (nonatomic,assign) BOOL autoRefreshEnable; //defeault is yes

- (void)setFooterAutoRefreshWithScrollView:(UIScrollView *)scrollView andCallBack:(RefreshCallBack)block;

- (void)startRefresh; // it's not necessarily to call this function besides you want to satart refresh immediately

- (void)endRefresh;

@end
