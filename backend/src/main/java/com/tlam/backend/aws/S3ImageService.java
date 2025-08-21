package com.tlam.backend.aws;

import org.springframework.stereotype.Service;

import com.tlam.backend.config.S3Config;

import lombok.extern.slf4j.Slf4j;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.HeadObjectRequest;
import software.amazon.awssdk.services.s3.model.NoSuchKeyException;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

@Slf4j
@Service
public class S3ImageService {
    private final S3Client s3Client;
    private final S3Config s3Config;

    public S3ImageService(S3Client s3Client, S3Config s3Config) {
        this.s3Client = s3Client;
        this.s3Config = s3Config;
    }

    // Uploads an image to S3 and returns the URL of the uploaded image
    public String uploadImage(byte[] imageData, String fileName, String contentType) {
        return uploadImage(imageData, fileName, contentType, "cards");
    }

    // Uploads an image to S3 with a specified folder and returns the URL of the uploaded image
    public String uploadImage(byte[] imageData, String fileName, String contentType, String folder) {
        try {
            String key = folder + "/" + fileName;

            PutObjectRequest putRequest = PutObjectRequest.builder()
                .bucket(s3Config.getBucketName())
                .key(key)
                .contentType(contentType)
                .build();
            
            s3Client.putObject(putRequest, RequestBody.fromBytes(imageData));

            log.info("Successfully uploaded image: {}", key);
            return generateImageUrl(key);

        } catch (Exception e) {
            log.error("Failed to upload image: {}", fileName, e);
            throw new RuntimeException("Failed to upload image", e);
        }
    }

    // Generates a URL for the uploaded image
    public String generateImageUrl(String key) {
        if (s3Config.getCloudFrontDomain() != null) {
            return s3Config.getCloudFrontDomain() + "/" + key;
        }
        
        // Fallback to S3 direct URL
        return String.format("https://%s.s3.%s.amazonaws.com/%s", 
                s3Config.getBucketName(), 
                s3Config.getRegion(), 
                key);
    }

    // Deletes an image from S3
    public void deleteImage(String key) {
        try {
            DeleteObjectRequest deleteRequest = DeleteObjectRequest.builder()
                    .bucket(s3Config.getBucketName())
                    .key(key)
                    .build();

            s3Client.deleteObject(deleteRequest);
            log.info("Successfully deleted image: {}", key);
            
        } catch (Exception e) {
            log.error("Failed to delete image: {}", key, e);
            throw new RuntimeException("Failed to delete image", e);
        }
    }

    // Checks if an image exists in S3
    public boolean imageExists(String key) {
        try {
            HeadObjectRequest headRequest = HeadObjectRequest.builder()
                    .bucket(s3Config.getBucketName())
                    .key(key)
                    .build();

            s3Client.headObject(headRequest);
            return true;
            
        } catch (NoSuchKeyException e) {
            return false;
        } catch (Exception e) {
            log.error("Failed to check if image exists: {}", key, e);
            return false;
        }
    }
}
