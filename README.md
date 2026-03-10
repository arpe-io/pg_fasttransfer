# pg_fasttransfer

A PostgreSQL extension to run the [FastTransfer](https://fasttransfer.arpe.io/) tool from an SQL function, enabling fast data transfer between databases.

![Tuto](assets/pg_fasttransfer.gif)

## Table of Contents

* [Prerequisites](#prerequisites)
* [FastTransfer Tool Requirement](#fasttransfer-tool-requirement)
* [Compatibility](#compatibility)
* [Installation](#installation)
  * [Linux](#linux)
  * [Windows](#windows)
* [SQL Setup](#sql-setup)
* [Function: pg\_fasttransfer\_encrypt](#function-pg_fasttransfer_encrypt)
* [Function: xp\_RunFastTransfer\_secure Usage](#function-xp_runfasttransfer_secure-usage)
* [Function Return Structure](#function-return-structure)
* [Notes](#notes)

---

## Prerequisites

* Sudo/Administrator privileges on Linux/Windows to copy files to the PostgreSQL installation directory.
* Your **FastTransfer tool binaries**. This extension requires the tool to be installed separately.

---

## FastTransfer Tool Requirement

This extension requires the **FastTransfer tool** to be installed separately.

Download FastTransfer and get a free trial license here:
👉 https://fasttransfer.arpe.io/start/

Once downloaded, extract the archive and provide the folder path using the `fasttransfer_path` parameter when calling the `xp_RunFastTransfer_secure` SQL function.

⚠️ **Important:** The PostgreSQL server process usually runs under the `postgres` user account.
You must ensure that this user has the appropriate permissions to execute the `FastTransfer` binary and read the license file.

---

### On Linux

* The `FastTransfer` binary must be **executable by the `postgres` user**.
* The license file (`.lic`) must be **readable by the `postgres` user**.

Example:

```bash
# Grant execute permission on the FastTransfer binary
sudo chmod +x /path/to/FastTransfer

# Ensure the postgres user can access it
sudo chown postgres:postgres /path/to/FastTransfer
sudo chmod 750 /path/to/FastTransfer

# Grant read permission on the license file
sudo chown postgres:postgres /path/to/license.lic
sudo chmod 640 /path/to/license.lic
```

---

### On Windows

Make sure that the PostgreSQL service account (by default `NT AUTHORITY\NetworkService` or `postgres` if you installed it manually) has:

* **Execute permission** on the `FastTransfer.exe` binary
* **Read permission** on the `.lic` file

---

## Compatibility

The **pg\_fasttransfer** extension has been tested and validated on the following environments:

### Windows

* PostgreSQL **16**
* PostgreSQL **17**

### Linux (Debian/Ubuntu 22.04 LTS)

* PostgreSQL **15**
* PostgreSQL **16**
* PostgreSQL **17**

⚠️ Other distributions or PostgreSQL versions may work but have not been officially tested.

---

## Installation

This section covers how to install the **pg_fasttransfer** extension.

### Linux

#### Automated Installation

The easiest way to install the extension on Linux is by using the `install-linux.sh` script included in the archive.

1. Extract the contents of the archive into a folder. This folder should contain:

   * `pg_fasttransfer.so`
   * `pg_fasttransfer.control`
   * `pg_fasttransfer--1.0.sql`
   * `install-linux.sh`

2. Make the script executable:

```bash
chmod +x install-linux.sh
```

3. Run the script with administrator privileges:

```bash
sudo ./install-linux.sh
```

The script will automatically detect your PostgreSQL installation and copy the files to the correct locations.

#### Manual Installation

If the automated script fails or you prefer to install the files manually, follow these steps:

1. Stop your PostgreSQL service:

```bash
sudo systemctl stop postgresql
```

2. Locate your PostgreSQL installation directory, typically:

```
/usr/lib/postgresql/<version>
```

3. Copy the files into the appropriate directories:

* `pg_fasttransfer.so` → PostgreSQL `lib` directory
* `pg_fasttransfer.control` and `pg_fasttransfer--1.0.sql` → PostgreSQL `share/extension` directory

Example:

```bash
sudo cp pg_fasttransfer.so /usr/lib/postgresql/<version>/lib/
sudo cp pg_fasttransfer.control pg_fasttransfer--1.0.sql /usr/share/postgresql/<version>/extension/
```

4. Restart your PostgreSQL service:

```bash
sudo systemctl start postgresql
```

---

### Windows

#### Automated Installation

The easiest way to install the extension is by using the `install-win.bat` script included in the archive.

1. Extract the contents of the ZIP file into a folder. This folder should contain the following files:

   * `pg_fasttransfer.dll`
   * `pg_fasttransfer.control`
   * `pg_fasttransfer--1.0.sql`
   * `install-win.bat`

2. Right-click on the `install-win.bat` file and select **"Run as administrator"**.

3. The script will automatically detect your PostgreSQL installation and copy the files to the correct locations.

#### Manual Installation

If the automated script fails or you prefer to install the files manually, follow these steps:

1. Stop your PostgreSQL service.
2. Locate your PostgreSQL installation folder, typically found at:

```
C:\Program Files\PostgreSQL\<version>
```

3. Copy the `pg_fasttransfer.dll` file into the `lib` folder of your PostgreSQL installation.
4. Copy the `pg_fasttransfer.control` and `pg_fasttransfer--1.0.sql` files into the `share\extension` folder.
5. Restart your PostgreSQL service.

---

## SQL Setup

After the files are in place, you need to set up the extension in your database.

### Drop existing extension (if any)

```sql
DROP EXTENSION IF EXISTS pg_fasttransfer CASCADE;
```

### Create the extension

```sql
CREATE EXTENSION pg_fasttransfer CASCADE;
```

---

## Function: pg_fasttransfer_encrypt

This function encrypts a given text string using `pgp_sym_encrypt` and encodes the result in base64.
It is useful for storing sensitive information, such as passwords, in a secure manner within your SQL scripts or configuration.

The `xp_RunFastTransfer_secure` function will automatically decrypt any values passed to its `--sourcepassword` and `--targetpassword` arguments using the same encryption key.
**The encryption/decryption key is defined by the `PGFT_ENCRYPTION_KEY` variable in the C source file (`pg_fasttransfer.c`)**

### Syntax

```sql
pg_fasttransfer_encrypt(text_to_encrypt text) RETURNS text
```

### Example

```sql
SELECT pg_fasttransfer_encrypt('MySecurePassword');
-- Returns: A base64-encoded encrypted string, e.g., "PgP...base64encodedstring=="
```

---

## Function: xp_RunFastTransfer_secure Usage

This is the main function to execute the FastTransfer tool.
It takes various parameters to configure the data transfer operation.

Password arguments (`sourcepassword`, `targetpassword`) will be automatically decrypted.

### Syntax

```sql
xp_RunFastTransfer_secure(
    sourceconnectiontype text DEFAULT NULL,
    sourceconnectstring text DEFAULT NULL,
    sourcedsn text DEFAULT NULL,
    sourceprovider text DEFAULT NULL,
    sourceserver text DEFAULT NULL,
    sourceuser text DEFAULT NULL,
    sourcepassword text DEFAULT NULL, 
    sourcetrusted boolean DEFAULT FALSE,
    sourcedatabase text DEFAULT NULL,
    sourceschema text DEFAULT NULL,
    sourcetable text DEFAULT NULL,
    query text DEFAULT NULL,
    fileinput text DEFAULT NULL,
    targetconnectiontype text DEFAULT NULL,
    targetconnectstring text DEFAULT NULL,
    targetserver text DEFAULT NULL,
    targetuser text DEFAULT NULL,
    targetpassword text DEFAULT NULL, 
    targettrusted boolean DEFAULT FALSE,
    targetdatabase text DEFAULT NULL,
    targetschema text DEFAULT NULL,
    targettable text DEFAULT NULL,
    degree integer DEFAULT NULL,
    method text DEFAULT NULL,
    distributekeycolumn text DEFAULT NULL,
    datadrivenquery text DEFAULT NULL,
    loadmode text DEFAULT NULL,
    batchsize integer DEFAULT NULL,
    useworktables boolean DEFAULT FALSE,
    runid text DEFAULT NULL,
    settingsfile text DEFAULT NULL,
    mapmethod text DEFAULT NULL,
    license text DEFAULT NULL,
    fasttransfer_path text DEFAULT NULL,
    debug boolean DEFAULT FALSE
) RETURNS TABLE
```

---

### Linux Example

```sql
SELECT * FROM xp_RunFastTransfer_secure(
    targetconnectiontype := 'msbulk',
    sourceconnectiontype := 'pgsql',
    sourceserver := 'localhost:5432',
    sourceuser := 'pytabextract_pguser',
    sourcepassword := pg_fasttransfer_encrypt('MyActualPassword'), 
    sourcedatabase := 'tpch',
    sourceschema := 'tpch_1',
    sourcetable := 'orders',
    targetserver := 'localhost,1433',
    targetuser := 'migadmin',
    targetpassword := pg_fasttransfer_encrypt('AnotherSecurePassword'), 
    targetdatabase := 'target_db',
    targetschema := 'tpch_1',
    targettable := 'orders',
    loadmode := 'Truncate',
    license := '/tmp/FastTransfer_linux-x64_v0.13.5/FastTransfer.lic',
    fasttransfer_path := '/tmp/FastTransfer_linux-x64_v0.13.5',
    debug := true
);
```

---

### Windows Example

```sql
SELECT * FROM xp_RunFastTransfer_secure(
    sourceconnectiontype := 'mssql',
    sourceserver := 'localhost',
    sourcepassword := pg_fasttransfer_encrypt('MyWindowsPassword'),
    sourceuser := 'FastLogin',
    sourcedatabase := 'tpch10',
    sourceschema := 'dbo',
    sourcetable := 'orders',
    targetconnectiontype := 'pgcopy',
    targetserver := 'localhost:15433',
    targetuser := 'postgres',
    targetpassword := pg_fasttransfer_encrypt('MyPostgresPassword'), 
    targetdatabase := 'postgres',
    targetschema := 'public',
    targettable := 'orders',
    method := 'Ntile',
    degree := 12,
    distributekeycolumn := 'o_orderkey',
    loadmode := 'Truncate',
    batchsize := 1048576,
    mapmethod := 'Position',
    fasttransfer_path := 'D:\sources\FastTransfer',
    debug := true
);
```

The `debug` parameter is a **boolean flag** that controls whether the full FastTransfer output is returned in the `output` column.

* When `debug := true`, `output` contains the **entire log** from FastTransfer.
* When `debug := false` (default), `output` is an empty string, but `error_message` will still contain any error lines.

---

## Function Return Structure

The function returns a table with the following columns, providing details about the execution:

| Column             | Type    | Description                                     |
| ------------------ | ------- | ----------------------------------------------- |
| exit_code         | integer | The exit code of the FastTransfer process.      |
| output             | text    | The full log output from the FastTransfer tool if the `debug` parameter is at `TRUE`. |
| error_message             | text    | Only the lines containing `ERROR` from the FastTransfer output. Empty if no errors occurred. |
| total_rows        | bigint  | The total number of rows transferred.           |
| total_columns     | integer | The total number of columns transferred.        |
| transfer_time_ms | bigint  | Transfer time in milliseconds.                  |
| total_time_ms    | bigint  | Total execution time in milliseconds.           |

---

## Notes

* The extension uses `pg_config` to locate PostgreSQL paths, so ensure it is available in your **PATH** if you are running the script.  

