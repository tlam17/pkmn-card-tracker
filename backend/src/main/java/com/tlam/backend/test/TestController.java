package com.tlam.backend.test;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.tlam.backend.aws.S3ImageService;
import com.tlam.backend.config.S3Config;

@RestController
@RequestMapping("/api/test")
public class TestController {

    private final S3ImageService s3ImageService;
    private final S3Config s3Config;

    public TestController(S3ImageService s3ImageService, S3Config s3Config) {
        this.s3ImageService = s3ImageService;
        this.s3Config = s3Config;
    }

    @GetMapping("/s3-config")
    public String testS3Config() {
        return "S3 Bucket: " + s3Config.getBucketName() + 
               ", Region: " + s3Config.getRegion() +
               ", CloudFront: " + s3Config.getCloudFrontDomain();
    }

    @PostMapping("/upload-test")
    public String testUpload() {
        try {
            String testContent = "Hello S3!";
            byte[] testData = testContent.getBytes();
            
            String url = s3ImageService.uploadImage(testData, "test.txt", "text/plain");
            return "Successfully uploaded test file. URL: " + url;
            
        } catch (Exception e) {
            return "Failed to upload: " + e.getMessage();
        }
    }

    @GetMapping
    public ResponseEntity<String> sayHello() {
        return ResponseEntity.ok("Hello, World!");
    }
}
