// Prevents additional console window on Windows in release
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use std::process::{Command, Child};
use std::sync::Mutex;
use tauri::Manager;

struct AppState {
    backend_process: Mutex<Option<Child>>,
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .manage(AppState {
            backend_process: Mutex::new(None),
        })
        .setup(|app| {
            let resource_dir = app.path()
                .resource_dir()
                .expect("Failed to get resource directory");

            // 尝试查找 native binary 或 jar
            // Tauri 2.x 保留原始目录结构: _up_/backend/target/
            let native_binary = resource_dir.join("_up_").join("backend").join("target").join("src-spring");
            let jar_file = resource_dir.join("_up_").join("backend").join("target").join("src-spring.jar");

            let child = if native_binary.exists() {
                println!("Starting Spring Boot Native Image from: {:?}", native_binary);
                // 直接运行本地二进制
                Command::new(&native_binary)
                    .spawn()
                    .expect("Failed to start Spring Boot native backend")
            } else if jar_file.exists() {
                println!("Starting Spring Boot JAR from: {:?}", jar_file);
                // 使用 Java 运行 JAR
                Command::new("java")
                    .arg("-jar")
                    .arg(&jar_file)
                    .spawn()
                    .expect("Failed to start Spring Boot JAR backend")
            } else {
                panic!("Neither native binary nor JAR file found in resource directory");
            };

            println!("Spring Boot process started with PID: {}", child.id());

            // 保存进程句柄
            let state = app.state::<AppState>();
            *state.backend_process.lock().unwrap() = Some(child);

            Ok(())
        })
        .on_window_event(|window, event| {
            if let tauri::WindowEvent::Destroyed = event {
                // 窗口关闭时，停止 Spring Boot 进程
                let state = window.state::<AppState>();
                if let Some(mut child) = state.backend_process.lock().unwrap().take() {
                    println!("Stopping Spring Boot backend...");
                    let _ = child.kill();
                };
            }
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
