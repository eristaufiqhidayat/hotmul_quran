```mermaid
erDiagram
    users {
        bigint id PK
        varchar name
        varchar email UK
        timestamp email_verified_at
        varchar password
        varchar remember_token
        bigint anggota_id
        int group_id
        timestamp created_at
        timestamp updated_at
    }

    daurah {
        int group_id PK
        varchar group_name
    }

    daurah_anggota {
        bigint user_id PK
        int group_id
        varchar name
    }

    khotmul {
        int id PK
        int group_id
        int juz
        int periode
        date tanggal
        int anggota_id
        varchar status
    }

    khotmul_periode {
        int id PK
        int periode
        int group_id
        date tanggal
        varchar keterangan
    }

    khotmul_rec {
        int id PK
        int khotmul_id FK
        int periode_id FK
        varchar name
        varchar path
        varchar mime_type
        varchar size
        int juz
        int surah
        int ayah_awal
        int ayah_akhir
        int anggota_id
        int group_id
        varchar catatan
    }

    messages {
        bigint id PK
        bigint sender_id FK
        enum target_type
        bigint target_id
        text content
        timestamp created_at
        timestamp updated_at
    }

    message_user {
        bigint id PK
        bigint message_id FK
        bigint user_id FK
        tinyint is_read
        timestamp created_at
        timestamp updated_at
    }

    quran_text {
        int id PK
        int juz
        int surah
        int ayah
        text text
    }

    surah_index {
        int no_surah PK
        varchar nama_surah
        int urutan_global_awal
        int urutan_global_akhir
    }

    juzAlquran_urutAyah {
        int id PK
        int juz
        int noSurah_awal
        int noAyah_awal
        int noSurah_akhir
        int noAyah_akhir
        int globalAwal
        int globalAkhir
    }

    ayahharian {
        int id PK
        int juz
        int hari_ke
        int no_surahawal
        varchar nama_surahawal
        int no_ayahawal
        int no_surahakhir
        varchar nama_surahakhir
        int no_ayahakhir
    }

    hapalan {
        int id PK
        int user_id
        int surah
        int ayah
        blob audio
    }

    khatam {
        int id PK
        bigint user_id
        int jumlah_khatam
        int jumlah_tidak_baca
        int jumlah_membadalkan
        varchar keterangan
        date tanggal
    }

    donasi {
        int id PK
        int user_id
        date tanggal
        decimal rp
    }

    reward {
        int id PK
        int anggota_id
        varchar keterangan
        int rp
    }

    jadwal_khatam {
        int id PK
        varchar nama_acara
        varchar nama_tempat
        date waktu
        varchar alamat
    }

    reportDaurah {
        int id PK
        varchar nama_daurah
        int Jumlah_anggota
        int jumlah_periode
    }

    group_user {
        int id PK
        varchar name
    }

    posts {
        bigint id PK
        varchar title
        text content
        timestamp created_at
        timestamp updated_at
    }

    %% Relationships
    users ||--o{ daurah_anggota : "has"
    users ||--o{ messages : "sends"
    users ||--o{ message_user : "receives"
    users ||--o{ khotmul : "assigned_to"
    users ||--o{ hapalan : "has"
    users ||--o{ khatam : "has"
    users ||--o{ donasi : "makes"
    users ||--o{ reward : "receives"

    daurah ||--o{ daurah_anggota : "contains"
    daurah ||--o{ khotmul : "has"
    daurah ||--o{ khotmul_periode : "has"

    khotmul ||--o{ khotmul_rec : "has_recording"
    khotmul_periode ||--o{ khotmul_rec : "belongs_to"

    messages ||--o{ message_user : "delivered_to"

    quran_text }|--|| surah_index : "references"
    juzAlquran_urutAyah }|--|| quran_text : "defines_juz"
    ayahharian }|--|| quran_text : "references"

    daurah_anggota }|--|| users : "belongs_to"
    messages }|--|| users : "sent_by"
    message_user }|--|| users : "received_by"