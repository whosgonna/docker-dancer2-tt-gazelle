## Create the build image. This image will be a base image for future Dancer2
## applications.
FROM whosgonna/perl-alt:latest-build AS build

## Copy things to be used in multiple future images to the /stack directory.
## and then build them.
COPY cpanfile* /stack/
RUN cd /stack && pdi-build-deps --stack


## Now create a new image based off of the runtime image and copy over the 
## /stack directory so our dependancies are present.

FROM whosgonna/perl-alt:latest-runtime

COPY --from=build /stack /stack/
