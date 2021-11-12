FROM alpine/git

ADD clone.sh clone-commit.sh clone-pull-request.sh clone-tag.sh /bin/
RUN chmod +x /bin/clone.sh /bin/clone-commit.sh /bin/clone-pull-request.sh /bin/clone-tag.sh
ENTRYPOINT /bin/clone.sh
