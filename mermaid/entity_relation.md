## ER Relation  Khotmul Quran
```mermaid
erDiagram
    USERS ||--o{ SISWA : mengelola
    KELAS ||--o{ SISWA : berisi

    USERS {
        int id PK
        string name
        string email
        string password
    }

    KELAS {
        int id PK
        string nama_kelas
        string wali_kelas
    }

    SISWA {
        int id PK
        string nama
        string nis
        date tgl_lahir
        int kelas_id FK
        int created_by FK
    }

