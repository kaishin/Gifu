import UIKit
import Gifu

class ViewController: UIViewController {
  @IBOutlet weak var imageView: GIFImageView!
  @IBOutlet weak var imageDataLabel: UILabel!
  @IBOutlet weak var memoryUsageLabel: UILabel!
  @IBAction func unwindToRootViewController(segue: UIStoryboardSegue) { }

  var currentGIFName: String = "earth" {
    didSet {
      self.animate()
    }
  }

  @IBAction func toggleAnimation(_ sender: AnyObject) {
    if imageView.isAnimatingGIF {
      imageView.stopAnimatingGIF()
      print(imageView.gifLoopDuration)
    } else {
      imageView.startAnimatingGIF()
      print(imageView.gifLoopDuration)
    }
  }

  @IBAction func swapImage(_ sender: AnyObject) {
    let gifs = ["mugen", "earth", "nailed"]
    if let index = gifs.firstIndex(of: currentGIFName) {
      let nextIndex = (index + 1) % gifs.count
      currentGIFName = gifs[nextIndex]
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    imageView.prepareForReuse()
  }

  override func viewDidAppear(_ animated: Bool) {
    self.animate()
    self.memoryUsageLabel.text = "Loading..."
  }

  func animate() {
    imageView.setFrameBufferSize(1)
    imageView.animate(withGIFNamed: currentGIFName, preparationBlock:  {
      DispatchQueue.main.async {
        self.imageDataLabel.text = self.currentGIFName.capitalized + " (\(self.imageView.frameCount) frames / \(String(format: "%.2f", self.imageView.gifLoopDuration))s)"
      }
    }, loopBlock: {
        print("Loop finished")
    })

    if #available(iOS 15.0, *) {
      Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
        DispatchQueue.main.async {
          self.memoryUsageLabel.text = "Memory usage: \(Memory.memoryFootprint()!.formatted(.byteCount(style: .memory)))"
        }
      }
    }
  }
}

class Memory: NSObject {
  // https://forums.developer.apple.com/thread/105088#357415
  class func memoryFootprint() -> Int? {
    let TASK_VM_INFO_COUNT = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
    let TASK_VM_INFO_REV1_COUNT = mach_msg_type_number_t(MemoryLayout.offset(of: \task_vm_info_data_t.min_address)! / MemoryLayout<integer_t>.size)

    var info = task_vm_info_data_t()
    var count = TASK_VM_INFO_COUNT

    let kr = withUnsafeMutablePointer(to: &info) { infoPtr in
      infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
        task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), intPtr, &count)
      }
    }

    guard
      kr == KERN_SUCCESS,
      count >= TASK_VM_INFO_REV1_COUNT
    else { return nil }

    let usedBytes = Float(info.phys_footprint)
    return Int(usedBytes)
  }
}
