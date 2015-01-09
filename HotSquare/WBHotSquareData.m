//
//  WBHotSquareData.m
//  GyPSiiImage
//
//  Created by gypsii001 on 15/1/7.
//
//

#import "WBHotSquareData.h"
#import "GPView.h"
#import "GPDefinition.h"
#import "GPController.h"

@implementation WBHotSquareData

- (instancetype)init
{
    if (self =[super init])
    {
        self.dataArr = [NSMutableArray array];
    }
    return self;
}
-(int) getSqrCellHeight:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 317.5;
        case 1:
            return 212.5;
        case 2:
            return 317.5;
        case 3:
            return 150;
    }
    
    return 0;
}

-(UIView*) createSquareCell:(NSIndexPath *)indexPath
{
    GPView* view=[[GPView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, [self getSqrCellHeight:indexPath])];
    view.backgroundColor=kClearColor;
    
    for (int i = 0; i < [self.dataArr count]; i++) {
        if (indexPath.section == 0 || indexPath.section == 2) {
            if (indexPath.row == 0) {
                CGRect tempFrame;
                
                if (i == 0) {
                    tempFrame = CGRectMake(0+2*i*(105+2.5), 2.5, 105*(2-i)+2.5, 105*(2-i)+2.5);
                } else if (i == 1) {
                    tempFrame = CGRectMake(0+2*i*(105+2.5), 2.5, 105*(2-i), 105*(2-i));
                } else if (i == 2) {
                    tempFrame = CGRectMake(0+2*(105+2.5), 2.5+105+2.5, 105, 105);
                }
                //背景图
                GImageView *imageView = [view buildImage:@"http://ww3.sinaimg.cn/webp720/6635aa54jw1emvfzt15nuj20hs0hs767.jpg" frame:tempFrame];
                [imageView buildImage2:[[UIImage imageNamed:@"blackrectLine.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:3] frame:imageView.bounds].userInteractionEnabled = NO;
                imageView.tag = i;
                [imageView addTarget:self action:@selector(action_clickImg:)];
                
                //小蒙版frame
                CGRect littleViewFrame = CGRectMake(tempFrame.origin.x, tempFrame.size.height-47.5, tempFrame.size.width, 50);
                //小蒙版上的大文字frame
                CGRect bigTextFrame = CGRectMake(tempFrame.origin.x+20, tempFrame.size.height-50, tempFrame.size.width-20, 30);
                //小蒙版上的小文字frame
                CGRect littleTextFrame = CGRectMake(bigTextFrame.origin.x, bigTextFrame.origin.y-30-10, bigTextFrame.size.width, 20);
                
                UIView *halfTransparencyView = [view buildBgView:kdarkBGColor frame:littleViewFrame];
                halfTransparencyView.alpha = 0.4;
                
                
                //小蒙版上的文字
                NSString *str = nil;
                if (i == 0) {
                    str = @"星空下的一朵玫瑰 (641)";
                } else if (i == 1) {
                    str = @"我从来不是这样 (12)";
                } else if (i ==2) {
                    str = @"LOVE不难 (356)";
                }
                UILabel *label = [view buildLabel:str frame:bigTextFrame font:Font(16) color:kWhiteColor];
                label.backgroundColor = kClearColor;
                
                UILabel *label1 = [view buildLabel:str frame:littleTextFrame font:Font(14) color:kWhiteColor];
                label1.backgroundColor = kClearColor;
                
                continue;
            } else if (indexPath.row == 1) {
                CGRect tempFrame = CGRectMake(0+i*(105+2.5), 5, 105, 105);
                GImageView *imageView = [view buildImage:@"http://ww3.sinaimg.cn/webp720/6635aa54jw1emvfzt15nuj20hs0hs767.jpg" frame:tempFrame];
                [imageView buildImage2:[[UIImage imageNamed:@"blackrectLine.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:3] frame:imageView.bounds].userInteractionEnabled = NO;
                imageView.tag = i;
                [imageView addTarget:self action:@selector(action_clickImg:)];
            }
        }
        else if (indexPath.section == 3){
            CGRect tempFrame = CGRectMake(60, (2.5+50)*i, KScreenWidth, 50);
            
            //文字
            NSString *str = nil;
            if (i == 0) {
                str = @"星空下的一朵玫瑰 (641)";
            } else if (i == 1) {
                str = @"我从来不是这样 (12)";
            } else if (i ==2) {
                str = @"LOVE不难 (356)";
            }
            UILabel *label = [view buildLabel:str frame:tempFrame font:Font(16) color:kdarkTextColor];
            label.backgroundColor = kWhiteColor;
            [label addTarget:self action:@selector(action_clickImg:)];
            
            //图片
            GImageView *imageView = [view buildImage:@"http://ww3.sinaimg.cn/webp720/6635aa54jw1emvfzt15nuj20hs0hs767.jpg" frame:CGRectMake(0, (2.5+50)*i, 50, 50)];
            
            [imageView buildImage2:[[UIImage imageNamed:@"blackrectLine.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:3] frame:imageView.bounds].userInteractionEnabled = NO;
            imageView.tag = i;
            
            //间隔
            UILabel *label1 = [view buildLabel:@"" frame:CGRectMake(50, (2.5+50)*i, 10, 50) font:Font(16) color:kdarkTextColor];
            label1.backgroundColor = kWhiteColor;
        } else {
            CGRect tempFrame = CGRectMake(0+i*(105+2.5), 2.5, 105, 105);
            GImageView *imageView = [view buildImage:@"http://ww3.sinaimg.cn/webp720/6635aa54jw1emvfzt15nuj20hs0hs767.jpg" frame:tempFrame];
            [imageView buildImage2:[[UIImage imageNamed:@"blackrectLine.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:3] frame:imageView.bounds].userInteractionEnabled = NO;
            imageView.tag = i;
            [imageView addTarget:self action:@selector(action_clickImg:)];
        }
    }
    
    return view;
}

-(void) action_clickImg:(UITapGestureRecognizer *)tagGest
{
    NSDictionary* dict=[self.dataArr objectAtIndex:tagGest.view.tag];
    [self.pControl jumpPageEventDetail:[dict objectForKey:@"id"] withData:dict jumpReplyNum:-1];
    [self.pControl performSelector:@selector(setNeedUpdateCell:) withObject:dict afterDelay:1]; // for ios7 can invoke viewWillAppear twice
}

- (void)dealloc
{
    self.dataArr  = nil;
    [super dealloc];
}

@end
