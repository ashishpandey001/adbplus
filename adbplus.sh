#!/usr/local/bin/zsh
projectPath=""
buildType=""
packageName=""

function choose_project_path() {
  if [ -z "$1" ]
  then
    projectPath=$PWD
  else
    projectPath=$1
  fi
}

function get_package_name() {
  packageName=$projectPath/android/app/src/main/AndroidManifest.xml| grep package | cut -d'=' -f2 | sed "s/^\([\"']\)\(.*\)\1\$/\2/g"
}

function check_if_react_native_project() {
  if [! -d "$1"] then
    echo "Not a react-native project"
    exit 1
  fi
}

function uninstall_app() {
  adb devices | awk 'NR>1 && NF{printf "\"%s\"\n",$1}' | xargs -n 1 -I {} adb -s {} uninstall $1
}

function choose_build_type() {
  if [ -z "$1" ] then
    echo "Choose a build type from debug or release"
    exit 1
  else
    case $1 in
    debug)
      buildType="debug"
      ;;
    release)
      buildType="release"
      ;;
    esac
  fi
}

function install_app() {
  adb devices | awk 'NR>1 && NF{printf "\"%s\"\n",$1}' | xargs -n 1 -I {} adb -s {} install -r $projectPath/android/app/build/outputs/apk/app-$buildType.apk
}

function build_app() {
  case $buildType in
  debug)
    cd $projectPath/android && ./gradlew assembleDebug && cd ..
    ;;
  release)
    cd $projectPath/android && ./gradlew assembleRelease && cd ..
    ;;
  esac
}

case $1 in
menu)
  adb devices | awk 'NR>1 && NF{printf "\"%s\"\n",$1}' | xargs -n 1 -I {} adb -s {} shell input keyevent 82
  ;;
reverse-proxy-packager)
  adb devices | awk 'NR>1 && NF{printf "\"%s\"\n",$1}' | xargs -n 1 -I {} adb -s {} reverse tcp:8081 tcp:8081
  ;;
reverse-proxy-devtools)
  adb devices | awk 'NR>1 && NF{printf "\"%s\"\n",$1}' | xargs -n 1 -I {} adb -s {} reverse tcp:8097 tcp:8097
  ;;
  build)
    # osascript -e "tell application \"Terminal\" to do script \"cd '$3' && yarn start\""
    choose_project_path $2
    check_if_react_native_project $2
    get_package_name
    uninstall_app $packageName
    choose_build_type $3
    build_app
    ;;
install)
  # osascript -e "tell application \"Terminal\" to do script \"cd '$3' && yarn start\""
  choose_project_path $2
  check_if_react_native_project $2
  get_package_name
  uninstall_app $packageName
  choose_build_type $3
  ;;
uninstall)
  uninstall_app $packageName
  ;;
esac
