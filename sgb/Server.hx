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
import sgb.Types.ResponseCode;
import sgb.Types.ResponseData;
import sgb.Types.ServerIP;
import sgb.Types.ServerPort;

class ServerBase {
    private var ip(default, null): ServerIP;
    private var port(default, null): ServerPort;

    private function new(ip: ServerIP, port: ServerPort) {
        this.ip = ip;
        this.port = port;
    }

    private function getServerUri(): String {
        return "http://" + this.ip.toString() + this.port.forConcat();
    }

    // TODO: Should be moved to next layer... AND REIMPLEMENTED!
    private function sendResponseWithMessage(data: RequestData, code: ResponseCode, printable: Dynamic): Void {
        var responseMessage = code.getMessage();

        data.output.writeString('HTTP/1.1 $code $responseMessage\nContent-Type: plain/text\r\n\r\n');
        data.output.writeString(Std.string(printable));
    }
}

final class ServerApi extends ServerBase {
    public var maxConnetions(default, null): MaxConnections;

    public function new(ip: ServerIP, port: ServerPort, maxConnetions: MaxConnections) {
        super(ip, port); 
        this.maxConnetions = maxConnetions;
    }

    public function startListening(): Void {
        var socket = new Socket();
        var host = new Host(this.ip.toString());

        socket.bind(host, this.port);
        socket.listen(this.maxConnetions);

        Sys.println("Server started on " + this.getServerUri() + "/");

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
            trace(error); // Should this be thrown?
        }

        socket.close();
    }

    private function defineRequestData(socket: Socket): RequestData {
        var line = socket.input.readLine();
        var parts = line.split(" ");

        var method = switch (parts[0]) {
            case "GET":
                Get;
            case "POST": 
                Post;
            default:
                Unhandled;
        };
        var path = switch (parts[1]) {
            case "/upload":
                Upload;
            default:
                Another;
        };

        var headers = new Map<String, String>();

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
            File.saveBytes(imageFilePath, body); // TODO: Create a system for downloading and storing photos.

            var result = sendTo3DAPI(imageFilePath);
            var json = Json.stringify(result);

            sendResponseWithMessage(data, 200, json);
            return;
        }
        
        sendResponseWithMessage(data, 501, 'Upload an image on ${this.getServerUri()}/upload/ to proceed next steps.');
    }

    private function handleGetRequest(data: RequestData): Void {
        sendResponseWithMessage(
            data,
            501,
            'Use POST method with uploading a picture on ${this.getServerUri()}/upload/ path to send image.'
        );
    }

    private function sendTo3DAPI(imagePath: String): ResponseData {
        var http = new Http("https://api.example.com"); // Replace with a real API. 

        http.addHeader("Authorization", "API_KEY");
        http.setPostData(imagePath); // You can insert a Base64 file here.
        http.request(true);

        return { data: http.responseData };
    }
}
