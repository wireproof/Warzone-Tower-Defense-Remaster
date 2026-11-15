import SwiftUI
import WebKit
import Network

@main struct WarzoneTDApp: App {
    var body: some Scene { WindowGroup { GameView().ignoresSafeArea().statusBarHidden(true) } }
}
final class LocalServer {
    private let queue = DispatchQueue(label: "com.wireproof.warzonetd.server")
    private var listener: NWListener?
    var onReady: ((URL) -> Void)?
    func start() throws {
        let params = NWParameters.tcp
        params.requiredLocalEndpoint = .hostPort(host: "127.0.0.1", port: .any)
        let listener = try NWListener(using: params); self.listener = listener
        listener.stateUpdateHandler = { [weak self, weak listener] state in
            guard case .ready = state, let port = listener?.port?.rawValue,
                  let url = URL(string: "http://127.0.0.1:\(port)/index.html") else { return }
            DispatchQueue.main.async { self?.onReady?(url) }
        }
        listener.newConnectionHandler = { [weak self] connection in self?.serve(connection) }
        listener.start(queue: queue)
    }
    private func serve(_ connection: NWConnection) {
        connection.start(queue: queue)
        connection.receive(minimumIncompleteLength: 1, maximumLength: 8192) { data, _, _, _ in
            let line = data.flatMap { String(data: $0, encoding: .utf8) }?.components(separatedBy: "\r\n").first ?? ""
            let parts = line.split(separator: " ")
            let path = parts.count > 1 ? String(parts[1].split(separator: "?").first ?? "") : ""
            let name = String(path.drop(while: { $0 == "/" }))
            let allowed = !name.isEmpty && !name.contains("/") && !name.contains("..")
            let url = allowed ? Bundle.main.resourceURL?.appendingPathComponent("Web").appendingPathComponent(name) : nil
            let payload = url.flatMap { try? Data(contentsOf: $0) }
            let type: String
            switch url?.pathExtension { case "html": type = "text/html; charset=utf-8"; case "js": type = "text/javascript"; case "wasm": type = "application/wasm"; case "swf": type = "application/x-shockwave-flash"; default: type = "application/octet-stream" }
            let body = payload ?? Data("Not found".utf8)
            let header = "HTTP/1.1 \(payload == nil ? "404 Not Found" : "200 OK")\r\nContent-Type: \(type)\r\nContent-Length: \(body.count)\r\nCache-Control: no-store\r\nConnection: close\r\n\r\n"
            var response = Data(header.utf8); response.append(body)
            connection.send(content: response, completion: .contentProcessed { _ in connection.cancel() })
        }
    }
}
struct GameView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator { Coordinator() }
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration(); config.mediaTypesRequiringUserActionForPlayback = []
        config.userContentController.add(context.coordinator, name: "status")
        let web = WKWebView(frame: .zero, configuration: config); web.isOpaque = false; web.backgroundColor = .black
        web.scrollView.isScrollEnabled = false; web.navigationDelegate = context.coordinator
        context.coordinator.server.onReady = { [weak web] url in web?.load(URLRequest(url: url)) }
        do { try context.coordinator.server.start() } catch { web.loadHTMLString("<h2>Could not start game</h2>", baseURL: nil) }
        return web
    }
    func updateUIView(_ view: WKWebView, context: Context) {}
    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        let server = LocalServer()
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) { NSLog("Warzone: %@", String(describing: message.body)) }
        func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            let url = action.request.url; decisionHandler(url?.host == "127.0.0.1" || url?.scheme == "about" ? .allow : .cancel)
        }
    }
}
