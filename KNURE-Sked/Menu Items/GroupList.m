//
//  HistoryList.m
//  KNURE-Sked
//
//  Created by Oksana Kubiria on 08.11.13.
//  Copyright (c) 2013 Влад. All rights reserved.
//

#import "GroupList.h"
#import "ECSlidingViewController.h"
#import "TabsViewController.h"

@interface HistoryList ()
@property (strong, nonatomic) NSMutableArray *historyTable;

@end

@implementation HistoryList
@synthesize menuBtn;
@synthesize historyTable;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    historyList = [[NSMutableArray alloc] init];
    if ([[NSUserDefaults standardUserDefaults] valueForKeyPath:@"SavedGroups"] != nil) {
    historyList = [[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"SavedGroups"] mutableCopy];
    }
    historyTable = [[NSMutableArray alloc] initWithArray:historyList];
    // Do any additional setup after loading the view.
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[TabsViewController class]]) {
        self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    self.menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(13, 30, 34, 24);
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"menuButton.png"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.menuBtn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)revealMenu:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [historyList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [historyList objectAtIndex:indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    @try {
        NSString *group = cell.textLabel.text;
        NSError *error=nil;
        int i=0;
        NSArray *matches;
        NSString *htmlResponseString;
        NSArray *facults = [NSArray arrayWithObjects:@"95",
                        @"114",
                        @"56",
                        @"152",
                        @"192",
                        @"287",
                        @"237",
                        @"2",
                        @"672"
                        @"6",
                        @"2001",
                        @"64",
                        @"128", nil];
        NSString* matchAllResult;
        NSString *URL = @"http://cist.kture.kharkov.ua/ias/app/tt/WEB_IAS_TT_AJX_GROUPS?p_id_fac=";
        do {
            NSString *request = [NSString stringWithFormat:@"%@%@", URL, [facults objectAtIndex:i]];
            NSString *expression = [NSString stringWithFormat:@"%@%@%@%@", @"\'", group, @"\'", @"+[,]+[0-9]+[0-9]+[0-9]"];
            NSData *responseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:request]];
            htmlResponseString = [[NSString alloc] initWithData:responseData encoding:NSWindowsCP1251StringEncoding];
            NSRegularExpression *matchAll = [NSRegularExpression regularExpressionWithPattern:expression
                                                                                  options:NSRegularExpressionCaseInsensitive
                                                                                    error:&error];
            matches = [matchAll matchesInString:htmlResponseString
                                    options:0
                                      range:NSMakeRange(0, [htmlResponseString length])];
            i++;
        } while (matches.count == 0);
    
        matchAllResult = [htmlResponseString substringWithRange:[matches[0] range]];
    
    
        NSLog(@"%@",matchAllResult);
        NSRegularExpression *finalMatch = [NSRegularExpression regularExpressionWithPattern:@"[0-9]+[0-9]+[0-9]"
                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                  error:&error];
        NSArray *finalMatchResult = [finalMatch matchesInString:matchAllResult
                                                    options:0
                                                      range:NSMakeRange(0, [matchAllResult length])];
        NSString* result = [matchAllResult substringWithRange:[finalMatchResult[0] range]];
        NSLog(@"%@",result);
        NSUserDefaults *fullData = [NSUserDefaults standardUserDefaults];
        [fullData setValue:result forKey:@"ID"];
        [self getGroupUpdate];
        [fullData setValue:group forKey:@"curName"];
        [fullData synchronize];
    }
    @catch (NSException * e) {
        UIAlertView *endGameMessage = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Введенно неверное название группы" delegate:self cancelButtonTitle:@"Далее" otherButtonTitles: nil];
        [endGameMessage show];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void) getGroupUpdate {
    NSString *curId = [[NSUserDefaults standardUserDefaults] valueForKey:@"ID"];
    NSString *curRequest = [NSString stringWithFormat:@"%@%@%@",@"http://cist.kture.kharkov.ua/ias/app/tt/WEB_IAS_TT_GNR_RASP.GEN_GROUP_POTOK_RASP?ATypeDoc=4&Aid_group=", curId, @"&Aid_potok=0&ADateStart=01.09.2013&ADateEnd=31.01.2014&AMultiWorkSheet=0"];
    //NSLog(@"%@",curRequest);
    NSError *error = nil;
    NSUserDefaults* fullLessonsData = [NSUserDefaults standardUserDefaults];
    NSData *responseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:curRequest]];
    NSString *csvResponseString = [[NSString alloc] initWithData:responseData encoding:NSWindowsCP1251StringEncoding];
    //NSLog(@"%@", csvResponseString);
    NSString *modifstr = [csvResponseString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSString *modifstr2 = [modifstr stringByReplacingOccurrencesOfString:@"," withString:@" "];
    //NSLog(@"%@%@",@"MODSTR2: ", modifstr2);
    NSRegularExpression *delGRP = [NSRegularExpression regularExpressionWithPattern:@"[А-ЯІЇЄҐ;]+[-]+[0-9]+[-]+[0-9]"
                                                                            options:NSRegularExpressionCaseInsensitive
                                                                              error:&error];
    NSString *delgrp = [delGRP stringByReplacingMatchesInString:modifstr2
                                                        options:0
                                                          range:NSMakeRange(0, [modifstr2 length])
                                                   withTemplate:@""];
    //NSLog(@"%@%@",@"DELGRP", delgrp);
    NSRegularExpression *delTIME = [NSRegularExpression regularExpressionWithPattern:@"[0-9]+[:]+[0-9]+[0-9:0-9]+[0-9]"
                                                                             options:NSRegularExpressionCaseInsensitive
                                                                               error:&error];
    NSString *deltime = [delTIME stringByReplacingMatchesInString:delgrp
                                                          options:0
                                                            range:NSMakeRange(0, [delgrp length])
                                                     withTemplate:@""];
    NSString *delSpace = [deltime stringByReplacingOccurrencesOfString:@"   " withString:@" "];
    //NSLog(@"%@", delSpace);
    NSRegularExpression *delREST = [NSRegularExpression regularExpressionWithPattern:@"  (.*)"
                                                                            options:NSRegularExpressionCaseInsensitive
                                                                              error:&error];
    NSString *delRest = [delREST stringByReplacingMatchesInString:delSpace
                                                        options:0
                                                          range:NSMakeRange(0, [delSpace length])
                                                   withTemplate:@""];
    //NSLog(@"%@%@",@"DELSPASE: ", delRest);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy"];
    NSDate *startDate = [[NSDate alloc] init];
    NSDate *endDate = [[NSDate alloc] init];
    NSMutableArray *dateList = [NSMutableArray array];
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    startDate = [formatter dateFromString:@"01.09.2013"];
    endDate = [formatter dateFromString:@"02.02.2014"];
    [dateList addObject: startDate];
    NSDate *currentDate = startDate;
    currentDate = [currentCalendar dateByAddingComponents:comps toDate:currentDate  options:0];
    while ( [endDate compare: currentDate] != NSOrderedAscending) {
        [dateList addObject: currentDate];
        currentDate = [currentCalendar dateByAddingComponents:comps toDate:currentDate  options:0];
    }
    NSMutableArray *normalDates = [NSMutableArray array];
    for (int i=0; i<dateList.count; i++) {
        NSString *dates = [NSString stringWithFormat:@"%@%@", [formatter stringForObjectValue:[dateList objectAtIndex:i]], @" "];
        [normalDates addObject:dates];
    }
    NSArray *list = [delRest componentsSeparatedByString:@"\r"];
    NSArray *list2 = [list arrayByAddingObjectsFromArray:normalDates];
    NSMutableArray *sorted = [[NSMutableArray alloc]init];
    for (NSString *str in list2) {
        if ([str isEqual:@""]) {
            continue;
        }
        NSRange rangeForSpace = [str rangeOfString:@" "];
        NSString *objectStr = [str substringFromIndex:rangeForSpace.location];
        NSString *dateStr = [str substringToIndex:rangeForSpace.location];
        NSDate *date = [formatter dateFromString:dateStr];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:objectStr, @"object", date, @"date", nil];
        [sorted addObject:dic];
    }
    NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    [sorted sortUsingDescriptors:[NSArray arrayWithObjects:sortDesc, nil]];
    
    [fullLessonsData setObject:sorted forKey: curId];
    [fullLessonsData synchronize];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [historyList removeObjectAtIndex:indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
    [self.tableView reloadData];
    /*else if (editingStyle == UITableViewCellEditingStyleInsert) {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }*/
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

*/

- (IBAction)addName:(id)sender {
    [historyList addObject:self.nameField.text];
    self.nameField.text = @"Введите вашу группу";
    NSUInteger index;
    NSArray * indexArray;
    index = [historyList count]-1;
    UITableView *tv = (UITableView *)self.view;
    [self.tableView beginUpdates];
    indexArray = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]];
    [tv insertRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];
    [self.tableView reloadData];
    }

- (void) viewWillDisappear:(BOOL)animated {
    NSUserDefaults *fullHistory = [NSUserDefaults standardUserDefaults];
    [fullHistory setValue:historyList forKeyPath:@"SavedGroups"];
    [fullHistory synchronize];
}

@end
