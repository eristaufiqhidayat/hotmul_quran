```mermaid

flowchart TD
    A[User buka DonasiPage] --> B{Login & Token Valid?}
    B -- Tidak --> L[Logout & kembali ke Login]
    B -- Ya --> C[Fetch Data Donasi dari API]
    C --> D{Loading?}
    D -- Ya --> E[Tampilkan Loading Indicator]
    D -- Tidak --> F[Tampilkan List Donasi]

    F --> G{User Action}
    G -->|Refresh| C
    G -->|Search| C
    G -->|Pagination| C
    G -->|Tambah Donasi| H[EditDonasiPage Form Baru]
    G -->|Edit Donasi| H2[EditDonasiPage Form Edit]
    H --> I[Simpan Donasi Baru ke API]
    H2 --> I2[Update Donasi di API]
    I --> C
    I2 --> C

