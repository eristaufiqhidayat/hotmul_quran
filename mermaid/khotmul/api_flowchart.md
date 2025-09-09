```mermaid
flowchart TD

    A[Start Register Function] --> B[Validate Request: name, email, password]
    B -->|Valid| C[Generate anggota_id: datePart + randomPart]
    B -->|Invalid| Z1[Return Validation Error]

    C --> D{Try Transaction}
    D --> E[Create User with anggota_id & group_id=2]
    E -->|Fail| Z2[Return 500: Gagal membuat user]
    E -->|Success| F[Get  from daurah_anggota]

    F -->|No group_id| Z3[Return 404: Belum ada data daurah_anggota]
    F -->|Found| G[Count anggota in lastGroupId]

    G --> H{JumlahAnggota >= 30?}
    H -->|Yes| I[Increment group_id and insert new daurah]
    H -->|No| J[Use lastGroupId]

    I --> K[Insert user into daurah_anggota]
    J --> K[Insert user into daurah_anggota]

    K --> L[Return 201: User registered successfully]

    D -->|QueryException| Z4[Return 500: Database error]
    D -->|\Exception| Z5[Return 500: General error]

    Z1 --> END[End]
    Z2 --> END
    Z3 --> END
    Z4 --> END
    Z5 --> END
    L --> END
