 ```mermaid
flowchart TD
    Start[Client Request] --> API[API Gateway]
    API --> Validate[Validation Service]
    Validate --> CheckDB[Database Check]
    CheckDB --> DB[(Users Table)]
    DB --> CheckDB
    CheckDB --> CreateUser[Create User Record]
    CreateUser --> DB2[(Users Table)]
    DB2 --> GetID[Get User ID]
    GetID --> AssignGroup[Assign to Group]
    AssignGroup --> DB3[(Groups Table)]
    DB3 --> GetGroupID[Get Group ID]
    GetGroupID --> StoreRelation[Store User-Group Relation]
    StoreRelation --> DB4[(User_Groups Table)]
    StoreRelation --> ReturnData[Prepare Response]
    ReturnData --> Response[API Response]
    Response --> End[Client Receives IDs]