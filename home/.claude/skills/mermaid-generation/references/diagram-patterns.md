# Diagram Patterns

各図種別のテンプレートと、TypeScript/Python コードからの変換パターン。

## classDiagram

### テンプレート

```mermaid
classDiagram
    class ClassName {
        +string propertyName
        -number privateProperty
        +methodName(param) ReturnType
        -privateMethod() void
    }
    ParentClass <|-- ChildClass : extends
    ClassA --> ClassB : uses
    ClassC ..|> InterfaceD : implements
```

### TypeScript からの変換

```typescript
// Source
interface Animal {
  name: string;
  speak(): void;
}

class Dog implements Animal {
  name: string;
  breed: string;
  speak(): void {
    /* ... */
  }
  private bark(): void {
    /* ... */
  }
}

class Cat implements Animal {
  name: string;
  speak(): void {
    /* ... */
  }
}
```

```mermaid
classDiagram
    class Animal {
        <<interface>>
        +string name
        +speak() void
    }
    class Dog {
        +string name
        +string breed
        +speak() void
        -bark() void
    }
    class Cat {
        +string name
        +speak() void
    }
    Animal <|.. Dog : implements
    Animal <|.. Cat : implements
```

### Python からの変換

```python
# Source
class Base(ABC):
    @abstractmethod
    def process(self) -> None: ...

class Handler(Base):
    def __init__(self, name: str):
        self.name = name
    def process(self) -> None: ...
```

```mermaid
classDiagram
    class Base {
        <<abstract>>
        +process()* None
    }
    class Handler {
        +str name
        +process() None
    }
    Base <|-- Handler
```

## sequenceDiagram

### テンプレート

```mermaid
sequenceDiagram
    participant U as User
    participant C as Controller
    participant S as Service
    participant D as Database

    U->>C: HTTP Request
    C->>S: Process
    S->>D: Query
    D-->>S: Result
    S-->>C: Response Data
    C-->>U: HTTP Response
```

### 変換のポイント

- `await` / `async` 呼び出し → 非同期メッセージ (`->>`)
- コールバック/戻り値 → 応答メッセージ (`-->>`)
- try/catch → alt/else ブロック
- ループ → loop ブロック

## flowchart

### テンプレート

```mermaid
flowchart TD
    A[Start] --> B{Condition}
    B -->|Yes| C[Action 1]
    B -->|No| D[Action 2]
    C --> E{Another Check}
    E -->|Pass| F[Success]
    E -->|Fail| G[Error Handler]
    D --> F
    G --> F
    F --> H[End]
```

### 変換のポイント

- `if/else` → 菱形ノード `{}`
- `switch/case` → 複数分岐
- `try/catch` → エラーハンドリングパス
- 関数呼び出し → サブグラフ

## erDiagram

### テンプレート

```mermaid
erDiagram
    USER {
        int id PK
        string name
        string email UK
        datetime created_at
    }
    POST {
        int id PK
        string title
        text content
        int user_id FK
    }
    COMMENT {
        int id PK
        text body
        int post_id FK
        int user_id FK
    }
    USER ||--o{ POST : writes
    USER ||--o{ COMMENT : writes
    POST ||--o{ COMMENT : has
```

### 変換のポイント

- Prisma schema / TypeORM Entity → テーブル定義
- `@relation` / `ForeignKey` → リレーション
- カーディナリティ: `||--o{` (1対多), `||--||` (1対1), `}o--o{` (多対多)

## stateDiagram

### テンプレート

```mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> Processing : start
    Processing --> Success : complete
    Processing --> Error : fail
    Error --> Idle : retry
    Error --> [*] : abort
    Success --> [*]
```

### 変換のポイント

- enum/union type の状態 → ステート
- 状態変更関数 → トランジション
- Redux reducer / XState config → 直接マッピング

## graph（依存関係）

### テンプレート

```mermaid
graph TD
    subgraph Core
        A[module-a]
        B[module-b]
    end
    subgraph Features
        C[feature-x]
        D[feature-y]
    end
    C --> A
    C --> B
    D --> A
```

### 変換のポイント

- `import` / `require` → 依存エッジ
- ディレクトリ構造 → サブグラフ
- 循環依存 → 双方向矢印で警告表示
