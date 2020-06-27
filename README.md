# Intermediate Docker image of Dancer2 with TemplateToolkit and Gazelle

This is an intermediary Docker image providing Dancer2, the Gazelle plack 
server and Dancer2's TemplateToolkit plugin.   It can be used as a base
for other images.  This can just be viewed as a 'timesaving' image, reducing
the necessity of taking the time to (continually) redeploy Dancer. 

There is also an eample `Dockerfile.devel` here which can be used to create a 
'development' image.  This adds in bash, git, and emacs and will install the
Data::Dunper and Devel::NYTProf modules.  If using this it would be bset to 
mount your application directory in the container.


# A brief walk through of using the `devel` template
This example assumes that you already have a Dancer application under 
development on your work directory:

```bash
[ben@BenFlex5~/projects/dancer2-hello]$ ls
.  ..  cpanfile  cpanfile.snapshot  Dancer2-Hello  Dockerfile  local
[ben@BenFlex5~/projects/dancer2-hello]$ ls Dancer2-Hello/
.  ..  bin  config.yml  cpanfile  .dancer  environments  lib  Makefile.PL  MANIFEST  MANIFEST.SKIP  public  t  views
```

Now, start the container, forwarding port 5000 and mounting the Dancer2-Hello
directory shown above, start the app, etc:

```bash
[ben@BenFlex5~/projects/dancer2-hello]$ docker run i -p 5000:5000 -v ~/projects/dancer2-hello/Dancer2-Hello:/home/perl/Dancer2-Hello whosgonna/dancer2-tt-gazelle:devel
bash-5.0$ ls
  Dancer2-Hello      app                cpanfile           cpanfile.snapshot  local
bash-5.0$ carton exec plackup --server Gazelle -p 5000 Dancer2-Hello/bin/app.psgi
  Plack::Handler::Gazelle: Accepting connections at http://0:5000/
  [Dancer2::Hello:9] core @2020-06-27 15:06:22> looking for get / in /home/perl/local/lib/perl5/Dancer2/Core/App.pm l. 35
```


However, this development container should not be used as the source image for the
final project.  To finish this for release, first make sure that the copy of the
cpanfile and cpanfile.snapshot on *your computer* have been updated.  Then 
create a Dockerfile like this:

```dockerfile
### Package deps, for build and devel phases
FROM whosgonna/dancer2-tt-gazelle:build AS build

## Install all of the perl modules:
COPY cpanfile* /home/perl/
RUN cpm install --workers 16 --without-develop --without-configure --with-suggests \
    && carton install --without 'develop,configure'




### Final phase: the runtime version - notice that we start from the base perl image.
FROM whosgonna/perl-runtime:latest

## Set any environmental variables here.
ENV PLACK_ENV=production

## If any software packages are needed in the final image, here's where they go.
#RUN apk --no-cache add mariadb-client

## Copy the local directory with the perl libraries, copy the cpan files, and re-run
## cpm and carton to finalize things:
COPY --from=build /home/perl/local/ /home/perl/local/

COPY cpanfile* /home/perl/
RUN cpm install --workers 16 --without-develop --without-configure --with-suggests \
    && carton install --without 'develop,configure'



COPY ./Dancer2-Hello/ Dancer2-Hello

CMD  carton exec plackup -p  5000 --server Gazelle /home/perl/Dancer2-Hello/bin/app.psgi
```

The server can then be run with the following command:

```bash
docker run -it -p 5000:5000 -d whosgonna/dancer2-hello
```

