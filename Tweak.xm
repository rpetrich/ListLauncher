
static id apps = nil;
static id table = nil;

static BOOL is_wildcat() { return (BOOL)(int)[[UIDevice currentDevice] isWildcat]; }

%hook UITableView
- (void)setAlpha:(float)alpha { if (self != table) %orig; }
%end

%hook SBSearchView
- (id)initWithFrame:(CGRect)frame withContent:(id)content onWallpaper:(id)wallpaper {
    self = %orig; table = [self tableView]; return self;
}
%end

%hook SBSearchController
%new(c@:)
- (BOOL)shouldGTFO { return ![[[[self searchView] searchBar] text] isEqualToString:@""]; }
- (BOOL)_hasSearchResults { return YES; }
- (float)tableView:(id)tv heightForRowAtIndexPath:(id)ip { return is_wildcat() ? 72.0f : 44.0f; }
%new(i@:@i)
- (int)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    int idx = [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
    for (int i = 0; i < [apps count]; i++) {
        if (idx <= [[UILocalizedIndexedCollation currentCollation] sectionForObject:[apps objectAtIndex:i] collationStringSelector:@selector(displayName)]) return i;
    }
    return -1;
}
%new(@@:@)
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if ([self shouldGTFO]) {
        return nil;
    } else {
        id titles = [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
        titles = [titles subarrayWithRange:NSMakeRange(0, [titles count] - 1)];
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
        MSHookIvar<float>(cell, "_sectionHeaderWidth") = is_wildcat() ? 68.0f : 39.0f;
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

    if (!apps) {
        apps = [[objc_getClass("SBApplicationController") sharedInstance] allApplications];
        id x = [[NSMutableArray array] retain];
        for (id app in apps) if (![[app tags] containsObject:@"hidden"]) [x addObject:app];
        apps = [[UILocalizedIndexedCollation currentCollation] sortedArrayFromArray:x collationStringSelector:@selector(displayName)];
        [apps retain];
    }

    return [apps count];
}
- (id)tableView:(id)tv viewForHeaderInSection:(int)s {
    if ([self shouldGTFO]) return %orig;

    id v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, is_wildcat() ? 68.0f : 39.0f, is_wildcat() ? 72.0f : 44.0f)];
    id m = [[[objc_getClass("SBIconModel") sharedInstance] applicationIconForDisplayIdentifier:[[apps objectAtIndex:s] displayIdentifier]] getIconImage:is_wildcat() ? 1 : 0];
    id i = [[objc_getClass("UIImageView") alloc] initWithImage:m];
    CGRect r = [i frame];
    r.size = [m size];
    r.origin.y = ([v frame].size.height - r.size.height) / 2;
    r.origin.x = ([v frame].size.width - r.size.width) / 2;
    [i setFrame:r];
    [v addSubview:i];
    [v setOpaque:0];
    [v setUserInteractionEnabled:NO];

    return v;
}
%end


