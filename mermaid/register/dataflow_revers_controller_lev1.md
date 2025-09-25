```mermaid
flowchart TD
    A[Client] -->|POST /register| B[API Controller]
    
    B --> C[Validation Process]
    C --> D[User Creation Process]
    D --> E[Daurah Group Processing]
    E --> F[Notification Creation]
    F --> G[Khotmul Processing]
    G --> H[Response Preparation]
    H --> I[API Response]
    
    subgraph Data Stores
        J[users Table]
        K[daurah_anggota Table]
        L[daurah Table]
        M[messages Table]
        N[message_user Table]
        O[khotmul Table]
    end
    
    D --> J
    E --> K
    E --> L
    F --> M
    F --> N
    G --> O