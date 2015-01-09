
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ExtendableTableView.h"
#import "SRRefreshView.h"

@interface ExtendableTableViewV4 : UITableView<UITableViewDelegate, UITableViewDataSource,SRRefreshDelegate>
{
//	RefreshTableHeader* _headerView;
    SRRefreshView   *_headerView;
    
	NSMutableArray* _cellDataArray;
	LoadingState _loadState;
	id<ExtendableTableViewDelegate> extendDelegate;
	
	NSInteger stepLength;
	NSInteger curIndex;
	CGFloat contentHeight;
	NSString* _contentType;
	
	NSInteger totalNum;
	BOOL endOfTable;
	BOOL freshOff;
	
	UIColor* _headerColor;
	NSTimer* timer;
	
	BOOL useEndOfTableFlag;
	BOOL beSetRefreash;
    
    UIView *footV;
    
    BOOL isNeedSelectionTouch;
    
    //20120907 slan add use cell buffer
    BOOL bolUseCellBuffer;
    
    BOOL setRefreshView;
    
    BOOL isNeedResetTableY;
    BOOL resetOff;
    
    BOOL isNeedHiddenButtom;
    float scrollBeginY;
    //ios8 计算高度
    int rowCount;
}



@property (nonatomic, assign) CGFloat contentHeight;
@property (nonatomic, retain) NSMutableArray* cellDataArray;
//@property (nonatomic, retain) RefreshTableHeader* headerView;
@property (nonatomic, retain) SRRefreshView* headerView;
@property (nonatomic, assign) id<ExtendableTableViewDelegate> extendDelegate;
@property (nonatomic, retain) NSString* contentType;
@property (nonatomic, assign) BOOL freshOff;
@property (nonatomic,assign) BOOL endOfTable;
@property (nonatomic,assign) BOOL isNeedSelectionTouch;
@property (nonatomic,assign) BOOL setRefreshView;
@property (nonatomic,assign) BOOL resetOff;
//20121030
@property (nonatomic,assign) LoadingState _loadState;


@property (nonatomic,assign) BOOL bolUseCellBuffer;

@property (nonatomic, assign) NSInteger stepLength;


@property (nonatomic ,assign) BOOL isNeedResetTableY;


@property (nonatomic,assign)BOOL isNeedHiddenButtom;

- (void)setTableLength:(NSInteger)len;
- (void)refreshExtendTableWithData:(NSArray*)data withParam:(NSDictionary*)param;
- (void)removeFreshHeader;
- (void)hiddenFreshHeader;
- (void)addFreshHeader;
-(void) rebuildFreshHeaderWithWidth:(CGFloat)width;

- (void)replaceHeaderWithView:(UIView*)headv;
- (void)replaceFooterWithView:(UIView*)footv;
- (void)setHeaderViewStyle:(UIColor*)color;
- (void)loadNormalStatus;
- (NSInteger)getTableLength;

-(void) setStatusRefresh;
-(void) setHiddenGetMoreLab:(BOOL)hidden;
-(void) refreshTable:(BOOL)animate;
-(void) refreshTable2;

- (void)setExtendTableStyle:(NSInteger)tablestyle;
-(void)refreshMeTable;

-(void)backupFootView;
-(void) setGetMoreLabOffset;

-(void) listScrollToTop;

@end
