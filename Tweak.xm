#import <UIKit/UIKit.h>
#import <AppList.h> //Using AppList to generate list of apps
#import <substrate.h>

#import <SBUIController.h>
#import <SBSearchTableViewCell.h>
#import <SBSearchController.h>

// Thanks caughtinflux for teaching me that I can 
// add interfaces here instead of importing classes
@interface SBSearchController (LLAdditions)
    -(BOOL)shouldDisplayListLauncher;
@end

@interface UIApplication (Undocumented)
    - (void) launchApplicationWithIdentifier: (NSString*)identifier suspended: (BOOL)suspended;
@end    

static ALApplicationList *apps = nil;
static NSArray *displayIdentifiers = nil;

static UITableView *table = nil;
static CGFloat sectionHeaderWidth;
static CGFloat searchRowHeight;

//is user on an iPad
static inline BOOL isPad() { return (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad); }

%hook UITableView
// Ensure that the table is not hidden
- (void)setAlpha:(float)alpha { 
    if (self != table) 
        %orig; 
}
%end

%hook SBSearchView
// Initialize the application list and create the table
- (id)initWithFrame: (CGRect)frame withContent: (id)content onWallpaper: (id)wallpaper {
    if ((self = %orig)) {

        apps = [ALApplicationList sharedApplicationList];

        displayIdentifiers = [[apps.applications allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[apps.applications objectForKey:obj1] caseInsensitiveCompare:[apps.applications objectForKey:obj2]];}];
        // displayNames = [[apps.applications allValues] sortedArrayUsingSelector:@selector(compare:)];
        [displayIdentifiers retain];
        // [displayNames retain];


        table = [self tableView];
        BOOL isWildcat = isPad();
        sectionHeaderWidth = isWildcat ? 68.0f : 39.0f;
        searchRowHeight = isWildcat ? 72.0f : 44.0f;
        table.rowHeight = searchRowHeight;
        [table setScrollEnabled:YES];        
    }
    return self;
}
%end

%hook SBSearchController

%new
-(BOOL)shouldDisplayListLauncher { 
    //Get's the search bar's text to check to see if it should display LL6
    return [[[[self searchView] searchBar] text] isEqualToString:@""];
}

// Shouldn't display the keyboard when viewing ListLauncher
-(BOOL)shouldShowKeyboardOnScroll { 
    if([self shouldDisplayListLauncher]) {
        return NO;
    }
    return %orig;
}

// Determine what to do when user taps on the section aka launch the app!
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self shouldDisplayListLauncher]) { %orig; return; }

    int index = indexPath.section;

    NSString *displayIdentifier = [displayIdentifiers objectAtIndex:index];

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

    NSString *name = [apps valueForKey:@"displayName" forDisplayIdentifier:[displayIdentifiers objectAtIndex:indexPath.section]];
    SBSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dude"];

    if (cell) {
        [cell clearContents];
    } else {
        //Thanks DHowett for teaching me how to hook properly. 
        cell = [[[%c(SBSearchTableViewCell) alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"dude"] autorelease]; //Actually need a style
        //Thanks caughtinflux and Jack! (sorta) Got me halfway to hooking!
        // float &secWidth = MSHookIvar<float>(cell, "_sectionHeaderWidth"); 
        // if (secWidth) {
        //     secWidth = sectionHeaderWidth;
        // }
        [cell setEdgeInset:0];
        cell.sectionHeaderWidth = isPad ? 39.0f : 68.0f;
    }

    if(indexPath.section % 2 == 0) {
       [cell setUsesAlternateBackgroundColor:NO]; 
    } else{
        [cell setUsesAlternateBackgroundColor:YES]; 
    }    

    if (indexPath.section == 0) {
        [cell setFirstInTableView:YES];
    } else {
        [cell setFirstInTableView:NO];
    }

   
    cell.title = name;
    [cell setBadged:NO];
    [cell setBelowTopHit:YES];
    [cell setFirstInSection:YES];
    [cell setNeedsDisplay];
    [[[self searchView] tableView] setScrollEnabled:YES];
    
    //[cell setAuxiliaryTitle:]; //It would be cool if it showed the last message etc; similiar to runninglist
    //[cell setSubtitle:]; //see above   

    return cell;
}

- (int)tableView: (id)tableView numberOfRowsInSection: (int)s {
    if (![self shouldDisplayListLauncher]) return %orig;
    else return 1;
}

- (int)numberOfSectionsInTableView: (id)tableView {
    if (![self shouldDisplayListLauncher]) return %orig;
    return [apps applicationCount];
}

- (id)tableView: (id)tableView viewForHeaderInSection: (int)index {
    //Asks the delegate for a view object to display in the 
    // header of the specified section of the table view.

    if (![self shouldDisplayListLauncher]) return %orig;

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sectionHeaderWidth, searchRowHeight)];
    NSString *displayIdentifier = [displayIdentifiers objectAtIndex:index];

    
    UIImage *icon = [apps iconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:displayIdentifier];
    UIImageView *iview = [[UIImageView alloc] initWithImage:icon];
    CGRect rec = [iview bounds];
    rec.size = [icon size];
    CGSize size = [view frame].size;
    rec.origin.y = (size.height - rec.size.height) * 0.5f;
    rec.origin.x = (size.width - rec.size.width) * 0.5f;

    iview.frame = rec;

    [view addSubview:iview];

    [view setOpaque:0];
    [view setUserInteractionEnabled:NO];

    [iview release];

    return [view autorelease];
}

%end


//These things don't exist in iOS6. At least in the headers I am looking at. 
// I believe these might be used for indexing which is a future feature. 

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
