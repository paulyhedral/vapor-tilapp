import App
import Vapor

var env = try Environment.detect()
print(env)
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }
try configure(app)
// Configure custom hostname.
app.http.server.configuration.hostname = "0.0.0.0"
try app.run()
