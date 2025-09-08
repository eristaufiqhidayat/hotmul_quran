```mermaid
flowchart TD
    A([Start: User buka KhotmulPage]) --> B{Token Valid?}
    B -- Tidak --> L([Logout ke LoginPage])
    B -- Ya --> C[Ambil anggota_id, group_id, daurah_id]
    C --> D[Fetch Data dari API /khotmul]
    D --> E{Loading?}
    E -- Ya --> F[Tampilkan CircularProgress]
    E -- Tidak --> G[Tampilkan List Juz & Status]

    G --> H{User Action}
    H -->|Refresh/Search| D
    H -->|Pagination| D
    H -->|Tambah Data| I[EditKhotmulPage/Form Baru/]
    H -->|Add Khatam| J[JuzAyahPage]

    I --> D
    J --> D
    D --> G
