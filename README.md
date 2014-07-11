# MySQL Docker Container

This is a docker container for MySQL 5.6. It is designed to be configurable
with ease and to allow for persistent storage on the host (optional).

The default configuration is intentionally minimal.

## Testing

Without any special configuration, you should be able to start the container
and connect to it on port 3306.

```
-bash$ docker run -d -p 3306:3306 d11wtq/mysql
abcdef1234567890abcdef1234567890abcdef1234567890ab

-bash$ nc -z localhost 3306
Connection to localhost port 3306 [tcp] succeeded!
```

A more complete test can be done by testing the server-client interaction:

```
-bash$ docker run -d --name server d11wtq/mysql
abcdef1234567890abcdef1234567890abcdef1234567890ab

-bash$ docker run -ti \
>   --link server:server \
>   d11wtq/mysql \
>   mysql -h server -u root

Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 1
Server version: 5.6.19 Source distribution

Copyright (c) 2000, 2014, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| test               |
+--------------------+
4 rows in set (0.00 sec)

mysql>
```

## Configuration

The container runs mysqld_safe in the foreground under a user called 'default'.
The data directory is stored at /mysql/data, and a minimal my.cnf is stored at
/mysql/my.cnf.

The 'root' user does not have a password.

For convenience, there is an empty database called 'db' and a passwordless user
called 'db' that has full privileges on this database (but not any others).  It
is advised to use this for application integration.

To adjust the configuration of MySQL, you can add \*.cnf files to
/mysql/my.cnf.d/, either by mounting a volume, or by using this image as a base
image.

The data directory is lazily initialized on container startup, unless it is
already initialized. This allows you to mount /mysql/data as a volume if you
need long-lived persistence on the host.

Logs are written to stdout and stderr.

## Example Usage

### Server

The following runs the mysqld, keeping the data directory on the host and
supplying configuration to enable the FEDERATED engine.

```
-bash$ docker run -d \
>   --name mysql \
>   -v $(pwd)/data:/mysql/data \
>   -v $(pwd)/conf.d:/mysql/my.cnf.d \
>   d11wtq/mysql
abcdef1234567890abcdef1234567890abcdef1234567890ab
-bash$
```

The shared volume conf.d/ contains a file named 'federated.cnf' with the
contents:

``` config
[mysqld]

federated = ON
```

The shared volume data/ is initially empty, but will be initialized by the
container.

### Client Access

If you need to try something in the MySQL client, the intended way to do this
is to use two containers in a client-server setup. Start the server container
with a name, then start a second container linking to that name, but running
'bash', or 'mysql' instead of the default server startup script.

Connecting a client to the above server would look like this:

```
-bash$ docker run -ti \
>   --link mysql:server \
>   d11wtq/mysql \
>   mysql -h server -u root

Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 1
Server version: 5.6.19 Source distribution

Copyright (c) 2000, 2014, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```

If you really want to work in a single container, you can run
/usr/local/bin/start_mysqld from a bash shell in the container. Press Ctrl-\\
(Ctrl-Backslash) to stop the server.
