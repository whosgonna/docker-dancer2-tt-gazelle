## This is based off of the perl BUILD image.  It will not be expored and 
## merged with the runtime image because it is intended to be a 'stack'
## image.  Dancer2, Gazelle, and TemplateToolkit will be installed so that
## this image can be used as a base build image for Dancer2 applications.
## when dockerizing THOSE applications, they should be merged back into the
## runtime image.
FROM whosgonna/perl-build:latest


## Copy the cpanfiles and install the perl modules.  This would also be a good
## time to add any additional software packages if they're required.  Note that
## the cpm command is a bit more complex.  We want to install the base required
## and suggested modules:
COPY cpanfile* /home/perl
RUN cpm install --no-prebuilt --workers 16 --without-develop --without-configure --with-suggests \
    && carton install --without 'develop,configure'


