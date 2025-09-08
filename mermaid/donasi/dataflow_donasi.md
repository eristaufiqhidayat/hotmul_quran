```mermaid

flowchart LR
    Anggota -->|Input Data Donasi| Flutter[Flutter App]
    Flutter -->|Request JSON + Token| API[Laravel API]
    API -->|Query| DB[(MySQL Database)]
    DB -->|Data Donasi| API
    API -->|Response JSON| Flutter
    Flutter -->|Tampilkan Donasi| Anggota