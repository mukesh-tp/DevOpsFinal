pipeline {
    agent any
    environment {
        ACTIVE_ENV = 'blue' // Set to 'green' initially if needed
    }
    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'master', url: 'https://github.com/mukesh-tp/DevOpsFinal.git'
            }
        }
        stage('Deploy to Blue') {
            when {
                expression { env.ACTIVE_ENV == 'green' }
            }
            steps {
                script {
                    sh 'docker-compose up -d blue'
                }
            }
        }
        stage('Deploy to Green') {
            when {
                expression { env.ACTIVE_ENV == 'blue' }
            }
            steps {
                script {
                    sh 'docker-compose up -d green'
                }
            }
        }
        stage('Health Check') {
            steps {
                script {
                    def response = sh(script: "curl -s -o /dev/null -w '%{http_code}' http://localhost:8083", returnStdout: true)
                    if (response != '200') {
                        error('Health check failed.')
                    }
                }
            }
        }
        stage('Switch Traffic') {
            steps {
                script {
                    def newEnv = env.ACTIVE_ENV == 'blue' ? 'green' : 'blue'
                    env.ACTIVE_ENV = newEnv
                    echo "Traffic switched to ${newEnv} environment."
                }
            }
        }
    }
    post {
        success {
            script {
                sh 'docker-compose down'
                sh "docker-compose up -d ${env.ACTIVE_ENV}"
            }
        }
        failure {
            echo 'Deployment failed. Reverting to the previous environment.'
        }
    }
}

