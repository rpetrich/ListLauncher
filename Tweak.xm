#import <UIKit/UIKit.h>
#import <AppList.h> //Using AppList to generate list of apps

static id apps = nil;
static UITableView *table = nil;
static CGFloat sectionHeaderWidth;
static CGFloat searchRowHeight;

static inline BOOL is_wildcat() { return (BOOL)(int)[[UIDevice currentDevice] isWildcat]; }

%hook UITableView
- (void)setAlpha:(float)alpha { if (self != table) %orig; }
%end

%hook SBSearchView
- (id)initWithFrame:(CGRect)frame withContent:(id)content onWallpaper:(id)wallpaper {
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
    %orig;

    [apps release];
    apps = [[NSMutableArray alloc] init];
    id x = [NSMutableArray array];
    id collation = [UILocalizedIndexedCollation currentCollation];
    for (int i = 0; i < [[collation sectionTitles] count]; i++) [x addObject:[NSMutableArray array]];
    for (id app in [self allApplications]) {
        if (![[app tags] containsObject:@"hidden"]) {
            int idx = [collation sectionForObject:app collationStringSelector:@selector(displayName)]; 
            [[x objectAtIndex:idx] addObject:app];
        }
    }
    for (id s in x) [apps addObjectsFromArray:[collation sortedArrayFromArray:s collationStringSelector:@selector(displayName)]];
}
%end

%hook SBSearchController
%new(c@:)
- (BOOL)shouldGTFO { return ![[[[self searchView] searchBar] text] isEqualToString:@""]; }
- (BOOL)_hasSearchResults { return YES; }
- (BOOL)respondsToSelector:(SEL)selector { return selector == @selector(tableView:heightForRowAtIndexPath:) ? NO : %orig; }
- (float)tableView:(id)tv heightForRowAtIndexPath:(id)ip { return searchRowHeight; }
%new(i@:@i)
/* When I installed it on my phone, the table was empty... and this generates the table? So this is bad?
- (int)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    int idx = [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
    for (int i = 0; i < [apps count]; i++) {
        if (idx <= [[UILocalizedIndexedCollation currentCollation] sectionForObject:[apps objectAtIndex:i] collationStringSelector:@selector(displayName)]) return i;
    }
    return -1;
}
*/ 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{ //This is straight from the applist sample code. I have never used Objective-C before so idk what this stuff means. It seems like variables are just coming out of nowhere. I assume 
  // they are from the api or something?
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *displayIdentifier = [dataSource displayIdentifierForIndexPath:indexPath];
    ALApplicationList *al = [ALApplicationList sharedApplicationList];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:[al.applications objectForKey:displayIdentifier] message:[displayIdentifier stringByAppendingString:@"\n\n\n\n\n\n"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    CGSize avSize = av.bounds.size;
    UIImage *largeIcon = [al iconOfSize:ALApplicationIconSizeLarge forDisplayIdentifier:displayIdentifier];
    if (largeIcon) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:largeIcon];
        CGSize imageSize = largeIcon.size;
        imageView.frame = (CGRect){ { roundf((avSize.width - imageSize.width) * (1.0f / 3.0f)), roundf((avSize.height - imageSize.height) * 0.5f) }, imageSize };
        [av addSubview:imageView];
        [imageView release];
    }
    UIImage *smallIcon = [al iconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:displayIdentifier];
    if (smallIcon) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:smallIcon];
        CGSize imageSize = smallIcon.size;
        imageView.frame = (CGRect){ { roundf((avSize.width - imageSize.width) * (2.0f / 3.0f)), roundf((avSize.height - imageSize.height) * 0.5f) }, imageSize };
        [av addSubview:imageView];
        [imageView release];
    }
    [av release];
}
%new(@@:@)
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if ([self shouldGTFO]) {
        return nil;
    } else {
        id titles = [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
        //titles = [titles subarrayWithRange:NSMakeRange(0, [titles count] - 1)];
        return titles;
    }
}
- (id)tableView:(id)tv cellForRowAtIndexPath:(id)ip {
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

    [cell setTitle:[[apps objectAtIndex:s] displayName]];
    //[cell setAuxiliaryTitle:];
    //[cell setSubtitle:];
    [cell setFirstInSection:YES];

    [[[self searchView] tableView] setScrollEnabled:YES];
    [cell setNeedsDisplay];

    return cell;
}
- (void)tableView:(id)tv didSelectRowAtIndexPath:(id)ip {
    if ([self shouldGTFO]) { %orig; return; }

    id a = [apps objectAtIndex:[ip section]];
    [[objc_getClass("SBUIController") sharedInstance] activateApplicationAnimated:a];
    [tv deselectRowAtIndexPath:ip animated:YES];
}
- (int)tableView:(id)tv numberOfRowsInSection:(int)s {
    if ([self shouldGTFO]) return %orig;
    else return 1;
}
- (int)numberOfSectionsInTableView:(id)tv {
    if ([self shouldGTFO]) return %orig;

    return [apps count];
}
- (id)tableView:(id)tv viewForHeaderInSection:(int)s {
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