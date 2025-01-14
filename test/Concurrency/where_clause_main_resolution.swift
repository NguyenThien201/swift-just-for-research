// RUN: %target-swift-frontend -disable-availability-checking -D CONFIG1 -dump-ast -parse-as-library %s | %FileCheck %s --check-prefixes=CHECK,CHECK-CONFIG1
// RUN: %target-swift-frontend -disable-availability-checking -D CONFIG1 -dump-ast -parse-as-library -async-main %s | %FileCheck %s --check-prefixes=CHECK,CHECK-CONFIG1-ASYNC
// RUN: %target-swift-frontend -disable-availability-checking -D CONFIG2 -dump-ast -parse-as-library %s | %FileCheck %s --check-prefixes=CHECK,CHECK-CONFIG2
// RUN: %target-swift-frontend -disable-availability-checking -D CONFIG2 -dump-ast -parse-as-library -async-main %s | %FileCheck %s --check-prefixes=CHECK,CHECK-CONFIG2-ASYNC
// RUN: %target-swift-frontend -disable-availability-checking -D CONFIG3 -dump-ast -parse-as-library %s | %FileCheck %s --check-prefixes=CHECK,CHECK-CONFIG3
// RUN: %target-swift-frontend -disable-availability-checking -D CONFIG3 -dump-ast -parse-as-library -async-main %s | %FileCheck %s --check-prefixes=CHECK,CHECK-CONFIG3-ASYNC

// REQUIRES: concurrency

protocol AppConfiguration { }

struct Config1: AppConfiguration {}
struct Config2: AppConfiguration {}
struct Config3: AppConfiguration {}

protocol App {
    associatedtype Configuration: AppConfiguration
}

// Load in the source file name and grab line numbers for default main funcs
// CHECK: (source_file "[[SOURCE_FILE:[^"]+]]"
// CHECK: (extension_decl range={{\[}}[[SOURCE_FILE]]:{{[0-9]+}}:{{[0-9]+}} - line:{{[0-9]+}}:{{[0-9]+}}{{\]}} App where
// CHECK: (extension_decl range={{\[}}[[SOURCE_FILE]]:{{[0-9]+}}:{{[0-9]+}} - line:{{[0-9]+}}:{{[0-9]+}}{{\]}} App where
// CHECK: (extension_decl range={{\[}}[[SOURCE_FILE]]:{{[0-9]+}}:{{[0-9]+}} - line:{{[0-9]+}}:{{[0-9]+}}{{\]}}
// CHECK-NOT: where
// CHECK-NEXT: (func_decl range={{\[}}[[SOURCE_FILE]]:[[DEFAULT_ASYNCHRONOUS_MAIN_LINE:[0-9]+]]:{{[0-9]+}} - line:{{[0-9]+}}:{{[0-9]+}}{{\]}} "main()"
// CHECK-SAME: interface type='<Self where Self : App> (Self.Type) -> () async -> ()'
// CHECK: (func_decl range={{\[}}[[SOURCE_FILE]]:[[DEFAULT_SYNCHRONOUS_MAIN_LINE:[0-9]+]]:{{[0-9]+}} - line:{{[0-9]+}}:{{[0-9]+}}{{\]}} "main()"
// CHECK-SAME: interface type='<Self where Self : App> (Self.Type) -> () -> ()'


extension App where Configuration == Config1 {
// CHECK-CONFIG1: (func_decl implicit "$main()" interface type='(MainType.Type) -> () -> ()'
// CHECK-CONFIG1: [[SOURCE_FILE]]:[[# @LINE+1 ]]
    static func main() { }

// CHECK-CONFIG1-ASYNC: (func_decl implicit "$main()" interface type='(MainType.Type) -> () async -> ()'
// CHECK-CONFIG1-ASYNC: [[SOURCE_FILE]]:[[DEFAULT_ASYNCHRONOUS_MAIN_LINE]]
}

extension App where Configuration == Config2 {
// CHECK-CONFIG2: (func_decl implicit "$main()" interface type='(MainType.Type) -> () -> ()'
// CHECK-CONFIG2: [[SOURCE_FILE]]:[[DEFAULT_SYNCHRONOUS_MAIN_LINE]]

// CHECK-CONFIG2-ASYNC: (func_decl implicit "$main()" interface type='(MainType.Type) -> () async -> ()'
// CHECK-CONFIG2-ASYNC: [[SOURCE_FILE]]:[[# @LINE+1 ]]
    static func main() async { }
}

extension App {
// CHECK-CONFIG3-ASYNC: (func_decl implicit "$main()" interface type='(MainType.Type) -> () async -> ()'
// CHECK-CONFIG3-ASYNC: [[SOURCE_FILE]]:[[# @LINE+1 ]]
    static func main() async { }

// CHECK-CONFIG3: (func_decl implicit "$main()" interface type='(MainType.Type) -> () -> ()'
// CHECK-CONFIG3: [[SOURCE_FILE]]:[[# @LINE+1 ]]
    static func main() { }
}

@main
struct MainType : App {

#if CONFIG1
    typealias Configuration = Config1
#elseif CONFIG2
    typealias Configuration = Config2
#elseif CONFIG3
    typealias Configuration = Config3
#endif
}
