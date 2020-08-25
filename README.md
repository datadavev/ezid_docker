# EZID Docker

Source for building EZID service docker image.

The application itself is a Django app and has many dependencies. `pyenv` is 
used to provide a level of python library version independence, and as such
it is necessary to install the build tools in the image to provide the expected
python and library versions.

## Notes

Building the image:

```
docker build --tag base_aws:1.0 .
```

Create container:

```
docker run --publish 18080:18080 -it --name aw_ezid_1 base_aws:1.0
```

Restart container:

```
docker start -ia aw_ezid_1
```

Remove container:

```
docker container rm aw_ezid_1
```

List images:

```
docker images  
```

Remove an image:

```
docker image rm HASH
```
