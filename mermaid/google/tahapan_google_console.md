```mermaid
flowchart TD

A[Login Google Play Console] --> B[Create App]
B --> C[Isi Data Awal]
C --> D[Store Listing]
D --> E[Upload Icon, Screenshot, Graphic]
E --> F[Isi Privacy Policy, Kontak, Kategori]

F --> G[Upload App Bundle AAB/APK]
G --> H[Create Release]

H --> I[Isi App Content Form]
I --> I1[Target Audience]
I --> I2[Data Safety]
I --> I3[Ads Declaration]
I --> I4[App Access]
I --> I5[Permissions]

I --> J[Set Harga & Distribusi]
J --> K[Review & Rollout to Production]

K --> L{Google Review}
L -->|Approved| M[App Live di Play Store 🎉]
L -->|Rejected| N[Revisi & Submit Ulang]
