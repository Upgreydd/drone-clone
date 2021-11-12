FROM alpine/git

ADD clone.sh /bin/
RUN chmod +x /bin/clone.sh
ENTRYPOINT /bin/clone.sh
