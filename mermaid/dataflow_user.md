 ```mermaid
flowchart TD
    User([User/Anggota]) -->|Login & Token| P1((Autentikasi))
    User --> |No Login| H((Homepage)) 
    P1 -->|Valid Token + anggota_id| P2((Dashboaard))

    %% Menu di Dashboard
    P2 --> P4((Donasi))
    P2 --> P5((Jadwal))
    P2 --> P6((Reward))
    P2 --> P3((Khotmul))
    P3 --> |Setor|DB[(A P I Database)]
    H --> R[Register]
    
    %% Dashboard Feedback 
    DB --> P4
    DB --> P5
    DB --> P6
    DB --> P3
    
    %% Menggunakan subgraph untuk memposisikan DB di bawah
    subgraph BottomSection [ ]
        DB
    end

 



