//
//  ViewController.m
//  GCDDemo
//
//  Created by 马少洋 on 15/5/15.
//  Copyright © 2015年 马少洋. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    for (NSInteger i = 0; i < 10; i++) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self run];
//        });
//    }
//    NSMutableArray * array = [[NSMutableArray alloc]init];
//    for (NSInteger i = 0; i < 10; i++) {
//        [array addObject:@(i)];
//    }
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    /** 此处应有索引 */
//    dispatch_apply(array.count, queue, ^(size_t index) {
//        NSLog(@"index = %lu,value = %d ----thread= %@",index,[array[index] integerValue],[NSThread currentThread]);
//    });





     __block UIImage * image1 = nil;
    __block UIImage * image2 = nil;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t grout = dispatch_group_create();
    dispatch_group_async(grout, queue, ^{

        NSURL * url = [[NSURL alloc]initWithString:@"http://pic32.nipic.com/20130829/12906030_124355855000_2.png"];
        NSData * data = [NSData dataWithContentsOfURL:url];
        image1 = [UIImage imageWithData:data];
    });
    dispatch_group_async(grout, queue, ^{

        NSURL * url = [[NSURL alloc]initWithString:@"http://pic32.nipic.com/20130829/12906030_124355855000_2.png"];
        NSData * data = [NSData dataWithContentsOfURL:url];
        image2 = [UIImage imageWithData:data];
    });


    dispatch_group_notify(grout, queue, ^{
        UIGraphicsBeginImageContext(CGSizeMake(300, 300));
        [image1 drawInRect:CGRectMake(0, 0, 150, 300)];
        [image2 drawInRect:CGRectMake(150, 0, 150, 300)];
        UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.imageView.image = image;
        });
        UIGraphicsEndImageContext();
    });



    // Do any additional setup after loading the view, typically from a nib.
}
- (void)run{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"你说我是不是只执行了一次呢");
    });
    NSLog(@"别催了😡,小明正在跑呢😄");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

//    [self sync];
//    [self async];
//    [self syncSe];
//    [self asyncSer];
//    [self mainQueue];
//    [self barrierQueue];

}

- (void)barrierQueue{
    /** 不能用全局队列，必须自己创建队列 */
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);/** 获取全局并行队列 */
    dispatch_queue_t queue = dispatch_queue_create("com.mayang.zz", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"-------1-------%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"-------2-------%@",[NSThread currentThread]);
    });
#warning 等待前边的任务执行完才回执行这个任务，之歌任务执行完才回执行后边添加的任务
#warning 但是不能在全局队列中，在全局队列中这个函数 会偶尔不起作用🔋🔋
    dispatch_barrier_async(queue, ^{
        NSLog(@"------等-----%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"-------3-------%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"-------4-------%@",[NSThread currentThread]);
    });
}

/** 系统主队列用异步函数是不会创建队列的只会按照加入队列的顺序 执行 */
- (void)mainQueue{
    /** 拿到系统主队列 */
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"1 ----------- %@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"2 ----------- %@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"3 ----------- %@",[NSThread currentThread]);
        }
    });

}

/** 创建一个同步并发队列 */ /** 会开线程，但是因为是并发队列 所以只开一个线程 */
- (void)syncSe{
    /** 创建一个同步队列 */
#warning 同步队列是没有全局队列的所以我们只能获取
    dispatch_queue_t queue = dispatch_queue_create("com.mayamg.ser", DISPATCH_QUEUE_SERIAL);
    /** 都可以 */
//    dispatch_queue_t queue = dispatch_queue_create("com.mayamg.ser", NULL);
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"1 ----------- %@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"2 ----------- %@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"3 ----------- %@",[NSThread currentThread]);
        }
    });
    
}
/** 创建一个同步串行队列 *//** 不会开线程，会在主线程按照顺序执行 */
- (void)asyncSer{
    dispatch_queue_t queue = dispatch_queue_create("com.mayamg.ser", DISPATCH_QUEUE_SERIAL);
    /** 都可以 */
//    dispatch_queue_t queue = dispatch_queue_create("com.mayamg.ser", NULL);
    /** 串行队列 */
    dispatch_sync(queue, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"1 ----------- %@",[NSThread currentThread]);
        }
    });
    dispatch_sync(queue, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"2 ----------- %@",[NSThread currentThread]);
        }
    });
    dispatch_sync(queue, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"3 ----------- %@",[NSThread currentThread]);
        }
    });
}
/** 创建一个同步并发队列 *//** 同步函数不会创建线程，只会在主线程执行，并且尊写fifo原则*/
-(void)sync{

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"1------------%@",[NSThread currentThread]);
        }
    });
    dispatch_sync(queue, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"2------------%@",[NSThread currentThread]);
        }
    });
    dispatch_sync(queue, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"3------------%@",[NSThread currentThread]);
        }
    });
}

/** 创建一个异步函数并行队列 */ /** 可以开启好多线程，线程数由gcd内部控制 */
- (void)async{
#if 0
    //创建一个并发任务队列
    dispatch_queue_t queue = dispatch_queue_create("com.mayang.test", DISPATCH_QUEUE_CONCURRENT);
#else
    /** 获取一个全局并发队列 */
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
#endif
    //** 将任务添加到并发任务队列 */
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i ++) {
            NSLog(@"1-------%@",[NSThread currentThread]);
        }
    });
    //** 将任务添加到并发任务队列 */
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i ++) {
            NSLog(@"2-------%@",[NSThread currentThread]);
        }
    });
    //** 将任务添加到并发任务队列 */
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i ++) {
            NSLog(@"3-------%@",[NSThread currentThread]);
        }
    });
}
@end
