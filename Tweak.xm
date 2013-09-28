#import <UIKit/UIKit.h>
#import <AppList.h> //Using AppList to generate list of apps
#import <substrate.h>

#import <SBUIController.h>
#import <SBSearchTableViewCell.h>
#import <SBSearchController.h>

//Thanks caughtinflux
@interface SBSearchController (LLAdditions)
    - (BOOL)shouldDisplayListLauncher;
    -(NSString *)getDisplayIdentifierInt:(int)index;
    -(NSString *)getDisplayIdentifier:(NSIndexPath *)indexPath;
@end

@interface UIApplication (Undocumented)
    - (void) launchApplicationWithIdentifier: (NSString*)identifier suspended: (BOOL)suspended;
@end    

static ALApplicationList *apps = nil;
static NSArray *displayIdentifiers = nil;
static ALApplicationTableDataSource *dataSource = nil;

static UITableView *table = nil;
static CGFloat sectionHeaderWidth;
static CGFloat searchRowHeight;

// wildcat = iPad
static inline BOOL is_wildcat() { return (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad); }

%hook UITableView
- (void)setAlpha:(float)alpha { 
    if (self != table) 
        %orig; 
}
%end

%hook SBSearchView
- (id)initWithFrame: (CGRect)frame withContent: (id)content onWallpaper: (id)wallpaper {
    if ((self = %orig)) {
        // table = [self tableView];
        // BOOL isWildcat = is_wildcat();
        // sectionHeaderWidth = isWildcat ? 68.0f : 39.0f;
        // searchRowHeight = isWildcat ? 72.0f : 44.0f;
        // table.rowHeight = searchRowHeight;
        // [table setScrollEnabled:YES];

        table = [self tableView];
        BOOL isWildcat = is_wildcat();
        sectionHeaderWidth = isWildcat ? 68.0f : 39.0f;
        searchRowHeight = isWildcat ? 72.0f : 44.0f;
        table.rowHeight = searchRowHeight;
        [table setScrollEnabled:YES];
        apps = [ALApplicationList sharedApplicationList];
        dataSource = [[ALApplicationTableDataSource alloc] init];
        dataSource.sectionDescriptors = [ALApplicationTableDataSource standardSectionDescriptors];
    }
    return self;


    // id ans = %orig;

   
    // //table.dataSource = dataSource;
    // //dataSource.tableView = table;
    // NSLog(@"ONLY CALLED ONCE"); NSLog(@"ONLY CALLED ONCE"); NSLog(@"ONLY CALLED ONCE");
    // return ans;
}
%end

%hook SBSearchController

%new
-(BOOL)shouldDisplayListLauncher { 
    //Get's the search bar's text to check to see if it should display LL6
    return [[[[self searchView] searchBar] text] isEqualToString:@""];
}

-(BOOL)shouldShowKeyboardOnScroll { 
    if([self shouldDisplayListLauncher]) {
        return NO;
    }
    return %orig;
}

%new
-(NSString *)getDisplayIdentifier:(NSIndexPath *)indexPath {
    if(displayIdentifiers == nil || [displayIdentifiers count] != [apps applicationCount]) {
        NSLog(@"inside");
        displayIdentifiers = [[apps.applications allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[apps.applications objectForKey:obj1] compare:[apps.applications objectForKey:obj2]];}];
    }
    int index = indexPath.section;
    NSString *displayIdentifier = [displayIdentifiers objectAtIndex:index];
    return [apps valueForKey:@"displayName" forDisplayIdentifier:displayIdentifier];
}

%new
-(NSString *)getDisplayIdentifierInt:(int)index {
    if(displayIdentifiers == nil || [displayIdentifiers count] != [apps applicationCount]) {
        NSLog(@"inside");
        displayIdentifiers = [[apps.applications allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[apps.applications objectForKey:obj1] compare:[apps.applications objectForKey:obj2]];}];
    }
    NSString *displayIdentifier = [displayIdentifiers objectAtIndex:index];
    return [apps valueForKey:@"displayName" forDisplayIdentifier:displayIdentifier];
}

- (void)tableView:(id)tableView didSelectRowAtIndexPath:(id)indexPath {
    //This launches the app
    if (![self shouldDisplayListLauncher]) { %orig; return; }

    //id app = [dataSource displayIdentifierForIndexPath:indexPath];
    //int index = ((NSIndexPath *)indexPath).section;
    //NSArray *displayIdentifiers = [apps.applications allKeys];

    NSLog(@"inside didSelectRowAtIndexPath");

    NSString *displayIdentifier = [self getDisplayIdentifier:indexPath];
    NSLog(@"inside didSelectRowAtIndexPath %@",displayIdentifier);
    [[UIApplication sharedApplication] launchApplicationWithIdentifier:displayIdentifier suspended:NO];
    //[[objc_getClass("SBUIController") sharedInstance] activateApplicationAnimated:displayIdentifier];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (float)tableView: (id)tv heightForRowAtIndexPath: (id)ip { 
    return searchRowHeight; 
}

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Asks the data source for a cell to insert in a particular 
    // location of the table view. (required)
    if (![self shouldDisplayListLauncher]) { return %orig; }

    NSLog(@"inside cellForRowAtIndexPath");

    //NSLog(@"indexpath(%d,%d)",indexPath.row,indexPath.section);
    //int index = indexPath.section;
    //NSArray *displayIdentifiers = [apps.applications allKeys];
    
    //NSString *displayIdentifier = [displayIdentifiers objectAtIndex:index];
    // displayNames = [apps.applications allValues];
    // NSString *name = [displayNames objectAtIndex:index];

    //NSString *displayIdentifier = [dataSource displayIdentifierForIndexPath:indexPath];
    //NSString *name = [apps valueForKey:@"displayName" forDisplayIdentifier:displayIdentifier];
    NSString *name = [self getDisplayIdentifier:indexPath];
    NSLog(@"finding a cell %@",name);

    int s = [indexPath section];

    id cell = [tableView dequeueReusableCellWithIdentifier:@"dude"];
    if (cell) {
        //[cell clearContents];
    } else {
        //Thanks DHowett!
        cell = [[[%c(SBSearchTableViewCell) alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"dude"] autorelease]; //Actually need a style
        //Thanks caughtinflux and Jack! (sorta)
        float &secWidth = MSHookIvar<float>(cell, "_sectionHeaderWidth"); 
        if (secWidth) {
            secWidth = sectionHeaderWidth;
        }
        [cell setEdgeInset:0];
    }

    [cell setBadged:NO];
    [cell setBelowTopHit:YES];
    [cell setUsesAlternateBackgroundColor:NO];
    if (s == 0) {
        [cell setFirstInTableView:YES];
    }
    else {
        [cell setFirstInTableView:NO];
    }

    [cell setTitle:name];
    object_setInstanceVariable(cell, "_title", name);
    //[cell setAuxiliaryTitle:]; //It would be cool if it showed the last message etc; similiar to runninglist
    //[cell setSubtitle:]; //see above
    [cell setFirstInSection:YES];

    [[[self searchView] tableView] setScrollEnabled:YES];
    //[[sv tableView] setScrollEnabled:YES];
    [cell setNeedsDisplay];

    return cell;
}

- (int)tableView: (id)tableView numberOfRowsInSection: (int)s {
    if (![self shouldDisplayListLauncher]) return %orig;
    else return 1;
}

- (int)numberOfSectionsInTableView: (id)tableView {
    if (![self shouldDisplayListLauncher]) return %orig;
    return [apps applicationCount];
    //return (int)[dataSource numberOfSectionsInTableView:dataSource.tableView];
    //int count = [dataSource numberOfSectionsInTableView:table];
    //NSLog(@"numberofSections:%d in %@",count,[dataSource.sectionDescriptors description]);
    //return count;
}

- (id)tableView: (id)tableView viewForHeaderInSection: (int)index {
    //Asks the delegate for a view object to display in the 
    // header of the specified section of the table view.

    if (![self shouldDisplayListLauncher]) return %orig;

    id v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sectionHeaderWidth, searchRowHeight)];
    //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:s];
    //NSString *displayIdentifier = [displayIdentifiers objectAtIndex:index];
    //NSString *displayIdentifier = [dataSource displayIdentifierForIndexPath:indexPath];
    //id m = [[[SBIconModel sharedInstance] applicationIconForDisplayIdentifier:displayIdentifier] getIconImage:is_wildcat()];
    //id i = [[UIImageView alloc] initWithImage:m];


    
    /*id i = [apps iconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:displayIdentifier];
    CGRect r = [i frame];
    r.size = [i size];
    CGSize size = [v frame].size;
    r.origin.y = (size.height - r.size.height) * 0.5f;
    r.origin.x = (size.width - r.size.width) * 0.5f;
    [i setFrame:r];
    [v addSubview:i];
    [i release];
    [v setOpaque:0]; */
    [v setUserInteractionEnabled:NO];

    return [v autorelease];
}

%end


//These things don't exist in iOS6. At least in the headers I am looking at. 

// - (BOOL)_hasSearchResults { return YES; }

// - (BOOL)respondsToSelector: (SEL)selector { 
//     return selector == @selector(tableView:heightForRowAtIndexPath:) ? NO : %orig; 
// }


// //%new(i@:@i)
// - (int)tableView: (UITableView *)tableView sectionForSectionIndexTitle: (NSString *)title atIndex: (NSInteger)index {
//     // Asks the datasource to return the index for the section having the given title and section title index
   
//     int idx = [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
//     for (int i = 0; i < [apps applicationCount]; i++) {
//         NSIndexPath *path = [NSIndexPath indexPathWithIndex:i];
//         if (idx <= [[UILocalizedIndexedCollation currentCollation] sectionForObject:[dataSource displayIdentifierForIndexPath:path] collationStringSelector:@selector(displayName)]) return i;
//     }
//     return -1;
// }

// //%new(@@:@)
// - (NSArray *)sectionIndexTitlesForTableView: (UITableView *)tableView {
//     //return the titles for the sections for a table view
//     if ([self shouldDisplayListLauncher]) {
//         return nil;
//     } else {
//         id titles = [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
//         //titles = [titles subarrayWithRange:NSMakeRange(0, [titles count] - 1)];
//         return titles;
//     }
// }
