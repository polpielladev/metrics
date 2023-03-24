import Compute

let router = Router()

router.post("/") { request, response in
    try await response.status(200).write("Hello world!")
}

try await router.listen()
