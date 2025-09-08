# LEVEL 0

```mermaid
flowchart TD
    User -->|Input Data| Flutter[Flutter App]
    Flutter -->|Request/Response JSON| API[Laravel API]
    API -->|Query| DB[(MySQL Database)]
    DB -->|Data| API
    API -->|Response| Flutter
    Flutter -->|Output| User
