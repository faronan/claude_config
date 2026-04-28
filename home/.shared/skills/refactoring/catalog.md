# Refactoring Catalog

## Code Smells 詳細

### 1. Long Method
**症状**: 関数が長すぎる（目安: 20行以上）

**問題点**:
- 理解しにくい
- テストしにくい
- 再利用しにくい

**対処法**: Extract Method
```typescript
// Before
function processOrder(order) {
  // validate
  if (!order.items) throw new Error('No items');
  if (!order.customer) throw new Error('No customer');
  // calculate total
  let total = 0;
  for (const item of order.items) {
    total += item.price * item.quantity;
  }
  // apply discount
  if (order.customer.isPremium) {
    total *= 0.9;
  }
  // ... more code
}

// After
function processOrder(order) {
  validateOrder(order);
  const total = calculateTotal(order);
  const finalTotal = applyDiscount(total, order.customer);
  // ...
}
```

---

### 2. Large Class
**症状**: クラスの責務が多すぎる

**問題点**:
- 単一責任原則違反
- 変更の影響範囲が大きい

**対処法**: Extract Class
```typescript
// Before
class User {
  name: string;
  email: string;
  // Address responsibility
  street: string;
  city: string;
  zipCode: string;
  // Authentication responsibility
  passwordHash: string;
  lastLogin: Date;
}

// After
class User {
  name: string;
  email: string;
  address: Address;
  auth: UserAuth;
}
```

---

### 3. Duplicate Code
**症状**: 同じ・類似のコードが複数箇所に存在

**対処法**: Extract Method / Pull Up Method

---

### 4. Feature Envy
**症状**: メソッドが自身のクラスより他クラスのデータを多用

**対処法**: Move Method

```typescript
// Before: OrderPrinter が Order のデータばかり使う
class OrderPrinter {
  print(order: Order) {
    console.log(`Items: ${order.items.length}`);
    console.log(`Total: ${order.calculateTotal()}`);
    console.log(`Customer: ${order.customer.name}`);
  }
}

// After: メソッドを Order に移動
class Order {
  print() {
    console.log(`Items: ${this.items.length}`);
    console.log(`Total: ${this.calculateTotal()}`);
    console.log(`Customer: ${this.customer.name}`);
  }
}
```

---

### 5. Data Clumps
**症状**: 常にセットで使われるデータ群

**対処法**: Introduce Parameter Object

```typescript
// Before
function createEvent(startDate, startTime, endDate, endTime, title) {}

// After
interface DateRange {
  start: DateTime;
  end: DateTime;
}
function createEvent(dateRange: DateRange, title: string) {}
```

---

### 6. Primitive Obsession
**症状**: プリミティブ型の過度な使用

**対処法**: Replace Primitive with Object

```typescript
// Before
const email: string = 'user@example.com';

// After
class Email {
  constructor(private readonly value: string) {
    if (!this.isValid(value)) throw new Error('Invalid email');
  }
  private isValid(value: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
  }
}
```

---

### 7. Long Parameter List
**症状**: 引数が多すぎる（目安: 4つ以上）

**対処法**: Introduce Parameter Object

```typescript
// Before
function createUser(
  name: string,
  email: string,
  age: number,
  address: string,
  phone: string,
  role: string
) {}

// After
interface CreateUserParams {
  name: string;
  email: string;
  age: number;
  address: string;
  phone: string;
  role: string;
}
function createUser(params: CreateUserParams) {}
```

---

## リファクタリング手順チェックリスト

### 事前準備
- [ ] テストが全て通ることを確認
- [ ] 変更範囲を特定
- [ ] 影響を受けるファイルをリストアップ

### 実行中
- [ ] 一度に1つのリファクタリングのみ実行
- [ ] 各ステップ後にテスト実行
- [ ] コミットを細かく分ける

### 完了後
- [ ] 全テストが通ることを確認
- [ ] 振る舞いが変わっていないことを確認
- [ ] コードレビューを依頼
