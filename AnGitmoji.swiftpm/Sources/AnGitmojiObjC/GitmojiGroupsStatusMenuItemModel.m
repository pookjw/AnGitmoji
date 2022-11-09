#import "GitmojiGroupsStatusMenuItemModel.h"
#import <CoreData/CoreData.h>
@import AnGitmojiCore;

#if TARGET_OS_OSX || TARGET_OS_MACCATALYST

@interface GitmojiGroupsStatusMenuItemModel () <NSFetchedResultsControllerDelegate>
@property (strong) NSOperationQueue *queue;
@property (strong) id<GitmojiUseCase> gitmojiUseCase;
@property (strong) NSManagedObjectContext *context;
@property (strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation GitmojiGroupsStatusMenuItemModel

- (instancetype)init {
    if (self = [super init]) {
        [self configureQueue];
        [self configureGitmojiUseCase];
        [self startBackgroundConfiguration];
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

- (void)startBackgroundConfiguration {
    [self.queue addOperationWithBlock:^{
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
        
        NSFetchRequest *fetchRequest = [GitmojiGroup _fetchRequest];
        fetchRequest.sortDescriptors = @[
            [[NSSortDescriptor alloc] initWithKey:@"index" ascending:NO]
        ];
        NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        fetchedResultsController.delegate = self;
        
        [self.gitmojiUseCase conditionSafeWithBlock:^{
            NSError * _Nullable error = nil;
            [fetchedResultsController performFetch:&error];
            if (error) {
                assert(error);
            }
        } completionHandler:^{

        }];
        
        self.context = context;
        self.fetchedResultsController = fetchedResultsController;
    }];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeContentWithDifference:(NSOrderedCollectionDifference<NSManagedObjectID *> *)diff {
    // https://developer.apple.com/documentation/foundation/nsorderedcollectiondifference?language=objc
    
    NSLog(@"START");
    
    [diff.insertions enumerateObjectsUsingBlock:^(NSOrderedCollectionChange<NSManagedObjectID *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"insertion: %@, %ld, %ld", obj.object, obj.index, obj.associatedIndex);
    }];
    
    [diff.removals enumerateObjectsUsingBlock:^(NSOrderedCollectionChange<NSManagedObjectID *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"removal: %@, %ld, %ld", obj.object, obj.index, obj.associatedIndex);
    }];
    
    NSLog(@"END");
}

@end

#endif
