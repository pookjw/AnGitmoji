#import "GitmojiGroupsStatusMenuItemModel.h"
#import <CoreData/CoreData.h>
@import AnGitmojiCore;

#if TARGET_OS_OSX || TARGET_OS_MACCATALYST

@interface GitmojiGroupsStatusMenuItemModel () <NSFetchedResultsControllerDelegate>
@property (strong) NSOperationQueue *queue;
@property (strong) id<GitmojiUseCase> gitmojiUseCase;
@property (strong) NSManagedObjectContext *context;
@property (strong) NSFetchedResultsController *gitmojiGroupsFetchedResultsController;
@property (strong) NSMapTable<GitmojiGroup *, NSFetchedResultsController *> *gitmojisFetchedResultsControllers;
@end

@implementation GitmojiGroupsStatusMenuItemModel

- (instancetype)init {
    if (self = [super init]) {
        [self configureQueue];
        [self configureGitmojiUseCase];
        
        [self.gitmojiUseCase conditionSafeWithBlock:^{
            [self configureContext];
            [self configureGitmojiGroups];
            [self configureGitmojis];
        } completionHandler:^{
            
        }];
    }
    
    return self;
}

- (void)dealloc {
    [self.queue cancelAllOperations];
}

- (void)configureQueue {
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.maxConcurrentOperationCount = 1;
    queue.qualityOfService = NSQualityOfServiceUtility;
    self.queue = queue;
}

- (void)configureGitmojiUseCase {
    id<GitmojiUseCase> gitmojiUseCase = DIService.gitmojiUseCase;
    self.gitmojiUseCase = gitmojiUseCase;
}

- (void)configureContext {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSManagedObjectContext *context;
    
    [self.gitmojiUseCase contextWithCompletionHandler:^(NSManagedObjectContext * _Nullable _context, NSError * _Nullable error) {
        if (error) {
            assert(error);
        }
        
        context = _context;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    self.context = context;
}

- (void)configureGitmojiGroups {
    NSFetchRequest *fetchRequest = [GitmojiGroup _fetchRequest];
    fetchRequest.sortDescriptors = @[
        [[NSSortDescriptor alloc] initWithKey:@"index" ascending:NO]
    ];
    
    //
    
    __block NSArray<GitmojiGroup *> *gitmojiGroups;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self.gitmojiUseCase gitmojiGroupsWithFetchRequest:fetchRequest completionHandler:^(NSArray<GitmojiGroup *> * _Nullable _gitmojiGroups, NSError * _Nullable error) {
        if (error) {
            assert(error);
        }
        
        gitmojiGroups = _gitmojiGroups;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    //
    
    NSMutableArray<NSOrderedCollectionChange<GitmojiGroup *> *> *changes = [NSMutableArray new];
    [gitmojiGroups enumerateObjectsUsingBlock:^(GitmojiGroup * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [changes addObject:[NSOrderedCollectionChange changeWithObject:obj
                                                                  type:NSCollectionChangeInsert
                                                                 index:idx
                                                       associatedIndex:idx]];
    }];
    
    NSOrderedCollectionDifference<GitmojiGroup *> *diff = [[NSOrderedCollectionDifference alloc] initWithChanges:changes];
    
    
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        [NSNotificationCenter.defaultCenter postNotificationName:NSNotificationNameGitmojiGroupsStatusMenuItemModelDidChangeGitmojiGroups
                                                          object:self
                                                        userInfo:@{GitmojiGroupsStatusMenuItemModelDidChangeGitmojiGroupsDifferenceItemKey: diff}];
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    //
    
    NSFetchedResultsController *gitmojiGroupsFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    gitmojiGroupsFetchedResultsController.delegate = self;
    self.gitmojiGroupsFetchedResultsController = gitmojiGroupsFetchedResultsController;
    
    [self.gitmojiUseCase conditionSafeWithBlock:^{
        NSError * _Nullable error = nil;
        [gitmojiGroupsFetchedResultsController performFetch:&error];
        if (error) {
            assert(error);
        }
    } completionHandler:^{

    }];
}

- (void)configureGitmojis {
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//    
//    //
//    
//    
//    
//    //
//    
//    NSMapTable<GitmojiGroup *, NSOrderedCollectionDifference<Gitmoji *> *> *mapTable = [NSMapTable strongToStrongObjectsMapTable];
//    
//    [gitmojiGroups enumerateObjectsUsingBlock:^(GitmojiGroup * _Nonnull gitmojiGroup, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSFetchRequest *fetchRequest = [Gitmoji _fetchRequest];
//        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K = %@" argumentArray:@[@"group", gitmojiGroup]];
//        fetchRequest.sortDescriptors = @[
//            [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]
//        ];
//        
//        [self.gitmojiUseCase gitmojisWithFetchRequest:fetchRequest completionHandler:^(NSArray<Gitmoji *> * _Nullable gitmojis, NSError * _Nullable error) {
//            if (error) {
//                assert(error);
//            }
//            
//            NSMutableArray<NSOrderedCollectionChange<Gitmoji *> *> *changes = [NSMutableArray new];
//            [gitmojis enumerateObjectsUsingBlock:^(Gitmoji * _Nonnull gitmoji, NSUInteger idx, BOOL * _Nonnull stop) {
//                [changes addObject:[NSOrderedCollectionChange changeWithObject:gitmoji
//                                                                          type:NSCollectionChangeInsert
//                                                                         index:idx
//                                                               associatedIndex:idx]];
//            }];
//            
//            NSOrderedCollectionDifference<Gitmoji *> *diff = [[NSOrderedCollectionDifference alloc] initWithChanges:changes];
//            [mapTable setObject:diff forKey:gitmojiGroup];
//            
//            dispatch_semaphore_signal(semaphore);
//        }];
//        
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//    }];
//    
//    //
//    
//    [NSOperationQueue.mainQueue addOperationWithBlock:^{
//        [NSNotificationCenter.defaultCenter postNotificationName:NSNotificationNameGitmojiGroupsStatusMenuItemModelDidChangeGitmojiGroup
//                                                          object:self
//                                                        userInfo:@{GitmojiGroupsStatusMenuItemModelDidChangeGitmojiGroupDifferenceMapItemKey: mapTable}];
//        dispatch_semaphore_signal(semaphore);
//    }];
//    
//    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeContentWithDifference:(NSOrderedCollectionDifference<NSManagedObjectID *> *)diff {
    [self.queue addOperationWithBlock:^{
        NSMutableArray<NSOrderedCollectionChange<GitmojiGroup *> *> *gitmojiGroupChanges = [NSMutableArray new];
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
    }];
}

@end

#endif
