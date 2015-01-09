
#import "GPHomeHotViewController.h"
#import "GPDefinition.h"
#import "GPSearchTagViewController.h"
#import "GPlayVideoManager.h"
#import "GFriendLoopViewController.h"
#import "UIView+Extras.h"
#import "GPersonalCell.h"
#import "WBHotPicData.h"
#import "FriendUtil.h"
#import "WBWallDetailViewController.h"
#import "WBHotSquareData.h"

@implementation GPHomeHotViewController
@synthesize hotSquareArr,tabIndex, extendDelegate;

GPHomeHotViewController* _sharedHomeHotViewController=nil;
+(GPHomeHotViewController*) sharedHomeHotViewController
{
    if(_sharedHomeHotViewController==nil)
    {
        _sharedHomeHotViewController=[[GPHomeHotViewController alloc] init];
    }
    return _sharedHomeHotViewController;
}

-(void) setTabSelect:(int)index
{
    if(tabIndex==index)
        return;
    
    tabIndex=index;
    if(currentBtn==nil)
        return;
    
    [self selectTab:oldBtn];
}

-(id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    if((self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        self.baseDelegate=self;
        extendDelegate = self;
    }
    return self;
}

-(void) dealloc
{
    list1.extendDelegate=nil;
    list1.tableDelegate=nil;
    [list1 release];
    
    list2.extendDelegate=nil;
    list2.tableDelegate=nil;
    [list2 release];
    
    self.hotSquareArr=nil;
    
    [super dealloc];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self checkUpdateCell];
}

-(void) checkUpdateCell
{
    if(self.needUpdateCell!=nil)
    {
        if(appDelegate.lastModifyEventId!=nil && appDelegate.lastModifyEventData!=nil)
        {
            for(WBHotPicData* cell in list1.dataArray)
            {
                for(NSDictionary* data in cell.dataArr)
                {
                    if(data==self.needUpdateCell && [[data objectForKey:@"id"] isEqualToString:appDelegate.lastModifyEventId])
                    {
                        [cell.dataArr replaceObjectAtIndex:[cell.dataArr indexOfObject:data] withObject:appDelegate.lastModifyEventData];
                        appDelegate.lastModifyEventId=nil;
                        appDelegate.lastModifyEventData=nil;
                        break;
                    }
                }
            }
        }
        
        self.needUpdateCell=nil;
    }
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    isFirstLoad=YES;
    [self SetVersion7BgColor];
    
    // build nav bar
    UIView* navbg=[self.view buildBgView:kWhiteColor frame:RECT(0, 0, KScreenWidth, KNavBarHeight)];
    [navbg buildBgView:kWhiteColor frame:RECT(0, 0, KScreenWidth, KNavStatusHeight)];
//    [navbg buildBgView:KWBColorBarLine frame:RECT(0, navbg.height-0.5, navbg.width, 0.5)];
    
    // build search bar
    UIImage* img=IMG(search_box);
    img=[img stretchableImageWithLeftCapWidth:img.size.width/2 topCapHeight:img.size.height/2];
    UIButton* btn=[navbg buildImgBtn:RECT((KScreenWidth-299)/2, KNavStatusHeight+(44-30)/2, 299, 30) target:self action:@selector(action_go2SearchVc) image:img];
    
    [btn buildImage2:IMG(topbar_icon_search) frame:RECT(8, (btn.height-17)/2, 35.0/2, 17)];
    [btn buildLabel:LTXT(TKN_ClickSearchUserTag) frame:RECT(30, 0, 150, btn.height) font:Font(14) color:Color(153, 153, 153)];
    
    // build tag bar
    tabbg=[self.view buildBgView:kWhiteColor frame:RECT(0, navbg.bottom, KScreenWidth, 44)];
    [tabbg buildBgView:KWBColorBarLine frame:RECT(0, tabbg.height-0.5, tabbg.width, 0.5)];
    
    float w=60;
    float h=tabbg.height-2;
    float x=60;
    
    btn=[tabbg buildBlankBtn:RECT(x, 0, w, h) target:self action:@selector(selectTab:)];
    tab1=[btn buildLabel:LTXT(TKN_HotPhotos) frame:RECT(0, 0, btn.width+10, btn.height) font:FontBold(15) color:KWBTxtColorGray];
    btn.tag=1;
    UIButton* tabBtn1=btn;
    
    x=KScreenWidth-w-x;
    btn=[tabbg buildBlankBtn:RECT(x, 0, w, h) target:self action:@selector(selectTab:)];
    tab2=[btn buildLabel:LTXT(TKN_HotSquare) frame:RECT(0, 0, btn.width+10, btn.height) font:FontBold(15) color:KWBTxtColorGray];
    btn.tag=2;
    
    tabLine=[tabbg buildBgView:KWBTxtColorRed frame:RECT(tabBtn1.left+13, tabbg.height-2.5, 30, 2.5)];
    [self selectTab:(tabIndex>0 ? btn : tabBtn1)];
    oldBtn=(tabIndex>0 ? tabBtn1 : btn);
    
    // load buffer
    [self performSelector:@selector(loadBuffer) withObject:nil];
    
    // check local friends info, if is nil, request it
//    NSArray* ary=[[[FriendUtil sharedFriendUtil] getFriendData:tudingfriend] allValues];
//    if(!ValidArray(ary))
//        [[FriendUtil sharedFriendUtil] sendGetMyFellowSyn:tudingfriend];
}

-(void) selectTab:(UIButton*)btn
{
    if(currentBtn==btn)
        return;
    
    tabIndex=(int)(btn.tag-1);
    currentBtn.selected=NO;
    btn.selected=YES;
    
    oldBtn=currentBtn;
    currentBtn=btn;
    
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:0.3];
    tabLine.left=btn.left+13;
    [UIView commitAnimations];
    
    switch(btn.tag)
    {
        case 1:
        {
            if(list1==nil)
            {
                list1=[[GTableViewV2 alloc] initWithFrame:CGRectMake(0, tabbg.bottom, KScreenWidth, self.view.height-tabbg.bottom-ButtomHeight2) style:UITableViewStylePlain];
                list1.resetOff=YES;
                list1.isNeedHiddenButtom=YES;
                list1.headerView.bolHaveLine=NO;
                list1.extendDelegate=self;
                list1.separatorStyle=UITableViewCellSeparatorStyleNone;
                list1.backgroundColor=[UIColor clearColor];
                [list1 setHeaderViewStyle:[UIColor clearColor]];
                [self.view addSubview:list1];
                
                [list1 refreshTable2];
            }
            
            list1.hidden = NO;
            
            if (list2) {
                list2.hidden = YES;
            }
            
            if(list1!=oldList)
            {
                list1.hidden=NO;
                
                oldList.hidden=YES;
                oldList=list1;
            }
            
            tab1.textColor=KWBTxtColorBlack;
            tab2.textColor=KWBTxtColorGray;
            break;
        }
        case 2:
        {
            if(list2==nil)
            {
                list2=[[GTableViewV3 alloc] initWithFrame:CGRectMake(0, tabbg.bottom, KScreenWidth, self.view.height-tabbg.bottom-ButtomHeight2) style:UITableViewStylePlain];
                list2.resetOff=YES;
                list2.isNeedHiddenButtom=YES;
                list2.headerView.bolHaveLine=NO;
                list2.extendDelegate=self;
                list2.separatorStyle=UITableViewCellSeparatorStyleNone;
                list2.backgroundColor=[UIColor clearColor];
                [list2 setHeaderViewStyle:[UIColor clearColor]];
                [self.view addSubview:list2];
                
                [list2 refreshTable2];
            }
            
//            if(list2!=oldList)
//            {
//                list2.hidden=NO;
//                
//                oldList.hidden=YES;
//                oldList=list2;
//            }
            list2.hidden = NO;
            if (list1) {
                list1.hidden = YES;
            }
            tab1.textColor=KWBTxtColorGray;
            tab2.textColor=KWBTxtColorBlack;
            break;
        }
    }
}

-(NSArray*) reloadTableWithData:(NSString*)param
{
    if(tabIndex==0)
    {
        offset=0;
        [self getContent:[DICT:@"yes",kNeedRefresh, @"0",kContentIndex, @"15",kContentNum, @"camera_place_gethotplacelist", kContentType,nil]];
    }
    else if(tabIndex==1)
    {
        [self getContent:[DICT:@"yes",kNeedRefresh, @"0",kContentIndex, @"15",kContentNum, @"camera_wall_list", kContentType,nil]];
    }

	return nil;
}

-(NSArray*) loadMoreTableFrom:(NSString*)index withNum:(NSString*)num andParam:(NSString*)param
{
    if(tabIndex==0)
    {
        [self getContent:[DICT:@"yes", kAppendList, @"15", kContentNum, @"camera_place_gethotplacelist", kContentType, nil]];
    }
    else if(tabIndex==1)
    {
        [self getContent:[DICT:@"yes", kAppendList, @"15", kContentNum, @"camera_wall_list", kContentType, nil]];
    }
    
    return nil;
}

-(NSDictionary*) getDataFromWeb:(id)param
{
	NSDictionary *dict=nil;
    if(tabIndex==0)
    {
        dict=[GPJsonCenter camera_place_gethotplacelist:@"15" offset:SFI(offset)];
    }
    else if(tabIndex==1)
    {
        dict=[GPJsonCenter camera_wall_list:@"20" misty:@"0"];
    }
	return dict;
}

-(BOOL) dataLoadFinished:(NSArray*)retdictary withParam:(id)param
{
    NSDictionary* row=[retdictary objectAtIndex:0];
    NSDictionary* data=[row objectForKey:@"data"];
    NSString* cmd=[row objectForKey:@"cmd"];
    int rsp=[[row objectForKey:@"rsp"] intValue];
    BOOL isFresh=[[(NSDictionary*)param allKeys] containsObject:kNeedRefresh];
    
    if(rsp==1)
    {
        if([cmd isEqualToString:@"camera_place_gethotplacelist"])
        {
            if(param!=nil)
                [list1 loadNormalStatus];
            
            NSArray* array=[data objectForKey:@"list"];
            list1.endOfTable=![[data objectForKey:@"havenextpage"] boolValue];
            offset+=15;
            
            if(isFresh)
            {
                [list1 resetCell];
                [self saveBuffer:retdictary];
            }
            
            int i=0;
            WBHotPicData* picData=nil;
            for(NSDictionary* dict in array)
            {
                if(i%3 == 0)
                {
                    picData=[[WBHotPicData alloc] init];
                    picData.pControl=self;
                    [list1 appendCell:picData];
                    [picData release];
                }
                
                [picData.dataArr addObject:dict];
                i++;
            }
        }
        else if([cmd isEqualToString:@"camera_wall_list"])
        {
            [list2 loadNormalStatus];
//            NSArray* array=[data objectForKey:@"list"];
            list2.endOfTable=YES;//![[data objectForKey:@"havenextpage"] boolValue];
            
//            if(isFresh)
//                [list2 resetCell];
//            NSMutableArray *array = [NSMutableArray array];
            WBHotSquareData* sqrData=nil;
            for (int i = 0; i < 9; i++) {
//                [array addObject:[NSString stringWithFormat:@"%d", i]];
                if(i%3 == 0)
                {
                    sqrData=[[WBHotSquareData alloc] init];
                    sqrData.pControl=self;
                    [list2 appendCell:sqrData];
                    [sqrData release];
                }
                [sqrData.dataArr addObject:[NSString stringWithFormat:@"%d", i]];
            }
//            if(ValidClass(array, NSArray))
//            {
////                self.hotSquareArr=array;
//                int i=0;
//                WBHotSquareData* sqrData=nil;
//                for(NSDictionary* dict in array)
//                {
//                    if(i%3 == 0)
//                    {
//                        sqrData=[[WBHotSquareData alloc] init];
//                        sqrData.pControl=self;
//                        [list2 appendCell:sqrData];
//                        [sqrData release];
//                    }
//                    
//                    [sqrData.dataArr addObject:dict];
//                    i++;
//                }
//            }
        }
    }
    else
    {
        if([cmd isEqualToString:@"camera_place_gethotplacelist"])
        {
            [list1 loadNormalStatus];
        }
        else if([cmd isEqualToString:@"camera_wall_list"])
        {
            [list2 loadNormalStatus];
        }
    }
    
    return YES;
}

-(void) freshView:(id)param
{
    [self freshView];
}

-(void) freshView
{
    if(tabIndex==0)
    {
        [list1 reloadCell];
    }
    else if(tabIndex==1)
    {
        [self loadHotSquareView];
        [list2 reloadCell];
    }
}

-(void) action_go2SearchVc
{
    GPSearchTagViewController *searchVc=[[GPSearchTagViewController alloc]init];
    [appDelegate.navController pushViewController:searchVc animated:NO];
    [searchVc release];
}

-(void) loadHotSquareView
{
    int i=0;
    int singleNum=0;
    float smallWidth=159;
    float smallHspace=2;
    float bigWidth=320;
    float heigth=80;
    float vspace=3;
    float ypoint=2;
    float allHeight=ypoint;
    
    UIView* view=[[UIView alloc] init];
    for(NSDictionary* dict in hotSquareArr)
    {
        CGRect tempFrame=CGRectZero;
        if(![[dict objectForKey:@"ntype"] isEqualToString:@"1"])
//        if(i>=3)
        {
            tempFrame=CGRectMake(0+(i-singleNum)%2*(smallWidth+smallHspace),ypoint+singleNum*(heigth+vspace)+(i-singleNum)/2*(heigth+vspace), smallWidth, heigth);
        }
        else
        {
            tempFrame=CGRectMake(0,ypoint+i*(heigth+vspace), bigWidth, heigth);
            singleNum++;
        }
        
        allHeight=tempFrame.origin.y+vspace+heigth;
        [view buildImage:[dict objectForKey:@"cover_icon_url"] frame:tempFrame];
        UIButton* btn=[view buildBlankBtn:tempFrame target:self action:@selector(action_go2Category:)];
        btn.tag=i;
        i++;
    }
    
    view.backgroundColor=kClearColor;
    view.frame=CGRectMake(0, 0, KScreenWidth, allHeight);
    list2.tableHeaderView=view;
    [view release];
}

-(void) go2WallDetailViewController:(NSDictionary*)dict
{
    WBWallDetailViewController* wallDetailVc=[[WBWallDetailViewController alloc] initWithNibName:@"WBWallDetailViewController" bundle:nil];
    wallDetailVc.hasBanner=[[dict objectForKey:@"has_banner"] boolValue];
    wallDetailVc.wallDict=dict;
    wallDetailVc.wall_id=[dict objectForKey:@"id"];
    wallDetailVc.wall_name=[dict objectForKey:@"search_title"];
    [appDelegate.navController pushViewController:wallDetailVc animated:YES];
    [wallDetailVc release];
}

-(void) action_go2Category:(UIButton*)btn
{
    NSDictionary* dict=[hotSquareArr objectAtIndex:btn.tag];
    [self go2WallDetailViewController:dict];
}


- (NSInteger)sqrTableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
        case 1:
            return 1;
        case 2:
            return 2;
        case 3:
            return 1;
            
        default:
            break;
    }
    return 0;
}

- (NSInteger)sqrNumberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}
- (CGFloat)sqrTableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)sqrTableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 40)];
    UILabel *label = [[UILabel alloc] initWithFrame:titleView.frame];
    label.backgroundColor = kClearColor;
    label.textColor = kBlackColor;
    [titleView addSubview:label];
    
    switch (section) {
        case 0:
            label.text = @"话题";
            break;
        case 1:
            label.text = @"品牌";
            break;
        case 2:
            label.text = @"兴趣";
            break;
        case 3:
            label.text = @"我关注的话题";
            break;
            
            
        default:
            break;
    }
    [label release];
    return titleView;
}

- (CGFloat)sqrHeightForRow:(NSIndexPath *)indexPath atTable:(UITableView*)table
{
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    return 212.5;
                case 1:
                    return 105;

                default:
                    break;
            }
        case 1:
            switch (indexPath.row) {
                case 0:
                    return 105+2.5;
                    
                default:
                    break;
            }
        case 2:
            switch (indexPath.row) {
                case 0:
                    return 212.5;
                case 1:
                    return 105;
                    
                default:
                    break;
            }
        case 3:
            return 150;
    }
    
    return 0;
}

@end
