EZID Docker
===========

Source for building EZID service docker image.

The application itself is a Django app and has many dependencies.
`pyenv` is used to provide a level of python library version
independence, and as such it is necessary to install the build tools in
the image to provide the expected python and library versions.

Notes
-----

Building the image (set appropriate values for `ADMIN_PASSWORD` and
`DB_PASSWORD`):

    docker build \
      --tag base_aws:1.0 \
      --build-arg GIT_BRANCH=docker-setup \
      --build-arg ADMIN_PASSWORD=admin \
      --build-arg DB_PASSWORD=db_password \
      .

Create and run container (web server will listen on 18080 when started):

    docker run --publish 18080:18080 -it --name aw_ezid_1 base_aws:1.0

To start the apache server in the Docker container:

    # su - ezid
    [ezid]$ ~/etc/init.d/httpd start

Restart container:

    docker start -ia aw_ezid_1

Remove container:

    docker container rm aw_ezid_1

List images:

    docker images  

Remove an image:

    docker image rm HASH

MariaDB
-------

Get instance of MariaDB running and clone content from stage or dev
database. \[1\].

    docker pull mariadb/server:10.4
    docker run -d --name ezid_maria -e MARIADB_ROOT_PASSWORD=my_root_passwd mariadb/server:10.4

`docker run --name ezid-mariadb \            -e MYSQL_ROOT_PASSWORD=my-secret-pw             -d mariadb:10`

To access the database service from the container, use the special DNS
name for the host. \[2\] .OS X e.g.:

    mysql -h docker.for.mac.host.internal -u root -p

### Copying the database

Create a dump of the database using `mysqldump` \[3\]. Hint: This can be
done on your localhost by opening a tunnel to the dev or stage instance
of EZID.

    mysqldump -h ${DB_HOST} \
      -u ezidrw \
      -p \
      --single-transaction \
      --databases ezid > ezid_dump.sql

References
----------

<div id="refs" class="references">

<div id="ref-InstallingUsingMariaDB">

\[1\] “Installing and Using MariaDB via Docker,” *MariaDB
KnowledgeBase*.
<https://mariadb.com/kb/en/installing-and-using-mariadb-via-docker/>
(accessed Aug. 26, 2020).

</div>

<div id="ref-HowAccessHost">

\[2\] “How to access host port from docker container,” *Stack Overflow*.
<https://stackoverflow.com/questions/31324981/how-to-access-host-port-from-docker-container>
(accessed Aug. 26, 2020).

</div>

<div id="ref-MySQLMySQLReference">

\[3\] “MySQL :: MySQL 8.0 Reference Manual :: 4.5.4 mysqldump — A
Database Backup Program.”
<https://dev.mysql.com/doc/refman/8.0/en/mysqldump.html> (accessed Aug.
26, 2020).

</div>

</div>
