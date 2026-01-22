package com.benefits.userbff.client;

import org.springframework.cloud.openfeign.FeignClient;

import java.util.Map;

@FeignClient(name = "device-service", url = "${device.service.url:http://benefits-device-service:8088}")
public interface DeviceServiceClient {

    // TODO: Add device service methods
}