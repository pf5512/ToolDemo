//
//  NSString+MD5.m
//  LastHistory
//
//  Created by Frederik Seiffert on 28.11.08.
//  Copyright 2008 Frederik Seiffert. All rights reserved.
//

#import "NSString+MD5.h"
#import "GTMBase64.h"       

@implementation NSString (MD5)

- (NSString *)md5
{
	const char *cStr = [self UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	
	CC_MD5(cStr, strlen(cStr), result);
	
	NSMutableString *resultStr = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
	for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
		[resultStr appendFormat:@"%02x", result[i]];
	}
	return [[resultStr copy] autorelease];
}

+ (NSData *)desData:(NSData *)data key:(NSString *)keyString CCOperation:(CCOperation)op
{
	// Byte *buffer;
	char buffer [1024] ;
	memset(buffer, 0, sizeof(buffer));
	// memset(buffer, 0, 1024);
	size_t bufferNumBytes;
	CCCryptorStatus cryptStatus = CCCrypt(op, 
										  
										  kCCAlgorithmDES, 
										  
										  kCCOptionPKCS7Padding | kCCOptionECBMode,
										  
										  [keyString UTF8String], 
										  
										  kCCKeySizeDES,
										  
										  NULL, 
										  
										  [data bytes], 
										  
										  [data length],
										  
										  buffer, 
										  
										  1024,
										  
										  &bufferNumBytes);
	if(cryptStatus == kCCSuccess)
	{
		NSData *returnData = [NSData dataWithBytes:buffer length:bufferNumBytes];
		return returnData;
		// NSString *returnString = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding]autorelease];
	}
	NSLog(@"des failed！");
	return nil;
	
}

/*
 java平台和mac平台支持的3des模式不同，java的配套算法如下，结果和ios平台一致

 public static String encryptThreeDESECB(String src,String key) throws Exception
 {
 DESedeKeySpec dks = new DESedeKeySpec(key.getBytes("UTF-8"));
 SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("DESede");
 SecretKey securekey = keyFactory.generateSecret(dks);
 
 Cipher cipher = Cipher.getInstance("DESede/ECB/PKCS5Padding");
 cipher.init(Cipher.ENCRYPT_MODE, securekey);
 byte[] b=cipher.doFinal(src.getBytes());
 
 BASE64Encoder encoder = new BASE64Encoder();
 return encoder.encode(b).replaceAll("\r", "").replaceAll("\n", "");
 
 }
 
 //3DESECB解密,key必须是长度大于等于 3*8 = 24 位
 public static String decryptThreeDESECB(String src,String key) throws Exception
 {
 //--通过base64,将字符串转成byte数组
 BASE64Decoder decoder = new BASE64Decoder();
 byte[] bytesrc = decoder.decodeBuffer(src);
 //--解密的key
 DESedeKeySpec dks = new DESedeKeySpec(key.getBytes("UTF-8"));
 SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("DESede");
 SecretKey securekey = keyFactory.generateSecret(dks);
 
 //--Chipher对象解密
 Cipher cipher = Cipher.getInstance("DESede/ECB/PKCS5Padding");
 cipher.init(Cipher.DECRYPT_MODE, securekey);
 byte[] retByte = cipher.doFinal(bytesrc);
 
 return new String(retByte);
 }
 */
+ (NSString *)tripleDES:(NSString*)dataString encryptOrDecrypt:(CCOperation)encryptOrDecrypt key:(NSString*)key
{
    const void *vdataString;
    size_t dataStringBufferSize;
    
    if (encryptOrDecrypt == kCCDecrypt)
    {
        NSData *EncryptData = [GTMBase64 decodeData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
        dataStringBufferSize = [EncryptData length];
        vdataString = [EncryptData bytes];
    }
    else
    {
        NSData* data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
        dataStringBufferSize = [data length];
        vdataString = (const void *)[data bytes];
    }
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    // uint8_t ivkCCBlockSize3DES;
    
    bufferPtrSize = (dataStringBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    // memset((void *) iv, 0x0, (size_t) sizeof(iv));
    
    //    NSString *key = @"123456789012345678901234";
    NSString *initVec = @"init Vec";
    const void *vkey = (const void *) [key UTF8String];
    const void *vinitVec = (const void *) [initVec UTF8String];
    
    ccStatus = CCCrypt(encryptOrDecrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding | kCCOptionECBMode,
                       vkey, //"123456789012345678901234", //key
                       kCCKeySize3DES,
                       vinitVec, //"init Vec", //iv,
                       vdataString, //"Your Name", //dataString,
                       dataStringBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    //if (ccStatus == kCCSuccess) NSLog(@"SUCCESS");
    /*else if (ccStatus == kCC ParamError) return @"PARAM ERROR";
	 else if (ccStatus == kCCBufferTooSmall) return @"BUFFER TOO SMALL";
	 else if (ccStatus == kCCMemoryFailure) return @"MEMORY FAILURE";
	 else if (ccStatus == kCCAlignmentError) return @"ALIGNMENT";
	 else if (ccStatus == kCCDecodeError) return @"DECODE ERROR";
	 else if (ccStatus == kCCUnimplemented) return @"UNIMPLEMENTED"; */
    
    NSString *result;
    
    if (encryptOrDecrypt == kCCDecrypt)
    {
        result = [[[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr 
                                                                length:(NSUInteger)movedBytes] 
                                        encoding:NSUTF8StringEncoding] 
                  autorelease];
    }
    else
    {
        NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
        result = [GTMBase64 stringByEncodingData:myData];
    }
    
    return result;
}

/*
调用示例代码

NSString* req = @"234234234234234中国";
NSString* key = @"888fdafdakfjak;";

NSString* ret1 = [NSString TripleDES:req encryptOrDecrypt:kCCEncrypt key:key];        
NSLog(@"3DES/Base64 Encode Result=%@", ret1);

NSString* ret2 = [NSString TripleDES:ret1 encryptOrDecrypt:kCCDecrypt key:key];
NSLog(@"3DES/Base64 Decode Result=%@", ret2);
*/

@end






