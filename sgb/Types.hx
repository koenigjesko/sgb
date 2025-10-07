package sgb;

import haxe.io.Input;
import haxe.io.Output;

final class ServerIP {
    public var octet_1(default, null): Int;
    public var octet_2(default, null): Int;
    public var octet_3(default, null): Int;
    public var octet_4(default, null): Int;

    public function new(
        octet_1: Int, 
        octet_2: Int, 
        octet_3: Int, 
        octet_4: Int
    ) {
        for (octet in [octet_1, octet_2, octet_3, octet_4]) {
            if (octet < 0 || octet > 255) {
                throw InvalidIPAddress("Each octet of an IP address must be valid.");
            }
        }

        this.octet_1 = octet_1; 
        this.octet_2 = octet_2;
        this.octet_3 = octet_3;
        this.octet_4 = octet_4;
    }

    @:to
    public inline function toString(): String {
        var ipString = '$octet_1.$octet_2.$octet_3.$octet_4';

        if (ipString == "0.0.0.0") {
            return "localhost";
        }

        return ipString;
    }
}

abstract ServerPort(Int) {
    @:from
    public static function fromInt(number: Int): ServerPort {
        if (Std.string(number).length != 4) {
            throw InvalidPort("The port must be 4 characters long.");
        }

        return new ServerPort(number);
    }

    @:to
    public function toInt(): Int {
        return this;
    }

    public inline function new(number: Int) {
        this = number;
    }

    public inline function forConcat(): String {
        return ':$this';
    }
}

abstract MaxConnections(Int) {
    @:from
    public static function fromInt(number: Int): MaxConnections {
        if (number <= 0 || number > 10) {
            throw ValueError("The maximum connections value must be in the range from 1 to 10.");
        }

        return new MaxConnections(number);
    }

    @:to
    public function toInt(): Int {
        return this;
    }

    public inline function new(number: Int) {
        this = number;
    }
}

enum RequestType {
    Get;
    Post;
    Unhandled;
}

enum RequsetPath {
    Root;
    Upload;
    Another;
}

typedef RequestData = {
    public var input(default, null): Input;
    public var headers(default, null): Map<String,String>;
    public var output(default, null): Output;
    public var method(default, null): RequestType;
    public var path(default, null): RequsetPath;
}

enum SGBErrors {
    InvalidIPAddress(message: String);
    InvalidPort(message: String);
    ValueError(message: String);
}
