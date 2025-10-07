 ```mermaid
flowchart TD
    Admin([Admin]) -->|Login & Token| P1((Autentikasi))
    Admin --> |No Login| Home((Homepage)) 
    P1 -->|Valid Token| P2((Dashboard))

    %% Menu di Dashboard

    P2 --> P3(Anggota):::grey
    P2 --> P4(Daurah):::grey 
    P2 --> P5(Khatam)
    P2 --> P6(Donasi):::grey 
    P2 --> P7(Jadwal Khatam):::grey 
    P2 --> P8(Khotmul Periode):::grey 
    P2 --> P9(Reward):::grey 
    P2 --> P10(Laporan):::grey 
    
    %% Status berwarna
    P5 --> |Fetch Data| DB[(Database API Server)]
    
    %% Dashboard Feedback 

    DB --> |Approve| STATUSHIJAU((Status: Hijau))
    STATUSHIJAU:::hijau --> P5
    %% Menggunakan subgraph untuk memposisikan DB di bawah
    subgraph BottomSection [ ]
        DB
    end

    %% STYLE DEFINITIONS
    classDef kuning fill:#fff176,stroke:#fbc02d,stroke-width:2px,color:#000,font-weight:bold;
    classDef hijau fill:#6CF527,stroke:#fbc02d,stroke-width:2px,color:#000,font-weight:bold;
    classDef grey fill:#808080,stroke:#fbc02d,stroke-width:2px,color:#000,font-weight:bold;
    %%linkStyle 9 stroke:#4CAF50,stroke-width:5px,stroke-dasharray:5 5;


 



