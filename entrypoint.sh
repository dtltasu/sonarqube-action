#!/bin/bash

set -e

REPOSITORY_NAME=$(basename "${GITHUB_REPOSITORY}")

if [[ -f "${INPUT_PROJECTBASEDIR%/}/pom.xml" ]]; then
  echo "::error file=${INPUT_PROJECTBASEDIR%/}pom.xml::Maven project detected. You should run the goal 'org.sonarsource.scanner.maven:sonar' during build rather than using this GitHub Action."
  exit 1
fi

if [[ -f "${INPUT_PROJECTBASEDIR%/}/build.gradle" ]]; then
  echo "::error file=${INPUT_PROJECTBASEDIR%/}build.gradle::Gradle project detected. You should use the SonarQube plugin for Gradle during build rather than using this GitHub Action."
  exit 1
fi

unset JAVA_HOME

if [[ ! -f "${INPUT_PROJECTBASEDIR%/}/sonar-project.properties" ]]; then
  [[ -z "${INPUT_PROJECTKEY}" ]] && SONAR_PROJECTKEY="${REPOSITORY_NAME}" || SONAR_PROJECTKEY="${INPUT_PROJECTKEY}"
  [[ -z "${INPUT_PROJECTNAME}" ]] && SONAR_PROJECTNAME="${REPOSITORY_NAME}" || SONAR_PROJECTNAME="${INPUT_PROJECTNAME}"
  [[ -z "${INPUT_PROJECTVERSION}" ]] && SONAR_PROJECTVERSION="" || SONAR_PROJECTVERSION="${INPUT_PROJECTVERSION}"
  sonar-scanner \
    -D sonar.host.url="${INPUT_HOST}" \
    -D sonar.projectKey="${SONAR_PROJECTKEY}" \
    -D sonar.projectName="${SONAR_PROJECTNAME}" \
    -D sonar.projectVersion="${SONAR_PROJECTVERSION}" \
    -D sonar.projectBaseDir="${INPUT_PROJECTBASEDIR}" \
    -D sonar.token="${INPUT_TOKEN}" \
    -D sonar.sources="${INPUT_PROJECTBASEDIR}" \
    -D sonar.sourceEncoding="${INPUT_ENCODING}"
else
  sonar-scanner -X \
    -D sonar.host.url="${INPUT_HOST}" \
    -D sonar.token="${INPUT_TOKEN}"
fi
