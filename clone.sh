#!/bin/sh

f [[ ! -z "${DRONE_NETRC_MACHINE}" ]]; then
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

rm -rf ./*
if [[ -n "$PLUGIN_REMOTE" ]] && [[ -n "$PLUGIN_VERSION" ]] ; then
  git clone --single-branch --branch "${VERSION:-${DRONE_BRANCH}}" https://github.com/"${REMOTE:-${DRONE_REPO_NAMESPACE}}"/"${DRONE_REPO_NAME}".git .
else
  git clone -b "$DRONE_BRANCH" "$DRONE_REMOTE_URL" .
  git checkout "$DRONE_BRANCH"
  git fetch origin "$DRONE_COMMIT_REF"
  git merge "$DRONE_COMMIT"
fi
