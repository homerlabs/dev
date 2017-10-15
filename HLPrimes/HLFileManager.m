//
//  HLFileManager.m
//  FileToolObjC
//
//  Created by Matthew Homer on 10/14/17.
//  Copyright © 2017 Matthew Homer. All rights reserved.
//

#import "HLFileManager.h"
#import <stdio.h>

@implementation HLFileManager

FILE *inFile, *outFile;
FILE *readFile;
NSString *filePath;


-(void)openForRead  {
    fclose( readFile );
    readFile = fopen(filePath.UTF8String, "r");
}

-(void)cleanup  {
    fclose( inFile );
    fclose( outFile );
    fclose( readFile );
}


-(instancetype)initWithPath:(NSString *)path
{
    self = [super init];
    
    filePath = path;
    inFile = fopen(filePath.UTF8String, "r");
    if ( !inFile )
    {
        FILE *tempFile = fopen(path.UTF8String, "w");
        NSString *tempString = [NSString stringWithFormat:@"1\t2\n2\t3\n3\t5\n4\t7\n"];
        fprintf(tempFile, "%s", tempString.UTF8String);
        fclose( tempFile );
        //  try now ...
        inFile = fopen(filePath.UTF8String, "r");
    }
    
    NSLog( @"HLFileManager-  initWithPath: %@", path );
    NSString *lastLine = [self getLastLine];
    NSLog( @"HLFileManager-  initWithPath-  lastLine: %@", lastLine );
    
    outFile = fopen(path.UTF8String, "a");
    return self;
}

-(NSString *)getLastLine
{
    FILE *tempFile = fopen(filePath.UTF8String, "r");
    int num = 0;
    long prime = 0;
    int items = fscanf(tempFile, "%d\t%ld\n", &num, &prime );
    
    while ( items > 0 )    {
//        NSLog( @"HLFileManager-  getLastLine-  items: %d   num: %d   prime: %ld", items, num, prime );
        items = fscanf(tempFile, "%d\t%ld\n", &num, &prime );
   }
   
   fclose( tempFile );
    return [NSString stringWithFormat:@"%d\t%ld",num, prime];
}

-(void)writeLine:(NSString *)line
{
    NSLog( @"HLFileManager-  writeLine: %@", line );
    fputs(line.UTF8String, outFile);
}

-(NSString *)readLine
{
    int num = 0;
    long prime = 0;
    int items = fscanf(readFile, "%d\t%ld\n", &num, &prime );
    NSLog( @"items: %d   num: %d    prime: %ld", items, num, prime );
    
    if ( items == 2 )
        return [NSString stringWithFormat:@"%d\t%ld",num, prime];
    else
        return nil;
}

@end
