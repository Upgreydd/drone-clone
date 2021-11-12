#!/bin/sh

if [[ -n "${DRONE_WORKSPACE}" ]]; then
	cd ${DRONE_WORKSPACE}
fi

if [[ ! -z "${DRONE_NETRC_MACHINE}" ]]; then
	cat <<EOF > ${HOME}/.netrc
machine ${DRONE_NETRC_MACHINE}
login ${DRONE_NETRC_USERNAME}
password ${DRONE_NETRC_PASSWORD}
EOF
fi

if [[ ! -z "${DRONE_SSH_KEY}" ]]; then
	mkdir ${HOME}/.ssh
	echo -n "$DRONE_SSH_KEY" > ${HOME}/.ssh/id_rsa
	chmod 600 ${HOME}/.ssh/id_rsa

	touch ${HOME}/.ssh/known_hosts
	chmod 600 ${HOME}/.ssh/known_hosts
	ssh-keyscan -H ${DRONE_NETRC_MACHINE} > /etc/ssh/ssh_known_hosts 2> /dev/null
fi

if [[ ! -z "$DRONE_AWS_ACCESS_KEY" ]]; then
	aws configure set aws_access_key_id $DRONE_AWS_ACCESS_KEY
	aws configure set aws_secret_access_key $DRONE_AWS_SECRET_KEY
	aws configure set default.region $DRONE_AWS_REGION

	git config --global credential.helper '!aws codecommit credential-helper $@'
	git config --global credential.UseHttpPath true
fi

if [[ -z "${DRONE_COMMIT_AUTHOR_NAME}" ]]; then
	export DRONE_COMMIT_AUTHOR_NAME=drone
fi

if [[ -z "${DRONE_COMMIT_AUTHOR_EMAIL}" ]]; then
	export DRONE_COMMIT_AUTHOR_EMAIL=drone@localhost
fi

export GIT_AUTHOR_NAME=${DRONE_COMMIT_AUTHOR_NAME}
export GIT_AUTHOR_EMAIL=${DRONE_COMMIT_AUTHOR_EMAIL}
export GIT_COMMITTER_NAME=${DRONE_COMMIT_AUTHOR_NAME}
export GIT_COMMITTER_EMAIL=${DRONE_COMMIT_AUTHOR_EMAIL}

CLONE_TYPE=$DRONE_BUILD_EVENT
case $DRONE_COMMIT_REF in
  refs/tags/* ) CLONE_TYPE=tag ;;
  refs/pull/* ) CLONE_TYPE=pull_request ;;
  refs/pull-request/* ) CLONE_TYPE=pull_request ;;
  refs/merge-requests/* ) CLONE_TYPE=pull_request ;;
esac

if [[ -n "$PLUGIN_REMOTE" ]] && [[ -n "$PLUGIN_VERSION" ]] ; then
  echo "Using remote: $PLUGIN_REMOTE"
  echo "Using version: $PLUGIN_VERSION"
  git clone --single-branch --branch "${PLUGIN_VERSION:-${DRONE_BRANCH}}" https://github.com/"${PLUGIN_REMOTE:-${DRONE_REPO_NAMESPACE}}"/"${DRONE_REPO_NAME}".git .
else
  case $CLONE_TYPE in
  pull_request)
    clone-pull-request.sh
    ;;
  tag)
    clone-tag.sh
    ;;
  *)
    clone-commit.sh
    ;;
  esac
fi
