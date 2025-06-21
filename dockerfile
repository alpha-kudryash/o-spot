FROM ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && 
    apt-get install -y apache2 && 
    apt-get clean && 
    rm -rf varlibaptlists

RUN rm -rf varwwwhtml && 
    ln -s mntres varwwwhtml

EXPOSE 80

CMD [usrsbinapache2ctl, -D, FOREGROUND]
