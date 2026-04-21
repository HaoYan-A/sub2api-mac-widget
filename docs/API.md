# sub2api 接口说明

本小组件依赖 sub2api 的以下接口。真实返回样例（来自 `http://nas.yanhaohub.com:3002`）：

## 1. 登录

```
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "xxx@example.com",
  "password": "xxx"
}
```

响应：

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "access_token": "eyJ...",
    "refresh_token": "rt_...",
    "expires_in": 86400,
    "token_type": "Bearer",
    "user": {
      "id": 1,
      "email": "xxx@example.com",
      "role": "admin",
      "balance": 998553.16
    }
  }
}
```

## 2. Token 续期

```
POST /api/v1/auth/refresh
Content-Type: application/json

{
  "refresh_token": "rt_..."
}
```

响应结构与登录相同。

## 3. 🏆 核心接口：Dashboard Stats（小组件主数据源）

```
GET /api/v1/usage/dashboard/stats
Authorization: Bearer <access_token>
```

响应：

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "total_api_keys": 8,
    "active_api_keys": 6,
    "total_requests": 144559,
    "total_input_tokens": 1146832620,
    "total_output_tokens": 75536718,
    "total_cache_creation_tokens": 441574583,
    "total_cache_read_tokens": 14014545989,
    "total_tokens": 15678489910,
    "total_cost": 15437.70,
    "total_actual_cost": 15437.70,
    "today_requests": 283,
    "today_input_tokens": 2240112,
    "today_output_tokens": 186784,
    "today_cache_creation_tokens": 555780,
    "today_cache_read_tokens": 8299839,
    "today_tokens": 11282515,
    "today_cost": 16.49,
    "today_actual_cost": 16.49,
    "average_duration_ms": 11550.37,
    "rpm": 1,
    "tpm": 785
  }
}
```

**为什么选这个接口**：
- 无需传参
- 今日 + 累计字段齐全（请求数、Token、花费）
- 包含实时活动度（RPM/TPM）
- 响应小（~500 字节），适合高频轮询

## 4. 7 天趋势（Large Widget 用）

```
GET /api/v1/usage/dashboard/trend?granularity=day
Authorization: Bearer <access_token>
```

响应：

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "start_date": "2026-04-14",
    "end_date": "2026-04-21",
    "granularity": "day",
    "trend": [
      { "date": "2026-04-14", "requests": 4584, "total_tokens": 614386499, "cost": 645.87, "actual_cost": 645.87 },
      { "date": "2026-04-15", "requests": 5262, "total_tokens": 820139814, "cost": 1047.90, "actual_cost": 1047.90 }
      // ...
    ]
  }
}
```

## 数据单位说明

- `cost` / `actual_cost` / `balance` 的单位**不是 USD**
- 从数量级推测是 sub2api 的内部记账单位（可能是 1 USD = 1000 积分）
- UI 显示时不加货币符号，直接显示数字

## 错误处理

| HTTP 状态 | 含义 | 客户端行为 |
|---|---|---|
| 200 + `code=0` | 成功 | 解包 `data` 字段 |
| 200 + `code≠0` | 业务错误 | 显示 `message` |
| 401 | Token 失效 | 自动 refresh_token，失败则密码重登 |
| 5xx | 服务端错误 | 退回缓存，显示错误徽标 |
