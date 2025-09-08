 ```mermaid
flowchart TD
    User([User/Anggota]) -->|Login & Token| P1((Autentikasi))
    P1 -->|Valid Token + anggota_id| P2((KhotmulPage))

    %% Data Flow
    P2 -->|Fetch Data by group_id, daurah_id| DB[(Tabel Khotmul)]
    DB -->|Data Khotmul| P2
    P2 -->|Tampilkan List| User

    %% CRUD
    User -->|Tambah/Edit Khotmul| P3((CRUD Khotmul))
    P3 --> DB
    User -->|Add Khatam| P4((JuzAyah Modul))
    P4 --> DB
    User -->|Add Donasi| P5((Donasi Modul))
    P5 --> DB

    DB -->|Update Data| P2
