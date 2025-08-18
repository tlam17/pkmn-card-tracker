package com.tlam.backend.test;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.tlam.backend.config.S3Config;

@RestController
@RequestMapping("/api/test")
public class TestController {

    private final S3Config s3Config;

    public TestController(S3Config s3Config) {
        this.s3Config = s3Config;
    }

    @GetMapping("/s3-config")
    public String testS3Config() {
        return "S3 Bucket: " + s3Config.getBucketName() + 
               ", Region: " + s3Config.getRegion() +
               ", CloudFront: " + s3Config.getCloudFrontDomain();
    }

    @GetMapping
    public ResponseEntity<String> sayHello() {
        return ResponseEntity.ok("Hello, World!");
    }
}
