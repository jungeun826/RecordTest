//
//  ViewController.m
//  RecordTest
//
//  Created by SDT-1 on 2014. 1. 16..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UILabel *status;
//@property (weak, nonatomic) IBOutlet UIProgressView *progress;

@end

@implementation ViewController{
    AVAudioRecorder *recorder;
    NSMutableArray *recordingFiles;
}

-(NSString *)getPullPath:(NSString *)fileName{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    
    return [documentPath stringByAppendingPathComponent:fileName];
}
-(void)startRecording{
    NSDate *date = [NSDate date];
    NSString *filePath = [self getPullPath:[NSString stringWithFormat:@"%@.caf ",[date description]]];
    NSLog(@"recording Path : %@",filePath);
    
    NSURL *url =[NSURL fileURLWithPath:filePath];
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    [setting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [setting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    
    __autoreleasing NSError *error;
    recorder = [[AVAudioRecorder alloc] initWithURL:url settings:setting error:&error];
    recorder.delegate = self;
    if([recorder prepareToRecord]){
        self.status.text = [NSString stringWithFormat:@"Recording : %@", [[url path]lastPathComponent]];
        [recorder recordForDuration:10];
    }
}
-(void)updateRecordedFiles{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES) objectAtIndex:0];

    __autoreleasing NSError *error;
    recordingFiles = [[NSMutableArray alloc]initWithArray:[fm contentsOfDirectoryAtPath:documentPath error:&error]];
    [self. table reloadData];
}
-(void)stopRecording{
    [recorder stop];
    [self updateRecordedFiles];
}
- (IBAction)toggleRecording:(id)sender {
    if([recorder isRecording]){
        [self stopRecording];
        ((UIBarButtonItem *)sender).title = @"Record";
    }else{
        [self startRecording];
        ((UIBarButtonItem *)sender).title = @"Stop";
    }
}
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    self.status.text = @"녹음 완료";
    [self updateRecordedFiles];
}
-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    self.status.text = [NSString stringWithFormat:@"녹음 중 오류 : %@", [error description]];
}

#pragma mark Table..
#define RECORD_CELL @"RECORD_CELL"
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [recordingFiles count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RECORD_CELL];
    cell.textLabel.text = [recordingFiles objectAtIndex:indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *fileName = [recordingFiles objectAtIndex:indexPath.row];
    NSString *fullPath = [self getPullPath:fileName];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    __autoreleasing NSError *error;
    BOOL ret = [fm removeItemAtPath:fullPath error:&error];
    
    if(ret == NO)
        NSLog(@"Error : %@", [error localizedDescription]);
    
    [recordingFiles removeObjectAtIndex:indexPath.row];
    [self.table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
