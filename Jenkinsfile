// https://jenkins.io/doc/book/pipeline/syntax/
@Library('alauda-cicd') _


def GIT_BRANCH
def GIT_COMMIT
def deployment
def IMAGE
def CURRENT_VERSION
def RELEASE_VERSION
def RELEASE_BUILD
def code_data
def DEBUG = false
def CHART
def VALUES
def FOLDER
def BOTNAME = "devops-chat-bot"
def VERSION
def IMAGE_TAG
def COMPONENT
def ENV
def VALUES_KEY = ""
def VALUES_KEY_ADDITIONAL = ""
def STABLE
// All chart folders
// ATTENTION: Adding a new chart should change this variable
def ALL_CHARTS = [
    "jenkins", 
    "gitlab-ce", 
    "harbor"
]
def GIT_TAG
pipeline {
    agent {
        label 'gonew'
    }

    options {
        // 保留多少流水线记录（建议不放在jenkinsfile里面）
        buildDiscarder(logRotator(numToKeepStr: '10'))

        // 不允许并行执行
        disableConcurrentBuilds()

    }
    
    parameters {
        string(name: 'CHART', defaultValue: '', description: 'The chart that is been worked on.')
        string(name: 'VERSION', defaultValue: '', description: 'New version of the chart.')
        string(name: 'COMPONENT', defaultValue: '', description: 'The component of the chart worked on. Will be used to update the values.yaml file.')
        string(name: 'IMAGE_TAG', defaultValue: '', description: 'The tag used for the new version of the component.')
        string(name: 'ENV', defaultValue: '', description: 'Environment used to publish the chart.')
        booleanParam(name: 'DEBUG', defaultValue: false, description: 'Debugging a pipeline will not cause real changes in the repo or in the chart repository.')
        booleanParam(name: 'STABLE', defaultValue: false, description: 'Is a stable version publishing.')
        string(name: 'GIT_TAG', defaultValue: '', description: 'The tag of the chart.')
    }
    environment {
        TAG_CREDENTIALS = "alaudabot-bitbucket"
        OWNER = "mathildetech"
        REPOSITORY = "devops-charts"
        PROD_CHART_CREDENTIALS_ADDRESS = "chart-repository-address"
        PROD_CHART_CREDENTIALS_USERNAME = "chart-repository"
        INCUBATOR_CHART_CREDENTIALS_ADDRESS = "chart-incubator-address"
        
    }
    // stages
    stages {
        stage('Checkout') {
            steps {
                script {
                    DEBUG = params.DEBUG
                    FOLDER = params.CHART
                    CHART = params.CHART
                    VERSION = params.VERSION
                    IMAGE_TAG = params.IMAGE_TAG
                    COMPONENT = params.COMPONENT
                    GIT_TAG = params.GIT_TAG
                    ENV = params.ENV
                    STABLE = params.STABLE
                    BOTNAME = "devops-chat-bot"
                    // checkout code
                    def scmVars
                    container('tools') { 
                        scmVars = checkout scm
                        if (GIT_TAG != "") {
                            sh "git branch"
                        }
                        
                        // extract git information
                        env.GIT_COMMIT = scmVars.GIT_COMMIT
                        env.GIT_BRANCH = scmVars.GIT_BRANCH
                        echo "current branch: ${env.GIT_BRANCH}"
                        if (STABLE && GIT_TAG != "") {
                            echo "checking out ${GIT_TAG}"
                            sh "git checkout ${GIT_TAG}"
                        } else {
                            echo "checking out master"
                            sh "git checkout master"
                        }
                    }
                    GIT_COMMIT = "${scmVars.GIT_COMMIT}"
                    GIT_BRANCH = "${scmVars.GIT_BRANCH}"
                    echo "Parameters: chart: ${CHART}  version: ${VERSION}  component: ${COMPONENT}  tag: ${IMAGE_TAG}"
                    RELEASE_VERSION = "${CHART}-${VERSION}"
                }
            }
        }

        stage('Updating chart'){
            when {
                expression {
                    !STABLE
                }
            }
            steps {
                script {
                    container('tools') {
                        if ("${IMAGE_TAG}" == "") {
                            error("Image tag was not provided...")
                        }
                        echo "Folder: ${FOLDER}"
                        VALUES = "${FOLDER}/values.yaml"
                        switch ("${CHART}") {
                            case "jenkins":
                                // update component tag
                                switch ("${COMPONENT}".toLowerCase()) {
                                    // Jenkins 3 images
                                    case "jenkins":
                                    def (master, slave, plugins) = IMAGE_TAG.tokenize(',')
                                    sh "yq w -i ${VALUES} global.images.jenkins.tag ${master}"
                                    sh "yq w -i ${VALUES} global.images.slave.tag ${slave}"
                                    sh "yq w -i ${VALUES} global.images.plugins.tag ${plugins}"

                                    // updating charts appVersion
                                    def (master_version, release_version) = master.tokenize('-')
                                    sh "yq w -i ${CHART}/Chart.yaml appVersion ${master_version}"
                                    break
                                    case "tools":
                                    def (ubuntu, alpine) = IMAGE_TAG.tokenize(',')
                                    sh "yq w -i ${VALUES} global.images.toolsUbuntu.tag ${ubuntu}"
                                    sh "yq w -i ${VALUES} global.images.toolsAlpine.tag ${alpine}"
                                    break
                                    case "golang":
                                    def (ubuntu10, ubuntu11, alpine10, alpine11) = IMAGE_TAG.tokenize(',')
                                    sh "yq w -i ${VALUES} global.images.golang10ubuntu.tag ${ubuntu10}"
                                    sh "yq w -i ${VALUES} global.images.golang11ubuntu.tag ${ubuntu11}"
                                    sh "yq w -i ${VALUES} global.images.golang10Alpine.tag ${alpine10}"
                                    sh "yq w -i ${VALUES} global.images.golang11Alpine.tag ${alpine11}"
                                    break
                                    case "java":
                                    def (java, alpine) = IMAGE_TAG.tokenize(',')
                                    sh "yq w -i ${VALUES} global.images.javaOpenjdk8.tag ${java}"
                                    sh "yq w -i ${VALUES} global.images.javaOpenjdk8Alpine.tag ${alpine}"
                                    break
                                    case "nodejs":
                                    def (node10Debian, node10Alpine) = IMAGE_TAG.tokenize(',')
                                    sh "yq w -i ${VALUES} global.images.nodejs10Debian.tag ${node10Debian}"
                                    sh "yq w -i ${VALUES} global.images.nodejs10Alpine.tag ${node10Alpine}"
                                    break
                                    case "python":
                                    def (ubuntu27, ubuntu36, ubuntu37, alpine27, alpine36, alpine37) = IMAGE_TAG.tokenize(',')
                                    sh "yq w -i ${VALUES} global.images.python27Ubuntu.tag ${ubuntu27}"
                                    sh "yq w -i ${VALUES} global.images.python36Ubuntu.tag ${ubuntu36}"
                                    sh "yq w -i ${VALUES} global.images.python37Ubuntu.tag ${ubuntu37}"
                                    sh "yq w -i ${VALUES} global.images.python27Alpine.tag ${alpine27}"
                                    sh "yq w -i ${VALUES} global.images.python36Alpine.tag ${alpine36}"
                                    sh "yq w -i ${VALUES} global.images.python37Alpine.tag ${alpine37}"
                                    break
                                    default:
                                        // error("Component ${COMPONENT} does not exist or is not supported...")
                                        echo "not updating anything in values.yaml"
                                }
                            break
                            case "gitlab-ce":
                                echo "Will not change gitlab chart"
                            case "harbor":
                                echo "Will not change harbor chart"
                            default:
                                error("Chart ${CHART} is not supported or doesn't exist....")
                        }
                        sh "yq r ${FOLDER}/Chart.yaml version > curversion"
                        CURRENT_VERSION = readFile('curversion').trim()
                        echo "Current chart version is: ${CURRENT_VERSION}"
                        sh "gitversion chart ${CURRENT_VERSION} ${VERSION} > nextversion"
                        VERSION =  readFile('nextversion').trim()
                        echo "New chart version is: ${VERSION}"
                        RELEASE_VERSION = "${CHART}-${VERSION}"
                        // updating chart version
                        sh "yq w -i ${FOLDER}/Chart.yaml version ${VERSION}"
                        if (DEBUG) {
                            sh "cat ${FOLDER}/Chart.yaml"
                        }
                    }
                }
            }
        }
        stage('Bundle Stable') {
            when {
                expression {
                    STABLE
                }
            }
            steps {
                script {
                    container('tools') {
                        CHART = "stable"
                        RELEASE_VERSION = GIT_TAG
                        echo "Will bundle stable"
                        for (def i in ALL_CHARTS) {
                            sh "helm package ${i} --save=false"
                            sh "yq r ${i}/Chart.yaml version > ${i}.version"
                        }
                        if (!DEBUG) {
                            echo "Will start upload of chart...."
                            if (ENV == "test") {
                                for (def i in ALL_CHARTS) {
                                    def chartVersion = readFile("${i}.version").trim()
                                    def version = "${i}-${chartVersion}"
                                    sh "curl -v --fail -F 'chart=@${version}.tgz' http://chartmuseum.alaudak8s.haproxy-150-109-47-155-alaudak8s.myalauda.cn/stable/api/charts"
                                }
                            } else {
                                withCredentials([usernamePassword(credentialsId: PROD_CHART_CREDENTIALS_ADDRESS, passwordVariable: 'REPO_PROTOCOL', usernameVariable: 'REPO_ADDRESS')]) {
                                    withCredentials([usernamePassword(credentialsId: PROD_CHART_CREDENTIALS_USERNAME, passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                                        for (def i in ALL_CHARTS) {
                                            def chartVersion = readFile("${i}.version").trim()
                                            def version = "${i}-${chartVersion}"
                                            sh "curl -v --fail -F 'chart=@${version}.tgz' -u '${USERNAME}:${PASSWORD}' ${REPO_ADDRESS}/api/charts"
                                        }
                                    }
                                }
                                withCredentials([usernamePassword(credentialsId: TAG_CREDENTIALS, passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                                    sh """
                                        git config --global user.email "alaudabot@alauda.io"
                                        git config --global user.name "Alauda Bot"
                                    """
                                    def repo = "https://${GIT_USERNAME}:${GIT_PASSWORD}@bitbucket.org/${OWNER}/${REPOSITORY}.git"
                                    sh "git tag -a stable-${GIT_TAG} -m 'auto add release tag by jenkins'"
                                    sh "git push ${repo} --tags"
                                }
                            }
                            
                        } else {
                            sh "ls -la"
                        }
                    }
                }
            }
        }
        // after build it should start deploying
        stage('Upload') {
            when {
                expression {
                    !STABLE
                }
            }
            steps {
                script {
                    container('tools') {
                        sh "helm package ${FOLDER} --save=false"
                        echo "file ${RELEASE_VERSION}.tgz generated..."
                        if (!DEBUG) {
                            echo "Will start upload of chart...."
                            if (ENV == "test") {
                                sh "curl -v --fail -F 'chart=@${RELEASE_VERSION}.tgz'  http://chartmuseum.alaudak8s.haproxy-150-109-47-155-alaudak8s.myalauda.cn/incubator/api/charts"
                            } else {
                                withCredentials([usernamePassword(credentialsId: INCUBATOR_CHART_CREDENTIALS_ADDRESS, passwordVariable: 'REPO_PROTOCOL', usernameVariable: 'REPO_ADDRESS')]) {
                                    withCredentials([usernamePassword(credentialsId: PROD_CHART_CREDENTIALS_USERNAME, passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                                        sh "curl -v --fail -F 'chart=@${RELEASE_VERSION}.tgz' -u '${USERNAME}:${PASSWORD}' ${REPO_ADDRESS}/api/charts"
                                    }
                                }
                            }
                            
                            withCredentials([usernamePassword(credentialsId: TAG_CREDENTIALS, passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                                sh "git tag -l | xargs git tag -d" // clean local tags
                                sh """
                                    git config --global user.email "alaudabot@alauda.io"
                                    git config --global user.name "Alauda Bot"
                                """
                                sh "git add ${FOLDER} && git commit -am 'Auto-commit by jenkins on ${RELEASE_VERSION}'"
                                def repo = "https://${GIT_USERNAME}:${GIT_PASSWORD}@bitbucket.org/${OWNER}/${REPOSITORY}.git"
                                sh "git fetch --tags ${repo}" // retrieve all tags
                                sh("git tag -a ${RELEASE_VERSION} -m 'auto add release tag by jenkins'")
                                sh "git push ${repo}"
                                sh("git push ${repo} --tags")
                            }
                        }
                    }
                }
            }
        }
    }

    // (optional)
    // happens at the end of the pipeline
    post {
        // 成功
        success {
            script {
                echo "success"
                if (!DEBUG) {
                    deploy.notificationSuccess("Chart ${CHART}", BOTNAME, "发布成功了", "${RELEASE_VERSION}")
                }

            }
        }
        // 失败
        failure {
            script {
                echo "failed"
                if (!DEBUG) {
                    deploy.notificationFailed("Chart ${CHART}", BOTNAME, "发布失败了", "${RELEASE_VERSION}")
                }
            }
        }
    }
}
