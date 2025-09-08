```mermaid
flowchart LR
    Admin -->|Tambah/Edit Daurah| Flutter
    Flutter -->|POST/PUT| API
    API -->|INSERT/UPDATE| DB[(MySQL)]
    DB --> API
    API -->|Response JSON| Flutter
    Flutter -->|Tampilkan hasil| Anggota
