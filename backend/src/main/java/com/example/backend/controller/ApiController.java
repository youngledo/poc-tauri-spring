package com.example.backend.controller;

import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class ApiController {

    @GetMapping("/hello")
    public Map<String, Object> hello() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Hello from Spring Boot!");
        response.put("timestamp", LocalDateTime.now().toString());
        response.put("status", "success");
        return response;
    }

    @PostMapping("/echo")
    public Map<String, Object> echo(@RequestBody Map<String, String> request) {
        Map<String, Object> response = new HashMap<>();
        response.put("received", request.get("message"));
        response.put("echo", "Echo: " + request.get("message"));
        response.put("timestamp", LocalDateTime.now().toString());
        return response;
    }

    @GetMapping("/info")
    public Map<String, Object> info() {
        Map<String, Object> response = new HashMap<>();
        response.put("application", "Tauri + Spring Boot POC");
        response.put("version", "1.0.0");
        response.put("java_version", System.getProperty("java.version"));
        response.put("os", System.getProperty("os.name"));
        return response;
    }
}
