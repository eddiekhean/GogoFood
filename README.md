# GogoFood System 
> **GogoFood** là một hệ thống mô phỏng nền tảng đặt món ăn đa dịch vụ,  được xây dựng trên kiến trúc **microservices** với trọng tâm là **bảo mật, mở rộng và tính độc lập giữa các module**.
> Hệ thống được xây dựng bằng Spring Boot 3, PostgreSQL, Redis, Kafka, và Docker Compose nhằm đảm bảo khả năng mở rộng, chịu tải cao và dễ triển khai.
---
## 1. Tổng quan hệ thống 
Hệ thống **GogoFood** được thiết kế theo kiến trúc **microservice**, trong đó mỗi thành phần chịu trách nhiệm cho một domain riêng biệt (User, Commerce, Notification...).

Tất cả request từ Client đều được xử lý thông qua *API Gateway*, đóng vai trò trung gian xác thực và bảo vệ hệ thống: 
  1. Kiểm tra và xác thực **JWT (RSA)**.
  2. Sinh **HMAC nội bộ** để forward sang các service con.
  3. Đảm bảo chỉ có Gateway mới được phép truy cập vào các API nội bộ.
> Các service bên dưới (như User Service hoặc Commerce Service) sẽ tự xác minh tính hợp lệ của HMAC trước khi xử lý logic .
```mermaid
flowchart TD
    %% TẦNG 1: CLIENT
    subgraph Client_Layer[" Client Layer"]
        C[Client / Frontend]
    end

    %% TẦNG 2: API GATEWAY
    subgraph Gateway_Layer[" Gateway Layer"]
        G[API Gateway<br/> JWT Validation<br/> HMAC Signing]
    end

    %% TẦNG 3: SERVICE LAYER
    subgraph Service_Layer[" Microservice Layer"]
        direction LR
        U[User Service<br/> Account & Profile]
        M[Commerce Service<br/> Planning Products & Orders]
        N[Notification Service<br/>Email / Push]
    end

    %% TẦNG 4: INFRASTRUCTURE LAYER
    subgraph Infra_Layer[" Infrastructure Layer"]
        direction LR
        DB[(PostgreSQL)]
        R[(Redis Cache)]
        K[(Kafka Broker)]
    end

    %% LUỒNG CHÍNH (TOP-DOWN)
    C -->|JWT Token| G
    G -->|Forward + Internal HMAC| U
    G -->|Forward + Internal HMAC| M

    %% EVENT FLOW
    U -->|Publish Domain Events| K
    M -->|Publish Domain Events| K
    K -->|Consume Events| N

    %% DATA & CACHE
    U --> DB
    U --> R
    M --> R
    N --> R

    %% LIÊN KẾT HẠ TẦNG
    G -. uses .-> R
    N -. may store logs .-> DB
```
## 2. Thiết kế cơ sở dữ liệu 
Cơ sở dữ liệu của GogoFood được xây dựng trên nền tảng PostgreSQL, đóng vai trò là tầng lưu trữ trung tâm cho các service trong hệ thống. 
Thiết kế hướng tới tính toàn vẹn dữ liệu, ràng buộc nghiệp vụ tại cấp DB, và khả năng mở rộng linh hoạt cho nhiều domain khác nhau (User, Restaurant, Address...). 
### 2.1. Mô hình tổng quan (ERD) 
> Sơ đồ dưới đây thể hiện mối quan hệ giữa các bảng chính trong hệ thống người dùng và nhà hàng:
```mermaid
erDiagram
    USERS ||--o{ ADDRESSES : "has many"
    USERS ||--|| RESTAURANT_PROFILES : "owns"
    ADDRESSES ||--o| RESTAURANT_PROFILES : "location_of"

    USERS {
        UUID id PK
        VARCHAR username
        VARCHAR email
        VARCHAR password
        user_role role
        user_status status
        gender_type gender
        DATE date_of_birth
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    ADDRESSES {
        UUID id PK
        UUID user_id FK
        VARCHAR street
        VARCHAR city
        BOOLEAN is_default
        DOUBLE latitude
        DOUBLE longitude
    }

    RESTAURANT_PROFILES {
        UUID id PK
        UUID user_id FK
        UUID address_id FK
        VARCHAR name
        VARCHAR description
        BOOLEAN is_open
        restaurant_status status
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }
```
