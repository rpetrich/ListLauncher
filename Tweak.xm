#import <UIKit/UIKit.h>
#import <AppList.h> //Using AppList to generate list of apps

@interface AppListViewController : UITableViewController {
@private 
	ALApplicationTableDataSource *apps; 
}
@end;

static id app_id = nil; 
static UITableView *table = nil;
static CGFloat sectionHeaderWidth;
static CGFloat searchRowHeight;

static inline BOOL is_wildcat() { return (BOOL)(int)[[UIDevice currentDevice] isWildcat]; }

%hook UITableView
- (void)setAlpha:(float)alpha { 
    if (self != table) 
        %orig; 
}
%end

%hook SBSearchView
- (id)initWithFrame: (CGRect)frame withContent: (id)content onWallpaper: (id)wallpaper {
    if ((self = %orig)) {
        table = [self tableView];
        BOOL isWildcat = is_wildcat();
        sectionHeaderWidth = isWildcat ? 68.0f : 39.0f;
        searchRowHeight = isWildcat ? 72.0f : 44.0f;
        table.rowHeight = searchRowHeight;
    }
    return self;
}
%end

%hook SBApplicationController
- (void)loadApplications {
    // Gets the list of all the applications
    %orig;

    [apps release];

    apps = [ALApplicationList sharedApplicationList];

    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        apps = [[ALApplicationTableDataSource alloc] init];
        apps.sectionDescriptors = [ALApplicationTableDataSource standardSectionDescriptors];
    }
}
%end

%hook SBSearchController
%new(c@:)
- (BOOL)shouldGTFO { return ![[[[self searchView] searchBar] text] isEqualToString:@""]; }
//returns false when there is no search term

- (BOOL)_hasSearchResults { return YES; }

- (BOOL)respondsToSelector: (SEL)selector { 
    return selector == @selector(tableView:heightForRowAtIndexPath:) ? NO : %orig; 
}

- (float)tableView: (id)tv heightForRowAtIndexPath: (id)ip { 
    return searchRowHeight; 
}

%new(i@:@i)
- (int)tableView: (UITableView *)tableView sectionForSectionIndexTitle: (NSString *)title atIndex: (NSInteger)index {
    // Asks the datasource to return the index for the section having the given title and section title index
   
    int idx = [[UILocalizedIndexedCollation currentCollation]
sectionForSectionIndexTitleAtIndex:index];
    for (int i = 0; i < [apps count]; i++) {
        if (idx <= [[UILocalizedIndexedCollation currentCollation] sectionForObject:[apps objectAtIndex:i] collationStringSelector:@selector(displayName)])
            return i;
    }
    return -1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{ //Tells the delegate what row is now selected
    %orig;
}

%new(@@:@)
- (NSArray *)sectionIndexTitlesForTableView: (UITableView *)tableView {
    //return the titles for the sections for a table view
    if ([self shouldGTFO]) {
        return nil;
    } else {
        id titles = [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
        //titles = [titles subarrayWithRange:NSMakeRange(0, [titles count] - 1)];
        return titles;
    }
}
- (id)tableView: (id)tv cellForRowAtIndexPath: (id)ip {
    // Asks the data source for a cell to insert in a particular 
    // location of the table view. (required)
    if ([self shouldGTFO]) return %orig;

    int s = [ip section];

    id cell = [tv dequeueReusableCellWithIdentifier:@"dude"];
    if (cell) {
        [cell clearContents];
    } else {
        cell = [[[objc_getClass("SBSearchTableViewCell") alloc] initWithStyle:(UITableViewCellStyle)0 reuseIdentifier:@"dude"] autorelease];
        MSHookIvar<float>(cell, "_sectionHeaderWidth") = sectionHeaderWidth;
        [cell setEdgeInset:0];
    }

    [cell setBadged:NO];
    [cell setBelowTopHit:YES];
    [cell setUsesAlternateBackgroundColor:NO];
    if ([ip section] == 0) [cell setFirstInTableView:YES];
    else [cell setFirstInTableView:NO];

    //[cell setTitle:[[apps objectAtIndex:s] displayName]];
    [cell setTitle:[[dataSource displayIdentifierForIndexPath:indexPath] displayName]];
    //[cell setAuxiliaryTitle:]; //It would be cool if it showed the last message etc; similiar to runninglist
    //[cell setSubtitle:]; //see above
    [cell setFirstInSection:YES];

    [[[self searchView] tableView] setScrollEnabled:YES];
    [cell setNeedsDisplay];

    return cell;
}
- (void)tableView: (id)tv didSelectRowAtIndexPath: (id)ip {
    //This launches the app
    if ([self shouldGTFO]) { %orig; return; }

    id a = [apps objectAtIndex:[ip section]];
    [[objc_getClass("SBUIController") sharedInstance] activateApplicationAnimated:a];
    [tv deselectRowAtIndexPath:ip animated:YES];
}

- (int)tableView: (id)tv numberOfRowsInSection: (int)s {
    if ([self shouldGTFO]) return %orig;
    else return 1;
}
- (int)numberOfSectionsInTableView: (id)tv {
    if ([self shouldGTFO]) return %orig;
    return [apps count];
}
- (id)tableView: (id)tv viewForHeaderInSection: (int)s {
    //Asks the delegate for a view object to display in the 
    // header of the specified section of the table view.

    if ([self shouldGTFO]) return %orig;

    id v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sectionHeaderWidth, searchRowHeight)];
    id m = [[[objc_getClass("SBIconModel") sharedInstance] applicationIconForDisplayIdentifier:[[apps objectAtIndex:s] displayIdentifier]] getIconImage:is_wildcat()];
    id i = [[UIImageView alloc] initWithImage:m];
    CGRect r = [i frame];
    r.size = [m size];
    CGSize size = [v frame].size;
    r.origin.y = (size.height - r.size.height) * 0.5f;
    r.origin.x = (size.width - r.size.width) * 0.5f;
    [i setFrame:r];
    [v addSubview:i];
    [i release];
    [v setOpaque:0];
    [v setUserInteractionEnabled:NO];

    return [v autorelease];
}
%end
