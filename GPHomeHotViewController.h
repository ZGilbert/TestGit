
#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "GTableViewV2.h"
#import "GTableViewV3.h"
#import "GPController.h"

@interface GPHomeHotViewController : BaseViewController<GPControllerDelegate,ExtendableTableViewDelegate>
{
    GTableViewV2* list1; // hot image
    BOOL isFirstLoad;
    int offset;
    
    GTableViewV3* list2; // hot square
    
    UIView* tabbg;
    UIView* tabLine;
    UIButton* currentBtn;
    UIButton* oldBtn;
    GTableViewV2* oldList;
    
    UILabel* tab1;
    UILabel* tab2;
    
    id<ExtendableTableViewDelegate> _extendDelegate;
}

+(GPHomeHotViewController*) sharedHomeHotViewController;
@property (nonatomic, retain) NSArray* hotSquareArr;
@property (nonatomic, assign) int tabIndex;
@property (nonatomic, assign) id<ExtendableTableViewDelegate> extendDelegate;

-(void) setTabSelect:(int)index; // only 0 | 1
- (NSInteger)adc:(UITableView *)table numberOfRowsInSection:(NSInteger)section;

@end
