
#import "ExtendableTableViewV4.h"
#import "GPTabView.h"
@protocol GTableViewDelegate
@optional
-(void) clickCell:(id)sender; // GDataObjectV2 or GPView
-(NSArray*) loadMoreTableFrom:(NSString*)index withNum:(NSString*)num andParam:(NSString*)param;
-(NSArray*) reloadTableWithData:(id)data;
@end

@class GDataObjectV2;

@interface GTableViewV3 : ExtendableTableViewV4 <ExtendableTableViewDelegate>
{
	id<GTableViewDelegate>  tableDelegate;
    NSMutableArray*         dataArray;
}

@property (nonatomic,assign) id<GTableViewDelegate>     tableDelegate;
@property (nonatomic,readonly) NSMutableArray*          dataArray;

-(void) resetCell;
-(void) appendCell:(GDataObjectV2*)data;
-(void) insterToFirstCell:(GDataObjectV2*)data;
-(void) reloadCell;
-(int) getDataLength;
-(float) getAllCellHeight;

-(void)backupFootView;

@end
