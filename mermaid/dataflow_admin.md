 ```mermaid
flowchart TD
    User([Admin]) -->|Login & Token| P1((Autentikasi))
    User --> |No Login| H((Homepage)) 
    P1 -->|Valid Token + anggota_id| P2((Dashboaard))

    %% Menu di Dashboard
    P2 --> P4[Donasi]
    P2 --> P5[Jadwal]
    P2 --> P6[Reward]
    P2 --> P3((Khotmul))
    P2 --> P7[Daurah]
    P2 --> |Read Message|M[Message]
    
    %% Dashboard Feedback 
    M --> |Create|DB[(A P I Database)]
    DB --> M
    P4-->DB
    P5-->DB
    P6-->DB
    P7-->DB
    DB --> P7
    DB --> P4
    DB --> P5
    DB --> P6
    DB --> P3
    
  

 



