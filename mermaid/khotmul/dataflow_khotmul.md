 ```mermaid
flowchart TD
    User([User/Anggota]) -->|Login & Token| P1((Autentikasi))
    User --> |No Login| Home((Homepage)) 
    P1 -->|Valid Token + anggota_id| P2((Dashboard))

    %% Menu di Dashboard
    P2 --> P4(Donasi)
    P2 --> P5(Jadwal)
    P2 --> P6(Reward)
    P2 --> P3(Khotmul)
    
    %% Status berwarna
    P3 --> |Add Khatam ALL| STATUSKUNING((Status: Kuning))
    STATUSKUNING:::kuning --> |Menunggu Approval Admin Status: Hijau| DB[(Database)]
    
    %% Dashboard Feedback 
    P4--> |Add Donasi|DB
    DB --> P5
    DB --> P6
    
    %% Menggunakan subgraph untuk memposisikan DB di bawah
    subgraph BottomSection [ ]
        DB
    end

    %% STYLE DEFINITIONS
    classDef kuning fill:#fff176,stroke:#fbc02d,stroke-width:2px,color:#000,font-weight:bold;


 



