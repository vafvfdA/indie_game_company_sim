---
name: GDScript Strict Typing Requirements
description: Godot 4.6 treats Variant type inference as error - must type all variables from Dictionary/Array access
type: feedback
originSessionId: b8a395b0-e5ea-405d-9b01-ea871c377ae7
---
Godot 4.6 GDScript严格模式下，从Dictionary/Array访问得到的值会被推断为Variant，导致编译错误。必须显式标注类型。

**Why:** Godot 4.6将Variant推断作为error而非warning处理，会导致项目无法运行。

**How to apply:**
- `var m = dict[key]` → `var m: Dictionary = dict[key]`
- `for emp in employees` → `for emp: Employee in employees`
- `func hire(employee)` → `func hire(employee: Employee)`
- `var old = arr.pop_front()` → `var old: Control = arr.pop_front()`
- `for r in researches` → `for r: Dictionary in researches`
- `var x = max(0, y)` → `var x: int = maxi(0, y)` (max()返回Variant)
- Lambda捕获节点时必须加 `if not is_instance_valid(self): return` 防止节点释放后崩溃
- `company.employees` 必须声明为 `Array[Employee]` 而非 `Array`
