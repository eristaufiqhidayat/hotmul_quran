
# Flow Chart Anggota

```mermaid

flowchart TD
    A[Homepage Anggota Login] --> B{Login}   
    B -->|Valid| C[Dashboard]
    B -->|Tidak Valid| A
    C --> KHOT[Konfirmasi Khotmul]
    C --> DON[Konfirmasi Donasi]
    C --> DAR[Lihat Daurah]
    C --> GIT[Lihat Jadwal]
    C --> REW[Lihat Reward]
    C --> REW[Lihat Laporan]
    KHOT --> F
    DON --> F[Kirim Data ke API Laravel]
    F --> G[(Database)]
    G --> H[Response API]
    H --> C
