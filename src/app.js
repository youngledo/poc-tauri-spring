const API_BASE = 'http://localhost:8080';

// 检查后端状态
async function checkBackendStatus() {
    const indicator = document.getElementById('backend-indicator');
    const statusText = document.getElementById('backend-status');

    const maxRetries = 30;
    let retries = 0;

    while (retries < maxRetries) {
        try {
            const response = await fetch(`${API_BASE}/actuator/health`, {
                method: 'GET',
                headers: {
                    'Accept': 'application/json'
                }
            });

            if (response.ok) {
                indicator.className = 'status-indicator success';
                statusText.textContent = '运行中 ✓';
                console.log('Backend is ready!');
                return true;
            }
        } catch (error) {
            retries++;
            statusText.textContent = `等待启动... (${retries}/${maxRetries})`;
            await sleep(1000);
        }
    }

    indicator.className = 'status-indicator error';
    statusText.textContent = '启动失败 ✗';
    showResponse('错误', '后端启动失败，请检查控制台日志');
    return false;
}

// 工具函数：延迟
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

// 显示响应
function showResponse(title, content) {
    const responseDiv = document.getElementById('response');
    const contentDiv = document.getElementById('response-content');

    contentDiv.textContent = typeof content === 'string' ? content : JSON.stringify(content, null, 2);
    responseDiv.classList.add('show');
}

// 清空响应
function clearResponse() {
    const responseDiv = document.getElementById('response');
    responseDiv.classList.remove('show');
}

// API 调用函数
async function callApi(endpoint, options = {}) {
    try {
        const response = await fetch(`${API_BASE}${endpoint}`, {
            ...options,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                ...options.headers
            }
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        return await response.json();
    } catch (error) {
        console.error('API 调用失败:', error);
        throw error;
    }
}

// 测试 Hello API
async function testHello() {
    try {
        const data = await callApi('/api/hello');
        showResponse('Hello API 响应', data);
    } catch (error) {
        showResponse('错误', `调用失败: ${error.message}`);
    }
}

// 测试 Echo API
async function testEcho() {
    const input = document.getElementById('echo-input').value;

    if (!input.trim()) {
        showResponse('提示', '请输入要发送的文本');
        return;
    }

    try {
        const data = await callApi('/api/echo', {
            method: 'POST',
            body: JSON.stringify({ message: input })
        });
        showResponse('Echo API 响应', data);
    } catch (error) {
        showResponse('错误', `调用失败: ${error.message}`);
    }
}

// 测试 Info API
async function testInfo() {
    try {
        const data = await callApi('/api/info');
        showResponse('系统信息', data);
    } catch (error) {
        showResponse('错误', `调用失败: ${error.message}`);
    }
}

// 页面加载时检查后端状态
window.addEventListener('DOMContentLoaded', async () => {
    console.log('应用已启动，正在检查后端状态...');
    await checkBackendStatus();
});
