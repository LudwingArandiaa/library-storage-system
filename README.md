# Library Storage System 📚

This is a C++ terminal-based program that uses `mariadb-connector-c` with MariaDB to manage a library storage system. It allows users to register book loans and applies penalties for late returns.

## 📌 Features

- Connects to a MariaDB database.
- Registers book loans.
- Manages penalties for overdue returns.
- Command-line interface.

## 🚀 Requirements

Before running the program, make sure you have the following installed:

- **MariaDB** (database and server)
- **MariaDB Connector/C**
- **CMake** and a C++ compiler (such as `g++` or `clang`)

On Debian-based systems (like Ubuntu or Zorin OS), you can install them with:

```sh
sudo apt update
sudo apt install mariadb-server mariadb-client libmariadb-dev cmake g++
```

## ⚙️ Instalation

### 1. Clone this repository:
```sh
git clone https://github.com/LudwingArandiaa/library-storage-system.git
cd library-storage-system
```

### 2. Create the database by executing the included SQL script:
```sh
mysql -u root -p < database.sql
```

### 3.Compile the program:
```sh
g++ main.cpp -o main -lmariadb
```

### 4. Run the program:
```sh
./main
```

## 📬 Contact
Let me know if you'd like any modifications! 🚀
