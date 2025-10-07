 ```mermaid
flowchart TD
    User([User/Anggota]) -->|Login & Token| P1((Autentikasi))
    User --> |No Login| Home((Homepage)) 
    P1 -->|Valid Token + anggota_id| P2((Dashboard))

    %% Menu di Dashboard

    P2 --> P3(Khotmul)
    P2 --> P4(Donasi):::grey 
    P2 --> P5(Reward):::grey 
    P2 --> P6(Jadwal Khatam):::grey 
    
    %% Status berwarna
    P3 --> |Add Khatam ALL| STATUSKUNING((Status: Kuning))
    STATUSKUNING:::kuning --> DB[(Database API Server)]
    
    %% Dashboard Feedback 

    DB -.-> |Approv dari admin| STATUSHIJAU((Status: Hijau))
    STATUSHIJAU:::hijau --> P3
    %% Menggunakan subgraph untuk memposisikan DB di bawah
    subgraph BottomSection [ ]
        DB
    end

    %% STYLE DEFINITIONS
    classDef kuning fill:#fff176,stroke:#fbc02d,stroke-width:2px,color:#000,font-weight:bold;
    classDef hijau fill:#6CF527,stroke:#fbc02d,stroke-width:2px,color:#000,font-weight:bold;
    classDef grey fill:#808080,stroke:#fbc02d,stroke-width:2px,color:#000,font-weight:bold;
    linkStyle 9 stroke:#4CAF50,stroke-width:5px,stroke-dasharray:5 5;


 



