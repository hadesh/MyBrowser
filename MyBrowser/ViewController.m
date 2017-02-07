//
//  ViewController.m
//  MyBrowser
//
//  Created by hanxiaoming on 17/2/7.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import "ViewController.h"
#import "KINWebBrowserViewController.h"

static NSString *const defaultAddress = @"https://www.baidu.com";

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, KINWebBrowserDelegate>
{
    UITableView *_tableView;
    NSMutableArray<KINWebBrowserViewController *> *_pagesArray;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initTableView];
    [self initActionButton];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initTableView
{
    _pagesArray = [NSMutableArray array];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_tableView];
}

- (void)initActionButton
{
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionNewPage)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(actionClearAll)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

#pragma mark - Action

- (void)newPageWithURL:(NSString *)urlString
{
    if (urlString.length == 0)
    {
        urlString = [defaultAddress copy];
    }
    
    if (![urlString hasPrefix:@"http://"] && ![urlString hasPrefix:@"https://"])
    {
        urlString = [NSString stringWithFormat:@"http://%@", urlString];
    }
    
    KINWebBrowserViewController *webBrowser = [KINWebBrowserViewController webBrowser];
    [webBrowser setDelegate:self];
    [self.navigationController pushViewController:webBrowser animated:YES];
    [webBrowser loadURLString:urlString];
    
    [_pagesArray addObject:webBrowser];
    [_tableView reloadData];
}

- (void)actionNewPage
{
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入网址" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    UITextField *urlField = [alert textFieldAtIndex:0];
    urlField.placeholder = defaultAddress;
    
    [alert show];
}

- (void)actionClearAll
{
    [_pagesArray removeAllObjects];
    [_tableView reloadData];
}

#pragma mark - 

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        UITextField *urlField = [alertView textFieldAtIndex:0];
        [self newPageWithURL:urlField.text];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    KINWebBrowserViewController *webBrowser = _pagesArray[indexPath.row];
    [self.navigationController pushViewController:webBrowser animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle != UITableViewCellEditingStyleDelete)
    {
        return;
    }
    [_pagesArray removeObjectAtIndex:indexPath.row];
    
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _pagesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    KINWebBrowserViewController *webBrowser = _pagesArray[indexPath.row];
    
    cell.textLabel.text = webBrowser.wkWebView.title;
    cell.detailTextLabel.text = webBrowser.wkWebView.URL.absoluteString;
    
    return cell;
}

#pragma mark - KINWebBrowserDelegate

- (void)webBrowser:(KINWebBrowserViewController *)webBrowser didStartLoadingURL:(NSURL *)URL
{
    
}

- (void)webBrowser:(KINWebBrowserViewController *)webBrowser didFinishLoadingURL:(NSURL *)URL
{
    NSUInteger row = [_pagesArray indexOfObject:webBrowser];
    
    if (row != NSNotFound) {
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)webBrowser:(KINWebBrowserViewController *)webBrowser didFailToLoadURL:(NSURL *)URL error:(NSError *)error
{
    NSLog(@"load failed :%@", error);
}

- (void)webBrowserViewControllerWillDismiss:(KINWebBrowserViewController*)viewController
{
    
}

@end
