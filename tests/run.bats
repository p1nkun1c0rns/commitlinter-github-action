#!/usr/bin/env bats

# global variables ############################################################
CONTAINER_NAME="commitlinter-github-action"

# build container to test the behavior ########################################
@test "build container" {
  docker rmi $CONTAINER_NAME -f >> /dev/null
  docker build -t $CONTAINER_NAME . >&2
}

# functions ###################################################################

function setup() {

  # set global git name and email if running in ci
  # https://help.github.com/en/actions/configuring-and-managing-workflows/using-environment-variables#default-environment-variables
  if [ "$CI" = true ] ; then
    git config --global user.email "ci@github.com"
    git config --global user.name "GitHub Action"
  fi

  unset INPUT_WORKINGDIR
  unset INPUT_BASEBRANCH
  unset INPUT_AUTHOR_NAME_REGEX
  unset INPUT_AUTHOR_NAME_MESSAGE
  unset INPUT_AUTHOR_EMAIL_REGEX
  unset INPUT_AUTHOR_EMAIL_MESSAGE
  unset INPUT_COMMITTER_NAME_REGEX
  unset INPUT_COMMITTER_NAME_MESSAGE
  unset INPUT_COMMITTER_EMAIL_REGEX
  unset INPUT_COMMITTER_EMAIL_MESSAGE
  unset INPUT_COMMIT_MESSAGE_REGEX
  unset INPUT_COMMIT_MESSAGE_MESSAGE
  unset ret_val
}

function create_mock_repo() {
    fixturefile=$1

    # check if file exist
    [ ! -f $fixturefile ] && echo "ERROR: $fixturefile does not exist"

    # create temp folder
    TEMP_BASE="$(pwd)/.temp/"
    UUID=$(uuidgen)
    mkdir -p "${TEMP_BASE}/${UUID}"
    repoPath="${TEMP_BASE}/${UUID}/"

    # init repo
    git -C $repoPath init
    touch $repoPath/README.txt
    git -C $repoPath add .
    git -C $repoPath commit -am "init"
    git -C $repoPath checkout -b test_branch

    # for each line in the file, skip #
    # https://unix.stackexchange.com/questions/24260/reading-lines-from-a-file-with-bash-for-vs-while
IFS='
'

    for commit in $(cat ${fixturefile}) ; do
        git -C $repoPath commit --allow-empty -am "${commit}"
    done;

    # return the repo with the commits
    ret_val=$repoPath
}

function debug() {
  status="$1"
  output="$2"
  if [[ ! "${status}" -eq "0" ]]; then
  echo "status: ${status}"
  echo "output: ${output}"
  fi
}

###############################################################################
## test cases #################################################################
###############################################################################

### INPUT_COMMIT_MESSAGE_REGEX
@test "INPUT_COMMIT_MESSAGE_REGEX: OK .*" {

  # export is needed, i dont know why but git need it
  export GIT_COMMITER_NAME="Blondie"
  export GIT_COMMITER_EMAIL="blondie@new-mexico.gov"
  export GIT_AUTHOR_NAME="Blondie"
  export GIT_AUTHOR_EMAIL="blondie@new-mexico.gov"

  create_mock_repo tests/fixtures/the-good.txt

  run docker run --rm \
  -v "$ret_val:/mnt/" \
  -e INPUT_WORKINGDIR="/mnt/" \
  -e INPUT_BASEBRANCH="master" \
  -e INPUT_COMMIT_MESSAGE_REGEX=".*" \
  -i $CONTAINER_NAME

  debug "${status}" "${output}" "${lines}"

  [[ "${status}" -eq 0 ]]

}

# @test "INPUT_COMMIT_MESSAGE_REGEX: OK ^\[(NoRef-0|S5|([A-Z]{2,10})-\d{1,7})\] [A-Z].*[^\. ]$" {
#
#   # export is needed, i dont know why but git need it
#   export GIT_COMMITER_NAME="Blondie"
#   export GIT_COMMITER_EMAIL="blondie@new-mexico.gov"
#   export GIT_AUTHOR_NAME="Blondie"
#   export GIT_AUTHOR_EMAIL="blondie@new-mexico.gov"
#
#   create_mock_repo tests/fixtures/jira.txt
#
#   run docker run --rm \
#   -v "$ret_val:/mnt/" \
#   -e INPUT_WORKINGDIR="/mnt/" \
#   -e INPUT_BASEBRANCH="master" \
#   -e INPUT_COMMIT_MESSAGE_REGEX="^\[(NoRef-0|S5|([A-Z]{2,10})-\d{1,7})\] [A-Z].*[^\. ]$" \
#   -i $CONTAINER_NAME
#
#   debug "${status}" "${output}" "${lines}"
#
#   [[ "${status}" -eq 0 ]]
#
# }

@test "INPUT_COMMIT_MESSAGE_REGEX: FAIL ^\[(NoRef-0|S5|([A-Z]{2,10})-\d{1,7})\] [A-Z].*[^\. ]$" {

  # export is needed, i dont know why but git need it
  export GIT_COMMITER_NAME="Blondie"
  export GIT_COMMITER_EMAIL="blondie@new-mexico.gov"
  export GIT_AUTHOR_NAME="Blondie"
  export GIT_AUTHOR_EMAIL="blondie@new-mexico.gov"

  create_mock_repo tests/fixtures/the-good.txt

  run docker run --rm \
  -v "$ret_val:/mnt/" \
  -e INPUT_WORKINGDIR="/mnt/" \
  -e INPUT_BASEBRANCH="master" \
  -e INPUT_COMMIT_MESSAGE_REGEX="^\[(NoRef-0|S5|([A-Z]{2,10})-\d{1,7})\] [A-Z].*[^\. ]$" \
  -i $CONTAINER_NAME

  debug "${status}" "${output}" "${lines}"

  [[ "${status}" -eq 1 ]]

}
