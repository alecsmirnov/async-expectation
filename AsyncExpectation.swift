//
//  AsyncExpectation.swift
//  AsyncExpectation
//
//  Created by Alexander Smirnov.
//

private enum Constants {
    static let nanosecondsInSecond: UInt64 = 1_000_000_000
}

enum AsyncExpectationDurationKind {
    case seconds(UInt64)
    case nanoseconds(UInt64)
}

actor AsyncExpectation {
    private var waitTask: Task<Void, Error>?

    nonisolated func fulfill() {
        Task {
            await waitTask?.cancel()
        }
    }

    func wait(durationKind: AsyncExpectationDurationKind) async throws {
        let duration: UInt64 = switch durationKind {
            case let .seconds(duration):
                duration * Constants.nanosecondsInSecond
            case let .nanoseconds(duration):
                duration
        }

        waitTask = Task {
            try await Task.sleep(nanoseconds: duration)
        }

        try await waitTask?.value
    }
}
