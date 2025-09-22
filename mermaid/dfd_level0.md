```mermaid
flowchart TD
    %% Define styles for entities
    classDef entity fill:#d4f2ff,stroke:#333,stroke-width:2px;
    classDef process fill:#fff2cc,stroke:#333,stroke-width:2px;

    %% External Entities
    Pelanggan([Pelanggan])
    Restoran([Restoran])
    Driver([Driver])

    %% Main Process
    Sistem("Sistem Pemesanan<br>Makanan Online")

    %% Data Flows
    Pelanggan -- Detail Pesanan & Pembayaran --> Sistem
    Sistem -- Pesanan --> Restoran
    Sistem -- Detail Pengantaran --> Driver
    Restoran -- Konfirmasi Pesanan & Status --> Sistem
    Driver -- Status Pengantaran --> Sistem
    Sistem -- Konfirmasi & Notifikasi Status --> Pelanggan

    %% Apply styles
    class Pelanggan,Restoran,Driver entity;
    class Sistem process;