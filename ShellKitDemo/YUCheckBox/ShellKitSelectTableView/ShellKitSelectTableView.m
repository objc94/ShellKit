//
//  ShellKitSelectTableView.m
//  ShellKitDemo
//
//  Created by jimi on 2018/5/25.
//  Copyright © 2018年 jimi. All rights reserved.
//

#import "SheKit.h"
@interface ShellKitSelectTableView()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UITextFieldDelegate>
@property (strong,nonatomic) NSMutableDictionary  *isRegClass;
@property (strong,nonatomic) UIView *curEnditingView; // 当前编辑的view
@property (strong,nonatomic) UIToolbar *toolbar;
@property (assign,nonatomic) CGFloat moreHieght ;

@end
@implementation ShellKitSelectTableView


#pragma mark lazy

- (UIToolbar *)toolbar {
    if( !_toolbar ) {
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 44)];
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(textFieldDone:)];
        toolbar.items = @[space, bar];
        _toolbar = toolbar;
    }
    return _toolbar;
}
#pragma mark event

- (void)textFieldDone:(id)sender {
    [self.curEnditingView endEditing:YES];
}

#pragma mark system
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self )
    {
        [self setUpView];
        [self initData];
        [self startKeyboardObserve];
        
    }
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
         [self setUpView];
         [self initData];
         [self startKeyboardObserve];
    }
    return self;
}
- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self.tableView setFrame:self.bounds];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

}

#pragma mark init
- (void)setUpView
{
    _tableView = [[UITableView alloc]initWithFrame:self.bounds style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self ;
    _tableView.backgroundColor = [UIColor redColor];

    
    [self addSubview:_tableView];
}

- (void)initData
{
    _tableViewDataSource = [[ShellKitSelectTableViewDataSource alloc]init];
    _isRegClass = [[NSMutableDictionary alloc]init];
    _moreHieght= 0 ;
    
}
#pragma mark keyboard
- (void) stopKeyboardObserve{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void) startKeyboardObserve{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(transformView:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)transformView:(NSNotification *)aNSNotification
{
    //获取键盘弹出前的Rect
    NSValue *keyBoardBeginBounds=[[aNSNotification userInfo]objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect beginRect=[keyBoardBeginBounds CGRectValue];
    //获取键盘弹出后的Rect
    NSValue *keyBoardEndBounds=[[aNSNotification userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect  endRect=[keyBoardEndBounds CGRectValue];
    //获取键盘位置变化前后纵坐标Y的变化值
    CGFloat deltaY=endRect.origin.y-beginRect.origin.y;
    NSLog(@"看看这个变化的Y值:%f",deltaY);
    
    if( _curEnditingView ) {
        
        CGPoint txt_off = [_curEnditingView convertPoint:CGPointMake(0, 0) toView:_tableView];
        CGPoint keyboard_in_tbviw = [self.window convertPoint:CGPointMake(0, endRect.origin.y) toView:_tableView]; //键盘在tableview中的origin-y
        CGFloat py = 15;
        CGFloat pc =(txt_off.y - keyboard_in_tbviw.y );
        CGFloat k = (txt_off.y - keyboard_in_tbviw.y ) + _curEnditingView.frame.size.height +py;
       
        _tableView.contentOffset = CGPointMake(0, _tableView.contentOffset.y +k);
        _tableView.contentSize= CGSizeMake(_tableView.contentSize.width, _tableView.contentSize.height + deltaY * (-1));
    }
}

#pragma mark textField/text delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    _curEnditingView = textField;
    return YES;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    _curEnditingView = textView;
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    
    return YES;
}
#pragma mark tableview
- (void)reloadData
{
    [_tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableViewDataSource.sectionArrays[section].rowArrays.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _tableViewDataSource.sectionArrays.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShellKitTableViewCellModel * model = _tableViewDataSource.sectionArrays[indexPath.section].rowArrays[indexPath.row];
    return model.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    ShellKitSectionModel * model = _tableViewDataSource.sectionArrays[section];
    return model.sectionHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView<YUCheckBoxSectionDelegate> *  headView = nil;
    ShellKitSectionModel * sectionModel = _tableViewDataSource.sectionArrays[section] ;
    NSString * setcionID = NSStringFromClass(sectionModel.sectionCellStyleClass);
    headView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:setcionID];
    if(headView == nil)
    {
        [tableView registerHeaderFooter:sectionModel.sectionCellStyleClass];
        headView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:setcionID];
    }
    [headView shell_setModel:sectionModel];
    return headView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ShellKitTableViewCellModel * model  = _tableViewDataSource.sectionArrays[indexPath.section].rowArrays[indexPath.row];
    ShellKitSectionModel * sectionModel = _tableViewDataSource.sectionArrays[indexPath.section] ;
    model.rowNumber = indexPath.row;
    NSString * cellId = NSStringFromClass(sectionModel.rowCellStyleClass);
    UITableViewCell * cell= [tableView dequeueReusableCellWithIdentifier:cellId ];
    if(cell == nil)
    {
        // cell的class尚未注册，无法通过 dequeueReusableCellWithIdentifier:cellId 读取cell
        // 注册之后，dequeueReusableCellWithIdentifier:cellId会重新创建或则从复用队列中读取。
        [tableView registerCell:sectionModel.rowCellStyleClass];
        cell= [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    }
    if( [cell conformsToProtocol:@protocol(YUCheckBoxRowTextCellDelegate)]) {
        UIView * inputView =  [cell performSelector:@selector(shell_inputView)];
        if( [inputView isKindOfClass:[UITextView class]] ) {
            // 对于UITextView ～ 处理
            UITextView *textView = ((UITextView *)inputView);
            if( textView.delegate == nil ) {
                textView.delegate = self ;
                textView.inputAccessoryView = self.toolbar;
            }
        }else if( [inputView isKindOfClass:[UITextField class]] ) {
            // 对于UITextField ～ 处理
            UITextField *textField = ((UITextField *)inputView);
            if( textField.delegate == nil ) {
                textField.delegate = self;
                textField.inputAccessoryView = self.toolbar;
            }
        }
    }
    [self reModifyCell:cell withModel:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ShellKitSectionModel * sectionModel = _tableViewDataSource.sectionArrays[indexPath.section] ;
    ShellKitTableViewCellModel * rowmModel = sectionModel.rowArrays[indexPath.row];
    /** cell缓存高度  */
    if( rowmModel.cellHeight == UITableViewAutomaticDimension && cell.frame.size.height > 0  ) {
        rowmModel.cellHeight = cell.frame.size.height;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShellKitSectionModel * sectionModel = _tableViewDataSource.sectionArrays[indexPath.section] ;
    ShellKitTableViewCellModel * rowmModel = sectionModel.rowArrays[indexPath.row];
    rowmModel.isSelected = !rowmModel.isSelected;
    NSMutableArray<NSIndexPath *> * updateIndexPaths = [[NSMutableArray alloc]initWithArray:@[indexPath]];
    // 点击后的状态
    if( rowmModel.isSelected == YES ) {
        if( !sectionModel.isCanMultipleChoice )
        {
                // 不可多选，将已选的取消选择，保证已经选择只存在一个
            for ( ShellKitTableViewCellModel * selectedRow in sectionModel.selectRowsSet )
            {
                selectedRow.isSelected = NO ;
                NSIndexPath * unSelectIndexPath =[NSIndexPath indexPathForRow:selectedRow.rowNumber inSection:indexPath.section];
                [updateIndexPaths addObject:unSelectIndexPath];
            }
            [sectionModel.selectRowsSet removeAllObjects];
        }
        [sectionModel.selectRowsSet addObject:rowmModel];
    }
    else
    {
        [sectionModel.selectRowsSet removeObject:rowmModel];
    }
    [_tableView reloadData];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}
#pragma mark view logic
- (void)reModifyCell:(UITableViewCell  * ) cell
           withModel:(ShellKitTableViewCellModel *)model
{
    if(model.isSelected)
    {
        if( [cell respondsToSelector:@selector(shell_selectedStatus)] ){
            [cell performSelector:@selector(shell_selectedStatus)];
        }
    }else
    {
        if( [cell respondsToSelector:@selector(shell_unSelectStatus)] ) {
            
            [cell performSelector:@selector(shell_unSelectStatus)];
        }
    }
    if( [cell respondsToSelector:@selector(shell_setModel:)] ) {
        [cell performSelector:@selector(shell_setModel:) withObject:model];
    }
}

- (int)sign:(CGFloat)x {
    return x!=0? x/x:0 ;
}

- (void)dealloc {
    [self stopKeyboardObserve];
    
}
@end
