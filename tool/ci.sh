#!/bin/bash
# Created with package:mono_repo v4.1.0

# Support built in commands on windows out of the box.
# When it is a flutter repo (check the pubspec.yaml for "sdk: flutter")
# then "flutter" is called instead of "pub".
# This assumes that the Flutter SDK has been installed in a previous step.
function pub() {
  if grep -Fq "sdk: flutter" "${PWD}/pubspec.yaml"; then
    if [[ $TRAVIS_OS_NAME == "windows" ]]; then
      command flutter.bat pub "$@"
    else
      command flutter pub "$@"
    fi
  else
    if [[ $TRAVIS_OS_NAME == "windows" ]]; then
      command pub.bat "$@"
    else
      command dart pub "$@"
    fi
  fi
}
function dartfmt() {
  if [[ $TRAVIS_OS_NAME == "windows" ]]; then
    command dartfmt.bat "$@"
  else
    command dartfmt "$@"
  fi
}
function dartanalyzer() {
  if [[ $TRAVIS_OS_NAME == "windows" ]]; then
    command dartanalyzer.bat "$@"
  else
    command dartanalyzer "$@"
  fi
}

if [[ -z ${PKGS} ]]; then
  echo -e '\033[31mPKGS environment variable must be set! - TERMINATING JOB\033[0m'
  exit 64
fi

if [[ "$#" == "0" ]]; then
  echo -e '\033[31mAt least one task argument must be provided! - TERMINATING JOB\033[0m'
  exit 64
fi

SUCCESS_COUNT=0
declare -a FAILURES

for PKG in ${PKGS}; do
  echo -e "\033[1mPKG: ${PKG}\033[22m"
  EXIT_CODE=0
  pushd "${PKG}" >/dev/null || EXIT_CODE=$?

  if [[ ${EXIT_CODE} -ne 0 ]]; then
    echo -e "\033[31mPKG: '${PKG}' does not exist - TERMINATING JOB\033[0m"
    exit 64
  fi

  dart pub upgrade || EXIT_CODE=$?

  if [[ ${EXIT_CODE} -ne 0 ]]; then
    echo -e "\033[31mPKG: ${PKG}; 'dart pub upgrade' - FAILED  (${EXIT_CODE})\033[0m"
    FAILURES+=("${PKG}; 'dart pub upgrade'")
  else
    for TASK in "$@"; do
      EXIT_CODE=0
      echo
      echo -e "\033[1mPKG: ${PKG}; TASK: ${TASK}\033[22m"
      case ${TASK} in
      dartanalyzer_0)
        echo 'dart analyze --fatal-infos .'
        dart analyze --fatal-infos . || EXIT_CODE=$?
        ;;
      dartanalyzer_1)
        echo 'dart analyze .'
        dart analyze . || EXIT_CODE=$?
        ;;
      dartfmt)
        echo 'dart format --output=none --set-exit-if-changed .'
        dart format --output=none --set-exit-if-changed . || EXIT_CODE=$?
        ;;
      test_0)
        echo 'dart test'
        dart test || EXIT_CODE=$?
        ;;
      test_1)
        echo 'dart test --run-skipped -t presubmit-only'
        dart test --run-skipped -t presubmit-only || EXIT_CODE=$?
        ;;
      test_2)
        echo 'dart test -x presubmit-only'
        dart test -x presubmit-only || EXIT_CODE=$?
        ;;
      *)
        echo -e "\033[31mUnknown TASK '${TASK}' - TERMINATING JOB\033[0m"
        exit 64
        ;;
      esac

      if [[ ${EXIT_CODE} -ne 0 ]]; then
        echo -e "\033[31mPKG: ${PKG}; TASK: ${TASK} - FAILED (${EXIT_CODE})\033[0m"
        FAILURES+=("${PKG}; TASK: ${TASK}")
      else
        echo -e "\033[32mPKG: ${PKG}; TASK: ${TASK} - SUCCEEDED\033[0m"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
      fi

    done
  fi

  echo
  echo -e "\033[32mSUCCESS COUNT: ${SUCCESS_COUNT}\033[0m"

  if [ ${#FAILURES[@]} -ne 0 ]; then
    echo -e "\033[31mFAILURES: ${#FAILURES[@]}\033[0m"
    for i in "${FAILURES[@]}"; do
      echo -e "\033[31m  $i\033[0m"
    done
  fi

  popd >/dev/null || exit 70
  echo
done

if [ ${#FAILURES[@]} -ne 0 ]; then
  exit 1
fi
