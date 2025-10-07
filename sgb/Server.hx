package sgb;

import haxe.io.Bytes;
import haxe.Http;
import haxe.Json;
import sys.io.File;
import sys.net.Host;
import sys.net.Socket;

import sgb.Types.MaxConnections;
import sgb.Types.RequestData;
import sgb.Types.RequsetPath;
import sgb.Types.RequestType;
import sgb.Types.ServerIP;
import sgb.Types.ServerPort;

final class ApiServer {
    public final ip: ServerIP;
    public final port: ServerPort;
    public final maxConnetions: MaxConnections;

    public function new(ip: ServerIP, port: ServerPort, maxConnetions: MaxConnections) {
        this.ip = ip;
        this.port = port;
        this.maxConnetions = maxConnetions;
    }

    public function startListening(): Void {
        var socket = new Socket();
        var host = new Host(this.ip.toString());

        socket.bind(host, this.port);
        socket.listen(this.maxConnetions);

        trace("Server started on http://" + this.ip.toString() + this.port.forConcat()); // Sys.println() may be?

        while (true) {
            var request = socket.accept();
            handleRequest(request);
        }
    }

    public function handleRequest(socket: Socket): Void {
        try {
            var data = defineRequestData(socket);     

            switch (data.method) {
                case Post:
                    handlePostRequest(data);
                case Get:
                    handleGetRequest(data);
                default:
                    trace("Another request methods in not implemented.");
            }
        } catch (error) {
            trace(error);
        }

        socket.close();
    }

    private function defineRequestData(socket: Socket): RequestData {
        var line = socket.input.readLine();
        var parts = line.split(" ");

        var method = switch (parts[0]) {
            case "POST": 
                Post;
            case "GET":
                Get;
            default:
                Unhandled;
        };
        var path = switch (parts[1]) {
            case "/":
                Root;
            case "/upload":
                Upload;
            default:
                Another;
        };

        var headers = new Map<String,String>();

        while (true) {
            var localQuery = socket.input.readLine();

            if (localQuery.length == 0) {
                break;
            }

            var index = localQuery.indexOf(":");

            if (index > 0) {
                headers.set(
                    localQuery.substr(0, index).toLowerCase(), 
                    localQuery.substr(index + 1)
                );
            }
        }

        return {
            input: socket.input,
            headers: headers,
            output: socket.output,
            method: method,
            path: path
        };
    }

    private function handlePostRequest(data: RequestData): Void {
        if (data.path == Upload) {
            var len = Std.parseInt(data.headers.get("content-length"));
            var body = Bytes.alloc(len);

            data.input.readFullBytes(body, 0, len);
            
            var imageFilePath = "upload.jpg";
            File.saveBytes(imageFilePath, body); // Create a system for downloading and storing photos.
            var result = sendTo3DAPI(imageFilePath);

            var json = Json.stringify(result);
            data.output.writeString("HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r\n");
            data.output.writeString(json);
        }
    }

    private function handleGetRequest(data: RequestData): Void {
        data.output.writeString("HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\n");
        data.output.writeString("Use POST /upload to send image.");
    }

    /**
     * This method is a stopgap. It needs to be rewritten from scratch.
     **/
    function sendTo3DAPI(imagePath: String): String {
        var http = new Http("https://api.example.com"); // Replace with a real API. 

        http.addHeader("Authorization", "API_KEY");
        http.setPostData(imagePath); // You can insert a Base64 file here.
        http.request(true);

        return "Not implemented yet."; // return {status: http.responseStatus, data: http.responseData}
    }
}
