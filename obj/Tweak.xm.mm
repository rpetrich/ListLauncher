#line 1 "Tweak.xm"
#import <UIKit/UIKit.h>
#import <AppList.h> 
#import <substrate.h>

#import <SBUIController.h>
#import <SBSearchtableViewCell.h>

static ALApplicationList *apps;
static ALApplicationTableDataSource *dataSource;

static UITableView *table = nil;
static CGFloat sectionHeaderWidth;
static CGFloat searchRowHeight;


static inline BOOL is_wildcat() { return (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad); }

#include <logos/logos.h>
#include <substrate.h>
@class SBApplicationController; @class SBSearchView; @class UITableView; @class SBSearchController; 
static void (*_logos_orig$_ungrouped$UITableView$setAlpha$)(UITableView*, SEL, float); static void _logos_method$_ungrouped$UITableView$setAlpha$(UITableView*, SEL, float); static id (*_logos_orig$_ungrouped$SBSearchView$initWithFrame$withContent$onWallpaper$)(SBSearchView*, SEL, CGRect, id, id); static id _logos_method$_ungrouped$SBSearchView$initWithFrame$withContent$onWallpaper$(SBSearchView*, SEL, CGRect, id, id); static id (*_logos_orig$_ungrouped$SBApplicationController$loadApplications)(SBApplicationController*, SEL); static id _logos_method$_ungrouped$SBApplicationController$loadApplications(SBApplicationController*, SEL); static BOOL _logos_method$_ungrouped$SBSearchController$shouldDisplayListLauncher(SBSearchController*, SEL); static BOOL (*_logos_orig$_ungrouped$SBSearchController$shouldShowKeyboardOnScroll)(SBSearchController*, SEL); static BOOL _logos_method$_ungrouped$SBSearchController$shouldShowKeyboardOnScroll(SBSearchController*, SEL); static void (*_logos_orig$_ungrouped$SBSearchController$tableView$didSelectRowAtIndexPath$)(SBSearchController*, SEL, id, id); static void _logos_method$_ungrouped$SBSearchController$tableView$didSelectRowAtIndexPath$(SBSearchController*, SEL, id, id); static float (*_logos_orig$_ungrouped$SBSearchController$tableView$heightForRowAtIndexPath$)(SBSearchController*, SEL, id, id); static float _logos_method$_ungrouped$SBSearchController$tableView$heightForRowAtIndexPath$(SBSearchController*, SEL, id, id); static id (*_logos_orig$_ungrouped$SBSearchController$tableView$cellForRowAtIndexPath$)(SBSearchController*, SEL, id, id); static id _logos_method$_ungrouped$SBSearchController$tableView$cellForRowAtIndexPath$(SBSearchController*, SEL, id, id); static int (*_logos_orig$_ungrouped$SBSearchController$tableView$numberOfRowsInSection$)(SBSearchController*, SEL, id, int); static int _logos_method$_ungrouped$SBSearchController$tableView$numberOfRowsInSection$(SBSearchController*, SEL, id, int); static int (*_logos_orig$_ungrouped$SBSearchController$numberOfSectionsInTableView$)(SBSearchController*, SEL, id); static int _logos_method$_ungrouped$SBSearchController$numberOfSectionsInTableView$(SBSearchController*, SEL, id); static id (*_logos_orig$_ungrouped$SBSearchController$tableView$viewForHeaderInSection$)(SBSearchController*, SEL, id, int); static id _logos_method$_ungrouped$SBSearchController$tableView$viewForHeaderInSection$(SBSearchController*, SEL, id, int); 

#line 18 "Tweak.xm"

static void _logos_method$_ungrouped$UITableView$setAlpha$(UITableView* self, SEL _cmd, float alpha) { 
    if (self != table) 
        _logos_orig$_ungrouped$UITableView$setAlpha$(self, _cmd, alpha); 
}



static id _logos_method$_ungrouped$SBSearchView$initWithFrame$withContent$onWallpaper$(SBSearchView* self, SEL _cmd, CGRect frame, id content, id wallpaper) {
    if ((self = _logos_orig$_ungrouped$SBSearchView$initWithFrame$withContent$onWallpaper$(self, _cmd, frame, content, wallpaper))) {
        table = [self tableView];
        BOOL isWildcat = is_wildcat();
        sectionHeaderWidth = isWildcat ? 68.0f : 39.0f;
        searchRowHeight = isWildcat ? 72.0f : 44.0f;
        table.rowHeight = searchRowHeight;
    }

    return self;
}



static id _logos_method$_ungrouped$SBApplicationController$loadApplications(SBApplicationController* self, SEL _cmd) {
    
    id rdd = _logos_orig$_ungrouped$SBApplicationController$loadApplications(self, _cmd);

    apps = [ALApplicationList sharedApplicationList];
    dataSource = [[ALApplicationTableDataSource alloc] init];
    dataSource.sectionDescriptors = [ALApplicationTableDataSource standardSectionDescriptors];

    return rdd;
}






static BOOL _logos_method$_ungrouped$SBSearchController$shouldDisplayListLauncher(SBSearchController* self, SEL _cmd) { 
    SBSearchView *sv = nil;
    object_getInstanceVariable(self, "_searchView", (void**)sv);
    return [[[sv searchBar] text] isEqualToString:@""];
}

static BOOL _logos_method$_ungrouped$SBSearchController$shouldShowKeyboardOnScroll(SBSearchController* self, SEL _cmd) { 
    if([self shouldDisplayListLauncher]) {
        return NO;
    }
    return _logos_orig$_ungrouped$SBSearchController$shouldShowKeyboardOnScroll(self, _cmd);
}

static void _logos_method$_ungrouped$SBSearchController$tableView$didSelectRowAtIndexPath$(SBSearchController* self, SEL _cmd, id tableView, id indexPath) {
    
    if (![self shouldDisplayListLauncher]) { _logos_orig$_ungrouped$SBSearchController$tableView$didSelectRowAtIndexPath$(self, _cmd, tableView, indexPath); return; }

    id app = [dataSource displayIdentifierForIndexPath:indexPath];
    SBUIController *sv = nil;
    object_getInstanceVariable(objc_getClass("SBUIController"), "_sharedInstance", (void**)sv);
    [sv activateApplicationAnimated:app];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

static float _logos_method$_ungrouped$SBSearchController$tableView$heightForRowAtIndexPath$(SBSearchController* self, SEL _cmd, id tv, id ip) { 
    return searchRowHeight; 
}

static id _logos_method$_ungrouped$SBSearchController$tableView$cellForRowAtIndexPath$(SBSearchController* self, SEL _cmd, id tableView, id indexPath) {
    
    
    if (![self shouldDisplayListLauncher]) return _logos_orig$_ungrouped$SBSearchController$tableView$cellForRowAtIndexPath$(self, _cmd, tableView, indexPath);

    NSLog(@"finding a cell in (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2");

    int s = [indexPath section];

    id cell = [tableView dequeueReusableCellWithIdentifier:@"dude"];
    if (cell) {
        
    } else {
        cell = [[[SBSearchTableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"dude"] autorelease]; 
        
        float *secWidth = &(MSHookIvar<float>(cell, "_sectionHeaderWidth")); 
        if (secWidth) {
            *secWidth = sectionHeaderWidth;
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

    [cell setTitle:[[dataSource displayIdentifierForIndexPath:indexPath] description]];
    
    
    [cell setFirstInSection:YES];

    SBSearchView *sv = nil;
    object_getInstanceVariable(self, "_tableView", (void**)sv);
    [sv setScrollEnabled:YES];
    
    [cell setNeedsDisplay];

    return cell;
}

static int _logos_method$_ungrouped$SBSearchController$tableView$numberOfRowsInSection$(SBSearchController* self, SEL _cmd, id tableView, int s) {
    if (![self shouldDisplayListLauncher]) return _logos_orig$_ungrouped$SBSearchController$tableView$numberOfRowsInSection$(self, _cmd, tableView, s);
    else return 1;
}

static int _logos_method$_ungrouped$SBSearchController$numberOfSectionsInTableView$(SBSearchController* self, SEL _cmd, id tableView) {
    if (![self shouldDisplayListLauncher]) return _logos_orig$_ungrouped$SBSearchController$numberOfSectionsInTableView$(self, _cmd, tableView);
    return [apps applicationCount];
}

static id _logos_method$_ungrouped$SBSearchController$tableView$viewForHeaderInSection$(SBSearchController* self, SEL _cmd, id tv, int s) {
    
    

    if (![self shouldDisplayListLauncher]) return _logos_orig$_ungrouped$SBSearchController$tableView$viewForHeaderInSection$(self, _cmd, tv, s);

    id v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sectionHeaderWidth, searchRowHeight)];
    NSIndexPath *path = [NSIndexPath indexPathWithIndex:s];
    
    
    id i = [apps iconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:[dataSource displayIdentifierForIndexPath:path]];
    CGRect r = [i frame];
    r.size = [i size];
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
















   



















static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$UITableView = objc_getClass("UITableView"); MSHookMessageEx(_logos_class$_ungrouped$UITableView, @selector(setAlpha:), (IMP)&_logos_method$_ungrouped$UITableView$setAlpha$, (IMP*)&_logos_orig$_ungrouped$UITableView$setAlpha$);Class _logos_class$_ungrouped$SBSearchView = objc_getClass("SBSearchView"); MSHookMessageEx(_logos_class$_ungrouped$SBSearchView, @selector(initWithFrame:withContent:onWallpaper:), (IMP)&_logos_method$_ungrouped$SBSearchView$initWithFrame$withContent$onWallpaper$, (IMP*)&_logos_orig$_ungrouped$SBSearchView$initWithFrame$withContent$onWallpaper$);Class _logos_class$_ungrouped$SBApplicationController = objc_getClass("SBApplicationController"); MSHookMessageEx(_logos_class$_ungrouped$SBApplicationController, @selector(loadApplications), (IMP)&_logos_method$_ungrouped$SBApplicationController$loadApplications, (IMP*)&_logos_orig$_ungrouped$SBApplicationController$loadApplications);Class _logos_class$_ungrouped$SBSearchController = objc_getClass("SBSearchController"); { char _typeEncoding[1024]; unsigned int i = 0; memcpy(_typeEncoding + i, @encode(BOOL), strlen(@encode(BOOL))); i += strlen(@encode(BOOL)); _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SBSearchController, @selector(shouldDisplayListLauncher), (IMP)&_logos_method$_ungrouped$SBSearchController$shouldDisplayListLauncher, _typeEncoding); }MSHookMessageEx(_logos_class$_ungrouped$SBSearchController, @selector(shouldShowKeyboardOnScroll), (IMP)&_logos_method$_ungrouped$SBSearchController$shouldShowKeyboardOnScroll, (IMP*)&_logos_orig$_ungrouped$SBSearchController$shouldShowKeyboardOnScroll);MSHookMessageEx(_logos_class$_ungrouped$SBSearchController, @selector(tableView:didSelectRowAtIndexPath:), (IMP)&_logos_method$_ungrouped$SBSearchController$tableView$didSelectRowAtIndexPath$, (IMP*)&_logos_orig$_ungrouped$SBSearchController$tableView$didSelectRowAtIndexPath$);MSHookMessageEx(_logos_class$_ungrouped$SBSearchController, @selector(tableView:heightForRowAtIndexPath:), (IMP)&_logos_method$_ungrouped$SBSearchController$tableView$heightForRowAtIndexPath$, (IMP*)&_logos_orig$_ungrouped$SBSearchController$tableView$heightForRowAtIndexPath$);MSHookMessageEx(_logos_class$_ungrouped$SBSearchController, @selector(tableView:cellForRowAtIndexPath:), (IMP)&_logos_method$_ungrouped$SBSearchController$tableView$cellForRowAtIndexPath$, (IMP*)&_logos_orig$_ungrouped$SBSearchController$tableView$cellForRowAtIndexPath$);MSHookMessageEx(_logos_class$_ungrouped$SBSearchController, @selector(tableView:numberOfRowsInSection:), (IMP)&_logos_method$_ungrouped$SBSearchController$tableView$numberOfRowsInSection$, (IMP*)&_logos_orig$_ungrouped$SBSearchController$tableView$numberOfRowsInSection$);MSHookMessageEx(_logos_class$_ungrouped$SBSearchController, @selector(numberOfSectionsInTableView:), (IMP)&_logos_method$_ungrouped$SBSearchController$numberOfSectionsInTableView$, (IMP*)&_logos_orig$_ungrouped$SBSearchController$numberOfSectionsInTableView$);MSHookMessageEx(_logos_class$_ungrouped$SBSearchController, @selector(tableView:viewForHeaderInSection:), (IMP)&_logos_method$_ungrouped$SBSearchController$tableView$viewForHeaderInSection$, (IMP*)&_logos_orig$_ungrouped$SBSearchController$tableView$viewForHeaderInSection$);} }
#line 201 "Tweak.xm"
