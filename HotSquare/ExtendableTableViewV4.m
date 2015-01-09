
#import "ExtendableTableViewV4.h"
#import "GPAdvertisementCell.h"
#import "GPDefinition.h"
#import "GDataObjectV2.h"
#import "GPSquareAddCell.h"
#import "wbEventListCell.h"

#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define BORDER_COLOR [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define KTagTipGetMoreLab 4892

@interface ExtendableTableViewV4 (Private)
- (void)loadSubviews;
@end

@implementation ExtendableTableViewV4

@synthesize contentHeight;
@synthesize headerView = _headerView;
@synthesize cellDataArray = _cellDataArray;
@synthesize extendDelegate;
@synthesize contentType = _contentType;
@synthesize freshOff,endOfTable,stepLength,isNeedSelectionTouch,bolUseCellBuffer,setRefreshView,_loadState;
@synthesize isNeedResetTableY;
@synthesize resetOff;
@synthesize isNeedHiddenButtom;
-(void) myinit
{
    isNeedResetTableY=NO;
    resetOff = YES;
	self.delegate = self;
	self.dataSource = self;
	[self loadSubviews];
	self.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    isNeedSelectionTouch = NO;
    //    self.separatorColor=KC_CELL_LINE;
}

- (void)awakeFromNib
{
    [self myinit];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self myinit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
	if ((self = [super initWithFrame:frame style:style]))
    {
        [self myinit];
    }
    return self;
}

- (void)dealloc
{
	[_headerView release];
	[_cellDataArray release];
	[_contentType release];
	[_headerColor release];
    [super dealloc];
}

- (void)loadSubviews
{
	curIndex = 0;
	stepLength = 20;
	totalNum = MAXCOUNT;
	
	self.backgroundColor = [UIColor clearColor];
	self.separatorStyle = UITableViewCellSeparatorStyleNone;
	
//	_headerView = [[RefreshTableHeader alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.frame.size.height, 320.0f, self.frame.size.height)];
//    NSLog(@"!!!!!!!!!!%f",self.frame.size.height);
//	if (_headerColor != nil) {
//		_headerView.backgroundColor = _headerColor;
//	} else {
//        //		_headerView.backgroundColor = [UIColor colorWithRed:0.545 green:0.824 blue:0.941 alpha:1.0];	
//		_headerView.backgroundColor = [UIColor clearColor];
//	}
//	[self addSubview:_headerView];
//    _headerView.autoresizesSubviews=NO;
    
    [self newHeaderView];
	
	footV = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40.0)];
	footV.backgroundColor = [UIColor clearColor];
	
	UIActivityIndicatorView *moreLoadingV = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.frame.size.width/2-10, 10.0, 20.0, 20.0)];
	moreLoadingV.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	moreLoadingV.backgroundColor = [UIColor clearColor];
	moreLoadingV.tag = 100;
	[footV addSubview:moreLoadingV];
	moreLoadingV.hidden = YES;
	[moreLoadingV release];
    
	UILabel * moreLoadingL = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 5.0, 280.0, 30.0)];
	moreLoadingL.backgroundColor = [UIColor clearColor];
	moreLoadingL.textColor = [UIColor grayColor];
	moreLoadingL.textAlignment = UITextAlignmentCenter;
    //	moreLoadingL.text = NSLocalizedString(@"TKN_MORE", @"");
	//moreLoadingL.text = NSLocalizedString(@"TKN_MOREREFRESH", @"");
	moreLoadingL.font = [UIFont boldSystemFontOfSize:14];
    moreLoadingL.tag = 101;
	[footV addSubview:moreLoadingL];
 	moreLoadingL.hidden = YES;
	[moreLoadingL release];
	
	self.tableFooterView = footV;
	//[footV release];
    
//    [self setEndOfTable:YES];
//    [self setHiddenGetMoreLab:YES];
}

-(void) newHeaderView
{
    _headerView = [[SRRefreshView alloc] init];
    [self addSubview:_headerView];
    _headerView.delegate = self;
    
    _headerView.upInset = 2;
    _headerView.slimeMissWhenGoingBack = YES;
    _headerView.slime.bodyColor = [UIColor darkGrayColor];//[UIColor colorWithRed:132 green:141 blue:148 alpha:1.0];
    _headerView.slime.skinColor = [UIColor darkGrayColor];
    _headerView.slime.lineWith = 1;
    _headerView.slime.shadowBlur = 4;
    _headerView.slime.shadowColor = [UIColor darkGrayColor];
}

-(void) setHiddenGetMoreLab:(BOOL)hidden
{
//    UILabel* lab=(UILabel*)[self.tableFooterView viewWithTag:KTagTipGetMoreLab];
//    if(lab!=nil && [lab isKindOfClass:[UILabel class]])
//        lab.hidden=hidden;
}

-(void) rebuildFreshHeaderWithWidth:(CGFloat)width
{
	if(!_headerView)
	{
        [self newHeaderView];
//		_headerView = [[RefreshTableHeader alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.frame.size.height, width, self.frame.size.height)];
	}
    
    if(_headerColor == nil)
        _headerView.backgroundColor = [UIColor clearColor];
    else
        _headerView.backgroundColor = _headerColor;
    
	if([_headerView superview] == nil)
	{
		[self addSubview:_headerView];
		freshOff = NO;
	}
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    if (extendDelegate && [extendDelegate respondsToSelector:@selector(sqrTableView:numberOfRowsInSection:)]) {
        return [extendDelegate sqrTableView:table numberOfRowsInSection:section];
    }
	return [_cellDataArray count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if (extendDelegate && [extendDelegate respondsToSelector:@selector(sqrNumberOfSectionsInTableView:)]) {
        return [extendDelegate sqrNumberOfSectionsInTableView:tableView];
    }
    return 1;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (isNeedSelectionTouch) {
    	id celldata = [_cellDataArray objectAtIndex:indexPath.row];
        if ([celldata isKindOfClass:[GPSquareAddCell class]]){
        
            [celldata setBackImageLabel];
        
        }
        [self performSelector:@selector(deselect:) withObject:celldata afterDelay:0.5f];

        
        return indexPath;

    
    }else{
    
    
        return indexPath;

    }

    
}

- (void)deselect:(id)sender
{
    GPSquareAddCell *ob=(GPSquareAddCell *)sender;
    [ob removeBackImageLabel];
    [self deselectRowAtIndexPath:[self indexPathForSelectedRow] animated:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString* cellIdentifier = @"vlingdi_tabele_v2";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    BOOL bolNil = NO;
	if (cell == nil)
    {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        bolNil = YES;
    }
    else if ([cell.contentView subviews] != nil)
    {
        if (!bolUseCellBuffer) {
            for(UIView *v in [cell.contentView subviews])
                [v removeFromSuperview];
        }

	}
	
	cell.textLabel.text = @"";
    if(isNeedSelectionTouch)
    {   cell.selectedBackgroundView =[[[UIView alloc] initWithFrame:cell.frame] autorelease];
        cell.selectedBackgroundView.alpha=0.0;
//        cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_rect_frame.png"]] autorelease];
//        [cell.selectedBackgroundView bringSubviewToFront:cell.contentView];

//        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
//	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
	id celldata = [_cellDataArray objectAtIndex:indexPath.row];
    if ([celldata isKindOfClass:[GDataObjectV2 class]])
    {
        if (!bolUseCellBuffer || bolNil) {
            UIView *v = [(GDataObjectV2*)celldata createSquareCell:indexPath];
            [cell.contentView addSubview:v];
            [v release];
        }else{
            [(GDataObjectV2*)celldata changeSubView:cell.contentView];
        }
    }
    cell.backgroundColor=kClearColor;
    
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (extendDelegate && [extendDelegate respondsToSelector:@selector(sqrTableView:heightForHeaderInSection:)])
        return [extendDelegate sqrTableView:tableView heightForHeaderInSection:section];
    
	return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if (extendDelegate && [extendDelegate respondsToSelector:@selector(sqrTableView:viewForHeaderInSection:)]) 
		return [extendDelegate sqrTableView:tableView viewForHeaderInSection:section];
    
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (extendDelegate && [extendDelegate respondsToSelector:@selector(sqrHeightForRow:atTable:)])
    {
        return [extendDelegate sqrHeightForRow:indexPath atTable:tableView];
    }
    
    return 0;
}

-(BOOL)bolAddContentH:(NSInteger)index
{
    if (index == rowCount) {
        rowCount++;
        return YES;
    }
    return NO;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (extendDelegate != nil && [extendDelegate respondsToSelector:@selector(didSelectRow:atTable:withData:)])
    {
		[extendDelegate didSelectRow:indexPath.row 
							 atTable:tableView 
							withData:[NSDictionary dictionaryWithObjectsAndKeys:_contentType, @"type",[_cellDataArray objectAtIndex:indexPath.row],@"data",nil]];
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (extendDelegate!= nil && ![extendDelegate isKindOfClass:[ExtendableTableViewV4 class]] && [extendDelegate respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)])
		return [extendDelegate tableView:tableView canEditRowAtIndexPath:indexPath];
	
	return YES;
}

- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{


	if (extendDelegate!=nil && [extendDelegate respondsToSelector:@selector(tableView:willBeginEditingRowAtIndexPath:)])
        [extendDelegate tableView:tableView willBeginEditingRowAtIndexPath:indexPath];


}
- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{


	if (extendDelegate!=nil && [extendDelegate respondsToSelector:@selector(tableView:didEndEditingRowAtIndexPath:)])
        [extendDelegate tableView:tableView didEndEditingRowAtIndexPath:indexPath];


}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (extendDelegate!=nil && [extendDelegate respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)])
        [extendDelegate tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (extendDelegate!=nil && ![extendDelegate isKindOfClass:[ExtendableTableViewV4 class]] && [extendDelegate respondsToSelector:@selector(tableView:editingStyleForRowAtIndexPath:)])
		return [extendDelegate tableView:tableView editingStyleForRowAtIndexPath:indexPath];
    
	if(self.editing)
		return UITableViewCellEditingStyleDelete;
	
	return UITableViewCellEditingStyleNone;
}

#pragma mark - slimeRefresh delegate
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    //[_headerView performSelector:@selector(endRefresh) withObject:nil afterDelay:3 inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    [self refreshTable:NO];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (extendDelegate!=nil &&[extendDelegate respondsToSelector:@selector(extScrollViewDidScroll:)]) {
        [extendDelegate extScrollViewDidScroll:scrollView];
    }
    
    if (IsIos7Version) {
        
        if (resetOff==NO) {
            float offsetHeight=0;
            if (isNeedResetTableY) {
                offsetHeight=64.0;
            }else{
                offsetHeight=20.0;
                
                
            }
            
            float offY=scrollView.contentOffset.y;
            
            CGRect rect =  self.frame;
            
            if (offY < 0) {
                offY = 0;
            }
            if (offY>=0 && offY < offsetHeight){
                self.frame = CGRectMake(rect.origin.x, offsetHeight-offY, rect.size.width, rect.size.height);
                
                
            }
            
            if (offY > offsetHeight) {
                
                self.frame=CGRectMake(rect.origin.x, 0, rect.size.width, rect.size.height);
            }
            
 
        }
        
        

        
    }
    
	if(freshOff) return;
    if (extendDelegate != nil && [extendDelegate respondsToSelector:@selector(scrollViewDidScroll)])
    {
		[extendDelegate scrollViewDidScroll ];
	}
    
    //NSLog(@"scrollViewDidScroll--offset====%f", scrollView.contentOffset.y);
    
//	if (scrollView.isDragging)
//    {
//        //		NSLog(@"scrollViewDidScroll-----isDragging");
//		if (_headerView.state == HeaderRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_loadState)
//			[_headerView setState:HeaderRefreshNormal];
//		else if (_headerView.state == HeaderRefreshNormal && scrollView.contentOffset.y < -65.0f && !_loadState)
//			[_headerView setState:HeaderRefreshPulling];
//        if (setRefreshView) {
//            if (scrollView.contentOffset.y < -65.0f) {
//                CGRect frame = _headerView.frame;
//                frame.origin.y=0.0f - self.frame.size.height+scrollView.contentOffset.y+10;
//                _headerView.frame=frame;
//            }
//        }
//	}
    [_headerView scrollViewDidScroll];
    
    float KLimitOffset=-170;
    if (setRefreshView) {
        KLimitOffset=-150;
    }
    if(scrollView.contentOffset.y < KLimitOffset)
        scrollView.contentOffset=CGPointMake(scrollView.contentOffset.x, KLimitOffset);
    

    
    

}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{

    scrollBeginY = scrollView.contentOffset.y;
    if (extendDelegate!=nil &&[extendDelegate respondsToSelector:@selector(extscrollViewWillBeginDragging:)]) {
        [extendDelegate extscrollViewWillBeginDragging:scrollView];
    }
    [self showPointViews:scrollView oprateType:1];
}
-(void) setStatusRefresh
{
    if(freshOff || self.contentOffset.y <= -65)
        return;
    
    _loadState=0;
    self.contentOffset=CGPointMake(0, -65);
    beSetRefreash=YES;
    [self scrollViewDidEndDragging:self willDecelerate:NO];
    beSetRefreash=NO;
}

-(void) refreshTable:(BOOL)animate
{
    
    NSLog(@"_loadState_loadState_loadState_loadState = %d",_loadState);
    if (_loadState) {
        return;
    }
    
	if (extendDelegate != nil && [extendDelegate respondsToSelector:@selector(reloadTableWithData:)]) {
		curIndex = 0;
		[extendDelegate reloadTableWithData:_contentType];
        [_headerView setLoadingWithexpansion];
	}
	
	_loadState = 2;
	
	if (animate) {
//		[_headerView setState:HeaderRefreshLoading];
        //[_headerView scrollViewDidEndDraging];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		self.contentInset = UIEdgeInsetsMake(42.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
	}
	else {
//		[_headerView setState:HeaderRefreshLoading];
        //[_headerView scrollViewDidEndDraging];
		self.contentInset = UIEdgeInsetsMake(42.0f, 0.0f, 0.0f, 0.0f);
	}
	[self scrollRectToVisible:CGRectMake(0, 0, 320, 1) animated:NO];
}

-(void) refreshTable2
{
    [self performSelectorOnMainThread:@selector(realRefreshTable2) withObject:nil waitUntilDone:NO];
}

-(void) realRefreshTable2
{
    NSLog(@"_loadState_loadState_2 = %d",_loadState);
    if(_loadState)
        return;
    
    if(extendDelegate != nil && [extendDelegate respondsToSelector:@selector(reloadTableWithData:)])
    {
        curIndex = 0;
        [extendDelegate reloadTableWithData:_contentType];
    }
    
    _loadState = 2;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.02];
    self.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    [UIView commitAnimations];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_headerView scrollViewDidEndDraging];
    
    if (isNeedHiddenButtom &&NO) {
        if ((scrollView.contentOffset.y-scrollBeginY)>0) {
            [UIView beginAnimations:@"move" context:nil];
            [UIView setAnimationDuration:0.3];
            appDelegate.structViewController.buttomView.frame =CGRectMake(0, GetScreenHeight+ButtomHeight, 320, ButtomHeight);
            [UIView commitAnimations];
        }
        else if ((scrollView.contentOffset.y-scrollBeginY)<-8){
            [UIView beginAnimations:@"move" context:nil];
            [UIView setAnimationDuration:0.3];
            appDelegate.structViewController.buttomView.frame =CGRectMake(0, GetScreenHeight-ButtomHeight, 320, ButtomHeight);
            [UIView commitAnimations];
        }
    }
    if (extendDelegate!=nil &&[extendDelegate respondsToSelector:@selector(extscrollViewDidEndDragging:willDecelerate:)]) {
        [extendDelegate extscrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
//	if(freshOff) return;
	//top fresh
    
    //	NSLog(@"scrollViewDidEndDragging~");
    //NSLog(@"scrollViewDidEndDragging--offset====%f", scrollView.contentOffset.y);
    
//	if (scrollView.contentOffset.y < - 65.0f && !_loadState)
//	{
//		//here reload tableview data,may be neen runloop to notify the pulled view to scroll up
//		if (extendDelegate != nil && [extendDelegate respondsToSelector:@selector(reloadTableWithData:)])
//        {
//			curIndex = 0;
//            if(!beSetRefreash)
//                [extendDelegate reloadTableWithData:_contentType];
//		}
//		
//		_loadState = 2;
////		[_headerView setState:HeaderRefreshLoading];
//        [_headerView scrollViewDidEndDraging];
//
//
//        if (setRefreshView) {
////            CGRect frame = _headerView.frame;
////            frame.origin.y=0.0f - self.frame.size.height-55;
////            _headerView.frame=frame;
//            self.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0.0f, 0.0f, 0.0f);
//
//        }else{
//            [UIView beginAnimations:nil context:NULL];
//            [UIView setAnimationDuration:0.2];
//            self.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
//            [UIView commitAnimations];
//        }
//
//		return;
//	}
    
	//bottom fresh
	float footerH = 0;
	if (self.tableFooterView != nil)
		footerH = self.tableFooterView.frame.size.height;
    
	float headerH = 0.0;
	if (self.tableHeaderView != nil)
		headerH = self.tableHeaderView.frame.size.height;
    
	float contentH = footerH + contentHeight;
    //	NSLog(@"011--%f, 222--%f, 333--%f", scrollView.contentOffset.y, self.frame.size.height, headerH);
	float currentH = scrollView.contentOffset.y + self.frame.size.height - headerH;
    //	NSLog(@"footer1:%f,contentOffset:%f, content H:%f,current H:%f, self Height:%f",footerH,scrollView.contentOffset.y, contentH, currentH, self.frame.size.height);
//	NSLog(@"self.frame.size.height = %f",self.frame.size.height);
//	if(currentH - contentH >= 5 && !_loadState && contentH > self.frame.size.height && !endOfTable)
    //delete contentH > self.frame.size.height 
    if(currentH - contentH >= 5 && !_loadState  && !endOfTable)
	{
		//request again, and add new data into array,reload data
		if (extendDelegate != nil && [extendDelegate respondsToSelector:@selector(loadMoreTableFrom:withNum:andParam:)])
        {
            //			curIndex = curIndex + stepLength;
			[extendDelegate loadMoreTableFrom:[NSString stringWithFormat:@"%d", curIndex]
									  withNum:[NSString stringWithFormat:@"%d", stepLength]
									 andParam:_contentType];
		}
		
		UIActivityIndicatorView *av = (UIActivityIndicatorView*)[self.tableFooterView viewWithTag:100];
		[av startAnimating];
		av.hidden = NO;
		UILabel *ml = (UILabel*)[self.tableFooterView viewWithTag:101];
        if(ml!=nil)
            //ml.text = NSLocalizedString(@"TKN_LANDING_PROCESSING", @"");
        [self setHiddenGetMoreLab:YES];
		
		_loadState = 1;
        
//		[_headerView setState:HeaderRefreshLoading];
        //[_headerView scrollViewDidEndDraging];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		self.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 60.0f, 0.0f);
		[UIView commitAnimations];
	}
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (extendDelegate!=nil && [extendDelegate respondsToSelector:@selector(exscrollViewDidEndDecelerating:)]) {
        [extendDelegate exscrollViewDidEndDecelerating:scrollView];
    }
    
    [self showPointViews:scrollView oprateType:0];
}

-(void)showPointViews:(UIScrollView *)scrollView oprateType:(int)type
{
    UITableView *tableView = (UITableView *)scrollView;
    if (![tableView isKindOfClass:[UITableView class]]) {
        return;
    }
    NSArray *cellArr = [tableView visibleCells];
    if ([cellArr count])
    {
        for (UITableViewCell *cell in cellArr)
        {
            wbEventListCell *cellV2=nil;
            for(UIView* view in [cell.contentView subviews])
            {
                if(ValidClass(view, wbEventListCell))
                {
                    cellV2=[(wbEventListCell*)view retain];
                    break;
                }
            }
            
            if(cellV2!=nil)
            {
                if(type==0)
                {
                    CGPoint cellPoint2Main=[tableView convertPoint:cell.frame.origin toView:[tableView superview]];
                    NSLog(@"cellPoint === >%@",NSStringFromCGPoint(cellPoint2Main));
                    
                    if(cellPoint2Main.y > -120 && cellPoint2Main.y < KScreenHeight/2)
                    {
                        [cellV2 doListStay:YES];
                    }
                }
                else if (type==1)
                {
                    [cellV2 doListStay:NO];
                }
                
                [cellV2 release];
            }
        }
    }
}

- (void)loadNormalStatus{
    
    [self performSelectorOnMainThread:@selector(loadNormalStatusOnMain) withObject:nil waitUntilDone:NO];
}

-(void)loadNormalStatusOnMain
{
	_loadState = 0;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
    if (extendDelegate != nil && [extendDelegate respondsToSelector:@selector(initBackImage)] &&setRefreshView){
        
        [extendDelegate initBackImage];
    }

    [self setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
//	[_headerView setState:HeaderRefreshNormal];
//	[_headerView setCurrentDate];  //  should check if data reload was successful
    [_headerView endRefresh];
    
	UIActivityIndicatorView *av = (UIActivityIndicatorView*)[self.tableFooterView viewWithTag:100];
	[av stopAnimating];
	av.hidden = YES;
//	UILabel *ml = (UILabel*)[self.tableFooterView viewWithTag:101];
//	if(ml!=nil)
//        ml.text = NSLocalizedString(@"TKN_MOREREFRESH", @"");
}

-(void) listScrollToTop
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    
    self.contentOffset=CGPointMake(0, 0);
    [UIView commitAnimations];
}

- (void)setEndOfTable:(BOOL)isend 
{
//	useEndOfTableFlag = YES;
//	endOfTable = isend;
//    
//    [self setHiddenGetMoreLab:endOfTable];
    
    if (isend == YES) 
	{
		endOfTable = YES;
//		UILabel *ml = (UILabel*)[self.tableFooterView viewWithTag:101];
//		if(ml!=nil)
//            ml.hidden = YES;
		
	}
    else
    {
		endOfTable = NO;
//		UILabel *ml = (UILabel*)[self.tableFooterView viewWithTag:101];
//		if(ml!=nil)
//        {
//			if ([_cellDataArray count] > 0) {
//				ml.hidden = NO;
//			}else{
//                ml.hidden = YES;
//            }
//        }
        //ml.hidden = NO;
	}
    
}

- (void)refreshExtendTableWithData:(NSArray*)data withParam:(NSDictionary*)param
{
    //del by slan
//	if (useEndOfTableFlag == NO)
//    {
//		if ([data count] == totalNum)
//			endOfTable = YES;
//		else
//			endOfTable = NO;
//	}
    
    //	self.cellDataArray = [[data copy] autorelease];
    self.cellDataArray=nil;
    _cellDataArray = [data mutableCopy];
    if([param objectForKey:@"type"]!=nil)
        self.contentType = [param objectForKey:@"type"];
	curIndex = [data count];
	
	//EventList and CheckinList need correct offset to get AD
	for (UIView* v in data)
    {
		if ([v isKindOfClass:[GPAdvertisementCell class]])
			curIndex--;
	}
    rowCount = 0;
	contentHeight = 0;
	[self reloadData];
	[self loadNormalStatus];

    //add slan
//    UILabel *ml = (UILabel*)[self.tableFooterView viewWithTag:101];
//    if (endOfTable) {
//        ml.hidden = YES;
//    }else
//    {
//        ml.hidden = NO;
//    }
}

#pragma mark setting method
- (void)removeFreshHeader
{
	if([_headerView superview])
	{
		[_headerView removeFromSuperview];
		freshOff = YES;
	}
}
- (void)hiddenFreshHeader{

    _headerView.hidden=YES;

}
- (void)addFreshHeader
{
	if(!_headerView)
	{
//		_headerView = [[RefreshTableHeader alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.frame.size.height, 320.0f, self.frame.size.height)];
        [self newHeaderView];
		if (_headerColor == nil)
        {
            //			_headerView.backgroundColor = [UIColor colorWithRed:0.545 green:0.824 blue:0.941 alpha:1.0];
			_headerView.backgroundColor = [UIColor clearColor];
		}
		else
        {
			_headerView.backgroundColor = _headerColor;
		}
	}
    
	if([_headerView superview] == nil)
	{
		[self addSubview:_headerView];
		freshOff = NO;
	}
}

- (void)setExtendTableStyle:(NSInteger)tablestyle {
	//extendable style
	if (tablestyle == 1) {
		if (_headerView.hidden == YES) {
			_headerView.hidden = NO;
		}
//		self.tableFooterView = _footView;			
		freshOff = NO;
        //		self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	}
	//normal style
	if (tablestyle == 2) {
		if (_headerView.hidden == NO) {
			_headerView.hidden = YES;
		}
		if (self.tableFooterView != nil) {
			self.tableFooterView = nil;
		}
		freshOff = YES;
        //		self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;		
	}
}

- (void)replaceHeaderWithView:(UIView*)headv
{
	self.tableHeaderView = headv;
}

- (void)replaceFooterWithView:(UIView*)footv
{
	self.tableFooterView = footv;
}

-(void)backupFootView
{
    self.tableFooterView = footV;
}

- (void)setTableLength:(NSInteger)len
{
	totalNum = len;
}

- (NSInteger)getTableLength
{
	return totalNum;
}

- (void)setHeaderViewStyle:(UIColor*)color 
{
	if (_headerView != nil)
		_headerView.backgroundColor = color;
}

-(void)refreshMeTable
{
    if (extendDelegate != nil && [extendDelegate respondsToSelector:@selector(reloadTableWithData:)])
    {
		curIndex = 0;
		[extendDelegate reloadTableWithData:_contentType];
	}
	
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    [UIView commitAnimations];
    
	[self scrollRectToVisible:CGRectMake(0, 0, 320, 1) animated:NO];
    
}

-(void) setGetMoreLabOffset
{
    CGRect rect=[self.tableFooterView viewWithTag:KTagTipGetMoreLab].frame;
    rect.origin.x-=30;
    [self.tableFooterView viewWithTag:KTagTipGetMoreLab].frame=rect;
    
    rect=[self.tableFooterView viewWithTag:101].frame;
    rect.origin.x-=10;
    [self.tableFooterView viewWithTag:101].frame=rect;
}

@end
