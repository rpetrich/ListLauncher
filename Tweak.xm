#import <UIKit/UIKit.h>
#import <AppList.h> //Using AppList to generate list of apps
#import <substrate.h>

#import <SBUIController.h>
#import <SBSearchTableViewCell.h>
#import <SBSearchController.h>

//Thanks caughtinflux
@interface SBSearchController (LLAdditions)
    -(BOOL)shouldDisplayListLauncher;
@end

@interface UIApplication (Undocumented)
    - (void) launchApplicationWithIdentifier: (NSString*)identifier suspended: (BOOL)suspended;
@end    

static ALApplicationList *apps = nil;

static NSArray *displayIdentifiers = nil;
static NSArray *displayNames = nil;

//static NSArray *displayIdentifiers = nil;
//static ALApplicationTableDataSource *dataSource = nil;

static UITableView *table = nil;
static CGFloat sectionHeaderWidth;
static CGFloat searchRowHeight;

// wildcat = iPad
static inline BOOL isPad() { return (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad); }

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

        apps = [ALApplicationList sharedApplicationList];

        //case insentitive to properly order
        displayIdentifiers = [[apps.applications allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[apps.applications objectForKey:obj1] caseInsensitiveCompare:[apps.applications objectForKey:obj2]];}];
        displayNames = [[apps.applications allValues] sortedArrayUsingSelector:@selector(compare:)];
        [displayIdentifiers retain];
        [displayNames retain];

        //dataSource = [[ALApplicationTableDataSource alloc] init];
        //dataSource.sectionDescriptors = [ALApplicationTableDataSource standardSectionDescriptors];

        table = [self tableView];
        BOOL isWildcat = isPad();
        sectionHeaderWidth = isWildcat ? 68.0f : 39.0f;
        searchRowHeight = isWildcat ? 72.0f : 44.0f;
        table.rowHeight = searchRowHeight;
        [table setScrollEnabled:YES];


        //dataSource.tableView = table;
        //table.dataSource = dataSource;
        
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

//static NSArray *displayIdentifiers = [[NSArray alloc] init];

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




// %new
// -(NSString *)getDisplayIdentifier:(NSIndexPath *)indexPath {
//     if(displayIdentifiers == nil || [displayIdentifiers count] != [apps applicationCount]) {
//         NSLog(@"inside");
//         displayIdentifiers = [[apps.applications allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//         return [[apps.applications objectForKey:obj1] compare:[apps.applications objectForKey:obj2]];}];
//     }
//     int index = indexPath.section;
//     NSString *displayIdentifier = [displayIdentifiers objectAtIndex:index];
//     return [apps valueForKey:@"displayName" forDisplayIdentifier:displayIdentifier];
// }

// %new
// -(NSString *)getDisplayIdentifierInt:(int)index {
//     if(displayIdentifiers == nil || [displayIdentifiers count] != [apps applicationCount]) {
//         NSLog(@"inside");
//         displayIdentifiers = [[apps.applications allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//         return [[apps.applications objectForKey:obj1] compare:[apps.applications objectForKey:obj2]];}];
//     }
//     NSString *displayIdentifier = [displayIdentifiers objectAtIndex:index];
//     return [apps valueForKey:@"displayName" forDisplayIdentifier:displayIdentifier];
// }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //This launches the app
    if (![self shouldDisplayListLauncher]) { %orig; return; }

    //id app = [dataSource displayIdentifierForIndexPath:indexPath];
    //int index = ((NSIndexPath *)indexPath).section;
    //NSArray *displayIdentifiers = [apps.applications allKeys];
    NSLog(@"inside didSelectRowAtIndexPath");


    int index = indexPath.section;

    NSString *displayIdentifier = [displayIdentifiers objectAtIndex:index];
    //NSString *displayIdentifier = [self getDisplayIdentifier:indexPath];
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

    // if(![displayIdentifiers count]) {
    //     displayIdentifiers = [[apps.applications allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    //     return [[apps.applications objectForKey:obj1] compare:[apps.applications objectForKey:obj2]];}];
    // }
    //NSLog(@"indexpath(%d,%d)",indexPath.row,indexPath.section);
    //int index = indexPath.section;
    //NSArray *displayIdentifiers = [apps.applications allKeys];
    
    //NSString *displayIdentifier = [displayIdentifiers objectAtIndex:index];
    // displayNames = [apps.applications allValues];
    // NSString *name = [displayNames objectAtIndex:index];

    //NSString *displayIdentifier = [dataSource displayIdentifierForIndexPath:indexPath];
    //NSString *name = [apps valueForKey:@"displayName" forDisplayIdentifier:displayIdentifier];

    //NSString *name = [self getDisplayIdentifier:indexPath];
    NSString *name = [apps valueForKey:@"displayName" forDisplayIdentifier:[displayIdentifiers objectAtIndex:indexPath.section]];
    NSLog(@"finding a cell %@",name);

    //int s = indexPath.section;

    SBSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dude"];
    if (cell) {
        //[cell clearContents]; //Calling this creates a bug where you can't scroll up?
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

    if (indexPath.section == 0) {
        [cell setFirstInTableView:YES];
    }
    else {
        [cell setFirstInTableView:NO];
    }

    //[cell setTitle:name];
    cell.title = name;

    //object_setInstanceVariable(cell, "_title", name);
    //[cell setAuxiliaryTitle:]; //It would be cool if it showed the last message etc; similiar to runninglist
    //[cell setSubtitle:]; //see above
    [cell setFirstInSection:YES];
    cell.detailTextLabel.bounds = CGRectMake(20,0,320,20);
    cell.detailTextLabel.frame = CGRectMake(20,0,320,20);
    // cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    // cell.userInteractionEnabled = YES;
    //[cell setUserInteractionEnabled:YES];
    [[[self searchView] tableView] setScrollEnabled:YES];
    //[[self searchView] tableView].allowsSelection=YES;
    //[[sv tableView] setScrollEnabled:YES];
    [cell setNeedsDisplay];



    UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(3,2, 20, 25)];
    UIImage *icon = [apps iconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:[displayIdentifiers objectAtIndex:indexPath.section]];
    imv.image = icon;
    //[cell addSubview:imv];
    //cell.edgeInset = is_wildcat ? 68.0f : 39.0f;
    [imv release];
    cell.sectionHeaderWidth = isPad ? 39.0f : 68.0f;

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

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sectionHeaderWidth, searchRowHeight)];
    //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:index];
    NSString *displayIdentifier = [displayIdentifiers objectAtIndex:index];
    //NSString *displayIdentifier = [dataSource displayIdentifierForIndexPath:indexPath];
    //id m = [[[SBIconModel sharedInstance] applicationIconForDisplayIdentifier:displayIdentifier] getIconImage:is_wildcat()];
    //id i = [[UIImageView alloc] initWithImage:m];
    
    UIImage *icon = [apps iconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:displayIdentifier];
    UIImageView *iview = [[UIImageView alloc] initWithImage:icon];
    CGRect rec = [iview bounds];
    rec.size = [icon size];
    CGSize size = [view frame].size;
    rec.origin.y = (size.height - rec.size.height) * 0.5f;
    rec.origin.x = (size.width - rec.size.width) * 0.5f;

    iview.frame = rec;
    //[iview setFrame:rec];
    [view addSubview:iview];

    [view setOpaque:0];
    [view setUserInteractionEnabled:NO];

    [iview release];




    //  [icon release];
    //  [view setOpaque:0];
    //  [view setUserInteractionEnabled:YES];


    //  v.image = icon;

    // CGRect r = [i frame];
    // r.size = [i size];
    // CGSize size = [v frame].size;
    // r.origin.y = (size.height - r.size.height) * 0.5f;
    // r.origin.x = (size.width - r.size.width) * 0.5f;
    // [i setFrame:r];
    // [v addSubview:i];
    // [i release];
    // [v setOpaque:0];
    

    return [view autorelease];
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
