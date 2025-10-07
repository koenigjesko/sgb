# sgb (3D Souvenirs Generator backend server implementaton.)
Currently, it is possible to interact with a GET request to the root path and a POST request to the `/upload` path.

# Implemented API functionality
|  Path   | Method | Any type of data |
|:-------:|:------:|:----------------------------------------------------------------------------:|
| `/` | **GET** | None. There will be a instrution about using the **POST** method in the correct way. Returns 501 code. |
| `/upload` | **POST** | Optioinal* image (jpg/`png?`). Returns 200 code if correct image provided. |

\* - means that if argument is not provided, method won't return success code.

# Build and running
For easy **launching and interpretation**, make sure you have the [latest version of Haxe tools](https://haxe.org/download/) installed on your PC. If everything is like this, use the command in the root of project:
```bat
haxe -main sgb/Main.hx --interp
```

**To build and compile** project with NekoVM into executable use:
```bat
haxe build.hxml | neko bin/main.n
```

More compilation targets will be added later.

###### Detailed documentation and code comments will be compiled later. Optional transpilation to Python, C++, Java, and other popular languages ​​is available.
