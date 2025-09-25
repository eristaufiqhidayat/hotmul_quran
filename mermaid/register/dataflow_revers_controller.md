```mermaid
flowchart TD
    A[User] -->|Registration Request<br>name, email, password| B[Process: Register API]
    
    B -->|Validate Input| C[Process: Validation]
    C -->|Valid Data| D[Process: Generate Anggota ID]
    C -->|Invalid Data| E[Return Error Response]
    E --> A
    
    D -->|anggota_id| F[Process: Create User]
    F -->|Insert Data| G[Data Store: users Table]
    G -->|User Created| F
    
    F -->|user_id| H[Process: Process Daurah Group]
    H -->|Get Last Group ID| I[Data Store: daurah_anggota Table]
    I -->|lastGroupId| H
    
    H -->|Check Member Count| I
    H -->|Create New Group if Needed| J[Data Store: daurah Table]
    J -->|New Group Created| H
    
    H -->|Assign to Group| K[Process: Add to Daurah Anggota]
    K -->|Insert Member Data| I
    
    K -->|Assignment Complete| L[Process: Create Notification]
    L -->|Insert Message| M[Data Store: messages Table]
    M -->|message_id| L
    
    L -->|Link Message to User| N[Data Store: message_user Table]
    
    L -->|Notification Sent| O[Process: Process Khotmul]
    O -->|Get Last Period| P[Data Store: khotmul Table]
    P -->|periodeTerakhir| O
    
    O -->|Process Juz Assignment| P
    P -->|Juz Data Updated| O
    
    O -->|Khotmul Complete| Q[Process: Prepare Response]
    Q -->|Success Response| R[Return API Response]
    R --> A
    
    style A fill:#f00000
    style B fill:#f00000
    style G fill:#f00000
    style I fill:#f00000
    style J fill:#f00000
    style M fill:#f00000
    style N fill:#f00000
    style P fill:#f00000
    style R fill:#f00000