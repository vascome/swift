// RUN: %target-run-simple-swift( -Xfrontend -disable-availability-checking -parse-as-library) | %FileCheck %s

// REQUIRES: executable_test
// REQUIRES: concurrency

// rdar://76038845
// REQUIRES: concurrency_runtime
// UNSUPPORTED: back_deployment_runtime

// https://bugs.swift.org/browse/SR-14333
// UNSUPPORTED: OS=windows-msvc

class X {
  init() {
    print("X: init")
  }
  deinit {
    print("X: deinit")
  }
}

struct Boom: Error {}

@available(SwiftStdlib 5.1, *)
func test_detach() async {
  let x = X()
  let h = detach {
    print("inside: \(x)")
  }
  await h.get()
  // CHECK: X: init
  // CHECK: inside: main.X
  // CHECK: X: deinit
}

@available(SwiftStdlib 5.1, *)
func test_detach_throw() async {
  let x = X()
  let h = detach {
    print("inside: \(x)")
    throw Boom()
  }
  do {
    try await h.get()
  } catch {
    print("error: \(error)")
  }
  // CHECK: X: init
  // CHECK: inside: main.X
  // CHECK: error: Boom()
}


@available(SwiftStdlib 5.1, *)
@main struct Main {
  static func main() async {
    await test_detach()
    await test_detach_throw()
  }
}
