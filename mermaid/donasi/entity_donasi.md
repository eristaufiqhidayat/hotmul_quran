```mermaid
erDiagram
    USERS ||--o{ DONASI : membuat
    GROUPS ||--o{ DONASI : berisi

    USERS {
        int id PK
        string name
        string email
        string password
    }

    GROUPS {
        int id PK
        string group_name
    }

    DONASI {
        int id PK
        int user_id FK
        int group_id FK
        int rp
        date tanggal
        datetime created_at
        datetime updated_at
    }
