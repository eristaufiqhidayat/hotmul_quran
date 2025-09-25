```mermaid
flowchart TD
    A[Input Data] --> B{Validation}
    B -->|Valid| C[Generate anggota_id]
    B -->|Invalid| D[Error Response]
    
    C --> E[DB Transaction Start]
    E --> F[Create User Record]
    F --> G[users Table]
    G --> H[Get User ID]
    
    H --> I[Process Daurah]
    I --> J[Get Last Group ID]
    J --> K[daurah_anggota Table]
    K --> L[Check Member Count]
    
    L --> M{Count >= 30?}
    M -->|Yes| N[Create New Group]
    M -->|No| O[Use Existing Group]
    
    N --> P[daurah Table]
    O --> Q[Add to daurah_anggota]
    
    P --> Q
    Q --> R[daurah_anggota Table]
    
    R --> S[Create Notification]
    S --> T[messages Table]
    T --> U[message_user Table]
    
    U --> V[Process Khotmul]
    V --> W[Get Last Period]
    W --> X[khotmul Table]
    
    X --> Y{Period Exist?}
    Y -->|No| Z[Create 30 Juz Records]
    Y -->|Yes| AA[Update First Available Juz]
    
    Z --> X
    AA --> X
    
    X --> BB[Prepare Success Response]
    BB --> CC[API Response]
    
    D --> CC