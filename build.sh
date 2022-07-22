#!/usr/bin/env bash
scriptName="$(basename "$([[ -L "$0" ]] && readlink "$0" || echo "$0")")"
if [[ -z $scriptName ]]; then
  echo "Error, script name is empty. Exit" >&2
  exit 1
fi
#script directory
_source="${BASH_SOURCE[0]}"
while [[ -h "$_source" ]]; do
  _dir="$( cd -P "$( dirname "$_source" )" && pwd )"
  _source="$(readlink "$_source")"
  [[ $_source != /* ]] && _source="$_dir/$_source"
done
scriptDir="$( cd -P "$( dirname "$_source" )" && pwd )"
if [[ ! -d $scriptDir ]]; then
  echo "$scriptName error: incorrect script source directory $scriptDir, exit" >&2
  exit 1
fi
#Start script

if [[ $1 == "test" ]]; then
  dub -b unittest
  if [[ $? -ne 0 ]]; then
    echo "Test mode error, exit." >&2
    exit 1
  fi
  exit 0
fi

dub --quiet run --compiler=ldc2 --config=app-dev
errDub=$?
if [[ $errDub -ne 0 ]]; then
  echo "Dub error, exit." >&2
  exit 1
fi