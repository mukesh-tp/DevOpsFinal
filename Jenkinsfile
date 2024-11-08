pipeline {
    agent any
    environment {
        BLUE_PORT = '8081'
        GREEN_PORT = '8082'
        CURRENT_ENV = sh(script: "curl -s http://localhost:80 | grep -o 'Blue\\|Green'", returnStdout: true).trim()
    }
    stages {
        stage('Determine Target Environment') {
            steps {
                script {
                    // Define NEW_ENV and NEW_PORT inside a script block
                    def newEnv = CURRENT_ENV == 'Blue' ? 'green-app' : 'blue-app'
                    def newPort = CURRENT_ENV == 'Blue' ? GREEN_PORT : BLUE_PORT
                    env.NEW_ENV = newEnv
                    env.NEW_PORT = newPort
                }
            }
        }
        stage('Pull Latest Code') {
            steps {
                git 'https://github.com/mukesh-tp/DevOpsFinal.git'
            }
        }
        stage('Deploy to New Environment') {
            steps {
                sh "docker-compose up -d ${NEW_ENV}"
            }
        }
        stage('Health Check') {
            steps {
                script {
                    def statusCode = sh(script: "curl -s -o /dev/null -w '%{http_code}' http://localhost:${env.NEW_PORT}", returnStdout: true).trim()
                    if (statusCode != "200") {
                        error("Health check failed, deployment aborted!")
                    }
                }
            }
        }
        stage('Switch Traffic') {
            steps {
                sh '''
                    if [[ "${NEW_ENV}" == "green-app" ]]; then
                        sed -i 's/8081/8082/g' /etc/nginx/nginx.conf
                    else
                        sed -i 's/8082/8081/g' /etc/nginx/nginx.conf
                    fi
                    sudo systemctl reload nginx
                '''
            }
        }
        stage('Clean Old Environment') {
            steps {
                sh "docker-compose down ${CURRENT_ENV.toLowerCase()}-app"
            }
        }
    }
}
