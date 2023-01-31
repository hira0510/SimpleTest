//
//  ViewController.swift
//  QuenuGCDTest
//
//  Created by Hira on 2022/3/17.
//

import UIKit

/// 🤯Queue佇列 特性是FIFO（先進先出）
/// Dispatch queues 是 Grand Central Dispatch（GCD）的其中一個工具
///
/// GCD 就是用來幫助我們管理執行緒的 framework。GCD 提供三種工具
/// 分別是 Dispatch Queues、Dispatch Sources、和 Operation Queues
///
///
///
/// DispatchQueue.main (主佇列，serial) 是唯一一個可以更新畫面的 thread。
/// DispatchQueue.global(qos:) (全局佇列，concurrent queue)
/// DispatchQueue(label:) (自定義佇列，默認Serial)
///
///
///
///   區別 ｜   Serial Queue   ｜  Concurrent Queue ｜
/// －－－－｜－－－－－－－－－－－｜－－－－－－－－－－－－｜
///  Sync ｜            無開啟新的執行緒              ｜
///       ｜             照順序執行任務               ｜
/// －－－－｜－－－－－－－－－－－－－－－－－－－－－－－－｜
///  Async｜ 有開啟新的執行緒(1條)｜有開啟新的執行緒(多條) ｜
///       ｜    照順序執行任務   ｜同時執行任務(速度最快) ｜
/// －－－－｜－－－－－－－－－－－｜－－－－－－－－－－－－｜
///
///
///
/// 🤯有以下幾種不同的服務品質（優先度由高到低排序）：
/// userInteractive 使用者交互的服務品質，例如動畫、事件處理或更新應用程序的使用者介面。
/// userInitiated 阻止使用者主動使用你的應用程序任務的服務品質。
/// default 默認的服務品質。
/// utility 使用者沒有主動追蹤的服務品質。
/// background 你創建來用於維護或清理任務的服務品質。
/// unspecified 無指定服務品質。
///
/// userInteractive🔴 vs userInteractive🟡: 🔴🟡🔴🟡🔴🟡🔴🟡🔴🟡🔴🟡
/// userInteractive🔴 vs background🟡: 🟡🔴🔴🟡🔴🔴🔴🔴🟡🟡🟡🟡
/// default🔴 vs utility🟡: 🔴🔴🔴🔴🔴🔴🟡🟡🟡🟡🟡🟡
///
/// let queue = DispatchQueue(label: "test", qos: .default, attributes: .concurrent)
/// let queue = DispatchQueue(label: "test", qos: .default, attributes: [.concurrent, .initiallyInactive])
///
///
///
/// 如果有一個長時間的運行任務(ex:網路呼叫)，請在 global queue 或是 background dispatch queue 上運行它
/// 如果有一個網路呼叫，拿到資料時想更新UI，要在DispatchQueue.main
///
/// 設計併發任務時，不要調用阻塞目前執行執行緒程的方法
/// 如過多的執行緒創建，系統可能會耗盡你應用程序中的執行緒
/// 不應該是創建私有併發佇列，而是將任務提交到 DispatchQueue.global 之一
/// 串行任務，將其 target 設置為 DispatchQueue.global 之一
/// 適當的執行緒數量必須要根據裝置上 CPU 核心的數量而定
///
///
/// 查看Thread  print("\(Thread.current) 🟡")

/// Sync
class aViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // 🆎✅ DispatchQueue.global + Serial
        // 輸出：🔴🔴🔴🔴🟡🟡🟡🟡🟢🟢🟢🟢
        // serial queue：任務會按照順序執行
        // sync：等待前一個任務結束後，才會再接著下一個任務，依序進行
        let queue1 = DispatchQueue(label: "test")
        let queue11 = DispatchQueue(label: "test", target: DispatchQueue.global())

        // 🆎✅ DispatchQueue.global + Concurrent
        // 輸出：🔴🔴🔴🔴🟡🟡🟡🟡🟢🟢🟢🟢
        // Concurrent queue：在sync時任務會按照順序執行
        // sync：等待前一個任務結束後，才會再接著下一個任務，依序進行
        let queue2 = DispatchQueue.global()
        let queue22 = DispatchQueue(label: "test", attributes: .concurrent, target: DispatchQueue.global())

        // 🚫死鎖 queue3 主队列不能混入同步任务
        let queue3 = DispatchQueue(label: "test", target: DispatchQueue.main)

        queue1.sync {
            ForTest.forLoop("🔴")
        }
        queue11.sync {
            ForTest.forLoop("🟡")
        }
        ForTest.forLoop("🟢")
    }
}

/// Async
class bViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // 🅿️✅ DispatchQueue.global + Serial
        // 輸出： 🔴🔴🟢🟢🔴🔴🟢🟡🟡🟡🟡🟢、🟢🟢🟢🔴🔴🟢🔴🔴🟡🟡🟡🟡....
        // serial queue：🟡等待前一個🔴任務結束後，才會再接著下一個任務，依序進行
        // Async：🟢不會等待任務完成才運行，🔴🟡任務透過async額外開啟一條執行緒來異步執行任務
        let queue1 = DispatchQueue(label: "test")
        let queue11 = DispatchQueue(label: "test", target: DispatchQueue.global())

        // ✝️✅ DispatchQueue.global + Concurrent
        // 輸出： 🟢🟡🟡🔴🔴🟢🟢🟢🔴🔴🟡🟡、🟢🟢🟡🟢🟢🔴🔴🔴🔴🟡🟡🟡....
        // Concurrent queue：併發佇列，任務幾乎是同時開始的
        // Async：🔴🟡任務透過async額外開啟多個執行緒上運行，彼此間不會相互等待
        let queue2 = DispatchQueue.global()
        let queue22 = DispatchQueue(label: "test", attributes: .concurrent)
        let queue222 = DispatchQueue(label: "test", attributes: .concurrent, target: DispatchQueue.global())

        // 🆎✅ DispatchQueue.main + Serial/Concurrent
        // 輸出： 🟢🟢🟢🟢🔴🔴🔴🔴🟡🟡🟡🟡
        // DispatchQueue.main + Async：main是一個 global serial dispatch queue
        let queue3 = DispatchQueue.main
        let queue33 = DispatchQueue(label: "test", target: DispatchQueue.main)
        let queue333 = DispatchQueue(label: "test", attributes: .concurrent, target: DispatchQueue.main)

        queue1.async {
            ForTest.forLoop("🔴")
        }
        queue1.async {
            ForTest.forLoop("🟡")
        }
        ForTest.forLoop("🟢")
    }
}

/// dispatch groups
/// 更方便的等待機制
/// 當我們必須等待一個或一個以上的 thread 處理完工作後，再去執行某件事時，就可使用此機制來達成
/// 1️⃣是 queue 裡的工作項目都是很單純的個別子執行緒
/// 2️⃣是 queue 裡的工作項目除了都是個別的子執行緒外，每個子執行緒裡又有子執行緒
class cViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let group: DispatchGroup = DispatchGroup()

        /// 1️⃣的範例－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
//        // 事件🟡
//        let queue1 = DispatchQueue(label: "queue1", attributes: .concurrent)
//        queue1.async(group: group) {
//            ForTest.forLoop("🟡")
//        }
//        // 事件🟢
//        let queue2 = DispatchQueue(label: "queue2", attributes: .concurrent)
//        queue2.async(group: group) {
//            // 事件B
//            ForTest.forLoop("🟢")
//        }
//
//        group.notify(queue: DispatchQueue.main) {
//            // 已處理完事件A和事件B
//            print("處理完成事件🟡和事件🟢...")
//        }
        /// －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－



        /// 2️⃣的範例－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
        let queue3 = DispatchQueue(label: "queue1", attributes: .concurrent)
        group.enter() // 開始呼叫 API1
        queue3.async(group: group) {
            // Call 後端 API1
            ForTest.forLoop("🟡")
            // 結束呼叫 API1
            group.leave()
        }

        let queue4 = DispatchQueue(label: "queue2", attributes: .concurrent)
        group.enter() // 開始呼叫 API2
        queue4.async(group: group) {
            // Call 後端 API2
            ForTest.forLoop("🟢")
            // 結束呼叫 API2
            group.leave()
        }

        group.notify(queue: DispatchQueue.main) {
            // 完成所有 Call 後端 API 的動作
            print("完成所有 Call 後端 API 的動作...")
        }
        /// －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
    }
}


/// 特殊題 自定义concurrent队列嵌套同步任务，不會引起🚫死鎖
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
/// if A = async; B = sync. A包A|A包B|B包A||B包B 都不會死鎖
/// 🔸A包A輸出： 🟢🟡會一起等待🔵(🟢稍快出現); 🔴🟣會等待🟡結束; 其餘不會互相等待;
///  EX:🔵🔵🔵🔵🟢🟡🟢🟡🟡🟡🟢🔴🟣🟢🔴🟣🔴🔴🟣🟣
///
/// 🔸A包B輸出： 🟢🟡會一起等待🔵(🟢稍快出現); 🟣會等待🔴結束; 🔴會等待🟡結束; 🟢不會等待;
///  EX:🔵🔵🔵🔵🟢🟡🟢🟡🟡🟡🔴🟢🔴🔴🔴🟣🟢🟣🟣🟣
///
/// 🔸B包A輸出： 🟡會等待🔵; 🔴🟣會一起等待🟡(🟣稍快出現); 🟢會等待🟣;
///  EX:🔵🔵🔵🔵🟡🟡🟡🟡🟣🟣🔴🟣🟣🔴🟢🔴🟢🔴🟢🟢
///
/// 🔸B包B輸出： 🟡會等待🔵; 🔴會等待🟡; 🟣會等待🔴; 🟢會等待全部結束;
///  EX:🔵🔵🔵🔵🟡🟡🟡🟡🔴🔴🔴🔴🟣🟣🟣🟣🟢🟢🟢🟢
///
/// 🔸如果A包A是在main上，其餘🚫死鎖
///  EX:🔵🔵🔵🔵🟢🟢🟢🟢🟡🟡🟡🟡🟣🟣🟣🟣🔴🔴🔴🔴
        
        let concurrentQueue = DispatchQueue(label: "concurrent", attributes: .concurrent)
        ForTest.forLoop("🔵")
        concurrentQueue.async {
            ForTest.forLoop("🟡")
            concurrentQueue.async {
                ForTest.forLoop("🔴")
            }
            ForTest.forLoop("🟣")
        }
        ForTest.forLoop("🟢")
    }
}

/// 特殊題 🚫 以下是死鎖（deadlock）範例 自定义serial队列嵌套同步任务
class eViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
/// if A = async; B = sync.
/// 🔸main A包B輸出： 🔵🔵🔵🔵🟢🟢🟢🟢🟡🟡🟡🟡死鎖
/// 🔸main B包A｜B包B 輸出： 🔵🔵🔵🔵死鎖
/// 🔸serialQueue12 B包B 輸出： 🔵🔵🔵🔵🟡🟡🟡🟡死鎖
/// 🔸serialQueue12 A包B 輸出： 🔵🔵🔵🔵🟢🟢🟡🟢🟡🟢🟡🟡死鎖
/// 🔸serialQueue12 B包A 輸出： 🔵🔵🔵🔵🟡🟡🟡🟡🟣🟣🟣🟣🟢🟢🔴🟢🔴🟢🔴🔴 唯一不會死鎖
        
        let mainQueue = DispatchQueue.main
        let serialQueue1 = DispatchQueue(label: "serial")
        let serialQueue2 = DispatchQueue(label: "serial", target: DispatchQueue.global())
        ForTest.forLoop("🔵")
        serialQueue2.async {
            ForTest.forLoop("🟡")
            serialQueue2.sync {
                ForTest.forLoop("🔴")
            }
            ForTest.forLoop("🟣")
        }
        ForTest.forLoop("🟢")
    }
    
/// ⚠️死锁結論
/// 线程不在乎任务是同步还是异步，只有队列才在乎，线程不会死锁，只有队列才会死锁
/// 主队列上不能存在同步任务，否则一定会引起死锁
///
/// 🔸主队列添加同步任务会造成死锁的根本原因是
///   1.主队列是串行队列並且只能运行在主线程，它无法去创建新的线程
///   2.主队列没有本事开启后台线程去干别的事情
///   3.主队列一旦混入同步任务，就会跟已经存在的异步任务相互等待，导致死锁
///   ex:正常情况下，主队列上存在源源不断的异步任务（比如用来不断刷新UI的任务，用A表示），此時混入同步任务（用B表示），
///    B在A之后：从时间來看B执行完才能执行A；从空间來看A执行完才能执行B。两个任务都相互等待执行，于是就引起了死锁，导致程序卡死崩溃。
///    A在B之后：主队列上存在源源不断的异步任务，於是還是會死鎖。
///
/// 🔸為何自定义Serial队列添加同步任务不会死锁？
///   1.自定义串行队列有能力启动主线程和后台线程（只能启动一个后台线程）。
///   2.自定义串行队列遇到同步任务，会自动安排在主线程执行；遇到异步任务，自动安排在后台线程执行，所以不会死锁。
///
/// 🔸為何concurrent队列嵌套同步任务，不會引起死鎖呢?
///   1.并行队列有能力启动主线程和后台线程（可以启动一个或多个后台线程，部分设备上可以启动多达64个后台线程）
///   2.并行队列遇到同步任务，会自动安排在主线程执行；遇到异步任务，自动安排在后台线程执行，所以不会死锁。
///
///
}

class ForTest {
    static func forLoop(_ str: String) {
        for _ in 0..<5 {
//            print("\(Thread.current) " + str)
            print(str)
        }
    }
}
