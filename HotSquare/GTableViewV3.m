
#import "GTableViewV3.h"
#import "GDataObjectV2.h"

@implementation GTableViewV3
@synthesize tableDelegate,dataArray;

-(id) initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame style:UITableViewStylePlain])) 
	{
        dataArray=[[NSMutableArray alloc] init];
        self.extendDelegate=self;
        
        self.scrollEnabled=YES;
        self.scrollsToTop=YES;
	}
    return self;
}

-(void) awakeFromNib
{
    [super awakeFromNib];
    dataArray=[[NSMutableArray alloc] init];
    self.extendDelegate=self;
    
    self.scrollEnabled=YES;
    self.scrollsToTop=YES;
}
-(BOOL) scrollViewShouldScrollToTop:(UIScrollView*)scrollView
{
    return YES; 
}

-(void) resetCell
{
    [dataArray removeAllObjects];
	//[self reloadCell];
}

-(void) appendCell:(GDataObjectV2*)data
{
    if (!dataArray) {
        dataArray=[[NSMutableArray alloc] init];
    }
    [dataArray addObject:data];
}

-(void) insterToFirstCell:(GDataObjectV2*)data
{
    if (!dataArray) {
        dataArray=[[NSMutableArray alloc] init];
    }
    [dataArray insertObject:data atIndex:0];
}

-(int) getDataLength
{
    if (dataArray) {
        return [dataArray count];
    }
    return 0;
}

-(float) getAllCellHeight
{
    float height=0;
    for(GDataObjectV2* cell in dataArray)
    {
        height+=[cell getCellHeight];
    }
    
    return height;
}

-(void) reloadCell
{
    [self refreshExtendTableWithData:dataArray withParam:nil];
}

// for ExtendableTableViewDelegate
-(CGFloat) heightForRow:(NSInteger)row atTable:(UITableView*)table 
{
    if(dataArray!=nil && row<[dataArray count])
    {
        GDataObjectV2* data=[dataArray objectAtIndex:row];
        if(data!=nil && [data isKindOfClass:[GDataObjectV2 class]])
            return [data getCellHeight];
    }
    
	return 80;
}

-(void) didSelectRow:(NSInteger)row atTable:(UITableView*)table withData:(id)data 
{
    if(dataArray==nil || row>=[dataArray count])
        return;
    
    if(tableDelegate!=nil && [(NSObject*)tableDelegate respondsToSelector:@selector(clickCell:)])
    {
        GDataObjectV2* data=[dataArray objectAtIndex:row];
        if(data!=nil && [data isKindOfClass:[GDataObjectV2 class]])
            [tableDelegate clickCell:data];
    }
}

-(NSArray*) loadMoreTableFrom:(NSString*)index withNum:(NSString*)num andParam:(NSString*)param
{
    if(tableDelegate!=nil && [(NSObject*)tableDelegate respondsToSelector:@selector(loadMoreTableFrom:withNum:andParam:)])
    {
        return [tableDelegate loadMoreTableFrom:index withNum:num andParam:param];
    }
    else
        [self loadNormalStatus];
    
    return nil;
}

-(NSArray*) reloadTableWithData:(id)data
{
    if(tableDelegate!=nil && [(NSObject*)tableDelegate respondsToSelector:@selector(reloadTableWithData:)])
    {
        return [tableDelegate reloadTableWithData:data];
    }
    else
        [self loadNormalStatus];
    
    return nil;
}

-(void) dealloc
{
    self.extendDelegate=nil;
    self.tableDelegate=nil;
    
    [dataArray removeAllObjects];
    [dataArray release];
    
    [super dealloc];
}

-(void)backupFootView
{
    [super backupFootView];
}

@end
