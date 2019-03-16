//
//  ViewController.m
//  rememberify
//
//  Created by Admin on 26/02/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import "ViewController.h"
#import "MeaningViewController.h"

@interface ViewController ()

@end

@implementation ViewController {
    UISearchBar *searchBar;
    UITextChecker *textChecker;
    NSMutableArray *words;
    UITableView *tableView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        textChecker = [[UITextChecker alloc] init];
        
        searchBar = [[UISearchBar alloc] init];
        searchBar.delegate = self;
        searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        searchBar.spellCheckingType = UITextSpellCheckingTypeNo;
        searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.navigationItem.titleView = searchBar;
        [searchBar sizeToFit];
        
        words = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [self.view addSubview:tableView];
    
    [searchBar becomeFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [words removeAllObjects];
    
    if ([searchText length] < 3) {
        [tableView reloadData];
        return;
    }
    
    NSRange range = NSMakeRange(0, searchText.length);
    
    NSArray *completions = [textChecker completionsForPartialWordRange:range inString:searchText language:@"en"];
    for (NSString *c in completions) {
        [words addObject:c];
    }
    
    [tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    MeaningViewController *vc = [[MeaningViewController alloc] initWithWord:@"appeal"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [words count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [words objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // [searchBar resignFirstResponder];
    
    // NSString *word = [words objectAtIndex:indexPath.row];
    MeaningViewController *vc = [[MeaningViewController alloc] initWithWord:@"appeal"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
