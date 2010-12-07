
static id apps = nil;

static int compare_apps(id a, id b, void *c) { return [[a displayName] caseInsensitiveCompare:[b displayName]]; }

%hook SBSearchController
%new(c@:)
- (BOOL)shouldGTFO { return ![[[[self searchView] searchBar] text] isEqualToString:@""];; }
- (BOOL)_hasSearchResults { return YES; }
- (float)tableView:(id)tv heightForRowAtIndexPath:(id)ip { return 44.0f; }
- (id)tableView:(id)tv cellForRowAtIndexPath:(id)ip {
    if ([self shouldGTFO]) return %orig;

    int s = [ip section];

    id cell = [tv dequeueReusableCellWithIdentifier:@"dude"];
    if (cell) {
        [cell clearContents];
    } else {
        cell = [[[objc_getClass("SBSearchTableViewCell") alloc] initWithStyle:(UITableViewCellStyle)0 reuseIdentifier:@"dude"] autorelease];
        MSHookIvar<float>(cell, "_sectionHeaderWidth") = 39.0f;
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
        apps = x;
        [apps sortUsingFunction:compare_apps context:NULL];
    }

    return [apps count];
}
- (id)tableView:(id)tv viewForHeaderInSection:(int)s {
    if ([self shouldGTFO]) return %orig;

    id v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 39.0f, 44.0f)];
    id m = [[[objc_getClass("SBIconModel") sharedInstance] applicationIconForDisplayIdentifier:[[apps objectAtIndex:s] displayIdentifier]] getIconImage:0];
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


