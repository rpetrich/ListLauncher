@interface SBSearchController : NSObject {
    SBSearchView *_searchView;
    BOOL _reloadingTableContent;
    BOOL _resultsUpdated;
    void *_addressBook;
}

@property(retain, nonatomic) SBSearchView *searchView; // @synthesize searchView=_searchView;

-(SBSearchView *)searchView;