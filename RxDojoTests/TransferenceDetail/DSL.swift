import Quick
import Nimble
import RxSwift

func given(_ description: String, flags: FilterFlags = [:], closure: @escaping () -> Void) {
    context(description, flags: flags, closure: closure)
}

func when(_ description: String, flags: FilterFlags = [:], closure: @escaping () -> Void) {
    describe(description, flags: flags, closure: closure)
}

func then(_ description: String, flags: FilterFlags = [:], closure: @escaping () -> Void) {
    it(description, flags: flags, closure: closure)
}

func and(_ description: String, flags: FilterFlags = [:], closure: @escaping () -> Void) {
    context(description, flags: flags, closure: closure)
}
