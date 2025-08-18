package com.tlam.backend.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import lombok.Data;

@Data
@Component
@ConfigurationProperties(prefix = "aws.s3")
public class S3Config {
    private String bucketName;
    private String region;
    private String cloudFrontDomain;
}
