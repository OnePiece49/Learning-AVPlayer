# I. Introduction
Khi chúng ta làm việc với các kiểu collection types, sẽ rất khó trong việc xử lý login khi collection bị thay đổi như khi 1 items mới được added, deleted, modified,... Chúng ta thường sử dụng Notification-Center để thông báo liệu rằng có sự thay đổi hay không. Nhưng khi ta muốn kiểm tra nhiều thuộc tính, Notification-Center có thể làm code ta trở nên nhiều hơn. Có 1 cách xử lý tốt hơn là sử dụng **KVO(Key value Observing)**, cái mà liên quan trực tiếp đến cơ chế **KVC(Key Value Coding).**
Cả KVO và KVC cung cấp cho ta rất nhiều cơ chế để xử lý code.
- **KVC:** là 1 cơ chế cho phép ta truy cập vào các thuộc tính của 1 đối tượng không trực tiếp, ta sẽ sử dụng strings để truy cập thay vì sử dụng các properties của đối tượng 1 cách trực tiếp. Để có thể sử dụng cơ chế đó, class của chúng ta phải comform với protocol **NSKeyValueCoding.** \
Cắt nghĩa các câu trên:
Là 1 cơ chế cho phép ta truy cập vào các thuộc tính của 1 đối tượng không trực tiếp, ta sẽ sử dụng **strings** để truy cập thay vì sử dụng các properties của đối tượng 1 cách trực tiếp.
```php
class Profile: NSObject {
    var firstName: String
    var lastName: String
    var customProfile: Profile
}
```
Sau đó nếu ta muốn truy cập, gán các thuộc tính đó, thì với cách code thông thường ta sẽ:
```php
self.firstName = “Robert”
self.lastName = “Stark”
```
Nhưng với KVC ta sẽ làm như sau
```php
self.setValue(“Robert”, forKey: “firstName”)
self.setValue(“Stark”, forKey: lastName)
let robertLastName = self.value(forKey: “lastName”)
```
Ta thấy rằng đoạn code KVC trên giống như Dictionaries. Hmm, ta sẽ có 2 khải niệm mới **Key và KeyPath.**
- Key: Key đại diện cho 1 thuộc tính của 1 đối tượng, cái mà ta muốn set hoặc lấy value từ thuộc tính nó. Thông thường là hay xét name của key trùng với tên của property.
Như ở VD trên: self.setValue(“Stark”, forKey: lastName), key ở đây là lastname trùng tên của thuộc tính
- KeyPath: A KeyPath is formed with the dot-syntax by following the substrings, so it is not a single word/string. Key-path represents all the properties of an object, which comes in the way until to reach the desired value/property. Hmm đợi đọc vd2 bên dưới thì sẽ hiểu(spoild trước là ta muốn truy cập vào các properties bên trong của 1 property trong class thì dùng keyPath)

Để có thể sử dụng KVC trong Class của chúng ta, chúng ta cần cormform NSKeyValueCoding protocol. Bằng cách comform NSObject, chúng ta có thể đạt được cơ chế này. Vì UIViewController đã comform NSObject, nên ta có thể sử dụng các phương thức mà không cần comform hay là setup gì cả.


# II. Dynamic Dispatch và KVC
Dynamic Dispatch là 1 cơ chế của Objective-C. Nó là cơ chế cho phép Objective-C mà cho phép trong quá trình runtime, method nào sẽ được gọi. Ví dụ ta có 1 subclass, ta ovveride 1 phương thức từ baseclass, dynamic dispatch sẽ biết được phương thức nào sẽ được gọi. 
Còn đối với Swift runtime, nó sẽ sử dụng các cơ chế khác như static và virtual dispatch thay vì dynamic dispath. Swift sử dụng các cơ chế đó để làm tăng performance. Static and virtual dispatch are much faster than dynamic dispatch.
Bằng cách khai báo với từ khóa **dynamic**, việc khai báo này sẽ ngầm định được đánh dấu với **objc**. Thuộc tính **objc** làm việc khai báo available in Objective-C, từ khóa dynamic chỉ có thể được áp dụng cho các member của 1 class. Struct và Enum không có tính kế thừa, vì vậy trong thời điểm runtime, nó sẽ không phải phát hiện ra method nào cần sử dụng, nên sẽ dynamic sẽ không được support trong Struct và Enum.

Ta có VD1:
Ta khởi tạo 1 class Children:
```php
class Children: NSObject {
    @objc dynamic var name: String
    @objc dynamic var age: Int
    @objc dynamic var child: Children?

    override init() {
        name = ""
        age = 0
        super.init()

    }
}
```
Và trong Controller ta khai báo
```php
func learningObserve() {
    self.child1.setValue("Vietdz123", forKey: "name")
    self.child1.setValue(13, forKey: "age")
    
    let name = child1.value(forKey: "name")
    print("DEBUG: \(name)")
}
```
Ta thấy rằng, ta đã gán value và lấy giá trị thông qua sử dụng Key.
**Chú ý:** Nếu ta truyền 1 key mà không trùng tên của các properties, nó sẽ làm crash chương trình.
 VD ***self.child1.setValue("Vietdz123", forKey: "name123")*** sẽ làm crash chương trình

Tiếp tục với VD2, vẫn base Class như trên
```php
func learningObserve() {
    self.child2 = Children.init()
    self.child2.child = Children.init()
    
    self.child2.setValue("DucAnh", forKey: "name")
    self.child2.setValue(11, forKey: "age")
    self.child2.setValue("HuyNguNgoc", forKeyPath: "child.name")
    self.child2.setValue(15, forKeyPath: "child.age")
    
    print("DEBUG: \(child2.child?.name)")
}
```
Class Children có 1 property Child thuộc kiểu Children?, câu hỏi đặt ra là làm sao xét value cho các thuộc tính của property child. Đó là sử dụng **Keypath** như sau
**self.child2.setValue("HuyNguNgoc", forKeyPath: "child.name")**
Sử dụng Key, thì ta sẽ không truy cập vào được các phần tử bên trong của 1 property.
Sử dụng Keypath thì ta có thể truy cập vào được các phần tử bên trong của 1 property.
Qua bước này, ta đã biết làm sao viết code theo kiểu KVC

# III. KVO
Tiếp tục ta sẽ xem làm thế nào ta có thể theo dõi sự thay đổi của các properties. Ta sẽ thực hiện các bước sau để triển khai KVO:
1. Class muốn observer những thay đổi các properties của nó phải comform KVO. Như sau
    - Class bắt buộc phải comform KVC.
    - Class phải có khả năng gửi thông báo 1 cách tự động hoặc manually.
2. Class mà được sử dụng để observe các thuộc tính của class khác phải được set là **observe.**
3. Một phương thức đặc biệt có tên là **observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)** phải được triển khai trong observing class. 

Điều quan trọng nhất khi chúng ta muốn quan sát những thay đổi của một thuộc tính, là làm cho Class của chúng ta observe những thay đổi này. Ta thường sử dụng notification, nhuwngg trong trường hợp này ta sử dụng 1 method khác, đó là:
**addObserver(observer: <NSObject>, forKeyPath: <String>, options: <NSKeyValueObservingOptions>, context: <UnsafeMutableRawPointer>)**
Vơi các parameter như sau:
- observer: Ta cần truyền vào 1 observing class, thường là self. Ta cần chú ý rằng các UIViewController đều đã comform NSObject nên tự chúng đã là 1 observing class.
- forKeyPath: Đây là 1 string được ta sử dụng như 1 key hoặc keyPath mà cần phải match với name của property ta muốn observe.
- options: Là 1 mảng các *NSKeyValueObservingOptions* values
- context: Đây là 1 con trỏ mà được sử dụng 1 như là mà mã định danh độc nhất cho đối tượng ta muốn observe. ta thường xét chúng là nil.
Tiếp tục triển khai VD2. Ta sẽ observe sự thai đổi các thuộc tính name và age của child1 object.
```php
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    child1.addObserver(self, forKeyPath: "name", options: [.old, .new], context: nil)
    child1.addObserver(self, forKeyPath: "age", options: [.old, .new], context: nil)
}
```
Sau đó ta sẽ tiếp tục triển khai hàm **obserValue()**:
```php
override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if "name" == keyPath {
        print("DEBUG: child2 name is changed")
        print("DEBUG: newValue is \(change?[.newKey])")
        print("DEBUG: oldvalue is \(change?[.oldKey]) \n")
    }
    
    if "age" == keyPath {
        print("DEBUG: child2 age is changed")
        print("DEBUG: newValue is \(change?[.newKey])")
        print("DEBUG: oldvalue is \(change?[.oldKey]) \n")
    }
}
```
lúc này nếu ta xét
```php
self.child2.setValue("HUy12121", forKey: "name")
Thread.sleep(forTimeInterval: 2.0)
self.child2.setValue(22, forKey: "age")
self.child2.setValue(11, forKey: "age")
self.child2.setValue(11, forKey: "age")
```
Ta sẽ được kết quả thế này:
```php
DEBUG: child2 name is changed
DEBUG: newValue is Optional(HUy12121)
DEBUG: oldvalue is Optional(DucAnh) 
DEBUG: child2 age is changed
DEBUG: newValue is Optional(11)
DEBUG: oldvalue is Optional(11) 
DEBUG: child2 age is changed
DEBUG: newValue is Optional(11)
DEBUG: oldvalue is Optional(11) 
```
Ta thấy gán lại cùng giá trị thì nó vẫn nhảy vào observe, có vẻ cơ chế giống như didSet. Và ta cũng thấy rằng, ta truy cập các thuộc tính cũ và mới của property ta observe thông qua **.oldKey và .newKey**.

Đến đây, ta có 1 vấn đề là chưa phân biệt được các đối tượng với nhau, như kiểu 2 biến child1 và child2 đều observe name thì đều vào. Vậy để phân biệt các đối tượng child1 và child2 với nhau, thì ta sử dụng **context.**
```php
let context1 = UnsafeMutableRawPointer.allocate(byteCount: 4 * 4, alignment: 0)
let context2 = UnsafeMutableRawPointer.allocate(byteCount: 4 * 4, alignment: 1)
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    child2.addObserver(self, forKeyPath: "name", options: [.old, .new], context: context2)
    child1.addObserver(self, forKeyPath: "name", options: [.old, .new], context: context1)
}

override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    self.child2.setValue("HUy12121", forKey: "name")
    self.child1.setValue("KAKA", forKey: "name")
}

override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if context == context1 {
        if "name" == keyPath {
            print("DEBUG: child1 name is changed")
            print("DEBUG: newValue is \(change?[.newKey])")
            print("DEBUG: oldvalue is \(change?[.oldKey]) \n")
        }
    }

    if context == context2 {
        if "name" == keyPath {
            print("DEBUG: child2 name is changed")
            print("DEBUG: newValue is \(change?[.newKey])")
            print("DEBUG: oldvalue is \(change?[.oldKey]) \n")
        }
    }
}
```
Output:
```php
DEBUG: child2 name is changed
DEBUG: newValue is Optional(HUy12121)
DEBUG: oldvalue is Optional(DucAnh) 
DEBUG: child1 name is changed
DEBUG: newValue is Optional(KAKA)
DEBUG: oldvalue is Optional() 
```

Điều quan trọng cuối cùng là ta cần remove observe khi màn ko cần sử dụng nữa
```php
override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    self.child1.removeObserver(self, forKeyPath: "name", context: context1)
    self.child2.removeObserver(self, forKeyPath: "name", context: context2)

}
```

# IV. Automatic and Manual Notification

Thông thường, hệ thống sẽ gửi thông báo mỗi khi giá trị property thay đổi. Tuy nhiên đôi khi ta lại không muốn nhận thông báo, để đạt được điều này ta có thể triển khai phương thức **_automaticallyNotifiesObserverForKey:_**. trong trường hợp ta không muốn nhận thông báo, ta sẽ return false.
![](/images/automaticNotifi.png)
1