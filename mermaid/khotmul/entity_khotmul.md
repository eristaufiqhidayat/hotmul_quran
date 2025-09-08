```mermaid
erDiagram
    ANGGOTA {
        int id PK
        string name
        int group_id FK
    }

    GROUP {
        int id PK
        string name
    }

    DAURAH {
        int id PK
        string periode
        string keterangan
    }

    KHOTMUL {
        int id PK
        int anggota_id FK
        int group_id FK
        int daurah_id FK
        int juz
        string status
        string periode
    }

    

    ANGGOTA ||--o{ KHOTMUL : "memiliki"
    GROUP ||--o{ KHOTMUL : "digunakan"
    DAURAH ||--o{ KHOTMUL : "terikat"

