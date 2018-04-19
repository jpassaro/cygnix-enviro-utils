if [ -f branch.sh ] ; then source branch.sh ; done #sets BRANCH

if [[ -z "$BRANCH" ]] ; then
  echo >&2 error: environment variable BRANCH must be set or specified in branch.txt
  exit 1
fi

case "$1" in
  gs|ps|common) 
    CODEBASE_ARG="$1"
    export CODEBASE="ecn-$1"
    CODEBASE_FNAME=${CODEBASE}.${BRANCH/./_}
    shift
    export MSGFILELCL="commit-msg_${CODEBASE_FNAME}.txt"
    export DIFFFILELCL="diff_${CODEBASE_FNAME}.diff"
    export MERGEFILELCL="mergelogs_${CODEBASE_FNAME}..txt"
    export MSGFILE=../$MSGFILELCL
    export DIFFFILE=../$DIFFFILELCL
    export MERGEFILE=../$MERGEFILELCL
    export REVLIST="../listrevs_${CODEBASE_FNAME}.txt"
    export REVLOG="../log_${CODEBASE_FNAME}.txt"
    ;;
  *) 
    if [[ -z "$NO_APP_NECESSARY" ]] ; then
       echo "must specify common or gs or ps!" >&2 ; exit 1
    else
       NO_APP=no_app
    fi
    ;;
esac

case "$BRANCH" in
  trunk) export BRANCHURL=^/trunk ;;
  *) export BRANCHURL="^/branches/$BRANCH" ;;
esac

function mergeinfo() {
  _svn mergeinfo --show-revs eligible $BRANCHURL . | tr -d r\\r
}

function seelog() {
  sed "s%^.%-r&%" $REVLIST | xargs -tr _svn log "$@" $BRANCHURL 
}

function checkmsg(){
  if [[ -e $MSGFILE ]] ; then
    echo "$MSGFILE already exists; please run ./revert.sh or ./check-in.sh"
    return 1
  fi
}

function createcommit(){
  cat >$MSGFILE
  echo logged the following message to $MSGFILE:
  echo
  cat $MSGFILE
}

THEDATE="`date +%F_%T`"

function archive_it() {
  [[ -z "$NO_APP" ]] && D=.. || D=.
  for i in "$@" ; do 
    [[ -f "$D/$i" ]] && mv -v "$D/$i" "$D/archive/$i.$THEDATE" || true
  done
}

function archive(){
  echo archiving files with date-string $THEDATE
  [[ -n "$*" ]] && archive_it "$@" \
         || archive_it $MSGFILELCL $DIFFFILELCL $MERGEFILELCL
}

function wait(){
  echo >&2 Hit Enter to proceed or Ctrl-C to abort
  read </dev/tty
}

function create_merge_log(){
 arg="$1" ; shift ; ## should be search or revision
 (
   for x in "$@" ; do
       echo --$arg
       [[ "$arg" == search ]] && echo "$x" || echo "${x#-}" 
   done
   [[ "$arg" == revision ]] || sed s/^/-r/ $REVLIST
 ) | tr \\n \\0 | xargs -tr0 _svn log -v $BRANCHURL | pipe2n++.sh $MERGEFILE
}

function record_only_merge(){
  sed -rn 's/^r([0-9]+) \| [a-z]*.*/-c\1/p' $MERGEFILE \
    | while read REVARG ; do _svn merge --record-only $REVARG $BRANCHURL ; done
}

function create_merge_commit(){
  [[ "$#" == 0 ]] && MESSAGE=hand || MESSAGE="$*"
  sed -nr 's/^(r[0-9]+) \| [a-z]*.*/\1/p' $MERGEFILE \
    | ( xargs echo record-only merge from $BRANCH: ;
        echo identified by "$MESSAGE" ) \
    | createcommit
}

if [[ -n "$CODEBASE" ]] ; then cd $CODEBASE || exit 1 ; fi
