```mermaid
flowchart TD
    %% Define styles
    classDef entity fill:#d4f2ff,stroke:#333,stroke-width:2px;
    classDef process fill:#fff2cc,stroke:#333,stroke-width:2px;
    classDef datastore fill:#e5d1f9,stroke:#333,stroke-width:2px;

    %% External Entities
    P([Pelanggan])
    R([Restoran])
    Dv([Driver])

    %% Processes
    P1(1.0<br>Proses Pesanan)
    P2(2.0<br>Proses Pembayaran)
    P3(3.0<br>Koordinasikan Pengantaran)
    P4(4.0<br>Update Status)

    %% Data Stores
    DS1((D1: Data Pesanan))
    DS2((D2: Data Menu))
    DS3((D3: Data Driver))
    
    %% Data Flows from External Entities
    P -->|Detail Pesanan| P1
    P -->|Pembayaran| P2

    R -->|Konfirmasi Pesanan| P4
    Dv -->|Status Pengantaran| P4

    P4 -->|Notifikasi Status| P

    %% Data Flows between Processes
    P1 -->|Permintaan Pembayaran| P2
    P2 -->|Pembayaran Dikonfirmasi| P3

    %% Data Flows to/from Data Stores
    P1 -->|Cek Ketersediaan| DS2
    DS2 -->|Info Menu| P1

    P1 -->|Data Pesanan Baru| DS1
    P2 -->|Konfirmasi Pembayaran| DS1
    P3 -->|Ambil Data Pesanan| DS1
    P4 -->|Update Status| DS1

    P3 -->|Cari Driver| DS3
    DS3 -->|Driver Tersedia| P3

    %% Data Flows to External Entities
    P3 -->|Detail Pesanan| R
    P3 -->|Detail Pengantaran| Dv

    %% Apply styles
    class P,R,Dv entity;
    class P1,P2,P3,P4 process;
    class DS1,DS2,DS3 datastore;