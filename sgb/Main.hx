package sgb;

import sgb.Server.ApiServer;
import sgb.Types.MaxConnections;
import sgb.Types.ServerIP;
import sgb.Types.ServerPort;

final class Main {
    public static function main(): Void {
        // Later, data synchronization with the database or environment files is required.
        var serverIP = new ServerIP(0, 0, 0, 0);
        var serverPort: ServerPort = 8080;
        var maxConnections: MaxConnections = 10; // This might discussed!

        var server = new ApiServer(serverIP, serverPort, maxConnections);

        server.startListening();
    }
}
